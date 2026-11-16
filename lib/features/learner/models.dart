import '../../core/json.dart';

/// `HH:MM:SS` → minutes since midnight.
int minutesOf(String hhmm) {
  final p = hhmm.split(':');
  return p.length < 2 ? 0 : int.parse(p[0]) * 60 + int.parse(p[1]);
}

String hm(String hhmmss) => hhmmss.length >= 5 ? hhmmss.substring(0, 5) : hhmmss;

enum LessonStatus { scheduled, inProgress, completed, moved, cancelled }

class Lesson {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.subject,
    required this.date,
    required this.start,
    required this.end,
    required this.room,
    required this.teacherName,
    required this.classGroupId,
    required this.classGroupName,
    required this.status,
    required this.topic,
  });

  final String id;
  final String courseId;
  final String subject;
  final String date;
  final String start;
  final String end;
  final String? room;
  final String? teacherName;
  final String? classGroupId;
  final String? classGroupName;
  final LessonStatus status;
  final String topic;

  bool get isCancelled => status == LessonStatus.cancelled || status == LessonStatus.moved;

  /// Position of [now] relative to this lesson on its own date.
  bool isNow(DateTime now) {
    final m = now.hour * 60 + now.minute;
    return _sameDay(now) && m >= minutesOf(start) && m < minutesOf(end);
  }

  bool isPast(DateTime now) =>
      DateTime.parse(date).isBefore(DateTime(now.year, now.month, now.day)) ||
      (_sameDay(now) && now.hour * 60 + now.minute >= minutesOf(end));

  bool _sameDay(DateTime now) => date == isoDate(now);

  factory Lesson.fromJson(Json j) => Lesson(
        id: j.str('id'),
        courseId: j.str('course'),
        subject: j.strOrNull('subject_name') ?? j.strOrNull('course_name') ?? '—',
        date: j.str('date'),
        start: j.str('start_time'),
        end: j.str('end_time'),
        room: j.strOrNull('room_name') ?? j.strOrNull('classroom'),
        teacherName: j.strOrNull('teacher_name'),
        classGroupId: j.strOrNull('class_group_id'),
        classGroupName: j.strOrNull('class_group_name'),
        status: switch (j.str('status')) {
          'in_progress' => LessonStatus.inProgress,
          'completed' => LessonStatus.completed,
          'moved' => LessonStatus.moved,
          'cancelled' => LessonStatus.cancelled,
          _ => LessonStatus.scheduled,
        },
        topic: j.str('topic'),
      );
}

class Grade {
  const Grade({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseName,
    required this.value,
    required this.maxValue,
    required this.type,
    required this.comment,
    required this.date,
    required this.lessonId,
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
      );
}

class Attachment {
  const Attachment({required this.url, required this.name});
  final String? url;
  final String name;
  factory Attachment.fromJson(Json j) =>
      Attachment(url: j.strOrNull('file_url'), name: j.str('original_name'));
}

class Homework {
  const Homework({
    required this.id,
    required this.courseName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.minutes,
    required this.attachments,
    required this.isDone,
    required this.lessonId,
  });

  final String id;
  final String courseName;
  final String title;
  final String description;
  final String dueDate;
  final int? minutes;
  final List<Attachment> attachments;
  final bool isDone;
  final String? lessonId;

  Homework withDone(bool done) => Homework(
        id: id,
        courseName: courseName,
        title: title,
        description: description,
        dueDate: dueDate,
        minutes: minutes,
        attachments: attachments,
        isDone: done,
        lessonId: lessonId,
      );

  factory Homework.fromJson(Json j) => Homework(
        id: j.str('id'),
        courseName: j.str('course_name'),
        title: j.str('title'),
        description: j.str('description'),
        dueDate: j.str('due_date'),
        minutes: j.number('estimated_minutes')?.toInt(),
        attachments: j.list('attachments', Attachment.fromJson),
        isDone: j.flag('is_done'),
        lessonId: j.strOrNull('lesson'),
      );
}

enum Presence { present, absent, tardy, excused }

Presence presenceOf(String s) => switch (s) {
      'absent' => Presence.absent,
      'tardy' => Presence.tardy,
      'excused' => Presence.excused,
      _ => Presence.present,
    };

class CheckInStatus {
  const CheckInStatus({
    required this.enabled,
    required this.windowStart,
    required this.windowEnd,
    required this.windowOpen,
    required this.geofence,
    required this.consent,
    required this.checkedIn,
    required this.checkedAt,
    required this.late,
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
        windowStart: j.str('window_start'),
        windowEnd: j.str('window_end'),
        windowOpen: j.flag('window_open'),
        geofence: j.flag('geofence'),
        consent: j.flag('consent'),
        checkedIn: j.flag('checked_in'),
        checkedAt: DateTime.tryParse(j.str('checked_at'))?.toLocal(),
        late: j.flag('late'),
      );
}

/// `GET /students/{id}/today/?date=` — a learner's day in one response.
class LearnerDay {
  const LearnerDay({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.photoConsent,
    required this.lessons,
    required this.attendance,
    required this.checkIn,
    required this.homework,
    required this.recentGrades,
  });

  final String studentId;
  final String studentName;
  final String? className;
  final bool photoConsent;
  final List<Lesson> lessons;

  /// lesson id → mark.
  final Map<String, Presence> attendance;
  final CheckInStatus? checkIn;
  final List<Homework> homework;
  final List<Grade> recentGrades;

  factory LearnerDay.fromJson(Json j) {
    final student = (j['student'] as Json?) ?? const {};
    return LearnerDay(
      studentId: student.str('id'),
      studentName: student.str('full_name'),
      className: student.strOrNull('class_group_name'),
      photoConsent: student.flag('photo_consent'),
      lessons: j.list('lessons', Lesson.fromJson)
        ..sort((a, b) => a.start.compareTo(b.start)),
      attendance: {
        for (final a in j.list('attendance', (a) => a))
          a.str('lesson'): presenceOf(a.str('status')),
      },
      checkIn: j['check_in'] is Json ? CheckInStatus.fromJson(j['check_in'] as Json) : null,
      homework: j.list('homework', Homework.fromJson),
      recentGrades: j.list('recent_grades', Grade.fromJson),
    );
  }
}

/// A parent's child (GET /users/me/children/).
class Child {
  const Child({
    required this.id,
    required this.firstName,
    required this.fullName,
    required this.className,
    required this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String fullName;
  final String? className;
  final String? avatarUrl;

  factory Child.fromJson(Json j) {
    final u = (j['user'] as Json?) ?? const {};
    return Child(
      id: j.str('id'),
      firstName: u.str('first_name'),
      fullName: [u.str('last_name'), u.str('first_name')].where((s) => s.isNotEmpty).join(' '),
      className: j.strOrNull('class_group_name'),
      avatarUrl: u.strOrNull('avatar_url'),
    );
  }
}

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
