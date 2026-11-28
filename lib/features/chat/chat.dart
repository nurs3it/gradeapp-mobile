import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';

/// Chat (stage 4): the web chat's API (`/chat/conversations/…`) in the app.
/// Only the open conversation is polled (`?after=`); the list refreshes on
/// open, pull and push.

class ChatPerson {
  const ChatPerson({required this.userId, required this.name, this.avatarUrl, this.roles = const [], this.classLine = ''});
  final String userId;
  final String name;
  final String? avatarUrl;
  final List<String> roles;

  /// «4А» for a student, the children's classes for a parent — who this is.
  final String classLine;

  factory ChatPerson.fromMember(Json j) => ChatPerson(
    userId: j.str('user'),
    name: j.str('name'),
    avatarUrl: j.strOrNull('avatar_url'),
    roles: j.strings('roles'),
    classLine: _classLine(j),
  );

  /// A row of `GET /chat/conversations/members/` (whom one may write to).
  factory ChatPerson.fromCandidate(Json j) => ChatPerson(
    userId: j.str('id'),
    name: j.str('name').isNotEmpty ? j.str('name') : '${j.str('last_name')} ${j.str('first_name')}'.trim(),
    avatarUrl: j.strOrNull('avatar_url'),
    roles: j.strings('roles'),
    classLine: _classLine(j),
  );

  static String _classLine(Json j) {
    final own = j.str('class_name');
    if (own.isNotEmpty) return own;
    final kids = (j['children'] as List<dynamic>? ?? const []).whereType<Json>();
    return kids.map((k) => [k.str('name'), k.str('class_name')].where((s) => s.isNotEmpty).join(' · ')).join(', ');
  }
}

class ChatReaction {
  const ChatReaction({required this.emoji, required this.userIds});
  final String emoji;
  final List<String> userIds;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.system = false,
    this.attachmentUrl,
    this.attachmentName = '',
    this.edited = false,
    this.reactions = const [],
    this.pending = false,
    this.failed = false,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  /// `kind = system`: [text] is an event code (member_added…), not prose.
  final bool system;
  final String? attachmentUrl;
  final String attachmentName;
  final bool edited;
  final List<ChatReaction> reactions;

  /// Sent from here and not confirmed yet / refused.
  final bool pending;
  final bool failed;

  /// The server's timestamp exactly as sent: `?after=` compares to it.
  String get stamp => createdAt.toUtc().toIso8601String();

  factory ChatMessage.fromJson(Json j) => ChatMessage(
    id: j.str('id'),
    senderId: j.str('sender'),
    senderName: j.str('sender_name'),
    text: j.str('text'),
    createdAt: DateTime.tryParse(j.str('created_at'))?.toLocal() ?? DateTime.now(),
    system: j.str('kind') == 'system',
    attachmentUrl: j.strOrNull('attachment_url'),
    attachmentName: j.str('attachment_name'),
    edited: j.strOrNull('edited_at') != null,
    reactions: [
      for (final r in (j['reactions'] as List<dynamic>? ?? const []).whereType<Json>())
        ChatReaction(emoji: r.str('emoji'), userIds: r.strings('user_ids')),
    ],
  );

  ChatMessage copyWith({bool? pending, bool? failed}) => ChatMessage(
    id: id,
    senderId: senderId,
    senderName: senderName,
    text: text,
    createdAt: createdAt,
    system: system,
    attachmentUrl: attachmentUrl,
    attachmentName: attachmentName,
    edited: edited,
    reactions: reactions,
    pending: pending ?? this.pending,
    failed: failed ?? this.failed,
  );
}

class Conversation {
  const Conversation({
    required this.id,
    required this.type,
    required this.title,
    required this.members,
    this.lastMessage,
    this.unread = 0,
    this.muted = false,
    this.pinned = false,
    this.canPost = true,
    this.broadcast = false,
    this.memberCount = 0,
    this.updatedAt,
  });

  final String id;

  /// `direct` | `group`.
  final String type;
  final String title;
  final List<ChatPerson> members;
  final ChatMessage? lastMessage;
  final int unread;
  final bool muted;
  final bool pinned;
  final bool canPost;
  final bool broadcast;
  final int memberCount;
  final DateTime? updatedAt;

  bool get isDirect => type == 'direct';

