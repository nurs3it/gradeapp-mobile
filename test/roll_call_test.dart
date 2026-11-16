import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/offline/outbox.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/common/now_next.dart';
import 'package:gradeapp/features/teacher/teacher_models.dart';
import 'package:gradeapp/features/teacher/teacher_providers.dart';

RosterStudent st(String id, String last, String cls) =>
    RosterStudent(id: id, firstName: 'X', lastName: last, classId: cls, className: cls);

void main() {
  test('joint lesson: students of every class, by class then surname, no duplicates', () {
    final roster = mergeRoster(['10A', '10B'], {
      '10B': [st('3', 'Бекова', '10B'), st('1', 'Абаев', '10B')],
      '10A': [st('2', 'Ерлан', '10A'), st('1', 'Абаев', '10A'), st('4', 'Жанна', '10A')],
    });
    expect(roster.map((s) => s.id), ['1', '2', '4', '3']);
    expect(roster.first.classId, '10A');
  });

  test('roll call: default «есть», check-in and homeroom fill in, the queue wins', () {
    final students = [st('a', 'А', 'C'), st('b', 'Б', 'C'), st('c', 'В', 'C'), st('d', 'Г', 'C')];
    final defaults = LessonDefaults(
      students: {
        'a': AttendanceDefault(status: Presence.present, source: 'checkin', checkedAt: DateTime(2026, 11, 16, 7, 51)),
        'b': const AttendanceDefault(status: Presence.excused, code: 'Б', source: 'homeroom'),
        'c': const AttendanceDefault(status: Presence.present, source: 'lesson'),
      },
    );
    final queued = OutboxItem(
      key: 'att:L:d',
      method: 'POST',
      path: '/attendance/mark/',
      data: {
        'lesson_id': 'L',
        'records': [
          {'student_id': 'd', 'status': 'absent', 'code': 'Н'},
        ],
      },
    );
    final cells = rollCall(
      students: students,
      defaults: defaults,
      overlay: LessonOverlay.of([queued], 'L'),
      grades: [const Grade(id: 'g', studentId: 'a', courseId: 'x', courseName: 'x', value: 9, type: 'fo', date: '2026-11-16')],
      type: 'fo',
    );
    expect(cells['a']!.status, Presence.present);
    expect(cells['a']!.saved, isFalse, reason: 'check-in is a suggestion until the teacher confirms');
    expect(cells['a']!.grade, 9);
    expect(cells['b']!.code, 'Б');
    expect(cells['c']!.saved, isTrue);
    expect(cells['d']!.status, Presence.absent);
    expect(cells['d']!.queued, isTrue);
    expect(presentCount(cells), 2);
  });

  test('roll-call order: self check-ins first, then by surname, per class', () {
    final students = [st('1', 'Ахмет', 'C'), st('2', 'Бекова', 'C'), st('3', 'Ветров', 'C')];
    final defaults = {'3': const AttendanceDefault(status: Presence.present, source: 'checkin')};
    expect(rollCallOrder(students, defaults).map((s) => s.id), ['3', '1', '2']);
  });

  test('now / next across the day', () {
    Lesson l(String id, String s, String e) => Lesson(id: id, courseId: id, subject: id, date: '2026-11-16', start: s, end: e);
    final day = [l('a', '08:30', '09:15'), l('b', '09:25', '10:10'), l('c', '10:25', '11:10')];
    DateTime at(int h, int m) => DateTime(2026, 11, 16, h, m);
    final before = computeNowNext(day, at(7, 52));
    expect(before.phase, DayPhase.before);
    expect(before.minutes, 38);
    final during = computeNowNext(day, at(9, 30));
    expect(during.phase, DayPhase.lesson);
    expect(during.current!.id, 'b');
    expect(during.minutes, 40);
    expect(during.next!.id, 'c');
    expect(during.number, 2);
    final pause = computeNowNext(day, at(10, 15));
    expect(pause.phase, DayPhase.pause);
    expect(pause.next!.id, 'c');
    expect(pause.minutes, 10);
    final last = computeNowNext(day, at(10, 30));
    expect(last.isLast, isTrue);
    expect(computeNowNext(day, at(12, 0)).phase, DayPhase.after);
    expect(computeNowNext(const [], at(12, 0)).phase, DayPhase.none);
  });
}
