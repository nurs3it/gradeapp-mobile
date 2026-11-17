import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/models.dart';

void main() {
  test('joint lesson shows how many classes join the main one', () {
    const one = Lesson(
      id: 'a',
      courseId: 'c',
      subject: 'Математика',
      date: '2026-11-17',
      start: '08:30',
      end: '09:15',
      classGroupName: '1A',
    );
    expect(one.classLabel, '1A');
    const joint = Lesson(
      id: 'b',
      courseId: 'c',
      subject: 'Математика',
      date: '2026-11-17',
      start: '08:30',
      end: '09:15',
      classGroupName: '1A',
      additionalClassGroups: ['x'],
    );
    expect(joint.classLabel, '1A +1');
    final named = Lesson.fromJson({
      'lesson_id': 'b',
      'course_id': 'c',
      'subject': 'Математика',
      'date': '2026-11-17',
      'start_time': '08:30',
      'end_time': '09:15',
      'class_group_name': '1A',
      'additional_class_groups': ['x'],
      'additional_class_group_names': ['1B'],
    });
    expect(named.classLabel, '1A + 1B');
  });
}