  factory Conversation.fromJson(Json j) => Conversation(
    id: j.str('id'),
    type: j.str('type'),
    title: j.str('title'),
    members: [for (final m in (j['members'] as List<dynamic>? ?? const []).whereType<Json>()) ChatPerson.fromMember(m)],
    lastMessage: j['last_message'] is Json ? ChatMessage.fromJson(j['last_message'] as Json) : null,
    unread: (j.number('unread_count') ?? 0).toInt(),
    muted: j.flag('is_muted'),
    pinned: j.flag('is_pinned'),
    canPost: j['can_post'] != false,
    broadcast: j.flag('is_broadcast'),
    memberCount: (j.number('member_count') ?? 0).toInt(),
    updatedAt: DateTime.tryParse(j.str('updated_at'))?.toLocal(),
  );

  /// The other person of a direct chat (null for a group, or a chat with oneself).
  ChatPerson? other(String myId) => isDirect ? members.where((m) => m.userId != myId).firstOrNull : null;

  /// A group's title; for a direct chat, the other person's name.
  String titleFor(String myId) {
    if (!isDirect && title.isNotEmpty) return title;
    final o = other(myId);
    if (o != null) return o.name;
    return members.where((m) => m.userId != myId).map((m) => m.name).join(', ');
  }
}

/// Pinned first, then the latest activity.
List<Conversation> sortConversations(Iterable<Conversation> list) => [...list]
  ..sort((a, b) {
    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
    final ta = a.lastMessage?.createdAt ?? a.updatedAt ?? DateTime(2000);
    final tb = b.lastMessage?.createdAt ?? b.updatedAt ?? DateTime(2000);
    return tb.compareTo(ta);
  });

/// New messages into the thread: by id (a poll can repeat the last one, a
/// socket-less send comes back in the next poll), oldest first. A pending
/// local copy is dropped once the server's copy of the same text arrives.
List<ChatMessage> mergeMessages(List<ChatMessage> have, Iterable<ChatMessage> incoming) {
  final byId = {for (final m in have) m.id: m};
  for (final m in incoming) {
    byId[m.id] = m;
  }
  return byId.values.toList()..sort((a, b) {
    if (a.pending != b.pending) return a.pending ? 1 : -1;
    return a.createdAt.compareTo(b.createdAt);
  });
}

final conversationsProvider = StreamProvider<List<Conversation>>(
  (ref) => cachedGet(
    ref,
    '/chat/conversations/',
    query: const {'page_size': 100},
    parse: (d) => sortConversations(parseList(d, Conversation.fromJson)),
  ),
);

/// Opens (or finds) the direct chat with [userId]; returns its id. The server
/// answers 200 with the existing chat of the same two people.
Future<String> openDirectChat(Ref ref, String userId) async {
  final res = await ref
      .read(dioProvider)
      .post<Json>('/chat/conversations/', data: {'type': 'direct', 'member_ids': [userId]});
  ref.invalidate(conversationsProvider);
  return res.data!.str('id');
}

/// Whom the user may write to (server-side search).
final chatCandidatesProvider = FutureProvider.autoDispose.family<List<ChatPerson>, String>((ref, search) async {
  final q = search.trim();
  if (q.isNotEmpty) await Future<void>.delayed(const Duration(milliseconds: 300));
  final res = await ref
      .read(dioProvider)
      .get<Object?>('/chat/conversations/members/', queryParameters: {if (q.isNotEmpty) 'search': q, 'page_size': 50});
  return parseList(res.data, ChatPerson.fromCandidate);
});

class ChatThreadState {
  const ChatThreadState({this.messages = const [], this.loading = true, this.error = false, this.conversation});
  final List<ChatMessage> messages;
  final bool loading;
  final bool error;
  final Conversation? conversation;

  ChatThreadState copyWith({List<ChatMessage>? messages, bool? loading, bool? error, Conversation? conversation}) =>
      ChatThreadState(
        messages: messages ?? this.messages,
        loading: loading ?? this.loading,
        error: error ?? this.error,
        conversation: conversation ?? this.conversation,
      );
}

/// One open conversation: history, a 5-second `?after=` poll while it is on
/// screen, sending with a pending copy, and «read» when something new shows.
class ChatThread extends Notifier<ChatThreadState> {
  ChatThread(this.id);
  final String id;

