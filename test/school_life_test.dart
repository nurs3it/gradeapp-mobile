import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/learner/school_life.dart';

Lesson lesson(String id, String? cls) =>
    Lesson(id: id, courseId: 'c', subject: 'S', date: '2026-11-27', start: '09:00', end: '09:45', classGroupId: cls);

void main() {
  test('own class: the one most lessons of the week belong to', () {
    expect(mainClassOf([lesson('1', '4A'), lesson('2', '4B'), lesson('3', '4A')]), '4A');
    expect(mainClassOf([lesson('1', null)]), isNull);
  });

  test('menu lines and the first attachment; an empty menu counts as none', () {
    final m = CafeteriaMenu.fromJson({
      'title': 'Обед',
      'items': 'Суп\n\n Плов \n',
      'attachments': [
        {'file_url': '/media/menu.pdf'},
      ],
    });
    expect(m.items, ['Суп', 'Плов']);
    expect(m.fileUrl, '/media/menu.pdf');
    expect(CafeteriaMenu.fromJson({'title': '', 'items': ''}).isEmpty, isTrue);
  });

  test('birthday shows the first name (server sends «First Middle Last»)', () {
    expect(Birthday.fromJson({'name': 'Ольга Олжасқызы Касымова', 'in_days': 0}).firstName, 'Ольга');
    expect(Birthday.fromJson({'name': 'Айгерим', 'in_days': 1}).firstName, 'Айгерим');
  });
}
