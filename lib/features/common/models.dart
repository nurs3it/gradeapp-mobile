import '../../core/grading.dart';
import '../../core/json.dart';

export '../../core/grading.dart' show Presence, presenceOf;

/// `HH:MM[:SS]` → minutes since midnight.
int minutesOf(String hhmm) {
  final p = hhmm.split(':');
  return p.length < 2 ? 0 : (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
}

String hm(String hhmmss) => hhmmss.length >= 5 ? hhmmss.substring(0, 5) : hhmmss;

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Monday of the week containing [d].
DateTime mondayOf(DateTime d) => dateOnly(d).subtract(Duration(days: d.weekday - 1));

enum LessonStatus { scheduled, inProgress, completed, moved, cancelled }

LessonStatus lessonStatusOf(String s) => switch (s) {
  'in_progress' => LessonStatus.inProgress,
  'completed' => LessonStatus.completed,
  'moved' => LessonStatus.moved,
  'cancelled' => LessonStatus.cancelled,
  _ => LessonStatus.scheduled,
};

class Lesson {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.subject,
    required this.date,
    required this.start,
    required this.end,
    this.room,
    this.teacherName,
    this.classGroupId,
    this.classGroupName,
    this.additionalClassGroups = const [],
    this.additionalClassGroupNames = const [],
    this.subgroup = '',
    this.status = LessonStatus.scheduled,
    this.topic = '',
    this.summary = '',
    this.teacherId,
    this.isSubstitution = false,
    this.courseTeacherName,
  });

  final String id;
  final String courseId;
  final String subject;
  final String date;
  final String start;
  final String end;
  final String? room;
  final String? teacherName;
  final String? teacherId;

  /// T9: the lesson is taught by someone other than the course teacher.
  final bool isSubstitution;

  /// The course's own teacher — whom the substitute stands in for.
  final String? courseTeacherName;
  final String? classGroupId;
  final String? classGroupName;

  /// Joint lesson: other classes taught together with [classGroupId].
  final List<String> additionalClassGroups;

  /// Names of [additionalClassGroups] when the API sends them (teacher day).
  final List<String> additionalClassGroupNames;

  /// Subgroup label («1 подгруппа»), empty for the whole class.
  final String subgroup;
  final LessonStatus status;
  final String topic;
  final String summary;

  bool get isCancelled => status == LessonStatus.cancelled || status == LessonStatus.moved;
  bool get isJoint => additionalClassGroups.isNotEmpty;

  /// Every class whose students sit in this lesson.
  List<String> get classIds => [?classGroupId, ...additionalClassGroups];

  /// «1A», «1A + 1B» for a joint lesson, or «1A +1» when the API sent only
  /// the ids of the other classes.
  String? get classLabel {
    if (classGroupName == null || !isJoint) return classGroupName;
    if (additionalClassGroupNames.isNotEmpty) return [classGroupName!, ...additionalClassGroupNames].join(' + ');
    return '$classGroupName +${additionalClassGroups.length}';
  }

  int get startMin => minutesOf(start);
  int get endMin => minutesOf(end);

  DateTime startsAt() => DateTime.parse(date).add(Duration(minutes: startMin));
  DateTime endsAt() => DateTime.parse(date).add(Duration(minutes: endMin));

  bool isNow(DateTime now) => !now.isBefore(startsAt()) && now.isBefore(endsAt());
  bool isPast(DateTime now) => !now.isBefore(endsAt());

  /// Colour key: the course (stable per subject in a class).
  String get colorKey => subject;

  Lesson copyWith({LessonStatus? status, String? topic, String? summary}) => Lesson(
    id: id,
    courseId: courseId,
    subject: subject,
    date: date,
    start: start,
    end: end,
    room: room,
    teacherName: teacherName,
    teacherId: teacherId,
    isSubstitution: isSubstitution,
    courseTeacherName: courseTeacherName,
    classGroupId: classGroupId,
    classGroupName: classGroupName,
    additionalClassGroups: additionalClassGroups,
    additionalClassGroupNames: additionalClassGroupNames,
    subgroup: subgroup,
    status: status ?? this.status,
    topic: topic ?? this.topic,
    summary: summary ?? this.summary,
  );

  factory Lesson.fromJson(Json j) => Lesson(
    id: j.strOrNull('id') ?? j.str('lesson_id'),
    courseId: j.strOrNull('course') ?? j.str('course_id'),
    subject: j.strOrNull('subject_name') ?? j.strOrNull('course_name') ?? j.strOrNull('subject') ?? '—',
    date: j.str('date'),
    start: j.str('start_time'),
    end: j.str('end_time'),
    room: j.strOrNull('room_name') ?? j.strOrNull('classroom'),
    teacherName: j.strOrNull('teacher_name'),
    teacherId: j.strOrNull('teacher'),
    isSubstitution: j.flag('is_substitution'),
    courseTeacherName: j.strOrNull('course_teacher_name'),
    classGroupId: j.strOrNull('class_group_id'),
    classGroupName: j.strOrNull('class_group_name'),
    additionalClassGroups: j.strings('additional_class_groups'),
    additionalClassGroupNames: j.strings('additional_class_group_names'),
    subgroup: j.str('subgroup'),
    status: lessonStatusOf(j.str('status')),
    topic: j.str('topic'),
    summary: j.str('summary'),
  );
}

