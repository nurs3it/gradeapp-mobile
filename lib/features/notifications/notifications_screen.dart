import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'notifications.dart';

/// «Уведомления» of students and parents (C4, §6.1): by day, tap opens the
/// target and marks it read.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final list = ref.watch(notificationsProvider);
    final read = ref.watch(readIdsProvider);
    final items = list.value ?? const <AppNotification>[];
    final unread = items.where((n) => !n.read && !read.contains(n.id)).toList();
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(
        title: l.notifications,
        backLabel: l.back,
        actions: [
          if (unread.isNotEmpty)
            GButton(
              label: l.markAllRead,
              variant: GButtonVariant.plain,
              size: GButtonSize.s,
              onPressed: () => markAllRead(ref, unread),
            ),
        ],
      ),
      body: switch (list) {
        AsyncValue(:final value?) when value.isEmpty => GEmpty(title: l.notifEmpty, message: l.notifEmptyHint, icon: GIcons.bell),
        AsyncValue(:final value?) => RefreshIndicator.adaptive(
          onRefresh: () async => ref.invalidate(notificationsProvider),
          child: ListView(
            padding: EdgeInsets.fromLTRB(g, 0, g, 40 + MediaQuery.paddingOf(context).bottom),
            children: [
              for (final (title, group) in groupByDay(context, value)) ...[
                GSectionTitle(title: title),
                GGroup(
                  inset: 68,
                  children: [
                    for (final n in group)
                      NotificationRow(
                        n: n,
                        read: n.read || read.contains(n.id),
                        onTap: () => openNotification(context, ref, n),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        AsyncValue(:final error?) => GEmpty(
          error: true,
          title: l.errorTitle,
          message: '$error'.isEmpty ? null : l.errorOffline,
          action: l.retry,
          onAction: () => ref.invalidate(notificationsProvider),
        ),
        _ => const Center(child: GLoader()),
      },
    );
  }
}
