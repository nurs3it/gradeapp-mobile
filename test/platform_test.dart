import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/auth/user.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/notifications/notifications.dart';
import 'package:gradeapp/features/notifications/push.dart';
import 'package:gradeapp/features/platform/deep_links.dart';
import 'package:gradeapp/features/platform/lesson_live.dart';
import 'package:gradeapp/features/platform/platform_host.dart';
import 'package:gradeapp/features/platform/push_intent.dart';
import 'package:gradeapp/features/platform/reminders.dart';
import 'package:gradeapp/features/platform/widget_snapshot.dart';
import 'package:gradeapp/features/teacher/teacher_models.dart';
import 'package:gradeapp/l10n/gen/app_localizations.dart';

Lesson lesson(String id, String date, String start, String end, {String? cls, LessonStatus s = LessonStatus.scheduled}) =>
    Lesson(
      id: id,
      courseId: 'c$id',
      subject: 'Алгебра',
      date: date,
      start: start,
      end: end,
      room: '312',
      classGroupName: cls,
      status: s,
    );

void main() {
  group('web links (C7)', () {
    String? route(String path) => routeForWebLink(Uri.parse('https://grade-app.kz$path'));

    test('claimed paths map to app routes', () {
      expect(route('/student'), '/s/today');
      expect(route('/student/grades'), '/s/grades');
      expect(route('/student/homework'), '/s/tasks');
      expect(route('/parent'), '/p/today');
      expect(route('/parent/excuse'), '/p/family');
      expect(route('/parent/invoices/abc'), '/p/family');
      expect(route('/teacher/lesson/42'), '/lesson/42');
      expect(route('/teacher/my-day'), '/t/today');
      expect(route('/teacher/schedule'), '/t/week');
      expect(route('/check-in'), '/checkin');
      expect(route('/notifications'), '/notifications');
    });

    test('unknown sub-paths of a claimed prefix end on Today, others stay out', () {
      expect(route('/student/something/new'), '/s/today');
      expect(route('/parent/'), '/p/today');
      expect(route('/admin/students'), isNull);
      expect(route('/teacher/journal'), isNull);
      expect(route('/'), isNull);
    });

    test('app routes themselves are not web links', () {
      expect(routeForWebLink(Uri.parse('/s/today')), isNull);
      expect(routeForWebLink(Uri.parse('/lesson/1')), isNull);
    });

  });

  group('push intents', () {
    test('plain tap and unknown action open', () {
      expect(intentFor({'type': 'grade.created'}), isA<OpenIntent>());
      expect(intentFor({'type': 'grade.created'}, actionId: PushActions.explain), isA<OpenIntent>());
      expect(isDefaultAction('com.apple.UNNotificationDefaultActionIdentifier'), isTrue);
      expect(isDefaultAction(PushActions.open), isFalse);
    });

    test('EXPLAIN on attendance.flagged keeps student, attendance and date', () {
      final i =
          intentFor({
                'type': 'attendance.flagged',
                'student_id': 's1',
                'target_kind': 'attendance',
                'target_id': 'a1',
                'date': '2026-11-17',
              }, actionId: PushActions.explain)
              as ExplainIntent;
      expect((i.studentId, i.attendanceId, i.date), ('s1', 'a1', '2026-11-17'));
    });

    test('APPROVE needs an excuse id', () {
      final i = intentFor({'type': 'excuse.pending', 'target_id': 'e1'}, actionId: PushActions.approve);
      expect((i as ApproveIntent).excuseId, 'e1');
      expect(intentFor({'type': 'excuse.pending'}, actionId: PushActions.approve), isA<OpenIntent>());
    });

    test('sync pushes are recognised before any action logic', () {
      final i = intentFor({'type': 'sync.schedule', 'student_id': 's1', 'date': '2026-11-18'}) as SyncIntent;
      expect((i.schedule, i.today, i.studentId, i.date), (true, false, 's1', '2026-11-18'));
      expect((intentFor({'type': 'sync.today'}) as SyncIntent).today, isTrue);
    });

    test('checkin.missing opens the parent Today of that child', () {
      final n = notificationFromPush({'type': 'checkin.missing', 'student_id': 's2', 'student_name': 'Айдана'});
      expect(n.payload['student_id'], 's2');
      expect(notificationRoute(n, AppRole.parent), '/p/today');
    });

    test('only the two contract types are rendered by the app', () {
      expect(renderedTypes, {'attendance.flagged', 'excuse.pending'});
    });
  });

  group('widget snapshot (W1, W2)', () {
    final l = lookupAppLocalizations(const Locale('ru'));
    final now = DateTime(2026, 11, 17, 10, 0);
    final target = const WidgetTarget(role: 'student', learnerId: 's1');

    Map<String, dynamic> build({List<Lesson>? lessons, List<Homework>? homework, WidgetTarget? t}) => buildSnapshot(
      target: t ?? target,
      lessons: lessons ?? const [],
      homework: homework ?? const [],
      now: now,
      l: l,
      langCode: 'ru',
    );

    test('drops cancelled lessons, orders by time, covers 4 days', () {
      final s = build(
        lessons: [
          lesson('2', '2026-11-17', '11:00:00', '11:45:00'),
          lesson('1', '2026-11-17', '09:00:00', '09:45:00'),
          lesson('x', '2026-11-17', '10:00:00', '10:45:00', s: LessonStatus.cancelled),
        ],
      );
      final days = s['days'] as List<dynamic>;
      expect(days.length, snapshotDays);
      final first = (days.first as Map<String, dynamic>)['lessons'] as List<dynamic>;
      expect(first.map((e) => (e as Map)['id']), ['1', '2']);
      expect((first.first as Map)['start'], '09:00');
    });

    test('teacher widgets carry the class, student ones do not', () {
      final ls = [lesson('1', '2026-11-17', '12:00:00', '12:45:00', cls: '7 «Б»')];
      Map<String, dynamic> first(Map<String, dynamic> s) =>
          (((s['days'] as List).first as Map)['lessons'] as List).first as Map<String, dynamic>;
      expect(first(build(lessons: ls, t: const WidgetTarget(role: 'teacher', staffId: 't')))['cls'], '7 «Б»');
      expect(first(build(lessons: ls))['cls'], '');
    });

    test('homework for tomorrow: only undone, with the minutes summed', () {
      Homework hw(String id, String due, int? min, {bool done = false}) => Homework(
        id: id,
        courseId: 'c',
        courseName: 'Физика',
        title: 'Задача $id',
        description: '',
        dueDate: due,
        minutes: min,
        isDone: done,
      );
      final s = build(homework: [hw('1', '2026-11-18', 20), hw('2', '2026-11-18', 25), hw('3', '2026-11-18', 5, done: true), hw('4', '2026-11-19', 9)]);
      final h = s['homework'] as Map<String, dynamic>;
      expect(h['date'], '2026-11-18');
      expect(h['minutes'], 45);
      expect((h['items'] as List).length, 2);
    });

    test('labels come in the app language', () {
      final kk = buildSnapshot(
        target: target,
        lessons: const [],
        homework: const [],
        now: now,
        l: lookupAppLocalizations(const Locale('kk')),
        langCode: 'kk',
      );
      expect((kk['labels'] as Map)['next'], 'Келесі сабақ');
      expect((kk['labels'] as Map)['roomFmt'], contains('%s'));
    });

    test('pickLesson: in progress wins, then next, next day after the last', () {
      final s = build(
        lessons: [
          lesson('1', '2026-11-17', '09:00:00', '09:45:00'),
          lesson('2', '2026-11-17', '10:00:00', '10:45:00'),
          lesson('3', '2026-11-18', '08:30:00', '09:15:00'),
        ],
      );
      expect(pickLesson(s, DateTime(2026, 11, 17, 9, 50)).lesson!['id'], '2');
      final during = pickLesson(s, DateTime(2026, 11, 17, 10, 10));
      expect((during.lesson!['id'], during.now), ('2', true));
      expect(pickLesson(s, DateTime(2026, 11, 17, 11, 0)).lesson!['id'], '3');
      expect(pickLesson(s, DateTime(2026, 11, 18, 12, 0)).lesson, isNull);
    });

    test('never lies when stale: older than a day is flagged', () {
      final s = build();
      expect(pickLesson(s, now.add(const Duration(hours: 23))).stale, isFalse);
      expect(pickLesson(s, now.add(const Duration(hours: 25))).stale, isTrue);
    });

    test('signed-out snapshot has no lessons', () {
      final s = signedOutSnapshot(l, 'ru', now);
      expect(s['role'], 'none');
      expect(pickLesson(s, now).lesson, isNull);
    });

    test('widget target: parent follows the child, teacher uses the staff id', () {
      const user = AppUser(id: 'u', email: '', firstName: '', lastName: '', roles: [], staffId: 'st', studentId: 'me');
      expect(widgetTargetFor(user: user, role: AppRole.teacher)!.staffId, 'st');
      expect(widgetTargetFor(user: user, role: AppRole.student)!.learnerId, 'me');
      final p = widgetTargetFor(user: user, role: AppRole.parent, learnerId: 'kid', childName: 'Айдана')!;
      expect((p.learnerId, p.who), ('kid', 'Айдана'));
      expect(widgetTargetFor(user: null, role: AppRole.parent), isNull);
      expect(const WidgetTarget(role: 'parent').usable, isFalse);
      expect(WidgetTarget.fromJson(p.toJson())!.who, 'Айдана');
    });
  });

  group('reminders (T10)', () {
    TodoLesson todo(Lesson l, {bool marked = false}) => TodoLesson(lesson: l, attendanceMarked: marked);
    final now = DateTime(2026, 11, 17, 10, 0);

    test('only today, unmarked, not cancelled, still ahead; 5 minutes after the bell', () {
      final day = TeacherDay(
        today: [
          todo(lesson('past', '2026-11-17', '08:00:00', '08:45:00')),
          todo(lesson('marked', '2026-11-17', '10:00:00', '10:45:00'), marked: true),
          todo(lesson('cancelled', '2026-11-17', '11:00:00', '11:45:00', s: LessonStatus.cancelled)),
          todo(lesson('ok', '2026-11-17', '11:00:00', '11:45:00', cls: '7 «Б»')),
        ],
        overdue: const [],
      );
      final plans = planReminders(day, now);
      expect(plans.map((p) => p.lesson.id), ['ok']);
      expect(plans.single.at, DateTime(2026, 11, 17, 11, 50));
    });

    test('at most six a day, earliest first', () {
      final day = TeacherDay(
        today: [for (var i = 0; i < 9; i++) todo(lesson('l$i', '2026-11-17', '${10 + i}:00:00', '${10 + i}:45:00'))],
        overdue: const [],
      );
      final plans = planReminders(day, DateTime(2026, 11, 17, 7, 0));
      expect(plans.length, maxRemindersPerDay);
      expect(plans.first.lesson.id, 'l0');
    });

    test('ids are stable, in their own range and distinct per lesson', () {
      expect(reminderIdOf('a'), reminderIdOf('a'));
      expect(reminderIdOf('a'), isNot(reminderIdOf('b')));
      expect(reminderIdOf('a') & 0x30000000, 0x20000000);
    });
  });

  group('lesson live (W5)', () {
    final s = LiveLesson(
      lessonId: 'l',
      title: '7 «Б»',
      subject: 'Алгебра',
      startsAt: DateTime(2026, 11, 17, 10),
      endsAt: DateTime(2026, 11, 17, 10, 45),
    );

    test('runs until the bell, lingers 15 minutes, then is gone', () {
      expect(livePhase(s, DateTime(2026, 11, 17, 10, 30)), LivePhase.running);
      expect(livePhase(s, DateTime(2026, 11, 17, 10, 46)), LivePhase.ended);
      expect(livePhase(s, DateTime(2026, 11, 17, 10, 59)), LivePhase.ended);
      expect(livePhase(s, DateTime(2026, 11, 17, 11)), LivePhase.gone);
    });

    test('never outlives the bell by more than the hard limit', () {
      expect(liveLingerAfterBell, lessThan(liveHardLimit));
      expect(liveHardLimit, const Duration(minutes: 30));
    });

    test('state survives a restart', () {
      final back = LiveLesson.fromJson(s.copyWith(marked: 24, total: 26).toJson())!;
      expect((back.marked, back.total, back.endsAt), (24, 26, s.endsAt));
    });
  });
}