class Grade {
  const Grade({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseName,
    required this.value,
    required this.type,
    required this.date,
    this.maxValue,
    this.comment = '',
    this.lessonId,
    this.termId,
    this.createdAt,
    this.teacherName,
  });

  final String id;
  final String studentId;
  final String courseId;
  final String courseName;
  final num value;
  final num? maxValue;
  final String type;
  final String comment;
  final String date;
  final String? lessonId;
  final String? termId;
  final DateTime? createdAt;
  final String? teacherName;

  bool get isScore => maxValue != null && maxValue! > 0;
  double? get percent => isScore ? value / maxValue! * 100 : null;

  /// «9» or «18/25».
  String get display => isScore ? '${fmtNum(value)}/${fmtNum(maxValue!)}' : fmtNum(value);

  GradeInput get input => (value: value, maxValue: maxValue, type: type);

  factory Grade.fromJson(Json j) => Grade(
    id: j.str('id'),
    studentId: j.strOrNull('student_id') ?? j.str('student'),
    courseId: j.strOrNull('course_id') ?? j.str('course'),
    courseName: j.strOrNull('course_name') ?? '—',
    value: j.number('value') ?? 0,
    maxValue: j.number('max_value'),
    type: j.str('type'),
    comment: j.str('comment'),
    date: j.str('date'),
    lessonId: j.strOrNull('lesson'),
    termId: j.strOrNull('term'),
    createdAt: DateTime.tryParse(j.str('created_at'))?.toLocal(),
    teacherName: j.strOrNull('recorded_by_name'),
  );
}

class Attachment {
  const Attachment({required this.url, required this.name});
  final String? url;
  final String name;

  bool get isImage => RegExp(r'\.(png|jpe?g|gif|webp|heic)$', caseSensitive: false).hasMatch(name);

  factory Attachment.fromJson(Json j) => Attachment(
    url: j.strOrNull('file_url') ?? j.strOrNull('file'),
    name: j.strOrNull('original_name') ?? j.str('name'),
  );
}

class Homework {
  const Homework({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.description,
    required this.dueDate,
    this.minutes,
    this.attachments = const [],
    this.isDone = false,
    this.lessonId,
    this.teacherName,
    this.className,
  });

  final String id;
  final String courseId;
  final String courseName;
  final String title;
  final String description;
  final String dueDate;
  final int? minutes;
  final List<Attachment> attachments;
  final bool isDone;
  final String? lessonId;
  final String? teacherName;
  final String? className;

  Homework withDone(bool done) => Homework(
    id: id,
    courseId: courseId,
    courseName: courseName,
    title: title,
    description: description,
    dueDate: dueDate,
    minutes: minutes,
    attachments: attachments,
    isDone: done,
    lessonId: lessonId,
    teacherName: teacherName,
    className: className,
  );

