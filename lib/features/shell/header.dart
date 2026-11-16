import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/offline/outbox.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../common/models.dart';
import '../common/pulse.dart';
import '../learner/learner_providers.dart';
import '../teacher/sync_sheet.dart';
import 'profile_sheet.dart';
import '../common/presence.dart';

/// Bell with the unread badge (student, parent).
class BellButton extends ConsumerWidget {
  const BellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(pulseProvider.select((p) => p.notificationsUnread));
    final l = context.l10n;
    return GIconButton(
      icon: GIcons.bell,
      label: unread > 0 ? l.notificationsUnread(unread) : l.notifications,
      badge: unread,
      onPressed: () => context.push('/notifications'),
    );
  }
}

/// The user's avatar: opens the profile sheet (roles, school, settings).
class AvatarButton extends ConsumerWidget {
  const AvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((a) => a.value));
    if (user == null) return const SizedBox.shrink();
    return GPressable(
      onTap: () => showProfileSheet(context),
      scale: 0.94,
      semanticLabel: context.l10n.profile,
      excludeChildSemantics: true,
      child: PersonAvatar(
        presence: PresenceRef.user(user.id),
        name: user.fullName,
        url: user.avatarUrl,
        size: 44,
        color: subjectOf(user.id).fill,
        dotRing: context.c.canvas,
      ),
    );
  }
}

/// Parent header: the selected child's avatar with a ring; tap opens the
/// children sheet, a horizontal swipe flips to the next child (§3.20).
class ChildSwitcherButton extends ConsumerWidget {
  const ChildSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider).value ?? const <Child>[];
    final child = ref.watch(currentChildProvider);
    if (child == null) return const AvatarButton();
    final c = context.c;
    void flip(int step) {
      if (children.length < 2) return;
      final i = children.indexWhere((x) => x.id == child.id);
      GHaptics.selection();
      ref.read(selectedChildProvider.notifier).select(children[(i + step) % children.length].id);
    }

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() > 200) flip(v < 0 ? 1 : -1);
      },
      child: GPressable(
        onTap: () => showChildrenSheet(context),
        scale: 0.94,
        semanticLabel: context.l10n.switchChild(child.shortName),
        excludeChildSemantics: true,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PersonAvatar(
                presence: PresenceRef.student(child.id),
                dotTop: true,
                dotRing: c.canvas,
                name: child.fullName,
                url: child.avatarUrl,
                size: 40,
                color: childColor(child.id),
                ring: childColor(child.id),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.canvas, width: 2),
                  ),
                  child: GIcon(GIcons.expand, size: 14, color: c.ink2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Each child gets one subject colour for the ring and family dots.
Color childColor(String childId) => gSubjects[[4, 1, 0, 5, 3, 7][subjectIndex(childId) % 6]].fill;

/// Teacher's sync capsule (§3.19): done / sending / waiting N / refused N.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(outboxStateProvider).value;
    final c = context.c;
    final l = context.l10n;
    final rejected = s?.rejected.length ?? 0;
    final pending = s?.pending.length ?? 0;
    final sending = s?.sending ?? false;
    final (IconData icon, Color fg, Color? bg, String label, int count) = rejected > 0
        ? (GIcons.syncFailed, c.bad, c.badSoft, l.syncRejectedN(rejected), rejected)
        : pending > 0
        ? (GIcons.syncing, c.warn, c.warnSoft, sending ? l.syncSending : l.syncPendingN(pending), pending)
        : (GIcons.synced, c.ok, null, l.syncAllSent, 0);
    return GPressable(
      onTap: () => showSyncSheet(context),
      scale: 0.94,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: SizedBox(
        height: 44,
        child: Center(
          child: Container(
            height: 40,
            constraints: const BoxConstraints(minWidth: 40),
            padding: EdgeInsets.symmetric(horizontal: count > 0 ? 12 : 8),
            decoration: ShapeDecoration(color: bg ?? Colors.transparent, shape: const StadiumBorder()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sending && rejected == 0)
                  SizedBox.square(dimension: 20, child: GLoader(size: 20, color: fg))
                else
                  GIcon(icon, size: 22, color: fg, fill: 1),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: context.t.subhead.copyWith(color: fg, fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Offline bar (§3.19): no network — how old the data on screen is.
class NetBanner extends ConsumerWidget {
  const NetBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final net = ref.watch(netProvider);
    if (!net.offline) return const SizedBox.shrink();
    final l = context.l10n;
    final at = net.lastFresh;
    return Padding(
      padding: EdgeInsets.fromLTRB(GSpace.gutter(context), 0, GSpace.gutter(context), 12),
      child: GStateRow(
        title: at == null ? l.offlineBarNoTime : l.offlineBar(_ago(context, at)),
        icon: GIcons.syncFailed,
      ),
    );
  }

  static String _ago(BuildContext context, DateTime at) {
    final now = DateTime.now();
    final sameDay = now.year == at.year && now.month == at.month && now.day == at.day;
    return sameDay ? Fmt.clock(at) : '${Fmt.dayMonth(at, context.localeTag)}, ${Fmt.clock(at)}';
  }
}

/// Human label of a queued write, for the queue sheet and the inbox.
String outboxWhat(AppLocalizations l, OutboxItem item) {
  final what = item.label['what'] ?? '';
  final state = item.label['state'] ?? '';
  return switch (what) {
    'attendance' => l.whatAttendance(state),
    'all_present' => l.whatAllPresent(int.tryParse(state) ?? 0),
    'grade' => state.isEmpty ? l.whatGradeRemoved : l.whatGrade(state),
    'topic' => l.whatTopic,
    'start' => l.whatStart,
    'finish' => l.whatFinish,
    'summary' => l.whatSummary,
    'homework' => l.whatHomework,
    'feedback' => l.whatFeedback,
    _ => item.path,
  };
}

String rejectText(AppLocalizations l, OutboxItem item) => switch (item.reason) {
  RejectReason.sochLock => l.reasonSoch,
  RejectReason.forbidden => l.reasonForbidden,
  RejectReason.notFound => l.reasonNotFound,
  _ => item.detail?.isNotEmpty == true ? '${l.reasonInvalid}: ${item.detail}' : l.reasonInvalid,
};
