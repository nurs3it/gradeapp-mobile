import '../../core/grading.dart';
import '../../core/json.dart';

/// One attendance mark of a lesson (`GET /attendance/`).
class AttRecord {
  const AttRecord({
    required this.id,
    required this.lessonId,
    required this.date,
    required this.course,
    required this.start,
    required this.status,
    this.code = '',
    this.reason = '',
  });

  final String id;
  final String lessonId;
  final String date;
  final String course;
  final String start;
  final Presence status;
  final String code;
  final String reason;

  factory AttRecord.fromJson(Json j) => AttRecord(
    id: j.str('id'),
    lessonId: j.str('lesson'),
    date: j.str('lesson_date'),
    course: j.str('lesson_course'),
    start: j.str('lesson_start_time'),
    status: presenceOf(j.str('status')),
    code: j.str('code'),
    reason: j.str('reason'),
  );
}

/// Colour class of a calendar day. [none] = no lessons (weekend, holiday).
enum DayClass { present, tardy, absent, excused, none }

/// The worst mark of the day wins: absent > tardy > excused > present.
DayClass classifyDay(Iterable<AttRecord> records) {
  var worst = DayClass.none;
  int rank(DayClass c) => switch (c) {
    DayClass.none => 0,
    DayClass.present => 1,
    DayClass.excused => 2,
    DayClass.tardy => 3,
    DayClass.absent => 4,
  };
  for (final r in records) {
    final c = switch (r.status) {
      Presence.present => DayClass.present,
      Presence.tardy => DayClass.tardy,
      Presence.absent => DayClass.absent,
      Presence.excused => DayClass.excused,
    };
    if (rank(c) > rank(worst)) worst = c;
  }
  return worst;
}

/// `YYYY-MM-DD` → class of that day.
Map<String, DayClass> classifyDays(Iterable<AttRecord> records) {
  final byDay = <String, List<AttRecord>>{};
  for (final r in records) {
    (byDay[r.date] ??= []).add(r);
  }
  return {for (final e in byDay.entries) e.key: classifyDay(e.value)};
}

/// Cells of a month grid, Monday first: leading nulls, then every day.
List<DateTime?> monthCells(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final days = DateTime(month.year, month.month + 1, 0).day;
  return [
    for (var i = 1; i < first.weekday; i++) null,
    for (var d = 1; d <= days; d++) DateTime(month.year, month.month, d),
  ];
}

/// First day of the month [delta] months from [month].
DateTime shiftMonth(DateTime month, int delta) => DateTime(month.year, month.month + delta, 1);

/// Unexcused absences, newest first: what the parent can still explain.
List<AttRecord> absencesOf(Iterable<AttRecord> records) =>
    records.where((r) => r.status == Presence.absent || r.status == Presence.excused).toList()
      ..sort((a, b) => '${b.date}${b.start}'.compareTo('${a.date}${a.start}'));

/// Quarter attendance from `/attendance/statistics/`.
class AttStats {
  const AttStats({this.rate, this.total = 0, this.absent = 0, this.tardy = 0, this.excused = 0});

  /// Percent of lessons attended, null when there were none.
  final double? rate;
  final int total;
  final int absent;
  final int tardy;
  final int excused;

  factory AttStats.fromJson(Json j) => AttStats(
    rate: (j.number('total') ?? 0) == 0 ? null : j.number('attendance_rate')?.toDouble(),
    total: (j.number('total') ?? 0).toInt(),
    absent: (j.number('absent') ?? 0).toInt(),
    tardy: (j.number('tardy') ?? 0).toInt(),
    excused: (j.number('excused') ?? 0).toInt(),
  );
}