  factory Homework.fromJson(Json j) => Homework(
    id: j.str('id'),
    courseId: j.str('course'),
    courseName: j.str('course_name'),
    title: j.str('title'),
    description: j.str('description'),
    dueDate: j.str('due_date'),
    minutes: j.number('estimated_minutes')?.toInt(),
    attachments: j.list('attachments', Attachment.fromJson),
    isDone: j.flag('is_done'),
    lessonId: j.strOrNull('lesson'),
    teacherName: j.strOrNull('created_by_name'),
    className: j.strOrNull('class_group_name'),
  );
}

/// One attendance mark of a learner (`/today/` → attendance).
class AttendanceMark {
  const AttendanceMark({required this.status, this.code = '', this.reason = '', this.source = ''});
  final Presence status;
  final String code;
  final String reason;

  /// lesson / homeroom / checkin / excuse.
  final String source;

  factory AttendanceMark.fromJson(Json j) => AttendanceMark(
    status: presenceOf(j.str('status')),
    code: j.str('code'),
    reason: j.str('reason'),
    source: j.str('source'),
  );
}

class CheckInStatus {
  const CheckInStatus({
    required this.enabled,
    required this.windowStart,
    required this.windowEnd,
    required this.windowOpen,
    required this.geofence,
    required this.consent,
    required this.checkedIn,
    this.checkedAt,
    this.late = false,
  });

  final bool enabled;
  final String windowStart;
  final String windowEnd;
  final bool windowOpen;
  final bool geofence;
  final bool consent;
  final bool checkedIn;
  final DateTime? checkedAt;
  final bool late;

  factory CheckInStatus.fromJson(Json j) => CheckInStatus(
    enabled: j.flag('enabled'),
    windowStart: hm(j.str('window_start')),
    windowEnd: hm(j.str('window_end')),
    windowOpen: j.flag('window_open'),
    geofence: j.flag('geofence'),
    consent: j.flag('consent'),
    checkedIn: j.flag('checked_in'),
    checkedAt: DateTime.tryParse(j.str('checked_at'))?.toLocal(),
    late: j.flag('late'),
  );
}

enum ExcuseStatus { pending, approved, rejected, cancelled }

class Excuse {
  const Excuse({
    required this.id,
    required this.studentId,
    required this.scope,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.status,
    this.reason = '',
    this.reviewNote = '',
    this.lessonIds = const [],
    this.studentName,
    this.createdAt,
  });

  final String id;
  final String studentId;

  /// full_days / specific_lessons.
  final String scope;
  final String startDate;
  final String endDate;

  /// illness / family / appointment / other.
  final String category;
  final ExcuseStatus status;
  final String reason;
  final String reviewNote;
  final List<String> lessonIds;
  final String? studentName;
  final DateTime? createdAt;

  bool covers(String date, {String? lessonId}) {
    if (status == ExcuseStatus.rejected || status == ExcuseStatus.cancelled) return false;
    if (date.compareTo(startDate) < 0 || date.compareTo(endDate) > 0) return false;
    return scope != 'specific_lessons' || lessonId == null || lessonIds.contains(lessonId);
  }

  factory Excuse.fromJson(Json j) => Excuse(
    id: j.str('id'),
    studentId: j.str('student'),
    scope: j.str('scope'),
    startDate: j.str('start_date'),
    endDate: j.str('end_date'),
    category: j.str('category'),
    status: ExcuseStatus.values.asNameMap()[j.str('status')] ?? ExcuseStatus.pending,
    reason: j.str('reason'),
    reviewNote: j.str('review_note'),
    lessonIds: j.list('lessons', (l) => l.str('lesson')),
    studentName: j.strOrNull('student_name'),
    createdAt: DateTime.tryParse(j.str('created_at'))?.toLocal(),
  );
}

