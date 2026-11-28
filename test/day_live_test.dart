import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/platform/day_live.dart';

Lesson lesson(String id, String start, String end, {LessonStatus status = LessonStatus.scheduled}) => Lesson(
  id: id,
  courseId: 'c$id',
  subject: 'S$id',
  date: '2026-11-30',
  start: start,
  end: end,
  room: '20$id',
  status: status,
);

void main() {
  final day = [
    lesson('2', '09:25', '10:10'),
    lesson('1', '08:30', '09:15'),
    lesson('3', '10:20', '11:05'),
    lesson('4', '11:15', '12:00', status: LessonStatus.cancelled),
  ];
  DateTime at(int h, int m) => DateTime(2026, 11, 30, h, m);
  int unix(int h, int m) => at(h, m).millisecondsSinceEpoch ~/ 1000;

  test('before the first lesson: the first one, all three left', () {
    final s = dayLiveState(day, at(8, 0))!;
    expect(s.phase, 'before');
    expect(s.subject, 'S1');
    expect(s.startsAt, unix(8, 30));
    expect(s.nextSubject, 'S2');
    expect(s.left, 3);
  });

  test('during a lesson: it, the bell, what comes next', () {
    final s = dayLiveState(day, at(9, 30))!;
    expect(s.phase, 'lesson');
    expect(s.subject, 'S2');
    expect(s.room, '202');
    expect(s.endsAt, unix(10, 10));
    expect(s.nextSubject, 'S3');
    expect(s.nextStartsAt, unix(10, 20));
    expect(s.left, 2);
  });

  test('in a break: the next lesson; after the last (cancelled ignored): done', () {
    expect(dayLiveState(day, at(10, 15))!.phase, 'break');
    expect(dayLiveState(day, at(10, 15))!.subject, 'S3');
    final done = dayLiveState(day, at(11, 10))!;
    expect(done.phase, 'done');
    expect(done.left, 0);
    expect(dayLiveState(const [], at(9, 0)), isNull);
  });

  test('the app starts it from an hour before the first lesson until the end', () {
    expect(shouldStartDay(day, at(7, 20)), isFalse);
    expect(shouldStartDay(day, at(7, 31)), isTrue);
    expect(shouldStartDay(day, at(11, 10)), isFalse);
  });

  test('content state keys match the B6 contract', () {
    expect(dayLiveState(day, at(9, 30))!.toJson().keys.toSet(),
        {'phase', 'subject', 'room', 'startsAt', 'endsAt', 'nextSubject', 'nextStartsAt', 'left'});
  });
}
