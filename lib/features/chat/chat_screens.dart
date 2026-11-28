import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../common/presence.dart';
import 'chat.dart';

/// «Сообщения»: conversations, pinned and newest first.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final me = ref.watch(authProvider).value?.id ?? '';
    final async = ref.watch(conversationsProvider);
    final list = async.value;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(
        backLabel: l.back,
        actions: [
          GIconButton(icon: GIcons.add, label: l.chatNew, onPressed: () => unawaited(showNewChat(context, ref))),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          GRefreshControl(onRefresh: () async => ref.invalidate(conversationsProvider)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom),
            sliver: SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 14),
                  child: Semantics(header: true, child: Text(l.chatTitle, style: context.t.title1)),
                ),
                if (list == null)
                  async.hasError
                      ? GEmpty(
                          error: true,
                          title: l.errorTitle,
                          message: l.errorOffline,
                          action: l.retry,
                          onAction: () => ref.invalidate(conversationsProvider),
                        )
                      : const GSkeleton(hero: false)
                else if (list.isEmpty)
                  GCard(
                    child: GEmpty(
                      title: l.chatEmpty,
                      message: l.chatEmptyHint,
                      icon: GIcons.chat,
                      action: l.chatNew,
                      onAction: () => unawaited(showNewChat(context, ref)),
                    ),
                  )
                else
                  GGroup(inset: 72, children: [for (final conv in list) _ConversationRow(conv: conv, me: me)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conv, required this.me});
  final Conversation conv;
  final String me;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final other = conv.other(me);
    final title = conv.titleFor(me);
    final last = conv.lastMessage;
    final preview = last == null
        ? ''
        : last.system
        ? l.chatSystem
        : [
            if (last.senderId == me) l.chatYou else if (!conv.isDirect) last.senderName.split(' ').first,
            last.text.isNotEmpty ? last.text : l.chatAttachment,
          ].join(': ');
    return GRow(
      minHeight: 72,
      leading: PersonAvatar(
        presence: other == null ? null : PresenceRef.user(other.userId),
        name: title,
        url: other?.avatarUrl,
        size: 44,
      ),
      title: Text(title, style: conv.unread > 0 ? context.t.headline : null),
      subtitle: Text(preview),
      subtitleMaxLines: 2,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (last != null) Text(chatTime(context, last.createdAt), style: context.t.footnote.copyWith(color: c.ink3)),
          const SizedBox(height: 4),
          if (conv.unread > 0)
            GCountBadge(count: conv.unread)
          else if (conv.muted)
            GIcon(GIcons.bell, size: 16, color: c.ink3),
        ],
      ),
      onTap: () => context.push('/chat/${conv.id}'),
    );
  }
}

/// «14:05» today, «пт» this week, «03.11» before.
String chatTime(BuildContext context, DateTime t, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final locale = Localizations.localeOf(context).toLanguageTag();
  final day = DateTime(t.year, t.month, t.day);
  final today = DateTime(n.year, n.month, n.day);
  if (day == today) return DateFormat.Hm(locale).format(t);
  if (today.difference(day).inDays < 7) return DateFormat.E(locale).format(t);
  return DateFormat('dd.MM').format(t);
}

/// Picks someone and opens the direct chat with them.
Future<void> showNewChat(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final userId = await showGSheet<String>(context, title: l.chatNew, full: true, scrollable: false, builder: (_) => const _PeoplePicker());
  if (userId == null || !context.mounted) return;
  await openChatWith(context, ref, userId);
}

/// Opens (creating if needed) the direct chat with [userId].
Future<void> openChatWith(BuildContext context, WidgetRef ref, String userId) async {
  try {
    final id = await ref.read(_openDirectProvider(userId).future);
    if (context.mounted) unawaited(context.push('/chat/$id'));
  } catch (_) {
    if (context.mounted) GToast.show(context, context.l10n.chatOpenFailed, icon: GIcons.error);
  } finally {
    ref.invalidate(_openDirectProvider(userId));
  }
}

final _openDirectProvider = FutureProvider.autoDispose.family<String, String>((ref, userId) => openDirectChat(ref, userId));

class _PeoplePicker extends ConsumerStatefulWidget {
  const _PeoplePicker();