/// `GET /students/{id}/today/?date=` — a learner's day in one response.
class LearnerDay {
  const LearnerDay({
    required this.date,
    required this.studentId,
    required this.studentName,
    this.className,
    this.photoConsent = false,
    this.lessons = const [],
    this.attendance = const {},
    this.checkIn,
    this.excuses = const [],
    this.homework = const [],
    this.recentGrades = const [],
  });

  final String date;
  final String studentId;
  final String studentName;
  final String? className;
  final bool photoConsent;
  final List<Lesson> lessons;

  /// lesson id → mark.
  final Map<String, AttendanceMark> attendance;
  final CheckInStatus? checkIn;
  final List<Excuse> excuses;
  final List<Homework> homework;
  final List<Grade> recentGrades;

  factory LearnerDay.fromJson(Json j) {
    final student = (j['student'] as Json?) ?? const {};
    return LearnerDay(
      date: j.str('date'),
      studentId: student.str('id'),
      studentName: student.str('full_name'),
      className: student.strOrNull('class_group_name'),
      photoConsent: student.flag('photo_consent'),
      lessons: j.list('lessons', Lesson.fromJson)..sort((a, b) => a.start.compareTo(b.start)),
      attendance: {for (final a in j.list('attendance', (a) => a)) a.str('lesson'): AttendanceMark.fromJson(a)},
      checkIn: j['check_in'] is Json ? CheckInStatus.fromJson(j['check_in'] as Json) : null,
      excuses: j.list('excuses', Excuse.fromJson),
      homework: j.list('homework', Homework.fromJson),
      recentGrades: j.list('recent_grades', Grade.fromJson),
    );
  }
}

/// A parent's child (`/users/me/children/`).
class Child {
  const Child({
    required this.id,
    required this.firstName,
    required this.fullName,
    this.className,
    this.avatarUrl,
    this.photoConsent = false,
  });

  final String id;
  final bool photoConsent;
  final String firstName;
  final String fullName;
  final String? className;
  final String? avatarUrl;

  String get shortName => firstName.isEmpty ? fullName : firstName;

  factory Child.fromJson(Json j) {
    final u = (j['user'] as Json?) ?? const {};
    return Child(
      id: j.str('id'),
      firstName: u.str('first_name'),
      fullName: [u.str('last_name'), u.str('first_name')].where((s) => s.isNotEmpty).join(' '),
      className: j.strOrNull('class_group_name'),
      avatarUrl: u.strOrNull('avatar_url'),
      photoConsent: j.flag('photo_consent'),
    );
  }
}

/// Academic quarter (`/schools/academic-terms/`).
class Term {
  const Term({
    required this.id,
    required this.number,
    required this.name,
    required this.start,
    required this.end,
    this.isCurrent = false,
  });
  final String id;
  final int number;
  final String name;
  final String start;
  final String end;
  final bool isCurrent;

  bool contains(String date) => date.compareTo(start) >= 0 && date.compareTo(end) <= 0;

  factory Term.fromJson(Json j) => Term(
    id: j.str('id'),
    number: (j.number('number') ?? 0).toInt(),
    name: j.str('name'),
    start: j.str('start_date'),
    end: j.str('end_date'),
    isCurrent: j.flag('is_current'),
  );
}

/// Official quarter mark row (`/grades/period/`).
class PeriodGrade {
  const PeriodGrade({
    required this.courseId,
    required this.courseName,
    this.fo,
    this.sor,
    this.soch,
    this.percent,
    this.effectiveMark,
    this.isFinal = false,
  });

  final String courseId;
  final String courseName;
  final double? fo;
  final double? sor;
  final double? soch;
  final double? percent;
  final num? effectiveMark;
  final bool isFinal;

  factory PeriodGrade.fromJson(Json j) => PeriodGrade(
    courseId: j.str('course'),
    courseName: j.str('course_name'),
    fo: j.number('fo_percent')?.toDouble(),
    sor: j.number('sor_percent')?.toDouble(),
    soch: j.number('soch_percent')?.toDouble(),
    percent: j.number('quarter_percent')?.toDouble(),
    effectiveMark: j.number('effective_mark'),
    isFinal: j.flag('is_final'),
  );
}
