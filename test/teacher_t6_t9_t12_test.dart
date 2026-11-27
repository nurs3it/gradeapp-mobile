import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/offline/outbox.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/teacher/feedback_quick.dart';
import 'package:gradeapp/features/teacher/homework_completions.dart';
import 'package:gradeapp/features/teacher/teacher_providers.dart';
import 'package:gradeapp/features/teacher/teacher_week_screen.dart';
import 'package:gradeapp/l10n/gen/app_localizations_ru.dart';

void main() {
  group('T6 quick feedback', () {
    test('tags: tone first, then only that tone\'s templates', () {
      expect(feedbackTags('positive', ['active', 'late']), ['positive', 'active']);
      expect(feedbackTags('negative', ['late', 'no_homework']), ['negative', 'late', 'no_homework']);
      expect(feedbackTags(null, ['active']), isEmpty);
    });

    test('text is optional once there is a tone', () {
      expect(canSendFeedback(tone: 'positive', text: ''), isTrue);
      expect(canSendFeedback(tone: null, text: '  '), isFalse);
      expect(canSendFeedback(tone: null, text: 'Молодец'), isTrue);
    });

    test('goes through the outbox with templates and an empty text', () async {
      final outbox = Outbox.memory();
      const lesson = Lesson(
        id: 'l1',
        courseId: 'c1',
        subject: 'Алгебра',
        date: '2026-11-27',
        start: '09:00',
        end: '09:45',
      );
      await LessonActions(outbox, lesson).feedback('s1', '', tone: 'negative', templates: ['late', 'distracted']);
      final item = outbox.pending.single;
      expect(item.path, '/feedback/');
      expect(item.data, {
        'to_student': 's1',
        'text': '',
        'tags': ['negative', 'late', 'distracted'],
        'date': '2026-11-27',
      });
    });

    test('every template has words', () {
      final l = AppLocalizationsRu();
      for (final tag in [...positiveFeedbackTags, ...negativeFeedbackTags]) {
        expect(feedbackTagLabel(l, tag), isNotNull, reason: tag);
      }
      expect(feedbackTagLabel(l, 'positive'), isNull);
    });
  });

  group('T9 substitutions', () {
    final base = {
      'id': 'l1',
      'course': 'c1',
      'subject_name': 'Физика',
      'date': '2026-11-27',
      'start_time': '09:00',
      'end_time': '09:45',
      'teacher_name': 'Сидоров',
    };

    test('parses the flag and the course teacher; absent means false', () {
      final sub = Lesson.fromJson({...base, 'is_substitution': true, 'course_teacher_name': 'Иванов'});
      expect(sub.isSubstitution, isTrue);
      expect(sub.courseTeacherName, 'Иванов');
      final plain = Lesson.fromJson(base);
      expect(plain.isSubstitution, isFalse);
      expect(plain.courseTeacherName, isNull);
      expect(sub.copyWith(topic: 'x').isSubstitution, isTrue);
    });

    test('the note reads from the viewer\'s side', () {
      final l = AppLocalizationsRu();
      final sub = Lesson.fromJson({
        ...base,
        'teacher': 'staff-me',
        'is_substitution': true,
        'course_teacher_name': 'Иванов',
      });
      expect(substitutionNoteFor(l, sub, 'staff-me'), 'за Иванов');
      expect(substitutionNoteFor(l, sub, 'staff-other'), 'ведёт Сидоров');
      expect(substitutionNoteFor(l, Lesson.fromJson(base), 'staff-me'), isNull);
    });
  });

  group('T12 homework completions', () {
    final json = {
      'homework_id': 'h1',
      'done_count': 2,
      'students_count': 4,
      'students': [
        {'student_id': 'a', 'name': 'Ким Али', 'done': false, 'done_at': null},
        {'student_id': 'b', 'name': 'Аманов Бек', 'done': true, 'done_at': '2026-11-26T18:00:00+05:00'},
        {'student_id': 'c', 'name': 'Бекова Дана', 'done': false, 'done_at': null},
        {'student_id': 'd', 'name': 'Сеитов Ерлан', 'done': true, 'done_at': '2026-11-26T19:00:00+05:00'},
      ],
    };

    test('summary and who has not done it', () {
      final c = HomeworkCompletions.fromJson(json);
      expect(AppLocalizationsRu().t12Done(c.done, c.total), 'Выполнили 2 из 4');
      expect(c.notDone.map((s) => s.name), ['Бекова Дана', 'Ким Али']);
      expect(c.allDone, isFalse);
      final all = HomeworkCompletions.fromJson({'homework_id': 'h', 'done_count': 3, 'students_count': 3});
      expect(all.allDone, isTrue);
    });

    test('counts fall back to the rows', () {
      final c = HomeworkCompletions.fromJson({
        'homework_id': 'h',
        'students': [
          {'student_id': 'a', 'name': 'A', 'done': true},
          {'student_id': 'b', 'name': 'B', 'done': false},
        ],
      });
      expect((c.done, c.total), (1, 2));
    });

    test('remind: count, too soon (429), failure', () {
      expect((remindResultOf(data: {'notified': 8}) as Reminded).notified, 8);
      final tooSoon = DioException(
        requestOptions: RequestOptions(path: '/homework/h/remind/'),
        response: Response(
          requestOptions: RequestOptions(path: '/homework/h/remind/'),
          statusCode: 429,
          data: {'error': 'reminder_too_soon', 'retry_after': 3600},
        ),
      );
      expect(remindResultOf(error: tooSoon), isA<RemindTooSoon>());
      expect(remindResultOf(error: Exception('x')), isA<RemindFailed>());
      expect(remindResultOf(data: 'junk'), isA<RemindFailed>());
    });
  });
}
