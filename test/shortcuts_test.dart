import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/app/router.dart';
import 'package:gradeapp/features/auth/user.dart';

void main() {
  test('app shortcuts resolve by role (W7)', () {
    expect(shortcutRoute('/go/week', AppRole.parent), '/p/week');
    expect(shortcutRoute('/go/grades', AppRole.student), '/s/grades');
    expect(shortcutRoute('/go/grades', AppRole.teacher), '/t/today');
    expect(shortcutRoute('/go/checkin', AppRole.student), '/checkin');
    expect(shortcutRoute('/go/checkin', AppRole.parent), '/p/today');
    expect(shortcutRoute('/go/chat', AppRole.teacher), '/chat');
    expect(shortcutRoute('/go/chat', AppRole.student), '/s/today');
    expect(shortcutRoute('/go/today', AppRole.teacher), '/t/today');
    expect(shortcutRoute('/p/week', AppRole.parent), isNull);
  });
}
