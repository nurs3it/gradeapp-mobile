import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/offline/outbox.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../shell/header.dart';

/// Sync queue (T11, §5.3): refused records on top with the reason and
/// «Повторить» / «Удалить»; waiting ones below. Nothing is dropped silently.
Future<void> showSyncSheet(BuildContext context) {
  final l = context.l10n;
  return showGSheet<void>(context, title: l.syncTitle, bigTitle: true, builder: (_) => const _SyncBody());
}

class _SyncBody extends ConsumerWidget {
  const _SyncBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final s = ref.watch(outboxStateProvider).value ?? ref.read(outboxProvider).state;
    final outbox = ref.read(outboxProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.lastSentAt != null)
            Text(l.syncLast(Fmt.clock(s.lastSentAt!)), style: t.subhead.copyWith(color: c.ink2)),
          if (s.isEmpty) GEmpty(title: l.syncAllSent, message: l.syncAllSentHint, icon: GIcons.synced),
          if (s.rejected.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l.syncRejected(s.rejected.length), style: t.headline.copyWith(color: c.bad)),
            const SizedBox(height: 8),
            GGroup(
              children: [for (final i in s.rejected) _ItemRow(item: i, outbox: outbox)],
            ),
          ],
          if (s.pending.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text(l.syncWaiting(s.pending.length), style: t.headline)),
                if (s.sending) const GLoader(size: 20),
              ],
            ),
            const SizedBox(height: 8),
            GGroup(
              children: [for (final i in s.pending) _ItemRow(item: i, outbox: outbox)],
            ),
            const SizedBox(height: 12),
            GButton(
              label: l.retry,
              icon: GIcons.refresh,
              variant: GButtonVariant.tinted,
              expand: true,
              onPressed: () => unawaited(outbox.flush()),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.outbox});
  final OutboxItem item;
  final Outbox outbox;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final head = [item.label['lesson'], item.label['student']].where((s) => s != null && s.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (head.isNotEmpty) Text(head, style: t.footnote.copyWith(color: c.ink2)),
          Text(outboxWhat(l, item), style: t.bodyStrong),
          if (item.isRejected) ...[
            const SizedBox(height: 2),
            Text(rejectText(l, item), style: t.footnote.copyWith(color: c.bad)),
            const SizedBox(height: 10),
            Row(
              children: [
                GButton(
                  label: l.retry,
                  size: GButtonSize.s,
                  variant: GButtonVariant.tinted,
                  onPressed: () => unawaited(outbox.retry(item)),
                ),
                const SizedBox(width: 8),
                GButton(
                  label: l.delete,
                  size: GButtonSize.s,
                  variant: GButtonVariant.secondary,
                  onPressed: () async {
                    final ok = await confirmSheet(
                      context,
                      title: l.syncDeleteConfirm,
                      message: l.syncDeleteBody,
                      confirm: l.delete,
                      cancel: l.cancel,
                      destructive: true,
                    );
                    if (ok) await outbox.remove(item);
                  },
                ),
              ],
            ),
          ] else
            Text(l.createdAt(Fmt.clock(item.createdAt)), style: t.footnote.copyWith(color: c.ink3)),
        ],
      ),
    );
  }
}
