import '../../core/json.dart';
import '../learner/models.dart';

/// One lesson of the teacher with what is already filled in.
class TodoLesson {
  const TodoLesson({
    required this.lessonId,
    required this.date,
    required this.start,
    required this.end,
    required this.status,
    required this.subject,
    required this.classGroupName,
    required this.room,
    required this.topic,
    required this.missing,
  });

  final String lessonId;
  final String date;
  final String start;
  final String end;
  final LessonStatus status;
  final String subject;
  final String classGroupName;
  final String? room;
  final String topic;

  /// attendance / topic / homework / grades.
  final List<String> missing;

  factory TodoLesson.fromJson(Json j) => TodoLesson(
        lessonId: j.str('lesson_id'),
        date: j.str('date'),
        start: j.str('start_time'),
        end: j.str('end_time'),
        status: Lesson.fromJson({'status': j['status']}).status,
        subject: j.str('subject'),
        classGroupName: j.str('class_group_name'),
        room: j.strOrNull('room_name'),
        topic: j.str('topic'),
        missing: j.strings('missing'),
      );
}

class TeacherDay {
  const TeacherDay({required this.today, required this.overdue});
  final List<TodoLesson> today;

  /// Started lessons of the last 14 days without attendance or topic.
  final List<TodoLesson> overdue;

  factory TeacherDay.fromJson(Json j) => TeacherDay(
        today: j.list('today', TodoLesson.fromJson),
        overdue: j.list('overdue', TodoLesson.fromJson),
      );
}

class RosterStudent {
  const RosterStudent({required this.id, required this.name, required this.avatarUrl});
  final String id;
  final String name;
  final String? avatarUrl;

  factory RosterStudent.fromJson(Json j) {
    final c = Child.fromJson(j);
    return RosterStudent(id: c.id, name: c.fullName, avatarUrl: c.avatarUrl);
  }
}

/// School attendance code (Н/Б/П/О…) mapped to a status.
class AttendanceCode {
  const AttendanceCode({required this.code, required this.name, required this.status});
  final String code;
  final String name;
  final Presence status;

  factory AttendanceCode.fromJson(Json j) => AttendanceCode(
        code: j.str('code'),
        name: j.str('name'),
        status: presenceOf(j.str('status')),
      );
}

class WorkType {
  const WorkType({required this.code, required this.name, required this.kind});
  final String code;
  final String name;
  final String kind; // formative / sor / soch / other
  factory WorkType.fromJson(Json j) =>
      WorkType(code: j.str('code'), name: j.str('name'), kind: j.str('kind'));
}

/// Effective grading config of the active school (KZ preset + override).
class Grading {
  const Grading({
    required this.min,
    required this.max,
    required this.passing,
    required this.workTypes,
    required this.attendanceCodes,
  });

  final int min;
  final int max;
  final int passing;
  final List<WorkType> workTypes;
  final List<AttendanceCode> attendanceCodes;

  /// Work types a teacher grades inside a lesson (СОР/СОЧ have own flows).
  List<WorkType> get lessonTypes =>
      workTypes.where((w) => w.kind != 'sor' && w.kind != 'soch').toList();

  factory Grading.fromSchool(Json school) {
    final cfg = (school['grading_config'] ?? school['grading_system'] ?? const <String, dynamic>{}) as Json;
    final max = cfg.number('max')?.toInt() ?? 5;
    return Grading(
      min: cfg.number('min')?.toInt() ?? 1,
      max: max,
      passing: cfg.number('passing')?.toInt() ?? (max * 0.6).ceil(),
      workTypes: cfg.list('work_types', WorkType.fromJson),
      attendanceCodes: cfg.list('attendance_codes', AttendanceCode.fromJson),
    );
  }
}

/// Starting value of one student in a lesson marker, with where it came from.
class AttendanceDefault {
  const AttendanceDefault({required this.status, required this.code, required this.source});
  final Presence status;
  final String code;

  /// lesson (saved) / homeroom / checkin.
  final String source;

  factory AttendanceDefault.fromJson(Json j) => AttendanceDefault(
        status: presenceOf(j.str('status')),
        code: j.str('code'),
        source: j.str('source'),
      );
}
