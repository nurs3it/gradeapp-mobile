import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/offline/outbox.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import '../common/models.dart';
import 'teacher_models.dart';

final teacherDayProvider = StreamProvider.family<TeacherDay, String>(
  (ref, date) => cachedGet(ref, '/teacher/todo/', query: {'date': date}, parse: (d) => TeacherDay.fromJson(d as Json)),
);

final lessonProvider = StreamProvider.family<Lesson, String>(
  (ref, id) => cachedGet(ref, '/lessons/$id/', parse: (d) => Lesson.fromJson(d as Json)),
);

/// Students of one class.
final classStudentsProvider = StreamProvider.family<List<RosterStudent>, String>(
  (ref, classId) => cachedGet(ref, '/classes/$classId/students/', parse: (d) => parseList(d, RosterStudent.fromJson)),
);

/// Roster of a lesson: every class of a joint lesson, merged (T2 fix — v0
/// loaded only `class_group_id`).
final rosterProvider = Provider.family<AsyncValue<List<RosterStudent>>, Lesson>((ref, lesson) {
  final ids = lesson.classIds;
  if (ids.isEmpty) return const AsyncData([]);
  final parts = {for (final id in ids) id: ref.watch(classStudentsProvider(id))};
  final failed = parts.values.where((p) => p.hasError && !p.hasValue).firstOrNull;
  if (failed != null) return AsyncError(failed.error!, failed.stackTrace!);
  if (parts.values.any((p) => !p.hasValue)) return const AsyncLoading();
  return AsyncData(mergeRoster(ids, {for (final e in parts.entries) e.key: e.value.value!}));
});

/// student id → starting mark (saved, homeroom day mark or self check-in),
/// plus the СОЧ lock of the day.
final lessonDefaultsProvider = StreamProvider.family<LessonDefaults, String>(
  (ref, lessonId) => cachedGet(
    ref,
    '/attendance/lesson_defaults/',
    query: {'lesson_id': lessonId},
    parse: (d) => LessonDefaults.fromJson(d as Json),
  ),
);

final lessonGradesProvider = StreamProvider.family<List<Grade>, String>(
  (ref, lessonId) => cachedGet(
    ref,
    '/grades/',
    query: {'lesson_id': lessonId, 'page_size': 500},
    parse: (d) => parseList(d, Grade.fromJson),
  ),
);

/// Homework of a course (for «ДЗ» in the lesson and the summary).
final courseHomeworkProvider = StreamProvider.family<List<Homework>, String>(
  (ref, courseId) => cachedGet(
    ref,
    '/homework/',
    query: {'course_id': courseId, 'page_size': 200},
    parse: (d) => parseList(d, Homework.fromJson),
  ),
);

typedef CourseDate = ({String courseId, String date});

/// Lessons of the course three weeks around the date: the previous topic
/// («Как в прошлый раз») and the next lesson (ДЗ due date).
final courseLessonsProvider = StreamProvider.family<List<Lesson>, CourseDate>((ref, a) {
  final d = DateTime.parse(a.date);
  return cachedGet(
    ref,
    '/lessons/',
    query: {
      'course_id': a.courseId,
      'date_from': isoDate(d.subtract(const Duration(days: 35))),
      'date_to': isoDate(d.add(const Duration(days: 21))),
      'page_size': 200,
    },
    parse: (x) => parseList(x, Lesson.fromJson)..sort((p, q) => '${p.date}${p.start}'.compareTo('${q.date}${q.start}')),
  );
});

typedef PlanArgs = ({String classId, String subject, String date});

/// КТП topic for the lesson date: planned on that day, else the next one.
final ktpTopicProvider = FutureProvider.family<String?, PlanArgs>((ref, a) async {
  try {
    final res = await ref.read(dioProvider).get<Object?>('/planning/thematic-plans/', queryParameters: {'class_group': a.classId});
    final plans = resultsOf(res.data).where((p) => p.str('subject_name') == a.subject);
    final topics = [
      for (final p in plans)
        for (final s in p.list('sections', (s) => s))
          for (final t in s.list('topics', (t) => t)) (title: t.str('title'), date: t.str('planned_date')),
    ].where((t) => t.title.isNotEmpty && t.date.isNotEmpty).toList()
      ..sort((x, y) => x.date.compareTo(y.date));
    return topics.where((t) => t.date == a.date).firstOrNull?.title ??
        topics.where((t) => t.date.compareTo(a.date) > 0).firstOrNull?.title;
  } catch (_) {
    return null;
  }
});

typedef LoadArgs = ({String classId, String date});

/// Class homework load for a day vs the СанПиН norm.
final dailyLoadProvider = FutureProvider.family<({int total, int norm}), LoadArgs>((ref, a) async {
  final res = await ref
      .read(dioProvider)
      .get<Json>('/homework/daily_load/', queryParameters: {'class_group_id': a.classId, 'date': a.date});
  final j = res.data!;
  return (total: (j.number('total_minutes') ?? 0).toInt(), norm: (j.number('norm_minutes') ?? 0).toInt());
});

