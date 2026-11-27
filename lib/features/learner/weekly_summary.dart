import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../common/models.dart';

/// `verdict.code` of the weekly summary (B3), in the server's priority order.
enum WeekVerdictCode { empty, absences, dip, overdue, great, steady }

/// Unknown codes read as «steady»: a new server code never breaks the screen.
WeekVerdictCode weekVerdictCodeOf(String code) =>
    WeekVerdictCode.values.asNameMap()[code] ?? WeekVerdictCode.steady;

class WeekVerdict {
  const WeekVerdict({required this.code, this.courseName});
  final WeekVerdictCode code;
  final String? courseName;

  factory WeekVerdict.fromJson(Json j) =>
      WeekVerdict(code: weekVerdictCodeOf(j.str('code')), courseName: j.strOrNull('course_name'));
}

class WeekAttendance {
  const WeekAttendance({this.days = 0, this.daysOnTime = 0, this.absent = 0, this.tardy = 0, this.excused = 0});
  final int days;
  final int daysOnTime;
  final int absent;
  final int tardy;
  final int excused;

  factory WeekAttendance.fromJson(Json j) => WeekAttendance(
    days: (j.number('days') ?? 0).toInt(),
    daysOnTime: (j.number('days_on_time') ?? 0).toInt(),
    absent: (j.number('absent') ?? 0).toInt(),
    tardy: (j.number('tardy') ?? 0).toInt(),
    excused: (j.number('excused') ?? 0).toInt(),
  );
}

class WeekSubject {
  const WeekSubject({required this.courseId, required this.name, this.avg, this.prevAvg, this.items = const []});
  final String courseId;
  final String name;
  final double? avg;
  final double? prevAvg;
  final List<({String id, String date, String value, String kind})> items;

  /// Change against the previous week, null when either week has no marks.
  double? get delta => avg == null || prevAvg == null ? null : avg! - prevAvg!;

  factory WeekSubject.fromJson(Json j) => WeekSubject(
    courseId: j.str('course_id'),
    name: j.str('name'),
    avg: j.number('avg')?.toDouble(),
    prevAvg: j.number('prev_avg')?.toDouble(),
    items: j.list('items', (i) => (id: i.str('id'), date: i.str('date'), value: i.str('value'), kind: i.str('kind'))),
  );
}

class WeekHomework {
  const WeekHomework({this.assigned = 0, this.done = 0, this.overdue = 0});
  final int assigned;
  final int done;
  final int overdue;

  factory WeekHomework.fromJson(Json j) => WeekHomework(
    assigned: (j.number('assigned') ?? 0).toInt(),
    done: (j.number('done') ?? 0).toInt(),
    overdue: (j.number('overdue') ?? 0).toInt(),
  );
}

class WeekFeedback {
  const WeekFeedback({required this.id, required this.date, required this.text, this.tags = const [], this.from = ''});
  final String id;
  final String date;
  final String text;
  final List<String> tags;
  final String from;

  bool get positive => tags.isEmpty || tags.first != 'negative';

  factory WeekFeedback.fromJson(Json j) => WeekFeedback(
    id: j.str('id'),
    date: j.str('date'),
    text: j.str('text'),
    tags: j.strings('tags'),
    from: j.str('from_name'),
  );
}

class WeekAssessment {
  const WeekAssessment({required this.courseName, required this.kind, required this.date, this.title = ''});
  final String courseName;

  /// `sor` / `soch`.
  final String kind;
  final String date;
  final String title;

  factory WeekAssessment.fromJson(Json j) => WeekAssessment(
    courseName: j.str('course_name'),
    kind: j.str('kind'),
    date: j.str('date'),
    title: j.str('title'),
  );
}

class WeekEvent {
  const WeekEvent({required this.id, required this.title, required this.startDate});
  final String id;
  final String title;
  final String startDate;

  factory WeekEvent.fromJson(Json j) =>
      WeekEvent(id: j.str('id'), title: j.str('title'), startDate: j.str('start_date'));
}

