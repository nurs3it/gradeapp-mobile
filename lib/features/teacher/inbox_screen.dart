import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../common/pulse.dart';
import '../notifications/notifications.dart';
import '../shell/header.dart';
import 'my_class_providers.dart' show hasHomeroomProvider;
import 'sync_sheet.dart';
import 'teacher_providers.dart';

/// Teacher «Входящие» (C4, §5.5): what needs action first (refused records,
/// unmarked lessons, absence requests), then schedule changes, then the rest.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final now = ref.now;
    final rejected = ref.watch(outboxStateProvider.select((s) => s.value?.rejected.length ?? 0));
    final day = ref.watch(teacherDayProvider(isoDate(now))).value;
    final unmarked = day?.overdue.where((t) => t.needsAttendance).length ?? 0;
    final excuses = ref.watch(pulseProvider.select((p) => p.inbox));
    final chats = ref.watch(pulseProvider.select((p) => p.chatUnread));
    final homeroom = ref.watch(hasHomeroomProvider);
    final list = ref.watch(notificationsProvider);
    final read = ref.watch(readIdsProvider);
    final items = list.value ?? const <AppNotification>[];
    final schedule = items.where((n) => n.type.startsWith('lesson.')).toList();
    final other = items.where((n) => !n.type.startsWith('lesson.')).toList();
    final unread = items.where((n) => !n.read && !read.contains(n.id)).toList();
    final messages = GGroup(
      inset: 68,
      children: [
        GRow(
          minHeight: 64,
          leading: const _Plate(icon: GIcons.chat, tone: GTone.info),
          title: Text(l.chatTitle),
          subtitle: Text(chats > 0 ? l.chatUnreadCount(chats) : l.chatInboxSub),
          trailing: chats > 0 ? GCountBadge(count: chats) : null,
          chevron: chats == 0,
          onTap: () => context.push('/chat'),
        ),
      ],
    );
    final action = <Widget>[
      if (rejected > 0)
        GRow(
          minHeight: 72,
          leading: const _Plate(icon: GIcons.syncFailed, tone: GTone.bad),
          title: Text(l.inboxRejected),
          subtitle: Text(l.inboxRejectedSub),
          trailing: GCountBadge(count: rejected),
          onTap: () => showSyncSheet(context),
        ),
      if (unmarked > 0)
        GRow(
          minHeight: 72,
          leading: const _Plate(icon: GIcons.info, tone: GTone.warn),
          title: Text(l.tDebtsUnmarked(unmarked)),
          subtitle: Text(l.tDebts),
          chevron: true,
          onTap: () => StatefulNavigationShell.maybeOf(context)?.goBranch(0),
        ),
      if (excuses > 0)
        GRow(
          minHeight: 72,
          leading: const _Plate(icon: GIcons.excuse, tone: GTone.info),
          title: Text(l.inboxExcuses(excuses)),
          subtitle: Text(homeroom ? l.t8InboxSub : l.inboxExcusesSub),
          trailing: homeroom ? null : GIcon(GIcons.openInNew, size: 20, color: c.ink3),
          chevron: homeroom,
          // T8: a homeroom teacher decides in «Мой класс», others on the web.
          onTap: homeroom
              ? () => context.go('/t/class')
              : () => launchUrl(Uri.parse('https://grade-app.kz/teacher'), mode: LaunchMode.externalApplication),
        ),
    ];

    Widget notifGroup(List<AppNotification> list) => GGroup(
      inset: 68,
      children: [
        for (final n in list.take(30))
          Dismissible(
            key: ValueKey('n-${n.id}'),
            direction: n.read || read.contains(n.id) ? DismissDirection.none : DismissDirection.endToStart,
            background: Container(
              color: c.primarySoft,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Text(l.markRead, style: context.t.bodyStrong.copyWith(color: c.primarySoftText)),
            ),
            confirmDismiss: (_) async {
              GHaptics.light();
              await markRead(ref, n);
              return false;
            },
            child: NotificationRow(
              n: n,
              read: n.read || read.contains(n.id),
              onTap: () => openNotification(context, ref, n),
            ),
          ),
      ],
    );

    final empty = action.isEmpty && items.isEmpty && list.hasValue;
    return GRootPage(
      title: l.tabInbox,
      actions: [
        if (unread.isNotEmpty)
          GButton(
            label: l.markAllRead,
            variant: GButtonVariant.plain,
            size: GButtonSize.s,
            onPressed: () => markAllRead(ref, unread),
          ),
        const AvatarButton(),
      ],
      below: const NetBanner(),
      onRefresh: () async {
        ref
          ..invalidate(notificationsProvider)
          ..invalidate(teacherDayProvider);
        await ref.read(pulseProvider.notifier).refresh();
      },
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: g),
          sliver: SliverList.list(
            children: [
              messages,
              if (empty) GEmpty(title: l.inboxEmpty, message: l.inboxEmptyHint, icon: GIcons.inbox),
              if (action.isNotEmpty) ...[GSectionTitle(title: l.inboxAction), GGroup(inset: 68, children: action)],
              if (schedule.isNotEmpty) ...[GSectionTitle(title: l.inboxSchedule), notifGroup(schedule)],
              if (other.isNotEmpty) ...[GSectionTitle(title: l.inboxOther), notifGroup(other)],
              if (list.isLoading && !list.hasValue) const GSkeleton(hero: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.icon, required this.tone});
  final IconData icon;
  final GTone tone;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: ShapeDecoration(color: tone.soft(context.c), shape: GRadius.surface(13)),
    child: GIcon(icon, size: 22, color: tone.fg(context.c), fill: 1),
  );
}
