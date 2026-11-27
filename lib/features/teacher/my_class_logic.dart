import '../../core/json.dart';
import '../common/models.dart';
import 'teacher_models.dart';

/// A class of the signed-in teacher (`/classes/mine/`, T8).
class MyClass {
  const MyClass({required this.id, required this.name, this.isHomeroom = false, this.gradeLevel = 0});
  final String id;
  final String name;
  final bool isHomeroom;
  final int gradeLevel;

  factory MyClass.fromJson(Json j) => MyClass(
    id: j.str('id'),
    name: j.str('name'),
    isHomeroom: j.flag('is_homeroom'),
    gradeLevel: (j.number('grade_level') ?? 0).toInt(),
  );
}

/// Self check-in of a student on the day (`/attendance/check-ins/`).
class ClassCheckIn {
  const ClassCheckIn({required this.studentId, this.checkedAt, this.late = false});
  final String studentId;
  final DateTime? checkedAt;
  final bool late;

  factory ClassCheckIn.fromJson(Json j) => ClassCheckIn(
    studentId: j.str('student'),
    checkedAt: DateTime.tryParse(j.str('checked_at'))?.toLocal(),
    late: j.flag('late'),
  );
}

/// Saved homeroom mark of the day (`/attendance/day_marks/`).
class DayMark {
  const DayMark({required this.studentId, required this.status, this.code = '', this.reason = ''});
  final String studentId;
  final Presence status;
  final String code;
  final String reason;

  factory DayMark.fromJson(Json j) => DayMark(
    studentId: j.str('student_id'),
    status: presenceOf(j.str('status')),
    code: j.str('code'),
    reason: j.str('reason'),
  );
}

/// Absence request as the homeroom teacher reviews it: the shared [Excuse]
/// plus what only this card needs.
class ClassExcuse {
  const ClassExcuse({required this.excuse, this.attachmentUrl, this.className, this.requestedBy, this.relation});
  final Excuse excuse;
  final String? attachmentUrl;
  final String? className;
  final String? requestedBy;
  final String? relation;

  String get id => excuse.id;

  bool get attachmentIsImage =>
      attachmentUrl != null &&
      RegExp(r'\.(png|jpe?g|gif|webp|heic)(\?.*)?$', caseSensitive: false).hasMatch(attachmentUrl!);

  factory ClassExcuse.fromJson(Json j) => ClassExcuse(
    excuse: Excuse.fromJson(j),
    attachmentUrl: j.strOrNull('attachment'),
    className: j.strOrNull('class_name'),
    requestedBy: j.strOrNull('requested_by_name'),
    relation: j.strOrNull('requested_by_relation'),
  );
}

/// Today of the class in one glance (`/classes/{id}/overview/`).
class ClassOverview {
  const ClassOverview({
    this.studentCount = 0,
    this.attendanceMarked = false,
    this.absent = 0,
    this.excused = 0,
    this.pendingExcuses = 0,
    this.nextSubject,
    this.nextStartsAt,
  });
  final int studentCount;
  final bool attendanceMarked;
  final int absent;
  final int excused;
  final int pendingExcuses;
  final String? nextSubject;
  final DateTime? nextStartsAt;

  factory ClassOverview.fromJson(Json j) {
    final today = (j['attendance_today'] as Json?) ?? const {};
    final next = j['next_lesson'] as Json?;
    return ClassOverview(
      studentCount: (j.number('student_count') ?? 0).toInt(),
      attendanceMarked: today.flag('marked'),
      absent: (today.number('absent') ?? 0).toInt(),
      excused: (today.number('excused') ?? 0).toInt(),
      pendingExcuses: (j.number('pending_excuses') ?? 0).toInt(),
      nextSubject: next?.strOrNull('subject'),
      nextStartsAt: next == null ? null : DateTime.tryParse(next.str('starts_at'))?.toLocal(),
    );
  }
}