/// `GET /students/{id}/weekly-summary/?week=` (B3).
class WeeklySummary {
  const WeeklySummary({
    required this.week,
    required this.from,
    required this.to,
    required this.empty,
    required this.verdict,
    this.attendance = const WeekAttendance(),
    this.gradesCount = 0,
    this.subjects = const [],
    this.homework = const WeekHomework(),
    this.feedback = const [],
    this.assessments = const [],
    this.events = const [],
    this.checkinStreak,
    this.homeworkStreak,
  });

  final String week;
  final String from;
  final String to;
  final bool empty;
  final WeekVerdict verdict;
  final WeekAttendance attendance;
  final int gradesCount;
  final List<WeekSubject> subjects;
  final WeekHomework homework;
  final List<WeekFeedback> feedback;
  final List<WeekAssessment> assessments;
  final List<WeekEvent> events;
  final int? checkinStreak;
  final int? homeworkStreak;

  factory WeeklySummary.fromJson(Json j) {
    final grades = (j['grades'] as Json?) ?? const {};
    final upcoming = (j['upcoming'] as Json?) ?? const {};
    final streaks = j['streaks'] as Json?;
    return WeeklySummary(
      week: j.str('week'),
      from: j.str('date_from'),
      to: j.str('date_to'),
      empty: j.flag('empty'),
      verdict: WeekVerdict.fromJson((j['verdict'] as Json?) ?? const {}),
      attendance: WeekAttendance.fromJson((j['attendance'] as Json?) ?? const {}),
      gradesCount: (grades.number('count') ?? 0).toInt(),
      subjects: grades.list('by_subject', WeekSubject.fromJson),
      homework: WeekHomework.fromJson((j['homework'] as Json?) ?? const {}),
      feedback: j.list('feedback', WeekFeedback.fromJson),
      assessments: upcoming.list('assessments', WeekAssessment.fromJson),
      events: upcoming.list('events', WeekEvent.fromJson),
      checkinStreak: streaks?.number('checkin')?.toInt(),
      homeworkStreak: streaks?.number('homework')?.toInt(),
    );
  }
}

typedef SummaryArgs = ({String studentId, String week});

final weeklySummaryProvider = StreamProvider.family<WeeklySummary, SummaryArgs>(
  (ref, a) => cachedGet(
    ref,
    '/students/${a.studentId}/weekly-summary/',
    query: {'week': a.week},
    parse: (d) => WeeklySummary.fromJson(d as Json),
  ),
);

// ---- ISO weeks (pure, tested) ----

/// `2026-W48` for the ISO week containing [d].
String isoWeekId(DateTime d) {
  final day = DateTime.utc(d.year, d.month, d.day);
  final thursday = day.add(Duration(days: 4 - day.weekday));
  final jan1 = DateTime.utc(thursday.year, 1, 1);
  final week = thursday.difference(jan1).inDays ~/ 7 + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

/// Monday of an ISO week id, null for a malformed id.
DateTime? mondayOfIsoWeek(String id) {
  final m = RegExp(r'^(\d{4})-W(\d{2})$').firstMatch(id);
  if (m == null) return null;
  final year = int.parse(m.group(1)!);
  final week = int.parse(m.group(2)!);
  final jan4 = DateTime.utc(year, 1, 4);
  final monday = jan4.subtract(Duration(days: jan4.weekday - 1)).add(Duration(days: (week - 1) * 7));
  return DateTime(monday.year, monday.month, monday.day);
}

/// The week [delta] weeks away from [id] (negative = earlier).
String shiftIsoWeek(String id, int delta) {
  final monday = mondayOfIsoWeek(id) ?? mondayOfIsoWeek(isoWeekId(DateTime.now()))!;
  return isoWeekId(DateTime(monday.year, monday.month, monday.day + delta * 7, 12));
}

/// Weeks the summary can be paged back through.
const summaryWeeksBack = 26;

/// «Твоя неделя» for a student: Friday after the last lesson, and weekends.
bool weekCardVisible(DateTime now, List<Lesson> lessonsToday) {
  if (now.weekday >= DateTime.saturday) return true;
  if (now.weekday != DateTime.friday) return false;
  final live = lessonsToday.where((l) => !l.isCancelled);
  return live.every((l) => l.isPast(now));
}

/// Arrow of the week-to-week change: up, down or flat (< 0.1 is noise).
int deltaSign(double? delta) => delta == null || delta.abs() < 0.1 ? 0 : (delta > 0 ? 1 : -1);
