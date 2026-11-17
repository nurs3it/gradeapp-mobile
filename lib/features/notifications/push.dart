import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics.dart';
import '../../core/json.dart';
import '../../core/providers.dart';
import '../../core/storage/json_cache.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../common/models.dart';
import '../common/pulse.dart';
import '../learner/learner_providers.dart';
import '../parent/excuse_sheet.dart';
import '../platform/lesson_link.dart';
import '../platform/push_background.dart';
import '../platform/push_intent.dart';
import 'notifications.dart';

/// Firebase options come from the build, not from plist/json files:
/// `flutter run --dart-define-from-file=firebase.json` (see
/// `firebase.example.json`). Without them pushes are simply off.
abstract final class FirebaseEnv {
  static const _project = String.fromEnvironment('FB_PROJECT_ID');
  static const _sender = String.fromEnvironment('FB_SENDER_ID');
  static const _iosKey = String.fromEnvironment('FB_IOS_API_KEY');
  static const _iosApp = String.fromEnvironment('FB_IOS_APP_ID');
  static const _androidKey = String.fromEnvironment('FB_ANDROID_API_KEY');
  static const _androidApp = String.fromEnvironment('FB_ANDROID_APP_ID');

  static FirebaseOptions? get options {
    if (_project.isEmpty || kIsWeb) return null;
    final ios = Platform.isIOS;
    final key = ios ? _iosKey : _androidKey;
    final app = ios ? _iosApp : _androidApp;
    if (key.isEmpty || app.isEmpty) return null;
    return FirebaseOptions(
      apiKey: key,
      appId: app,
      messagingSenderId: _sender,
      projectId: _project,
      iosBundleId: ios ? 'kz.gradeapp.gradeapp' : null,
    );
  }
}

/// Badge, system settings and Android channels (native side: AppDelegate.swift,
/// MainActivity.kt).
abstract final class SystemBridge {
  static const _ch = MethodChannel('kz.gradeapp/system');

  static Future<void> setBadge(int n) => _call('setBadge', n);
  static Future<void> openNotificationSettings() => _call('openSettings');

  /// Android channels = preference groups, so the phone's own settings
  /// mirror the app's (C5). Names follow the app language.
  static Future<void> createChannels(AppLocalizations l) =>
      _call('createChannels', {for (final g in PushGroup.values) g.name: g.label(l)});

  static Future<void> _call(String method, [Object? args]) async {
    try {
      await _ch.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Tests and platforms without the bridge.
    } on PlatformException catch (e) {
      debugPrint('system bridge $method: $e');
    }
  }
}

/// `notification_prefs` groups (backend users/notification_prefs.py) + the
/// channel for types outside every group.
enum PushGroup {
  grades,
  homework,
  schedule,
  attendance,
  chat,
  billing,
  general;

  String label(AppLocalizations l) => switch (this) {
    grades => l.ngGrades,
    homework => l.ngHomework,
    schedule => l.ngSchedule,
    attendance => l.ngAttendance,
    chat => l.ngChat,
    billing => l.ngBilling,
    general => l.ngGeneral,
  };
}

/// FCM token lifecycle (C5): registered after sign-in once the user allowed
/// notifications, refreshed by FCM, removed on sign-out.
///
/// ponytail: classic registration tokens (`getToken`), deprecated in
/// firebase_messaging 17 in favour of FID direct-send (`register` /
/// `onRegistered`). The backend sends to `message.token`; move both sides
/// together once FID sending is settled.
// ignore_for_file: deprecated_member_use
class Push {
  Push(this._ref);
  final Ref _ref;

  static bool enabled = false;
  StreamSubscription<String>? _refresh;
  String? _token;

  /// Called in main() before the first frame.
  static Future<void> init() async {
    final options = FirebaseEnv.options;
    if (options == null) return;
    try {
      await Firebase.initializeApp(options: options);
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
      enabled = true;
    } catch (e) {
      debugPrint('firebase init failed: $e');
    }
  }