/// One student's week of attendance (`per_student` of `/attendance/statistics/`).
class StudentWeek {
  const StudentWeek({
    required this.studentId,
    required this.name,
    this.present = 0,
    this.absent = 0,
    this.excused = 0,
    this.tardy = 0,
  });
  final String studentId;
  final String name;
  final int present;
  final int absent;
  final int excused;
  final int tardy;

  factory StudentWeek.fromJson(Json j) => StudentWeek(
    studentId: j.str('student_id'),
    name: j.str('full_name'),
    present: (j.number('present') ?? 0).toInt(),
    absent: (j.number('absent') ?? 0).toInt(),
    excused: (j.number('excused') ?? 0).toInt(),
    tardy: (j.number('tardy') ?? 0).toInt(),
  );
}

/// The class's week: totals and who is at risk.
class ClassWeek {
  const ClassWeek({this.rate = 0, this.absent = 0, this.tardy = 0, this.students = const []});

  /// Share of present records, percent (0 when nothing was marked).
  final double rate;
  final int absent;
  final int tardy;
  final List<StudentWeek> students;

  /// «В зоне риска»: unexcused absences — [riskAbsences] lessons or more in
  /// the period, the worst first.
  List<StudentWeek> get atRisk => atRiskOf(students);

  factory ClassWeek.fromJson(Json j) => ClassWeek(
    rate: (j.number('attendance_rate') ?? 0).toDouble(),
    absent: (j.number('absent') ?? 0).toInt(),
    tardy: (j.number('tardy') ?? 0).toInt(),
    students: j.list('per_student', StudentWeek.fromJson),
  );
}

const riskAbsences = 3;

List<StudentWeek> atRiskOf(List<StudentWeek> all, {int threshold = riskAbsences}) =>
    all.where((s) => s.absent >= threshold).toList()..sort((a, b) {
      final byAbsent = b.absent.compareTo(a.absent);
      return byAbsent != 0 ? byAbsent : a.name.compareTo(b.name);
    });

/// Where a cell of the day came from.
enum DaySource {
  /// Nothing says anything yet.
  none,

  /// Check-in selfie.
  checkin,

  /// An approved absence request.
  excuse,

  /// Saved on the server as the homeroom mark.
  saved,

  /// Tapped here, waiting for the network.
  queued,
}

/// One student in the morning roll call of the homeroom.
class DayCell {
  const DayCell({
    this.status,
    this.code = '',
    this.reason = '',
    this.source = DaySource.none,
    this.checkedAt,
    this.pendingExcuse = false,
  });

  /// Null = nobody has said anything about this student yet.
  final Presence? status;
  final String code;
  final String reason;
  final DaySource source;
  final DateTime? checkedAt;

  /// A request is waiting for the teacher's decision.
  final bool pendingExcuse;

  bool get unmarked => status == null;
  bool get came => status == Presence.present || status == Presence.tardy;

  /// Already recorded on the server (or queued) — not just a suggestion.
  bool get recorded => source == DaySource.saved || source == DaySource.queued;
}

