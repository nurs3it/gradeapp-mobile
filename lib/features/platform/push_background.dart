import 'dart:async';
import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/api/api_client.dart';
import '../../core/api/session_store.dart';
import '../../core/storage/json_cache.dart';
import '../../l10n/gen/app_localizations.dart';
import '../notifications/push.dart';
import 'local_notifications.dart';
import 'platform_sync.dart';
import 'push_intent.dart';

/// Runs in a background isolate when a data-only push arrives while the app
/// is not in the foreground:
///  * Android `attendance.flagged` / `excuse.pending` — the app draws the
///    notification itself, with buttons (the server sends no `notification`);
///  * `sync.today` / `sync.schedule` — refresh the cache and the widgets.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage m) async {
  DartPluginRegistrant.ensureInitialized();
  final options = FirebaseEnv.options;
  if (options == null) return;
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: options);
  } catch (e) {
    debugPrint('background firebase init: $e');
  }
  final l = await resolveL10n();
  final intent = intentFor(m.data);
  if (intent is SyncIntent) {
    await runBackgroundSync(l);
    return;
  }
  final type = '${m.data['type']}';
  if (Platform.isAndroid && renderedTypes.contains(type) && m.data['title'] != null) {
    await LocalNotifications.init(l, background: true, onBackgroundResponse: notificationActionInBackground);
    await LocalNotifications.showPush(m.data, l);
  }
}

/// Silent sync without the UI: same refresh the app does on resume.
Future<void> runBackgroundSync(AppLocalizations l) async {
  final sessions = SessionStore();
  if (await sessions.load() == null) return;
  final api = ApiClient(sessions, onSessionLost: () {});
  final sync = PlatformSync(api.dio, await JsonCache.open(), await JsonCache.open('prefs'));
  await LocalNotifications.init(l, background: true, onBackgroundResponse: notificationActionInBackground);
  await sync.refresh(l: l, langCode: l.localeName);
}

/// Android: a button without `showsUserInterface` («Одобрить») lands here,
/// possibly with the app not running. Approves, then replaces the
/// notification with the result.
@pragma('vm:entry-point')
Future<void> notificationActionInBackground(NotificationResponse r) async {
  DartPluginRegistrant.ensureInitialized();
  final intent = intentFor(LocalNotifications.decode(r.payload), actionId: r.actionId);
  debugPrint('notification action ${r.actionId} -> ${intent.runtimeType}');
  if (intent is! ApproveIntent) return;
  final l = await resolveL10n();
  final sessions = SessionStore();
  var ok = false;
  if (await sessions.load() != null) {
    try {
      await ApiClient(sessions, onSessionLost: () {}).dio.post<void>('/excuses/${intent.excuseId}/approve/');
      ok = true;
    } catch (e) {
      debugPrint('background approve: $e');
    }
  }
  await LocalNotifications.init(l, background: true);
  final id = LocalNotifications.notificationIdOf(LocalNotifications.decode(r.payload));
  await LocalNotifications.plugin.show(
    id: id,
    title: ok ? l.excuseApprovedToast : l.excuseApproveFailed,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        'attendance',
        'attendance',
        icon: 'ic_notification',
        visibility: NotificationVisibility.private,
        timeoutAfter: ok ? 4000 : null,
        // Failure keeps the buttons reachable: open the app to retry.
      ),
    ),
    payload: r.payload,
  );
}