  static const pollEvery = Duration(seconds: 5);
  Timer? _timer;
  bool _disposed = false;

  Dio get _dio => ref.read(dioProvider);
  String get _base => '/chat/conversations/$id';

  @override
  ChatThreadState build() {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    unawaited(_load());
    return const ChatThreadState();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([_dio.get<Json>('$_base/'), _dio.get<Object?>('$_base/messages/')]);
      if (_disposed) return;
      state = state.copyWith(
        conversation: Conversation.fromJson(results[0].data! as Json),
        messages: mergeMessages(const [], parseList(results[1].data, ChatMessage.fromJson)),
        loading: false,
        error: false,
      );
      unawaited(_markRead());
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(loading: false, error: state.messages.isEmpty);
    }
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (!_disposed) _timer = Timer(pollEvery, poll);
  }

  /// What arrived since the last confirmed message (everything, when none).
  Future<void> poll() async {
    // The first load failed: retry it whole, so the title and «can post» come too.
    if (state.conversation == null) return _load();
    final confirmed = state.messages.where((m) => !m.pending && !m.failed);
    try {
      final res = await _dio.get<Object?>(
        '$_base/messages/',
        queryParameters: confirmed.isEmpty ? null : {'after': confirmed.last.stamp},
      );
      if (_disposed) return;
      final fresh = parseList(res.data, ChatMessage.fromJson).where((m) => !state.messages.any((h) => h.id == m.id));
      if (fresh.isNotEmpty) {
        state = state.copyWith(messages: mergeMessages(state.messages, fresh), error: false);
        unawaited(_markRead());
      }
    } catch (_) {
      // Offline: the next poll tries again.
    }
    _schedule();
  }

  Future<void> _markRead() async {
    try {
      await _dio.post<void>('$_base/read/');
      ref.invalidate(conversationsProvider);
    } catch (_) {
      // Not critical: the badge fixes itself on the next read.
    }
  }

  Future<void> send(String text, {required String myId, required String myName, String? retryId}) async {
    final body = text.trim();
    if (body.isEmpty) return;
    final localId = retryId ?? 'local-${DateTime.now().microsecondsSinceEpoch}';
    final local = ChatMessage(
      id: localId,
      senderId: myId,
      senderName: myName,
      text: body,
      createdAt: DateTime.now(),
      pending: true,
    );
    state = state.copyWith(messages: mergeMessages(state.messages.where((m) => m.id != localId).toList(), [local]));
    try {
      final res = await _dio.post<Json>('$_base/messages/', data: {'text': body});
      if (_disposed) return;
      final saved = ChatMessage.fromJson(res.data!);
      state = state.copyWith(messages: mergeMessages(state.messages.where((m) => m.id != localId).toList(), [saved]));
      ref.invalidate(conversationsProvider);
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(
        messages: [for (final m in state.messages) m.id == localId ? m.copyWith(pending: false, failed: true) : m],
      );
    }
  }

  /// Sets or clears my reaction.
  Future<void> react(ChatMessage m, String emoji, {required bool mine}) async {
    try {
      final path = '$_base/messages/${m.id}/reaction/';
      final res = mine ? await _dio.delete<Json>(path) : await _dio.post<Json>(path, data: {'emoji': emoji});
      if (_disposed || res.data == null) return;
      state = state.copyWith(messages: mergeMessages(state.messages, [ChatMessage.fromJson(res.data!)]));
    } catch (_) {
      // Leave it as it was.
    }
  }

  Future<void> setMuted(bool muted) async {
    await _dio.patch<void>('$_base/settings/', data: {'muted': muted});
    final c = state.conversation;
    if (c != null) {
      state = state.copyWith(
        conversation: Conversation(
          id: c.id,
          type: c.type,
          title: c.title,
          members: c.members,
          lastMessage: c.lastMessage,
          unread: c.unread,
          muted: muted,
          pinned: c.pinned,
          canPost: c.canPost,
          broadcast: c.broadcast,
          memberCount: c.memberCount,
          updatedAt: c.updatedAt,
        ),
      );
    }
    ref.invalidate(conversationsProvider);
  }
}

final chatThreadProvider = NotifierProvider.autoDispose.family<ChatThread, ChatThreadState, String>(ChatThread.new);

/// Reactions the server accepts (`REACTION_EMOJI`).
const chatReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