/// The teacher's lessons Mon..Sun (week tab).
final teacherWeekProvider = StreamProvider.family<List<Lesson>, String>((ref, monday) {
  final staff = ref.watch(authProvider.select((u) => u.value?.staffId));
  final from = DateTime.parse(monday);
  return cachedGet(
    ref,
    '/lessons/',
    query: {
      'teacher_id': ?staff,
      'date_from': monday,
      'date_to': isoDate(from.add(const Duration(days: 6))),
      'page_size': 500,
    },
    parse: (d) => parseList(d, Lesson.fromJson)..sort((x, y) => '${x.date}${x.start}'.compareTo('${y.date}${y.start}')),
  );
});

/// Unsent local marks of one lesson, replayed over the server values so the
/// teacher always sees what they tapped — online or not; plus what the
/// server refused, per student, so the row can say «не сохранено».
class LessonOverlay {
  const LessonOverlay({required this.attendance, required this.grades, this.failed = const {}, this.queued = const {}});

  /// student id → (status, code)
  final Map<String, ({Presence status, String code})> attendance;

  /// student id → value (null = removed)
  final Map<String, num?> grades;

  /// student id → refused write.
  final Map<String, OutboxItem> failed;

  /// Students with a write still waiting for the network.
  final Set<String> queued;

  static LessonOverlay of(List<OutboxItem> pending, String lessonId, {List<OutboxItem> rejected = const []}) {
    final att = <String, ({Presence status, String code})>{};
    final grades = <String, num?>{};
    final queued = <String>{};
    for (final item in pending) {
      final data = item.data;
      if (data is! Map) continue;
      final records = (data['records'] as List<dynamic>? ?? const []).whereType<Map<dynamic, dynamic>>();
      if (item.path == '/attendance/mark/' && data['lesson_id'] == lessonId) {
        for (final r in records) {
          att['${r['student_id']}'] = (status: presenceOf('${r['status']}'), code: '${r['code'] ?? ''}');
          queued.add('${r['student_id']}');
        }
      } else if (item.path == '/grades/bulk_upsert/' && data['lesson'] == lessonId) {
        for (final r in records) {
          grades['${r['student_id']}'] = r['value'] as num?;
          queued.add('${r['student_id']}');
        }
      }
    }
    final failed = <String, OutboxItem>{};
    for (final item in rejected) {
      final data = item.data;
      if (data is! Map || (data['lesson_id'] != lessonId && data['lesson'] != lessonId)) continue;
      for (final r in (data['records'] as List<dynamic>? ?? const []).whereType<Map<dynamic, dynamic>>()) {
        failed['${r['student_id']}'] = item;
      }
    }
    return LessonOverlay(attendance: att, grades: grades, failed: failed, queued: queued);
  }
}

final lessonOverlayProvider = Provider.family<LessonOverlay, String>((ref, lessonId) {
  final s = ref.watch(outboxStateProvider).value;
  return LessonOverlay.of(s?.pending ?? const [], lessonId, rejected: s?.rejected ?? const []);
});

/// One student's state in the roll call.
class RollCell {
  const RollCell({
    required this.status,
    this.code = '',
    this.saved = false,
    this.source = '',
    this.checkedAt,
    this.grade,
    this.failed,
    this.queued = false,
  });

  final Presence status;
  final String code;

  /// Already recorded for this lesson (server or queue) — not just a suggestion.
  final bool saved;

  /// checkin / homeroom / lesson.
  final String source;
  final DateTime? checkedAt;
  final num? grade;
  final OutboxItem? failed;
  final bool queued;

  bool get isAbsent => status == Presence.absent;
  bool get isOut => status == Presence.absent || status == Presence.excused;
}

/// Roll call (T2): the server default (saved / homeroom / check-in) with the
/// unsent queue on top. Everyone is «есть» unless something says otherwise.
Map<String, RollCell> rollCall({
  required List<RosterStudent> students,
  required LessonDefaults defaults,
  required LessonOverlay overlay,
  required List<Grade> grades,
  required String type,
}) => {
  for (final s in students)
    s.id: () {
      final o = overlay.attendance[s.id];
      final d = defaults.students[s.id];
      final server = grades.where((g) => g.studentId == s.id && g.type == type).firstOrNull?.value;
      return RollCell(
        status: o?.status ?? d?.status ?? Presence.present,
        code: o?.code ?? d?.code ?? '',
        saved: o != null || d?.source == 'lesson',
        source: d?.source ?? '',
        checkedAt: d?.checkedAt,
        grade: overlay.grades.containsKey(s.id) ? overlay.grades[s.id] : server,
        failed: overlay.failed[s.id],
        queued: overlay.queued.contains(s.id),
      );
    }(),
};

