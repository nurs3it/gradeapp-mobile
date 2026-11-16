import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/grading.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/parent/verdict.dart';

const grading = Grading(min: 2, max: 5, passing: 3, qualityMin: 4, workTypes: [], attendanceCodes: []);

Lesson lesson(String id, String start, String end, {LessonStatus status = LessonStatus.scheduled}) =>
    Lesson(id: id, courseId: 'c$id', subject: 'S$id', date: '2026-11-16', start: start, end: end, status: status);

final lessons = [lesson('1', '08:30', '09:15'), lesson('2', '09:25', '10:10'), lesson('3', '10:25', '11:10')];

CheckInStatus checkIn({bool checkedIn = false, bool late = false, bool consent = true}) => CheckInStatus(
  enabled: true,
  windowStart: '07:30',
  windowEnd: '08:30',
  windowOpen: false,
  geofence: false,
  consent: consent,
  checkedIn: checkedIn,
  checkedAt: checkedIn ? DateTime(2026, 11, 16, late ? 8 : 7, late ? 41 : 52) : null,
  late: late,
);

LearnerDay day({
  CheckInStatus? ci,
  Map<String, AttendanceMark> attendance = const {},
  List<Excuse> excuses = const [],
  List<Grade> grades = const [],
  List<Lesson>? ls,
  bool consent = true,
}) => LearnerDay(
  date: '2026-11-16',
  studentId: 's',
  studentName: 'A',
  photoConsent: consent,
  lessons: ls ?? lessons,
  attendance: attendance,
  checkIn: ci,
  excuses: excuses,
  recentGrades: grades,
);

Excuse excuse(ExcuseStatus status, {String scope = 'full_days', List<String> lessonIds = const []}) => Excuse(
  id: 'e',
  studentId: 's',
  scope: scope,
  startDate: '2026-11-16',
  endDate: '2026-11-16',
  category: 'illness',
  status: status,
  lessonIds: lessonIds,
);

final noon = DateTime(2026, 11, 16, 9, 40);

void main() {
  test('arrived, lessons going, nothing wrong → ok with counts', () {
    final v = verdictOf(day(ci: checkIn(checkedIn: true)), noon, grading: grading);
    expect(v.level, VerdictLevel.ok);
    expect(v.lessonsDone, 1);
    expect(v.lessonsTotal, 3);
    expect(v.arrivedAt, isNotNull);
  });

  test('no check-in after lessons started, no request → alarm', () {
    expect(verdictOf(day(ci: checkIn()), noon, grading: grading).level, VerdictLevel.alarm);
  });

  test('no alarm before the first lesson, with a request, or when a teacher saw the child', () {
    expect(verdictOf(day(ci: checkIn()), DateTime(2026, 11, 16, 8), grading: grading).level, VerdictLevel.ok);
    expect(verdictOf(day(ci: checkIn(), excuses: [excuse(ExcuseStatus.pending)]), noon, grading: grading).level, VerdictLevel.ok);
    final seen = day(ci: checkIn(), attendance: const {'1': AttendanceMark(status: Presence.present)});
    expect(verdictOf(seen, noon, grading: grading).level, VerdictLevel.ok);
  });

  test('absent without reason → question with «Объяснить»; explained by request → ok', () {
    const marks = {'1': AttendanceMark(status: Presence.absent)};
    final v = verdictOf(day(ci: checkIn(checkedIn: true), attendance: marks), noon, grading: grading);
    expect(v.level, VerdictLevel.question);
    expect(v.attention.single.kind, AttentionKind.absentNoReason);
    expect(v.attention.single.lesson!.id, '1');

    final explained = day(
      ci: checkIn(checkedIn: true),
      attendance: marks,
      excuses: [excuse(ExcuseStatus.pending, scope: 'specific_lessons', lessonIds: ['1'])],
    );
    expect(verdictOf(explained, noon, grading: grading).level, VerdictLevel.ok);
  });

  test('late check-in and a low grade today are questions', () {
    expect(verdictOf(day(ci: checkIn(checkedIn: true, late: true)), noon, grading: grading).level, VerdictLevel.question);
    final low = const Grade(id: 'g', studentId: 's', courseId: 'c1', courseName: 'S1', value: 2, type: 'fo', date: '2026-11-16');
    final v = verdictOf(day(ci: checkIn(checkedIn: true), grades: [low]), noon, grading: grading);
    expect(v.level, VerdictLevel.question);
    expect(v.lowGrades, [low]);
  });

  test('missing photo consent and declined request need an action', () {
    final v = verdictOf(day(ci: checkIn(consent: false), consent: false), noon, grading: grading);
    expect(v.level, VerdictLevel.action);
    expect(v.attention.map((a) => a.kind), contains(AttentionKind.noConsent));
    final rejected = verdictOf(day(ci: checkIn(checkedIn: true), excuses: [excuse(ExcuseStatus.rejected)]), noon, grading: grading);
    expect(rejected.level, VerdictLevel.action);
  });

  test('cancelled-only day and empty day → no lessons', () {
    expect(verdictOf(day(ls: const []), noon, grading: grading).level, VerdictLevel.noLessons);
    final cancelled = [lesson('1', '08:30', '09:15', status: LessonStatus.cancelled)];
    expect(verdictOf(day(ls: cancelled), noon, grading: grading).level, VerdictLevel.noLessons);
  });

  test('school without check-in never raises the alarm', () {
    expect(verdictOf(day(ci: checkIn()), noon, grading: grading, checkinEnabled: false).level, VerdictLevel.ok);
  });
}
