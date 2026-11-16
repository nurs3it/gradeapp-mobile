import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/auth/user.dart';
import 'package:gradeapp/features/notifications/notifications.dart';
import 'package:gradeapp/features/notifications/push.dart';

void main() {
  test('push data opens the same place as the inbox row', () {
    final n = notificationFromPush({
      'type': 'grade.created',
      'notification_id': 'n1',
      'target_kind': 'grade',
      'target_id': 'g1',
      'student_id': 's1',
    });
    expect(n.id, 'n1');
    expect(n.payload['student_id'], 's1');
    expect(notificationRoute(n, AppRole.parent), '/p/grades');
    expect(
      notificationRoute(
        notificationFromPush({'type': 'attendance.unmarked', 'target_kind': 'lesson', 'target_id': 'l1'}),
        AppRole.teacher,
      ),
      '/lesson/l1',
    );
  });

  test('channels match backend preference groups', () {
    // backend users/notification_prefs.py GROUPS + the fallback channel
    expect(PushGroup.values.map((g) => g.name), [
      'grades',
      'homework',
      'schedule',
      'attendance',
      'chat',
      'billing',
      'general',
    ]);
  });

  test('missing push preference means on', () {
    final u = AppUser.fromJson({
      'id': 'u',
      'email': 'e',
      'notification_prefs': {
        'grades': {'push': false},
        'chat': {'email': false},
      },
    });
    expect(u.pushOn('grades'), isFalse);
    expect(u.pushOn('chat'), isTrue);
    expect(u.pushOn('homework'), isTrue);
  });
}