  @override
  ConsumerState<_PeoplePicker> createState() => _PeoplePickerState();
}

class _PeoplePickerState extends ConsumerState<_PeoplePicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final async = ref.watch(chatCandidatesProvider(_q));
    final people = async.value;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: GField(
            hint: l.chatSearch,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: people == null
              ? (async.hasError
                    ? GEmpty(error: true, title: l.errorTitle, message: l.errorOffline)
                    : const Padding(padding: EdgeInsets.all(20), child: GSkeleton(hero: false)))
              : people.isEmpty
              ? GEmpty(title: l.chatNoOne, icon: GIcons.search)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    GGroup(
                      inset: 72,
                      children: [
                        for (final p in people)
                          GRow(
                            minHeight: 64,
                            leading: PersonAvatar(presence: PresenceRef.user(p.userId), name: p.name, url: p.avatarUrl, size: 40),
                            title: Text(p.name),
                            subtitle: p.classLine.isEmpty ? null : Text(p.classLine),
                            onTap: () => Navigator.of(context).pop(p.userId),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// One conversation: bubbles, day breaks, the composer.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final user = ref.read(authProvider).value;
    final body = _text.text;
    if (user == null || body.trim().isEmpty) return;
    GHaptics.light();
    _text.clear();
    unawaited(
      ref.read(chatThreadProvider(widget.id).notifier).send(body, myId: user.id, myName: '${user.firstName} ${user.lastName}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final me = ref.watch(authProvider).value?.id ?? '';
    final s = ref.watch(chatThreadProvider(widget.id));
    final conv = s.conversation;
    final thread = ref.read(chatThreadProvider(widget.id).notifier);
    final msgs = s.messages;
    final group = conv != null && !conv.isDirect;
    final canPost = conv?.canPost ?? true;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(
        backLabel: l.back,
        title: conv?.titleFor(me),
        actions: [
          if (conv != null)
            GIconButton(
              icon: GIcons.bell,
              label: conv.muted ? l.chatUnmute : l.chatMute,
              color: conv.muted ? c.ink3 : null,
              onPressed: () async {
                try {
                  await thread.setMuted(!conv.muted);
                  if (context.mounted) GToast.show(context, conv.muted ? l.chatUnmuted : l.chatMuted, icon: GIcons.bell);
                } catch (_) {
                  if (context.mounted) GToast.show(context, l.errorOffline, icon: GIcons.error);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: s.loading && msgs.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : s.error
                ? GEmpty(error: true, title: l.errorTitle, message: l.errorOffline, action: l.retry, onAction: () => ref.invalidate(chatThreadProvider(widget.id)))
                : msgs.isEmpty
                ? GEmpty(title: l.chatThreadEmpty, icon: GIcons.chat)
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      final m = msgs[msgs.length - 1 - i];
                      final prev = i + 1 < msgs.length ? msgs[msgs.length - 2 - i] : null;
                      final newDay = prev == null || !DateUtils.isSameDay(prev.createdAt, m.createdAt);
                      final firstOfRun = newDay || prev.senderId != m.senderId || prev.system;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (newDay) _DayBreak(day: m.createdAt),
                          _Bubble(
                            m: m,
                            mine: m.senderId == me,
                            showName: group && firstOfRun && m.senderId != me,
                            me: me,
                            onRetry: () {
                              final user = ref.read(authProvider).value;
                              if (user == null) return;
                              unawaited(thread.send(m.text, myId: user.id, myName: m.senderName, retryId: m.id));
                            },
                            onReact: (emoji, mine) => unawaited(thread.react(m, emoji, mine: mine)),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (canPost) _Composer(controller: _text, onSend: _send) else _ReadOnlyBar(text: l.chatReadOnly),
        ],
      ),
    );
  }
}

class _DayBreak extends StatelessWidget {
  const _DayBreak({required this.day});
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final label = DateUtils.isSameDay(day, now)
        ? context.l10n.todayWord
        : DateFormat(day.year == now.year ? 'd MMMM' : 'd MMMM y', locale).format(day);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: Text(label, style: context.t.footnote.copyWith(color: context.c.ink3))),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.m,
    required this.mine,
    required this.showName,
    required this.me,
    required this.onRetry,
    required this.onReact,
  });
  final ChatMessage m;
  final bool mine;
  final bool showName;
  final String me;
  final VoidCallback onRetry;
  final void Function(String emoji, bool mine) onReact;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l10n;
    if (m.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(child: Text(l.chatSystem, style: context.t.footnote.copyWith(color: c.ink3))),
      );
    }
    final fg = mine ? Colors.white : c.ink;
    final url = m.attachmentUrl;
    final time = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(m.createdAt);
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
      decoration: ShapeDecoration(
        color: mine ? (m.failed ? c.bad : c.primary) : c.surface,
        shape: GRadius.surface(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (url != null)
            GestureDetector(
              onTap: () => unawaited(launchUrl(Uri.parse(absoluteMediaUrl(url)), mode: LaunchMode.externalApplication)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GIcon(GIcons.attach, size: 18, color: fg),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        m.attachmentName.isEmpty ? l.chatAttachment : m.attachmentName,
                        style: context.t.subhead.copyWith(color: fg, decoration: TextDecoration.underline, decorationColor: fg),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (m.text.isNotEmpty) Text(m.text, style: context.t.body.copyWith(color: fg)),
          const SizedBox(height: 2),
          Text(
            [
              if (m.edited) l.chatEdited,
              if (m.failed) l.chatSendFailed else if (m.pending) l.chatSending else time,
            ].join(' · '),
            style: context.t.caption.copyWith(color: mine ? Colors.white70 : c.ink3, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(top: showName ? 8 : 2, bottom: 2),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName)
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 2),
              child: Text(m.senderName, style: context.t.footnote.copyWith(color: c.ink2)),
            ),
          GestureDetector(
            onTap: m.failed ? onRetry : null,
            onLongPress: m.pending || m.failed ? null : () => unawaited(_actions(context)),
            child: Semantics(label: '${mine ? l.chatYou : m.senderName}, $time', child: bubble),
          ),
          if (m.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                spacing: 4,
                children: [
                  for (final r in m.reactions)
                    GestureDetector(
                      onTap: () => onReact(r.emoji, r.userIds.contains(me)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: ShapeDecoration(
                          color: r.userIds.contains(me) ? c.primarySoft : c.surface2,
                          shape: const StadiumBorder(),
                        ),
                        child: Text('${r.emoji} ${r.userIds.length}', style: context.t.footnote),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _actions(BuildContext context) async {
    GHaptics.light();
    final l = context.l10n;
    final mineEmoji = m.reactions.where((r) => r.userIds.contains(me)).map((r) => r.emoji).firstOrNull;
    await showGSheet<void>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final e in chatReactions)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onReact(e, e == mineEmoji);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: e == mineEmoji ? ctx.c.primarySoft : ctx.c.surface2,
                        shape: const CircleBorder(),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
            if (m.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              GButton(
                label: l.copy,
                variant: GButtonVariant.tinted,
                onPressed: () {
                  unawaited(Clipboard.setData(ClipboardData(text: m.text)));
                  Navigator.of(ctx).pop();
                  GToast.show(context, l.copied, icon: GIcons.copy);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `/media/…` from the API is relative to the site, not to `/api`.
String absoluteMediaUrl(String url) {
  if (url.startsWith('http')) return url;
  final api = Uri.parse(apiBaseUrl);
  return api.replace(path: url, query: null).toString();
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l10n;
    return Container(
      color: c.surface,
      padding: EdgeInsets.fromLTRB(12, 8, 8, 8 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: context.t.body.copyWith(color: c.ink),
              decoration: InputDecoration(
                hintText: l.chatInputHint,
                hintStyle: context.t.body.copyWith(color: c.ink3),
                filled: true,
                fillColor: c.surface2,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, _) => GIconButton(
              icon: GIcons.send,
              label: l.chatSend,
              color: v.text.trim().isEmpty ? c.ink3 : c.primary,
              onPressed: v.text.trim().isEmpty ? null : onSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyBar extends StatelessWidget {
  const _ReadOnlyBar({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    color: context.c.surface,
    padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.paddingOf(context).bottom),
    child: Text(text, textAlign: TextAlign.center, style: context.t.footnote.copyWith(color: context.c.ink2)),
  );
}
