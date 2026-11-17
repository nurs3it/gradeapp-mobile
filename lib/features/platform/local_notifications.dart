import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gradeapp_native/gradeapp_native.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/storage/json_cache.dart';
import '../../l10n/gen/app_localizations.dart';
import 'push_intent.dart';

/// Language for code that runs without a BuildContext (background isolates,
/// boot): the user's choice in settings, else the phone's.
Future<AppLocalizations> resolveL10n([JsonCache? prefs]) async {
  String? code;
  try {
    final raw = await (prefs ?? await JsonCache.open('prefs')).read('settings');
    if (raw is Map) code = raw['locale'] as String?;
  } catch (_) {}
  code ??= PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode);
  return lookupAppLocalizations(Locale(supported.contains(code) ? code : 'ru'));
}

/// Android channel of the teacher's «Идёт урок» notification.
const liveChannelId = 'lesson_live';

/// Android channel of T10 reminders.
const reminderChannelId = 'reminders';

/// Local notifications: Android rendering of data-only pushes (with
/// buttons), the lesson-in-progress notification and T10 reminders. On iOS
/// it also registers the action categories remote pushes refer to.
///
/// The iOS UNUserNotificationCenter delegate stays with Flutter's app
/// delegate chain: firebase_messaging handles remote pushes (and reports the
/// tapped button as `RemoteMessage.actionIdentifier`), this plugin only
/// claims notifications it scheduled itself.
abstract final class LocalNotifications {
  static final plugin = FlutterLocalNotificationsPlugin();
  static final _taps = StreamController<NotificationResponse>.broadcast();

  /// Taps and buttons that open the app (foreground callback).
  static Stream<NotificationResponse> get taps => _taps.stream;

  static bool _tz = false;

  static Future<void> _initTimezone() async {
    if (_tz) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
    } catch (_) {
      // Falls back to UTC; reminders are then offset, so log it.
      debugPrint('local notifications: no local timezone');
    }
    _tz = true;
  }

  /// Safe to call again when the language changes (iOS action titles).
  static Future<void> init(
    AppLocalizations l, {
    bool background = false,
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  }) async {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return;
    await _initTimezone();
    try {
      await plugin.initialize(
        settings: InitializationSettings(
          android: const AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            notificationCategories: _categories(l),
          ),
        ),
        onDidReceiveNotificationResponse: background ? null : _taps.add,
        onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
      );
    } catch (e) {
      debugPrint('local notifications init: $e');
    }
  }

  static List<DarwinNotificationCategory> _categories(AppLocalizations l) => [
    DarwinNotificationCategory(
      PushActions.attendanceCategory,
      actions: [
        DarwinNotificationAction.plain(
          PushActions.explain,
          l.actExplain,
          options: {DarwinNotificationActionOption.foreground},
        ),
      ],
    ),
    DarwinNotificationCategory(
      PushActions.excuseCategory,
      actions: [
        // Foreground: the app opens, approves and confirms with a toast.
        DarwinNotificationAction.plain(
          PushActions.approve,
          l.actApprove,
          options: {DarwinNotificationActionOption.foreground},
        ),
        DarwinNotificationAction.plain(
          PushActions.open,
          l.notifOpen,
          options: {DarwinNotificationActionOption.foreground},
        ),
      ],
    ),
  ];

  /// Android channels this plugin posts to, named in the app language.
  static Future<void> ensureChannels(AppLocalizations l) async {
    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.createNotificationChannel(
      AndroidNotificationChannel(liveChannelId, l.liveChannel, importance: Importance.low, playSound: false),
    );
    await android.createNotificationChannel(AndroidNotificationChannel(reminderChannelId, l.remChannel));
  }

  /// The notification that launched the app from a terminated state.
  static Future<NotificationResponse?> launchResponse() async {
    try {
      final d = await plugin.getNotificationAppLaunchDetails();
      return d != null && d.didNotificationLaunchApp ? d.notificationResponse : null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> decode(String? payload) {
    if (payload == null || payload.isEmpty) return const {};
    try {
      final j = jsonDecode(payload);
      return j is Map<String, dynamic> ? j : const {};
    } catch (_) {
      return const {};
    }
  }

  /// Renders a data-only push (Android): title, body and channel come from
  /// the server's text (CONTRACTS «Push payloads»). Always private on the
  /// lock screen: the system then shows its own redacted version, so nothing
  /// about the child leaks past a secure lock screen — whatever the server
  /// puts in `visibility`.
  static Future<void> showPush(Map<String, dynamic> data, AppLocalizations l) async {
    final type = '${data['type'] ?? ''}';
    final channel = '${data['channel'] ?? 'general'}';
    final actions = switch (type) {
      'attendance.flagged' => [
        AndroidNotificationAction(
          PushActions.explain,
          l.actExplain,
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
      'excuse.pending' => [
        // Background: approves without opening the app.
        AndroidNotificationAction(PushActions.approve, l.actApprove, cancelNotification: false),
        AndroidNotificationAction(PushActions.open, l.notifOpen, showsUserInterface: true, cancelNotification: true),
      ],
      _ => <AndroidNotificationAction>[],
    };
    await plugin.show(
      id: notificationIdOf(data),
      title: '${data['title'] ?? ''}',
      body: '${data['body'] ?? ''}',
      payload: jsonEncode({for (final e in data.entries) e.key: '${e.value}'}),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel,
          icon: 'ic_notification',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
          category: AndroidNotificationCategory.message,
          actions: actions,
        ),
      ),
    );
    await hideOnLockScreen(notificationIdOf(data), l);
  }

  /// Gives the notification [id] a public version with generic text («GradeApp
  /// · Новое уведомление»): a secure lock screen shows that instead of the
  /// child's name. Android only; actions stay as they were.
  static Future<void> hideOnLockScreen(int id, AppLocalizations l) =>
      GradeappNative.addPublicVersion(id: id, title: l.notifPublicTitle, body: l.notifPublicBody);

  static int notificationIdOf(Map<String, dynamic> data) =>
      ('${data['notification_id'] ?? data['target_id'] ?? DateTime.now().microsecondsSinceEpoch}'.hashCode &
      0x3fffffff);
}
