import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/offline/outbox.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import '../learner/models.dart';
import 'models.dart';

final teacherDayProvider = StreamProvider.family<TeacherDay, String>(
  (ref, date) => cachedGet(
    ref,
    '/teacher/todo/',
    query: {'date': date},
    parse: (d) => TeacherDay.fromJson(d as Json),
  ),
);

final gradingProvider = StreamProvider<Grading>((ref) {
  final school = ref.watch(authProvider.select((u) => u.value?.linkedSchool));
  if (school == null) return const Stream.empty();
  return cachedGet(ref, '/schools/$school/', parse: (d) => Grading.fromSchool(d as Json));
});

final lessonProvider = StreamProvider.family<Lesson, String>(
  (ref, id) => cachedGet(ref, '/lessons/$id/', parse: (d) => Lesson.fromJson(d as Json)),
);

final rosterProvider = StreamProvider.family<List<RosterStudent>, String>(
  (ref, classId) => cachedGet(
    ref,
    '/classes/$classId/students/',
    parse: (d) => parseList(d, RosterStudent.fromJson)
      ..sort((a, b) => a.name.compareTo(b.name)),
  ),
);

/// student id → starting mark (saved, homeroom day mark or self check-in).
final attendanceDefaultsProvider = StreamProvider.family<Map<String, AttendanceDefault>, String>(
  (ref, lessonId) => cachedGet(
    ref,
    '/attendance/lesson_defaults/',
    query: {'lesson_id': lessonId},
    parse: (d) => {
      for (final s in (d as Json).list('students', (s) => s))
        s.str('student_id'): AttendanceDefault.fromJson(s),
    },
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

/// Unsynced local marks of one lesson, replayed over the server values so the
/// teacher always sees what they tapped — online or not.
class LessonOverlay {
  const LessonOverlay({required this.attendance, required this.grades});

  /// student id → (status, code)
  final Map<String, ({Presence status, String code})> attendance;

  /// student id → value (null = removed)
  final Map<String, num?> grades;

  static LessonOverlay of(List<OutboxItem> pending, String lessonId) {
    final att = <String, ({Presence status, String code})>{};
    final grades = <String, num?>{};
    for (final item in pending) {
      final data = item.data;
      if (data is! Map) continue;
      final records = (data['records'] as List<dynamic>? ?? const []).whereType<Map<dynamic, dynamic>>();
      if (item.path == '/attendance/mark/' && data['lesson_id'] == lessonId) {
        for (final r in records) {
          att['${r['student_id']}'] = (status: presenceOf('${r['status']}'), code: '${r['code'] ?? ''}');
        }
      } else if (item.path == '/grades/bulk_upsert/' && data['lesson'] == lessonId) {
        for (final r in records) {
          grades['${r['student_id']}'] = r['value'] as num?;
        }
      }
    }
    return LessonOverlay(attendance: att, grades: grades);
  }
}

final lessonOverlayProvider = Provider.family<LessonOverlay, String>((ref, lessonId) {
  final pending = ref.watch(outboxPendingProvider).value ?? const [];
  return LessonOverlay.of(pending, lessonId);
});

/// Writes of the lesson screen. All go through the outbox: instant locally,
/// synced when the network allows.
class LessonActions {
  LessonActions(this._outbox, this.lesson);
  final Outbox _outbox;
  final Lesson lesson;

  Future<void> mark(String studentId, Presence status, {String code = ''}) => _outbox.add(
        OutboxItem(
          key: 'att:${lesson.id}:$studentId',
          method: 'POST',
          path: '/attendance/mark/',
          data: {
            'lesson_id': lesson.id,
            'records': [
              {'student_id': studentId, 'status': status.name, 'code': code},
            ],
          },
        ),
      );

  /// «Все на месте»: one request for the whole roster.
  Future<void> markAll(Iterable<String> studentIds, Presence status) => _outbox.add(
        OutboxItem(
          key: 'att:${lesson.id}:all:${DateTime.now().microsecondsSinceEpoch}',
          method: 'POST',
          path: '/attendance/mark/',
          data: {
            'lesson_id': lesson.id,
            'records': [
              for (final id in studentIds) {'student_id': id, 'status': status.name, 'code': ''},
            ],
          },
        ),
      );

  Future<void> grade(String studentId, num? value, {required String type, required int scaleMax}) =>
      _outbox.add(
        OutboxItem(
          key: 'grade:${lesson.id}:$type:$studentId',
          method: 'POST',
          path: '/grades/bulk_upsert/',
          data: {
            'course': lesson.courseId,
            'date': lesson.date,
            'lesson': lesson.id,
            'type': type,
            'scale': '$scaleMax',
            'records': [
              {'student_id': studentId, 'value': value},
            ],
          },
        ),
      );

  Future<void> setTopic(String topic) => _outbox.add(
        OutboxItem(
          key: 'topic:${lesson.id}',
          method: 'PATCH',
          path: '/lessons/${lesson.id}/',
          data: {'topic': topic},
        ),
      );

  Future<void> start() => _outbox.add(
        OutboxItem(key: 'start:${lesson.id}', method: 'POST', path: '/lessons/${lesson.id}/start/', data: const <String, Object?>{}),
      );

  Future<void> finish() => _outbox.add(
        OutboxItem(key: 'finish:${lesson.id}', method: 'POST', path: '/lessons/${lesson.id}/finish/', data: const <String, Object?>{}),
      );
}
