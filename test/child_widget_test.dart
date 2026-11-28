import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/platform/child_status.dart';
import 'package:gradeapp/features/platform/deep_links.dart';
import 'package:gradeapp/features/platform/widget_snapshot.dart';
import 'package:gradeapp/l10n/gen/app_localizations.dart';

Lesson lesson(String id, {LessonStatus status = LessonStatus.scheduled, String end = '11:45'}) =>
    Lesson(id: id, courseId: 'c', subject: 'Алгебра', date: '2026-11-27', start: '11:00', end: end, status: status);

Grade grade(String id, DateTime created) => Grade(
  id: id,
  studentId: 's1',
  courseId: 'c',
  courseName: 'Алгебра',
  value: 9,
  type: 'fo',
  date: '2026-11-27',
  createdAt: created,
);

CheckInStatus checkIn({required bool done, DateTime? at}) => CheckInStatus(
  enabled: true,
  windowStart: '07:00',
  windowEnd: '09:00',
  windowOpen: true,
  geofence: false,
  consent: true,
  checkedIn: done,
  checkedAt: at,
);

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  final now = DateTime(2026, 11, 27, 10, 0);
  const child = Child(id: 's1', firstName: 'Дана', fullName: 'Аманова Дана', className: '3А');

  LearnerDay day({
    List<Lesson>? lessons,
    CheckInStatus? ci,
    List<Grade> grades = const [],
    Map<String, AttendanceMark> attendance = const {},
  }) => LearnerDay(
    date: '2026-11-27',
    studentId: 's1',
    studentName: 'Аманова Дана',
    lessons: lessons ?? [lesson('l1')],
    checkIn: ci,
    recentGrades: grades,
    attendance: attendance,
  );

  group('child status (W3)', () {
    test('after the last lesson: «Уроки закончились», no switch time left', () {
      final s = childStatusOf(
        child: child,
        day: day(lessons: [lesson('l1', end: '09:45')], ci: checkIn(done: true, at: DateTime(2026, 11, 27, 7, 52))),
        now: now,
        l: ru,
      );
      expect(s.kind, ChildKind.inSchool);
      expect(s.text, 'Уроки закончились');
      expect(s.until, isNull);
    });

    test('during lessons: the widget gets the switch time and the later text', () {
      final s = childStatusOf(
        child: child,
        day: day(
          lessons: [lesson('l1'), lesson('l2', end: '13:30'), lesson('l3', end: '15:00', status: LessonStatus.cancelled)],
          ci: checkIn(done: true, at: DateTime(2026, 11, 27, 7, 52)),
        ),
        now: now,
        l: ru,
      );
      expect(s.text, 'В школе с 07:52');
      expect(s.until, DateTime(2026, 11, 27, 13, 30));
      expect(s.afterText, 'Уроки закончились');
      final back = ChildStatus.fromJson(jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>);
      expect(back.until, s.until);
      expect(back.afterText, s.afterText);
    });

    test('checked in: «В школе с 07:52»', () {
      final s = childStatusOf(
        child: child,
        day: day(ci: checkIn(done: true, at: DateTime(2026, 11, 27, 7, 52))),
        now: now,
        l: ru,
      );
      expect(s.kind, ChildKind.inSchool);
      expect(s.text, 'В школе с 07:52');
      expect(s.since, '07:52');
      expect(s.name, 'Дана');
      expect(s.cls, '3А');
    });

    test('no check-in on a school day: not yet; no lessons: nothing to check in for', () {
      expect(
        childStatusOf(
          child: child,
          day: day(ci: checkIn(done: false)),
          now: now,
          l: ru,
        ).kind,
        ChildKind.notYet,
      );
      final none = childStatusOf(
        child: child,
        day: day(lessons: const []),
        now: now,
        l: ru,
      );
      expect(none.kind, ChildKind.noLessons);
      expect(none.text, 'Сегодня уроков нет');
      // only cancelled lessons is a day off too
      expect(
        childStatusOf(
          child: child,
          day: day(lessons: [lesson('x', status: LessonStatus.cancelled)]),
          now: now,
          l: ru,
        ).kind,
        ChildKind.noLessons,
      );
    });

    test('a lesson mark stands in for a missing check-in', () {
      final present = childStatusOf(
        child: child,
        day: day(attendance: {'l1': const AttendanceMark(status: Presence.present)}),
        now: now,
        l: ru,
      );
      expect(present.kind, ChildKind.inSchool);
      expect(present.text, 'В школе');
      final absent = childStatusOf(
        child: child,
        day: day(attendance: {'l1': const AttendanceMark(status: Presence.absent)}),
        now: now,
        l: ru,
      );
      expect(absent.kind, ChildKind.absent);
    });

    test('new grades are counted since the last visit, never shown', () {
      final grades = [
        grade('a', DateTime(2026, 11, 27, 8)),
        grade('b', DateTime(2026, 11, 26, 12)),
        grade('c', DateTime(2026, 11, 20)),
      ];
      expect(newGradesCount(grades, now, DateTime(2026, 11, 26, 18)), 1);
      // never looked: the last 48 hours
      expect(newGradesCount(grades, now, null), 2);
      final s = childStatusOf(
        child: child,
        day: day(grades: grades),
        now: now,
        l: ru,
        gradesSeenAt: DateTime(2026, 11, 21),
      );
      expect(s.newGrades, 2);
      expect(s.gradesText, '2 новые оценки');
      expect(jsonEncode(s.toJson()), isNot(contains('9')), reason: 'no grade values in the snapshot');
      expect(childStatusOf(child: child, day: day(), now: now, l: ru).gradesText, 'Новых оценок нет');
    });

    test('a day that failed to load is unknown, with no text', () {
      final s = childStatusOf(child: child, day: null, now: now, l: ru);
      expect(s.kind, ChildKind.unknown);
      expect(s.text, isEmpty);
      expect(s.gradesText, isEmpty);
    });

    test('the selected child goes first', () {
      const a = Child(id: 'a', firstName: 'А', fullName: 'А');
      const b = Child(id: 'b', firstName: 'Б', fullName: 'Б');
      expect(selectedFirst([a, b], 'b').map((c) => c.id), ['b', 'a']);
      expect(selectedFirst([a, b], null).map((c) => c.id), ['a', 'b']);
    });
  });

  group('snapshot v2', () {
    const target = WidgetTarget(role: 'parent', learnerId: 's1', who: 'Дана');
    Map<String, dynamic> build({List<ChildStatus> children = const []}) => buildSnapshot(
      target: target,
      lessons: const [],
      homework: const [],
      now: now,
      l: ru,
      langCode: 'ru',
      children: children,
    );

    test('is version 2 and carries the children of a parent', () {
      final kid = childStatusOf(
        child: child,
        day: day(
          ci: checkIn(done: true, at: DateTime(2026, 11, 27, 7, 52)),
          grades: [grade('a', DateTime(2026, 11, 27, 8))],
        ),
        now: now,
        l: ru,
      );
      final snap = build(children: [kid]);
      expect(snap['v'], 2);
      final back = jsonDecode(jsonEncode(snap)) as Map<String, dynamic>;
      final kids = childrenOf(back);
      expect(kids.single.id, 's1');
      expect(kids.single.text, 'В школе с 07:52');
      expect(kids.single.kind, ChildKind.inSchool);
      expect(kids.single.newGrades, 1);
      // lock-screen families read only status; the snapshot holds counts, not marks
      expect(jsonEncode(back['children']), isNot(contains('"value"')));
    });

    test('teacher and student snapshots have no children key', () {
      for (final role in ['teacher', 'student']) {
        final s = buildSnapshot(
          target: WidgetTarget(role: role, learnerId: 's', staffId: 't'),
          lessons: const [],
          homework: const [],
          now: now,
          l: ru,
          langCode: 'ru',
        );
        expect(s.containsKey('children'), isFalse, reason: role);
        expect(s['v'], 2);
      }
      expect(signedOutSnapshot(ru, 'ru', now)['v'], 2);
    });

    test('a v1 snapshot still reads: no children, lessons intact', () {
      final v1 = <String, dynamic>{
        'v': 1,
        'role': 'parent',
        'who': 'Дана',
        'generatedAt': now.toUtc().toIso8601String(),
        'days': [
          {
            'date': '2026-11-27',
            'lessons': [
              {'id': 'l', 'subject': 'Алгебра', 'start': '10:30', 'end': '11:15', 'room': '', 'cls': '', 'ci': 0},
            ],
          },
        ],
      };
      expect(childrenOf(v1), isEmpty);
      expect(pickChild(v1), isNull);
      expect(pickLesson(v1, now).lesson!['id'], 'l');
    });

    test('pickChild: the configured child, else the first', () {
      const a = ChildStatus(id: 'a', name: 'А', kind: ChildKind.notYet, text: 'x');
      const b = ChildStatus(id: 'b', name: 'Б', kind: ChildKind.inSchool, text: 'y');
      final snap = build(children: [a, b]);
      expect(pickChild(snap, id: 'b')!.id, 'b');
      expect(pickChild(snap, id: 'gone')!.id, 'a');
      expect(pickChild(snap)!.id, 'a');
    });

    test('an unknown kind from a newer app decodes to unknown', () {
      expect(ChildStatus.fromJson({'id': 'a', 'kind': 'teleported'}).kind, ChildKind.unknown);
    });
  });

  test('«Мой класс» web link opens the tab', () {
    expect(routeForWebLink(Uri.parse('https://grade-app.kz/teacher/my-class')), '/t/class');
  });
}