  FirebaseMessaging get _m => FirebaseMessaging.instance;

  static bool _granted(AuthorizationStatus s) =>
      s == AuthorizationStatus.authorized || s == AuthorizationStatus.provisional;

  Future<AuthorizationStatus> status() async =>
      enabled ? (await _m.getNotificationSettings()).authorizationStatus : AuthorizationStatus.notDetermined;

  /// System prompt; registers the token when allowed.
  Future<bool> request() async {
    if (!enabled) return false;
    final s = await _m.requestPermission();
    final ok = _granted(s.authorizationStatus);
    if (ok) await register();
    return ok;
  }

  /// Sends the token when notifications are allowed; silent otherwise.
  Future<void> register() async {
    if (!enabled) return;
    try {
      if (!_granted(await status())) return;
      // iOS hands FCM a token only after APNs registered the device, which
      // lags the permission grant by a moment.
      if (Platform.isIOS && !await _apnsReady()) {
        debugPrint('push: no APNs token yet');
        return;
      }
      final token = await _m.getToken();
      if (token != null) await _send(token);
      _refresh ??= _m.onTokenRefresh.listen(_send);
    } catch (e) {
      debugPrint('push register: $e');
    }
  }

  Future<bool> _apnsReady() async {
    for (var i = 0; i < 10; i++) {
      if (await _m.getAPNSToken() != null) return true;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> _send(String token) async {
    _token = token;
    try {
      await _ref
          .read(dioProvider)
          .post<void>('/push/devices/', data: {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'});
    } catch (_) {
      // Retried on the next start or token refresh.
    }
  }

  /// Before the session goes: the server forgets the device, and FCM
  /// invalidates the token in case the request does not get through.
  Future<void> unregister({bool withServer = true}) async {
    if (!enabled) return;
    try {
      final token = _token ?? await _m.getToken();
      if (withServer && token != null) {
        await _ref.read(dioProvider).delete<void>('/push/devices/', data: {'token': token});
      }
    } catch (_) {}
    try {
      await _m.deleteToken();
    } catch (_) {}
    _token = null;
    unawaited(SystemBridge.setBadge(0));
  }
}

final pushProvider = Provider<Push>(Push.new);

/// What a push carries in `data` (backend users/fcm.py), as a notification
/// the inbox already knows how to open.
AppNotification notificationFromPush(Map<String, dynamic> data) {
  final kind = data['target_kind'] as String?;
  final id = data['target_id'] as String?;
  final studentId = data['student_id'] as String?;
  return AppNotification(
    id: (data['notification_id'] as String?) ?? '',
    type: (data['type'] as String?) ?? '',
    payload: {'student_id': ?studentId},
    read: false,
    createdAt: DateTime.now(),
    target: kind == null || id == null ? null : NotificationTarget(kind: kind, id: id, available: true),
  );
}

/// Opens what a tapped push points at, or does what its button asked: picks
/// the child for a parent, then routes like the inbox does (§4.3).
/// [actionId] is the tapped button (`EXPLAIN`, `APPROVE`, `OPEN`), null for a
/// plain tap.
Future<void> openPush(BuildContext context, WidgetRef ref, Map<String, dynamic> data, {String? actionId}) async {
  await ref.read(authProvider.future);
  final role = ref.read(activeRoleProvider);
  if (role == null || !context.mounted) return;
  final intent = intentFor(data, actionId: isDefaultAction(actionId) ? null : actionId);
  if (intent is SyncIntent) return;
  final n = notificationFromPush(data);
  ref.read(analyticsProvider).track(AnalyticsEvents.pushOpen, {'type': n.type});
  final studentId = n.payload.strOrNull('student_id');
  if (role == AppRole.parent && studentId != null) await _selectChild(ref, studentId);
  if (!context.mounted) return;
  switch (intent) {
    case ApproveIntent(:final excuseId):
      await _approveExcuse(context, ref, excuseId, n);
    case ExplainIntent():
      await _explainAbsence(context, ref, intent);
    case AllPresentIntent(:final lessonId):
      final router = GoRouter.of(context);
      final here = router.routerDelegate.currentConfiguration.uri;
      final path = lessonPath(lessonId, allPresent: true);
      // Already on this lesson: the screen takes the request in place.
      if (parseLessonLink(here)?.lessonId == lessonId) {
        unawaited(router.replace<void>(path));
      } else {
        unawaited(router.push<void>(path));
      }
    case _:
      await openNotification(context, ref, n);
  }
}

/// A push can arrive before the children list is loaded.
Future<void> _selectChild(WidgetRef ref, String studentId) async {
  try {
    final children = await ref.read(childrenProvider.future);
    if (children.any((c) => c.id == studentId)) ref.read(selectedChildProvider.notifier).select(studentId);
  } catch (_) {
    // Offline and never loaded: Today opens on the remembered child.
  }
}

/// «Одобрить» from the notification: no extra screen, one confirmation.
Future<void> _approveExcuse(BuildContext context, WidgetRef ref, String excuseId, AppNotification n) async {
  final l = context.l10n;
  try {
    await ref.read(dioProvider).post<void>('/excuses/$excuseId/approve/');
    GHaptics.success();
    unawaited(markRead(ref, n));
    ref.invalidate(notificationsProvider);
    unawaited(ref.read(pulseProvider.notifier).refresh());
    if (context.mounted) GToast.show(context, l.excuseApprovedToast, icon: GIcons.ok);
  } catch (_) {
    GHaptics.error();
    if (context.mounted) GToast.show(context, l.excuseApproveFailed, icon: GIcons.error);
  }
}

/// «Объяснить пропуск»: the excuse form for that miss — its lesson when the
/// server tells which, else its day.
Future<void> _explainAbsence(BuildContext context, WidgetRef ref, ExplainIntent e) async {
  final studentId = e.studentId ?? ref.read(learnerIdProvider);
  if (studentId == null) return;
  Lesson? lesson;
  DateTime? date = e.date == null ? null : DateTime.tryParse(e.date!);
  final id = e.attendanceId;
  if (id != null) {
    try {
      final dio = ref.read(dioProvider);
      final att = (await dio.get<Json>('/attendance/$id/')).data!;
      date ??= DateTime.tryParse(att.str('lesson_date'));
      final lessonId = att.strOrNull('lesson');
      if (lessonId != null) lesson = Lesson.fromJson((await dio.get<Json>('/lessons/$lessonId/')).data!);
    } catch (_) {
      // Falls back to the plain form.
    }
  }
  if (!context.mounted) return;
  context.go('/p/today');
  await showExcuseSheet(context, studentId: studentId, lesson: lesson, date: lesson == null ? date : null);
}

/// C3: ask for notifications once, at a moment they make sense, with one
/// explaining sheet before the system prompt.
/// Takes [push] and [prefs] rather than a ref: the caller may be a screen
/// that is closing.
Future<void> askForPushOnce(BuildContext context, Push push, JsonCache prefs, String reason) async {
  const key = 'push_asked';
  if (!Push.enabled) return;
  if (await prefs.read(key) == true) return;
  if (await push.status() != AuthorizationStatus.notDetermined) return;
  await prefs.write(key, true);
  if (!context.mounted) return;
  final l = context.l10n;
  final ok = await showGSheet<bool>(
    context,
    title: l.pushAskTitle,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(reason, style: ctx.t.body.copyWith(color: ctx.c.ink2)),
    ),
    actions: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GButton(
            label: l.pushAskAllow,
            expand: true,
            size: GButtonSize.l,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          const SizedBox(height: 8),
          GButton(
            label: l.notNow,
            expand: true,
            variant: GButtonVariant.plain,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    ),
  );
  if (ok ?? false) await push.request();
}
