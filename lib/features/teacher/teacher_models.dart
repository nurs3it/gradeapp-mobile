import '../../core/json.dart';
import '../common/models.dart';

/// One lesson of the teacher with what is already filled in (`/teacher/todo/`).
class TodoLesson {
  const TodoLesson({
    required this.lesson,
    this.attendanceMarked = false,
    this.hasHomework = false,
    this.hasGrades = false,
    this.missing = const [],
  });

  final Lesson lesson;
  final bool attendanceMarked;
  final bool hasHomework;
  final bool hasGrades;

  /// attendance / topic / homework / grades.
  final List<String> missing;

  bool get needsAttendance => missing.contains('attendance');
  bool get needsTopic => missing.contains('topic');

  /// Debts that close the day: attendance and topic (homework and grades are
  /// not required on every lesson).
  List<String> get debts => missing.where((m) => m == 'attendance' || m == 'topic').toList();

  factory TodoLesson.fromJson(Json j) => TodoLesson(
    lesson: Lesson.fromJson(j),
    attendanceMarked: j.flag('attendance_marked'),
    hasHomework: j.flag('has_homework'),
    hasGrades: j.flag('has_grades'),
    missing: j.strings('missing'),
  );
}

class TeacherDay {
  const TeacherDay({required this.today, required this.overdue, this.unmarked = 0, this.noTopic = 0, this.excuses = 0});
  final List<TodoLesson> today;

  /// Started lessons of the last 14 days without attendance or topic.
  final List<TodoLesson> overdue;
  final int unmarked;
  final int noTopic;
  final int excuses;

  factory TeacherDay.fromJson(Json j) {
    final counts = (j['counts'] as Json?) ?? const {};
    return TeacherDay(
      today: j.list('today', TodoLesson.fromJson)..sort((a, b) => a.lesson.start.compareTo(b.lesson.start)),
      overdue: j.list('overdue', TodoLesson.fromJson),
      unmarked: (counts.number('unmarked') ?? 0).toInt(),
      noTopic: (counts.number('no_topic') ?? 0).toInt(),
      excuses: (counts.number('excuses') ?? 0).toInt(),
    );
  }
}

class RosterStudent {
  const RosterStudent({required this.id, required this.firstName, required this.lastName, this.avatarUrl, this.classId, this.className});
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? classId;
  final String? className;

  /// «Фамилия Имя», as in the journal.
  String get name => [lastName, firstName].where((s) => s.isNotEmpty).join(' ');

  factory RosterStudent.fromJson(Json j) {
    final u = (j['user'] as Json?) ?? const {};
    return RosterStudent(
      id: j.str('id'),
      firstName: u.str('first_name'),
      lastName: u.str('last_name'),
      avatarUrl: u.strOrNull('avatar_url'),
      classId: j.strOrNull('class_group'),
      className: j.strOrNull('class_group_name'),
    );
  }
}

/// Starting value of one student in a lesson marker, with where it came from.
class AttendanceDefault {
  const AttendanceDefault({required this.status, this.code = '', this.source = '', this.checkedAt});
  final Presence status;
  final String code;

  /// lesson (saved) / homeroom / checkin.
  final String source;
  final DateTime? checkedAt;

  factory AttendanceDefault.fromJson(Json j) => AttendanceDefault(
    status: presenceOf(j.str('status')),
    code: j.str('code'),
    source: j.str('source'),
    checkedAt: DateTime.tryParse(j.str('checked_at'))?.toLocal(),
  );
}

class LessonDefaults {
  const LessonDefaults({this.students = const {}, this.sochLocked = false});
  final Map<String, AttendanceDefault> students;
  final bool sochLocked;

  factory LessonDefaults.fromJson(Json j) => LessonDefaults(
    students: {for (final s in j.list('students', (s) => s)) s.str('student_id'): AttendanceDefault.fromJson(s)},
    sochLocked: j.flag('soch_locked'),
  );
}

/// Roster of a lesson (T2 fix): students of *every* class of the lesson —
/// the main one and `additional_class_groups` of a joint lesson — in the
/// lesson's class order, each class sorted by surname, no duplicates.
List<RosterStudent> mergeRoster(List<String> classIds, Map<String, List<RosterStudent>> byClass) {
  final seen = <String>{};
  final out = <RosterStudent>[];
  for (final id in classIds) {
    final list = [...?byClass[id]]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    for (final s in list) {
      if (seen.add(s.id)) {
        out.add(
          RosterStudent(
            id: s.id,
            firstName: s.firstName,
            lastName: s.lastName,
            avatarUrl: s.avatarUrl,
            classId: s.classId ?? id,
            className: s.className,
          ),
        );
      }
    }
  }
  return out;
}

/// Roll-call order inside a class (T2): checked in by selfie first, then the
/// rest, each by surname.
List<RosterStudent> rollCallOrder(List<RosterStudent> roster, Map<String, AttendanceDefault> defaults) {
  int group(RosterStudent s) => defaults[s.id]?.source == 'checkin' && defaults[s.id]?.status != Presence.absent ? 0 : 1;
  final classes = <String?>[];
  for (final s in roster) {
    if (!classes.contains(s.classId)) classes.add(s.classId);
  }
  return [
    for (final cls in classes)
      ...(roster.where((s) => s.classId == cls).toList()
        ..sort((a, b) {
          final gcmp = group(a).compareTo(group(b));
          return gcmp != 0 ? gcmp : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        })),
  ];
}