/// «22 из 24»: present and late count as present.
int presentCount(Map<String, RollCell> cells) =>
    cells.values.where((c) => c.status == Presence.present || c.status == Presence.tardy).length;

/// Writes of the lesson screen. All go through the outbox: instant locally,
/// synced when the network allows. Labels let the queue sheet say what and
/// whose record it is (T11).
class LessonActions {
  LessonActions(this._outbox, this.lesson);
  final Outbox _outbox;
  final Lesson lesson;

  Map<String, String> _label(String what, {String state = '', String student = ''}) => {
    'what': what,
    'lesson': [?lesson.classGroupName, lesson.subject].join(' · '),
    'lesson_id': lesson.id,
    'state': state,
    'student': student,
  };

  Future<void> mark(
    String studentId,
    Presence status, {
    String code = '',
    String reason = '',
    String name = '',
    String label = '',
  }) =>
      _outbox.add(
        OutboxItem(
          key: 'att:${lesson.id}:$studentId',
          method: 'POST',
          path: '/attendance/mark/',
          label: _label('attendance', state: label, student: name),
          data: {
            'lesson_id': lesson.id,
            'records': [
              {'student_id': studentId, 'status': status.name, 'code': code, if (reason.isNotEmpty) 'reason': reason},
            ],
          },
        ),
      );

  /// «Все на месте» / «Готово»: one request for the given students.
  Future<void> markMany(Map<String, ({Presence status, String code})> records) => _outbox.add(
    OutboxItem(
      key: 'att:${lesson.id}:all:${DateTime.now().microsecondsSinceEpoch}',
      method: 'POST',
      path: '/attendance/mark/',
      label: _label('all_present', state: '${records.length}'),
      data: {
        'lesson_id': lesson.id,
        'records': [
          for (final e in records.entries) {'student_id': e.key, 'status': e.value.status.name, 'code': e.value.code},
        ],
      },
    ),
  );

  Future<void> grade(
    String studentId,
    num? value, {
    required String type,
    required num scaleMax,
    String comment = '',
    String name = '',
  }) => _outbox.add(
    OutboxItem(
      key: 'grade:${lesson.id}:$type:$studentId',
      method: 'POST',
      path: '/grades/bulk_upsert/',
      label: _label('grade', state: value == null ? '' : '$value', student: name),
      data: {
        'course': lesson.courseId,
        'date': lesson.date,
        'lesson': lesson.id,
        'type': type,
        'scale': '$scaleMax',
        'records': [
          {'student_id': studentId, 'value': value, if (comment.isNotEmpty) 'comment': comment},
        ],
      },
    ),
  );

  /// Multi-select: one mark for several students in one request (T3).
  Future<void> gradeMany(Iterable<String> ids, num value, {required String type, required num scaleMax}) => _outbox.add(
    OutboxItem(
      key: 'grade:${lesson.id}:$type:multi:${DateTime.now().microsecondsSinceEpoch}',
      method: 'POST',
      path: '/grades/bulk_upsert/',
      label: _label('grade', state: '$value', student: '${ids.length}'),
      data: {
        'course': lesson.courseId,
        'date': lesson.date,
        'lesson': lesson.id,
        'type': type,
        'scale': '$scaleMax',
        'records': [
          for (final id in ids) {'student_id': id, 'value': value},
        ],
      },
    ),
  );

  Future<void> setTopic(String topic) => _outbox.add(
    OutboxItem(
      key: 'topic:${lesson.id}',
      method: 'PATCH',
      path: '/lessons/${lesson.id}/',
      label: _label('topic', state: topic),
      data: {'topic': topic},
    ),
  );

  Future<void> setSummary(String summary) => _outbox.add(
    OutboxItem(
      key: 'summary:${lesson.id}',
      method: 'PATCH',
      path: '/lessons/${lesson.id}/',
      label: _label('summary'),
      data: {'summary': summary},
    ),
  );

  Future<void> start() => _outbox.add(
    OutboxItem(
      key: 'start:${lesson.id}',
      method: 'POST',
      path: '/lessons/${lesson.id}/start/',
      label: _label('start'),
      data: const <String, Object?>{},
    ),
  );

  Future<void> finish() => _outbox.add(
    OutboxItem(
      key: 'finish:${lesson.id}',
      method: 'POST',
      path: '/lessons/${lesson.id}/finish/',
      label: _label('finish'),
      data: const <String, Object?>{},
    ),
  );

  /// T5: homework from the lesson (JSON part; attachments need the network).
  Future<void> assignHomework({required String title, required String description, required String due, int? minutes}) =>
      _outbox.add(
        OutboxItem(
          key: 'hw:${lesson.id}:${DateTime.now().microsecondsSinceEpoch}',
          method: 'POST',
          path: '/homework/',
          label: _label('homework', state: title),
          data: {
            'course': lesson.courseId,
            'lesson': lesson.id,
            'title': title,
            'description': description,
            'due_date': due,
            'estimated_minutes': ?minutes,
          },
        ),
      );
}
