import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/auth/user.dart';
import 'package:gradeapp/features/chat/chat.dart';
import 'package:gradeapp/features/notifications/notifications.dart';
import 'package:gradeapp/features/notifications/push.dart';
import 'package:gradeapp/features/platform/deep_links.dart';

ChatMessage msg(String id, int minute, {bool pending = false}) => ChatMessage(
  id: id,
  senderId: 'u1',
  senderName: 'Айгуль',
  text: id,
  createdAt: DateTime(2026, 11, 28, 10, minute),
  pending: pending,
);

void main() {
  group('chat', () {
    test('merge: by id, oldest first, a pending copy stays last', () {
      final have = [msg('a', 1), msg('local', 9, pending: true)];
      final out = mergeMessages(have, [msg('b', 2), msg('a', 1)]);
      expect(out.map((m) => m.id), ['a', 'b', 'local']);
    });

    test('a direct chat is titled by the other person; a group by its title', () {
      final direct = Conversation.fromJson({
        'id': 'c1',
        'type': 'direct',
        'title': '',
        'members': [
          {'user': 'me', 'name': 'Я'},
          {'user': 'u2', 'name': 'Иванова Айгуль', 'class_name': ''},
        ],
        'unread_count': 2,
      });
      expect(direct.titleFor('me'), 'Иванова Айгуль');
      expect(direct.other('me')?.userId, 'u2');
      expect(direct.unread, 2);
      final group = Conversation.fromJson({'id': 'c2', 'type': 'group', 'title': 'Родители 4А', 'members': <Object>[]});
      expect(group.titleFor('me'), 'Родители 4А');
    });

    test('pinned first, then the latest message', () {
      Conversation conv(String id, int minute, {bool pinned = false}) => Conversation(
        id: id,
        type: 'direct',
        title: id,
        members: const [],
        pinned: pinned,
        lastMessage: msg(id, minute),
      );
      final out = sortConversations([conv('old', 1), conv('new', 5), conv('pin', 0, pinned: true)]);
      expect(out.map((c) => c.id), ['pin', 'new', 'old']);
    });

    test('a chat notification and a web chat link open the conversation', () {
      final n = notificationFromPush({'type': 'chat.message', 'target_kind': 'conversation', 'target_id': 'c9'});
      expect(notificationRoute(n, AppRole.parent), '/chat/c9');
      expect(notificationRoute(n, AppRole.teacher), '/chat/c9');
      expect(routeForWebLink(Uri.parse('https://grade-app.kz/chat/c9')), '/chat/c9');
      expect(routeForWebLink(Uri.parse('https://grade-app.kz/chat')), '/chat');
    });
  });
}
