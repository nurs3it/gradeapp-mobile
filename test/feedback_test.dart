import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/offline/outbox.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/learner/feedback.dart';
import 'package:gradeapp/features/teacher/teacher_providers.dart';

void main() {
  test('feedback parses tags into praise / remark', () {
    final f = TeacherFeedback.fromJson({
      'id': 'f1',
      'from_user': 'u1',
      'from_user_name': 'Попов Ю.',
      'text': 'Отлично отвечал',
      'tags': ['positive'],
      'date': '2026-11-10',
    });
    expect(f.praise, isTrue);
    expect(f.remark, isFalse);
    expect(
      TeacherFeedback.fromJson({'id': 'f2', 'from_user': 'u1', 'text': 't', 'date': '2026-11-10'}).praise,
      isFalse,
    );
  });

  test('only the quarter in view is shown', () {
    const term = Term(id: 't1', number: 2, name: '2 четверть', start: '2026-11-02', end: '2026-12-27');
    TeacherFeedback at(String d) => TeacherFeedback(id: d, fromUserId: 'u', fromName: 'n', text: 't', date: d);
    expect(
      feedbackIn([at('2026-10-30'), at('2026-11-02'), at('2026-12-27'), at('2027-01-10')], term).map((f) => f.date),
      ['2026-11-02', '2026-12-27'],
    );
  });

  test('feedback from the lesson goes through the queue as a POST to /feedback/', () async {
    final outbox = Outbox.memory();
    const lesson = Lesson(
      id: 'l1',
      courseId: 'c1',
      subject: 'Алгебра',
      date: '2026-11-17',
      start: '09:00',
      end: '09:45',
      classGroupName: '7А',
    );
    await LessonActions(outbox, lesson).feedback('s1', 'Молодец', tone: 'positive', name: 'Бекова Алия');
    final item = outbox.pending.single;
    expect(item.method, 'POST');
    expect(item.path, '/feedback/');
    expect(item.data, {
      'to_student': 's1',
      'text': 'Молодец',
      'tags': ['positive'],
      'date': '2026-11-17',
    });
    expect(item.label['what'], 'feedback');
    expect(item.label['student'], 'Бекова Алия');
    await LessonActions(outbox, lesson).feedback('s2', 'Без тона');
    expect(outbox.pending.last.data, containsPair('tags', <String>[]));
  });
}
