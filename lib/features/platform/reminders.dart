import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/storage/json_cache.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/models.dart';
import '../teacher/teacher_models.dart';
import 'local_notifications.dart';

/// One planned reminder (T10).
class ReminderPlan {
  const ReminderPlan({required this.lesson, required this.at});
  final Lesson lesson;
  final DateTime at;
}

/// Pref switch in «Уведомления → На этом телефоне».
const remindersPrefKey = 'teacher_reminders';

/// Reminders per day (T10) and the margin under iOS's 64 pending limit.
const maxRemindersPerDay = 6;

/// How long after the bell the reminder comes.
const reminderDelay = Duration(minutes: 5);

/// Which lessons of today get a reminder: not cancelled, attendance still
/// unmarked, and the moment (bell + [reminderDelay]) still ahead. The
/// earliest [maxRemindersPerDay]; never more, so iOS's 64-pending limit and
/// the teacher's patience both hold.
List<ReminderPlan> planReminders(TeacherDay day, DateTime now, {int limit = maxRemindersPerDay}) {
  final plans = [
    for (final t in day.today)
      if (!t.lesson.isCancelled && !t.attendanceMarked && t.lesson.date == isoDate(now))
        ReminderPlan(lesson: t.lesson, at: t.lesson.endsAt().add(reminderDelay)),
  ].where((p) => p.at.isAfter(now)).toList()..sort((a, b) => a.at.compareTo(b.at));
  return plans.take(limit).toList();
}

/// Stable notification id of a lesson's reminder (30-bit, own range).
int reminderIdOf(String lessonId) => 0x20000000 | (lessonId.hashCode & 0x0fffffff);

/// Local reminders for the teacher: «7 Б: посещаемость не отмечена» soon
/// after the bell. Rescheduled from fresh day data, cancelled the moment the
/// attendance is saved.
abstract final class Reminders {
  static const _type = 'attendance.unmarked';

  static Future<bool> enabled(JsonCache prefs) async => await prefs.read(remindersPrefKey) != false;

  /// Replaces the reminders with the plan for [day].
  static Future<void> reschedule(TeacherDay day, DateTime now, AppLocalizations l, JsonCache prefs) async {
    final plugin = LocalNotifications.plugin;
    if (!await enabled(prefs)) return cancelAll();
    final plans = planReminders(day, now);
    final keep = {for (final p in plans) reminderIdOf(p.lesson.id)};
    try {
      for (final r in await plugin.pendingNotificationRequests()) {
        if (_isReminder(r.id) && !keep.contains(r.id)) await plugin.cancel(id: r.id);
      }
      for (final p in plans) {
        final cls = p.lesson.classGroupName ?? p.lesson.subject;
        await plugin.zonedSchedule(
          id: reminderIdOf(p.lesson.id),
          scheduledDate: tz.TZDateTime.from(p.at, tz.local),
          title: l.remTitle(cls),
          body: l.remBody(p.lesson.subject, hm(p.lesson.start), hm(p.lesson.end)),
          payload: '{"type":"$_type","target_kind":"lesson","target_id":"${p.lesson.id}","local":"1"}',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              reminderChannelId,
              reminderChannelId,
              icon: 'ic_notification',
              importance: Importance.high,
              priority: Priority.high,
              visibility: NotificationVisibility.private,
            ),
            iOS: DarwinNotificationDetails(threadIdentifier: 'reminders'),
          ),
        );
      }
    } catch (e) {
      // Notifications not allowed or the plugin is not ready: nothing to do.
      debugPrint('reminders: $e');
    }
  }

  static bool _isReminder(int id) => id & 0x20000000 != 0 && id & 0x10000000 == 0;

  /// Attendance was saved: no reminder for that lesson (also delivered ones
  /// leave the shade).
  static Future<void> cancelFor(String lessonId) async {
    try {
      await LocalNotifications.plugin.cancel(id: reminderIdOf(lessonId));
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    try {
      final p = LocalNotifications.plugin;
      for (final r in await p.pendingNotificationRequests()) {
        if (_isReminder(r.id)) await p.cancel(id: r.id);
      }
    } catch (_) {}
  }
}
