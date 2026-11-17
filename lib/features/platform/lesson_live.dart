import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gradeapp_native/gradeapp_native.dart';

import '../../core/storage/json_cache.dart';
import '../../l10n/gen/app_localizations.dart';
import 'local_notifications.dart';
import 'push_intent.dart';

/// The lesson the teacher is running (W5). No student names, no grades: only
/// class, subject, the bell and how many are marked.
class LiveLesson {
  const LiveLesson({
    required this.lessonId,
    required this.title,
    required this.subject,
    required this.startsAt,
    required this.endsAt,
    this.marked = 0,
    this.total = 0,
    this.topicMissing = false,
  });

  final String lessonId;

  /// Class name («7 «Б»»), or the subject when there is none.
  final String title;
  final String subject;
  final DateTime startsAt;
  final DateTime endsAt;
  final int marked;
  final int total;
  final bool topicMissing;

  LiveLesson copyWith({int? marked, int? total, bool? topicMissing}) => LiveLesson(
    lessonId: lessonId,
    title: title,
    subject: subject,
    startsAt: startsAt,
    endsAt: endsAt,
    marked: marked ?? this.marked,
    total: total ?? this.total,
    topicMissing: topicMissing ?? this.topicMissing,
  );

  Map<String, Object?> toJson() => {
    'lessonId': lessonId,
    'title': title,
    'subject': subject,
    'startsAt': startsAt.millisecondsSinceEpoch,
    'endsAt': endsAt.millisecondsSinceEpoch,
    'marked': marked,
    'total': total,
    'topicMissing': topicMissing,
  };

  static LiveLesson? fromJson(Object? j) {
    if (j is! Map) return null;
    return LiveLesson(
      lessonId: '${j['lessonId']}',
      title: '${j['title']}',
      subject: '${j['subject']}',
      startsAt: DateTime.fromMillisecondsSinceEpoch(j['startsAt'] as int),
      endsAt: DateTime.fromMillisecondsSinceEpoch(j['endsAt'] as int),
      marked: (j['marked'] as int?) ?? 0,
      total: (j['total'] as int?) ?? 0,
      topicMissing: j['topicMissing'] == true,
    );
  }
}

/// How long the «lesson ended» state stays after the bell (W5: 15 min), and
/// the hard ceiling (30 min) the notification times out at on Android.
const liveLingerAfterBell = Duration(minutes: 15);
const liveHardLimit = Duration(minutes: 30);

/// What the lock screen says at [now], pure so it can be tested.
enum LivePhase { running, ended, gone }

LivePhase livePhase(LiveLesson s, DateTime now) {
  if (now.isBefore(s.endsAt)) return LivePhase.running;
  return now.isBefore(s.endsAt.add(liveLingerAfterBell)) ? LivePhase.ended : LivePhase.gone;
}

/// Whole minutes to the bell (rounded up, never below 1 while running): the
/// text of the Android 16 status-bar chip.
int liveMinutesLeft(LiveLesson s, DateTime now) {
  final left = s.endsAt.difference(now).inSeconds;
  return left <= 0 ? 0 : (left + 59) ~/ 60;
}

/// W5: Live Activity (iOS, ActivityKit — ios/Runner/LiveActivity.swift) and
/// the ongoing notification (Android). Started and finished from the lesson
/// screen, updated locally; no server involved.
///
/// Ending on time: Android's notification carries `timeoutAfter` (bell +
/// 30 min), so the system removes it even if the app is dead. iOS has no such
/// timer: while the process lives a timer ends the activity at bell + 15 min,
/// and the next launch/resume sweeps the rest ([sweep]). Until then the
/// activity shows the «lesson ended» text (its stale date is the bell).
abstract final class LessonLive {
  static const _ch = MethodChannel('kz.gradeapp/live');
  static const _stateKey = 'live_lesson';
  static const prefKey = 'live_lesson_on';
  static const _androidId = 0x30000001;

  static LiveLesson? _current;
  static AppLocalizations? _l;
  static JsonCache? _prefs;
  static Timer? _tick;
  static Timer? _end;

  static LiveLesson? get current => _current;

  static Future<bool> enabled(JsonCache prefs) async => await prefs.read(prefKey) != false;

  /// «Начать урок».
  static Future<void> start(LiveLesson lesson, AppLocalizations l, JsonCache prefs) async {
    if (!await enabled(prefs)) return;
    if (_current?.lessonId == lesson.lessonId) return update(lesson, l, prefs);
    await _stop(immediate: true);
    _current = lesson;
    _l = l;
    _prefs = prefs;
    await prefs.write(_stateKey, lesson.toJson());
    await _render(created: true);
    _arm();
  }

  /// Marks changed (or the topic was entered): refresh the lock screen.
  static Future<void> update(LiveLesson lesson, AppLocalizations l, JsonCache prefs) async {
    final cur = _current;
    if (cur == null || cur.lessonId != lesson.lessonId) return;
    if (cur.marked == lesson.marked && cur.total == lesson.total && cur.topicMissing == lesson.topicMissing) return;
    _current = lesson;
    _l = l;
    await prefs.write(_stateKey, lesson.toJson());
    await _render();
  }

  /// «Завершить урок» or leaving a finished lesson: the activity goes now.
  static Future<void> finish(String lessonId) async {
    if (_current?.lessonId != lessonId) return;
    await _stop(immediate: true);
  }

