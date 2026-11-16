import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/offline/outbox.dart';
import 'package:gradeapp/features/learner/models.dart';
import 'package:gradeapp/features/teacher/teacher_providers.dart';

void main() {
  OutboxItem att(String lesson, List<(String, String)> recs) => OutboxItem(
        key: 'k$lesson${recs.length}',
        method: 'POST',
        path: '/attendance/mark/',
        data: {
          'lesson_id': lesson,
          'records': [for (final (id, s) in recs) {'student_id': id, 'status': s, 'code': ''}],
        },
      );

  test('later queued marks win, other lessons are ignored', () {
    final pending = [
      att('L1', [('a', 'present'), ('b', 'present')]), // «все на месте»
      att('L1', [('b', 'absent')]), // then b is tapped absent
      att('L2', [('a', 'absent')]),
      OutboxItem(
        key: 'g',
        method: 'POST',
        path: '/grades/bulk_upsert/',
        data: {
          'lesson': 'L1',
          'records': [
            {'student_id': 'a', 'value': 9},
          ],
        },
      ),
    ];

    final o = LessonOverlay.of(pending, 'L1');
    expect(o.attendance['a']!.status, Presence.present);
    expect(o.attendance['b']!.status, Presence.absent);
    expect(o.grades, {'a': 9});
  });

  test('lesson parsing tolerates missing optional fields', () {
    final l = Lesson.fromJson({'id': '1', 'date': '2026-11-16', 'start_time': '08:30:00', 'end_time': '09:15:00'});
    expect(l.subject, '—');
    expect(l.isNow(DateTime(2026, 11, 16, 8, 40)), isTrue);
    expect(l.isPast(DateTime(2026, 11, 16, 9, 15)), isTrue);
  });
}