/// Morning roll call: what is known about each student on [date], strongest
/// source first — the unsent local mark, the saved homeroom mark, an approved
/// full-day request, the check-in. A pending request does not mark anyone, it
/// only sets [DayCell.pendingExcuse] so the row can say so.
Map<String, DayCell> mergeDayMarks({
  required List<RosterStudent> students,
  required String date,
  List<ClassCheckIn> checkIns = const [],
  List<Excuse> excuses = const [],
  List<DayMark> saved = const [],
  Map<String, ({Presence status, String code, String reason})> queued = const {},
  String Function(Presence)? codeFor,
}) {
  String code(Presence p) => codeFor?.call(p) ?? '';
  final checkInBy = {for (final c in checkIns) c.studentId: c};
  final savedBy = {for (final m in saved) m.studentId: m};
  bool fullDay(Excuse e) => e.scope != 'specific_lessons' && e.covers(date);
  final approved = {
    for (final e in excuses)
      if (e.status == ExcuseStatus.approved && fullDay(e)) e.studentId,
  };
  final pending = {
    for (final e in excuses)
      if (e.status == ExcuseStatus.pending && fullDay(e)) e.studentId,
  };
  return {
    for (final s in students)
      s.id: () {
        final p = pending.contains(s.id);
        final ci = checkInBy[s.id];
        final q = queued[s.id];
        if (q != null) {
          return DayCell(
            status: q.status,
            code: q.code,
            reason: q.reason,
            source: DaySource.queued,
            checkedAt: ci?.checkedAt,
            pendingExcuse: p,
          );
        }
        final m = savedBy[s.id];
        if (m != null) {
          return DayCell(
            status: m.status,
            code: m.code,
            reason: m.reason,
            source: DaySource.saved,
            checkedAt: ci?.checkedAt,
            pendingExcuse: p,
          );
        }
        if (approved.contains(s.id)) {
          return DayCell(
            status: Presence.excused,
            code: code(Presence.excused),
            source: DaySource.excuse,
            checkedAt: ci?.checkedAt,
          );
        }
        if (ci != null) {
          final late = ci.late;
          return DayCell(
            status: late ? Presence.tardy : Presence.present,
            code: late ? code(Presence.tardy) : '',
            source: DaySource.checkin,
            checkedAt: ci.checkedAt,
            pendingExcuse: p,
          );
        }
        return DayCell(pendingExcuse: p);
      }(),
  };
}

/// «Пришли 24 из 27»: present and late count as having come.
({int came, int total, int unmarked}) dayCounts(Map<String, DayCell> cells) => (
  came: cells.values.where((c) => c.came).length,
  total: cells.length,
  unmarked: cells.values.where((c) => c.unmarked).length,
);

/// Students without a mark on top, then the rest; each by surname.
List<RosterStudent> dayOrder(List<RosterStudent> students, Map<String, DayCell> cells) {
  int rank(RosterStudent s) => (cells[s.id]?.unmarked ?? true) ? 0 : 1;
  return [...students]..sort((a, b) {
    final r = rank(a).compareTo(rank(b));
    return r != 0 ? r : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
}

/// Body of `POST /attendance/mark_day/`: the student's final status as the
/// school code (`''` is present). Records that are only suggestions (check-in,
/// excuse) are sent too, so the whole class is written in one request.
Map<String, Object?> markDayBody({
  required String classId,
  required String date,
  required Map<String, DayCell> cells,
  Iterable<String>? only,
}) {
  final ids = only ?? cells.keys;
  return {
    'class_group_id': classId,
    'date': date,
    'records': [
      for (final id in ids)
        if (cells[id]?.status != null)
          {'student_id': id, 'code': cells[id]!.code, if (cells[id]!.reason.isNotEmpty) 'reason': cells[id]!.reason},
    ],
  };
}

/// Queued `mark_day` writes of the class and date, student → mark. Newer
/// writes (later in [pending]) win.
Map<String, ({Presence status, String code, String reason})> queuedDayMarks(
  Iterable<({String path, Object? data})> pending,
  String classId,
  String date, {
  required Presence Function(String code) statusOfCode,
}) {
  final out = <String, ({Presence status, String code, String reason})>{};
  for (final item in pending) {
    final data = item.data;
    if (item.path != '/attendance/mark_day/' || data is! Map) continue;
    if (data['class_group_id'] != classId || data['date'] != date) continue;
    for (final r in (data['records'] as List<dynamic>? ?? const []).whereType<Map<dynamic, dynamic>>()) {
      final code = '${r['code'] ?? ''}';
      out['${r['student_id']}'] = (status: statusOfCode(code), code: code, reason: '${r['reason'] ?? ''}');
    }
  }
  return out;
}