  /// App start / resume: drops what outlived its time and re-arms the rest.
  static Future<void> sweep(AppLocalizations l, JsonCache prefs, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    final saved = LiveLesson.fromJson(await prefs.read(_stateKey));
    _l = l;
    _prefs = prefs;
    if (saved == null) {
      await _native('sweep', {'now': now.millisecondsSinceEpoch});
      return;
    }
    if (livePhase(saved, now) == LivePhase.gone || !await enabled(prefs)) {
      _current = saved;
      await _stop(immediate: true);
      return;
    }
    _current ??= saved;
    _arm();
    await _render();
  }

  static void _arm() {
    final s = _current;
    if (s == null) return;
    _tick?.cancel();
    _end?.cancel();
    // Progress bar on Android moves once a minute while the process lives.
    if (Platform.isAndroid) _tick = Timer.periodic(const Duration(minutes: 1), (_) => unawaited(_render()));
    final now = DateTime.now();
    final bell = s.endsAt.difference(now);
    if (!bell.isNegative) _end = Timer(bell + const Duration(seconds: 1), () => unawaited(_render()));
    final gone = s.endsAt.add(liveLingerAfterBell).difference(now);
    Timer(gone.isNegative ? Duration.zero : gone, () => unawaited(_stop(immediate: false, only: s.lessonId)));
  }

  static Future<void> _stop({required bool immediate, String? only}) async {
    final s = _current;
    if (s == null || (only != null && s.lessonId != only)) return;
    _tick?.cancel();
    _end?.cancel();
    _current = null;
    await _prefs?.write(_stateKey, null);
    await _native('end', {'lessonId': s.lessonId, 'immediate': immediate});
    if (Platform.isAndroid) {
      try {
        await LocalNotifications.plugin.cancel(id: _androidId);
      } catch (_) {}
    }
  }

  static Future<void> _render({bool created = false}) async {
    final s = _current;
    final l = _l;
    if (s == null || l == null) return;
    final now = DateTime.now();
    final phase = livePhase(s, now);
    if (phase == LivePhase.gone) return _stop(immediate: true);
    if (Platform.isIOS) {
      await _native(created ? 'start' : 'update', {
        ...s.toJson(),
        'ended': phase == LivePhase.ended,
        'labelUntil': l.liveUntilBell,
        'labelMarked': l.liveMarked(s.marked, s.total),
        'labelEnded': s.topicMissing ? l.liveEndedTopic : l.liveEnded,
        'labelAllPresent': l.tAllPresent,
        'endedUntil': s.endsAt.add(liveLingerAfterBell).millisecondsSinceEpoch,
      });
    } else if (Platform.isAndroid) {
      await _androidNotification(s, l, phase, now);
    }
  }

  static Future<void> _androidNotification(LiveLesson s, AppLocalizations l, LivePhase phase, DateTime now) async {
    final ended = phase == LivePhase.ended;
    final total = s.endsAt.difference(s.startsAt).inMinutes.clamp(1, 600);
    final done = now.difference(s.startsAt).inMinutes.clamp(0, total);
    final hardStop = s.endsAt.add(liveHardLimit).difference(now).inMilliseconds;
    try {
      await LocalNotifications.ensureChannels(l);
      await LocalNotifications.plugin.show(
        id: _androidId,
        title: ended ? (s.topicMissing ? l.liveEndedTopic : l.liveEnded) : '${s.title} · ${s.subject}',
        body: ended ? '${s.title} · ${s.subject}' : l.liveMarked(s.marked, s.total),
        payload: jsonEncode({'type': 'lesson.started', 'target_kind': 'lesson', 'target_id': s.lessonId}),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            liveChannelId,
            liveChannelId,
            icon: 'ic_notification',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: !ended,
            autoCancel: ended,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
            // Secure lock screen: the system's redacted version.
            visibility: NotificationVisibility.private,
            category: AndroidNotificationCategory.progress,
            subText: ended ? null : l.liveUntilBell,
            showProgress: !ended,
            maxProgress: total,
            progress: done,
            usesChronometer: !ended,
            chronometerCountDown: true,
            when: s.endsAt.millisecondsSinceEpoch,
            showWhen: !ended,
            timeoutAfter: hardStop > 0 ? hardStop : 1,
            // W5: opens the lesson and marks everyone present. Not while the
            // lesson is over, and not once everyone is already marked.
            actions: ended || (s.total > 0 && s.marked >= s.total)
                ? null
                : [AndroidNotificationAction(PushActions.allPresent, l.tAllPresent, showsUserInterface: true)],
          ),
        ),
      );
      // Secure lock screen: generic text. On Android 16 the running lesson
      // also becomes a Live Update (progress style, status-bar chip).
      if (ended) {
        await LocalNotifications.hideOnLockScreen(_androidId, l);
      } else {
        await GradeappNative.promoteLessonLive(
          id: _androidId,
          startMs: s.startsAt.millisecondsSinceEpoch,
          endMs: s.endsAt.millisecondsSinceEpoch,
          shortText: l.liveShortMinutes(liveMinutesLeft(s, now)),
          publicTitle: l.notifPublicTitle,
          publicBody: l.notifPublicBody,
        );
      }
    } catch (e) {
      debugPrint('lesson live notification: $e');
    }
  }

  static Future<void> _native(String method, Map<String, Object?> args) async {
    if (!Platform.isIOS) return;
    try {
      await _ch.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Tests.
    } on PlatformException catch (e) {
      debugPrint('live activity $method: ${e.message}');
    }
  }
}
