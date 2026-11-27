import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/teacher/my_class_logic.dart';
import 'package:gradeapp/features/teacher/teacher_models.dart';

RosterStudent st(String id, String last) => RosterStudent(id: id, firstName: 'А', lastName: last, classId: 'c1');

Excuse excuse(
  String student,
  ExcuseStatus status, {
  String scope = 'full_days',
  String from = '2026-11-27',
  String to = '2026-11-27',
}) => Excuse(
  id: 'e-$student',
  studentId: student,
  scope: scope,
  startDate: from,
  endDate: to,
  category: 'illness',
  status: status,
);

String codeFor(Presence p) => switch (p) {
  Presence.absent => 'Н',
  Presence.tardy => 'О',
  Presence.excused => 'У',
  Presence.present => '',
};

void main() {
  final students = [st('a', 'Аманов'), st('b', 'Бекова'), st('c', 'Ким'), st('d', 'Серик'), st('e', 'Тулеу')];
  const date = '2026-11-27';

  test('day prefill: saved mark beats excuse beats check-in; nothing = unmarked', () {
    final cells = mergeDayMarks(
      students: students,
      date: date,
      checkIns: [
        ClassCheckIn(studentId: 'a', checkedAt: DateTime(2026, 11, 27, 7, 52)),
        const ClassCheckIn(studentId: 'b', late: true),
        const ClassCheckIn(studentId: 'c'),
      ],
      excuses: [excuse('c', ExcuseStatus.approved), excuse('d', ExcuseStatus.approved)],
      saved: const [DayMark(studentId: 'c', status: Presence.absent, code: 'Н')],
      codeFor: codeFor,
    );
    expect(cells['a']!.status, Presence.present);
    expect(cells['a']!.source, DaySource.checkin);
    expect(cells['a']!.checkedAt, DateTime(2026, 11, 27, 7, 52));
    expect(cells['b']!.status, Presence.tardy);
    expect(cells['b']!.code, 'О');
    // saved wins over both the check-in and the excuse
    expect(cells['c']!.status, Presence.absent);
    expect(cells['c']!.source, DaySource.saved);
    // excused for the day with no check-in
    expect(cells['d']!.status, Presence.excused);
    expect(cells['d']!.code, 'У');
    expect(cells['d']!.source, DaySource.excuse);
    expect(cells['e']!.unmarked, isTrue);
  });

  test('queued local mark wins over the server', () {
    final cells = mergeDayMarks(
      students: students,
      date: date,
      saved: const [DayMark(studentId: 'a', status: Presence.present)],
      queued: {'a': (status: Presence.absent, code: 'Н', reason: '')},
    );
    expect(cells['a']!.status, Presence.absent);
    expect(cells['a']!.source, DaySource.queued);
    expect(cells['a']!.recorded, isTrue);
  });

  test('a pending request only flags the row; specific lessons and other dates do not excuse the day', () {
    final cells = mergeDayMarks(
      students: students,
      date: date,
      excuses: [
        excuse('a', ExcuseStatus.pending),
        excuse('b', ExcuseStatus.approved, scope: 'specific_lessons'),
        excuse('c', ExcuseStatus.approved, from: '2026-11-20', to: '2026-11-26'),
        excuse('d', ExcuseStatus.rejected),
      ],
    );
    expect(cells['a']!.unmarked, isTrue);
    expect(cells['a']!.pendingExcuse, isTrue);
    for (final id in ['b', 'c', 'd']) {
      expect(cells[id]!.unmarked, isTrue, reason: id);
    }
  });

  test('counts, order and request body', () {
    final cells = mergeDayMarks(
      students: students,
      date: date,
      checkIns: const [
        ClassCheckIn(studentId: 'a'),
        ClassCheckIn(studentId: 'b', late: true),
      ],
      saved: const [DayMark(studentId: 'c', status: Presence.absent, code: 'Н', reason: 'болеет')],
      codeFor: codeFor,
    );
    final counts = dayCounts(cells);
    expect(counts.came, 2);
    expect(counts.total, 5);
    expect(counts.unmarked, 2);
    // unmarked on top, each by surname
    expect(dayOrder(students, cells).map((s) => s.id), ['d', 'e', 'a', 'b', 'c']);
    expect(markDayBody(classId: 'c1', date: date, cells: cells), {
      'class_group_id': 'c1',
      'date': date,
      'records': [
        {'student_id': 'a', 'code': ''},
        {'student_id': 'b', 'code': 'О'},
        {'student_id': 'c', 'code': 'Н', 'reason': 'болеет'},
      ],
    });
  });

  test('queued mark_day writes of the class and date are read back, newest last wins', () {
    Presence statusOf(String code) => code.isEmpty ? Presence.present : Presence.absent;
    final out = queuedDayMarks(
      [
        (
          path: '/attendance/mark_day/',
          data: {
            'class_group_id': 'c1',
            'date': date,
            'records': [
              {'student_id': 'a', 'code': ''},
              {'student_id': 'b', 'code': 'Н'},
            ],
          },
        ),
        (
          path: '/attendance/mark_day/',
          data: {
            'class_group_id': 'c1',
            'date': date,
            'records': [
              {'student_id': 'a', 'code': 'Н'},
            ],
          },
        ),
        (
          path: '/attendance/mark_day/',
          data: {
            'class_group_id': 'c2',
            'date': date,
            'records': [
              {'student_id': 'x', 'code': 'Н'},
            ],
          },
        ),
        (path: '/attendance/mark/', data: {'lesson_id': 'l1', 'records': <Object>[]}),
      ],
      'c1',
      date,
      statusOfCode: statusOf,
    );
    expect(out.keys, {'a', 'b'});
    expect(out['a']!.status, Presence.absent);
  });

  test('at-risk: three or more absences, worst first', () {
    const all = [
      StudentWeek(studentId: 'a', name: 'Аманов', absent: 3),
      StudentWeek(studentId: 'b', name: 'Бекова', absent: 1),
      StudentWeek(studentId: 'c', name: 'Ким', absent: 5),
      StudentWeek(studentId: 'd', name: 'Алиев', absent: 3),
    ];
    expect(atRiskOf(all).map((s) => s.studentId), ['c', 'd', 'a']);
  });

  test('parses the class payloads', () {
    final ex = ClassExcuse.fromJson({
      'id': 'e1',
      'student': 's1',
      'student_name': 'Аманова Дана',
      'status': 'pending',
      'scope': 'full_days',
      'start_date': '2026-11-27',
      'end_date': '2026-11-28',
      'category': 'illness',
      'attachment': 'https://x/media/excuses/справка.JPG?sig=1',
      'requested_by_name': 'Аманова М.',
    });
    expect(ex.attachmentIsImage, isTrue);
    expect(ex.requestedBy, 'Аманова М.');
    expect(ClassExcuse.fromJson({'id': 'e2', 'attachment': 'https://x/a.pdf'}).attachmentIsImage, isFalse);
    final o = ClassOverview.fromJson({
      'student_count': 27,
      'attendance_today': {'marked': true, 'absent': 2, 'excused': 1},
      'pending_excuses': 3,
      'next_lesson': {'subject': 'Алгебра', 'starts_at': '2026-11-27T09:00:00+05:00'},
    });
    expect(o.studentCount, 27);
    expect(o.absent, 2);
    expect(o.nextSubject, 'Алгебра');
    final w = ClassWeek.fromJson({
      'attendance_rate': 94.4,
      'absent': 4,
      'tardy': 1,
      'per_student': [
        {'student_id': 'a', 'full_name': 'А', 'absent': 3},
      ],
    });
    expect(w.atRisk.single.studentId, 'a');
    expect(MyClass.fromJson({'id': 'c', 'name': '7А', 'is_homeroom': true}).isHomeroom, isTrue);
    expect(MyClass.fromJson({'id': 'c', 'name': '7А'}).isHomeroom, isFalse);
  });
}
