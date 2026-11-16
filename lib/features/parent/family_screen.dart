import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../learner/learner_providers.dart';
import '../shell/header.dart';
import 'excuse_sheet.dart';

/// Parent «Семья» in 1.0 (§4.5): excuse a child, requests with statuses,
/// children with the photo consent. Payments, teachers and news come in 1.2.
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final children = ref.watch(childrenProvider).value ?? const <Child>[];
    final current = ref.watch(currentChildProvider);
    final requests = [
      for (final ch in children) ...(ref.watch(excusesProvider(ch.id)).value ?? const <Excuse>[]),
    ]..sort((a, b) {
        final active = (b.status == ExcuseStatus.pending ? 1 : 0).compareTo(a.status == ExcuseStatus.pending ? 1 : 0);
        return active != 0 ? active : b.startDate.compareTo(a.startDate);
      });
    final loading = children.any((ch) => !ref.watch(excusesProvider(ch.id)).hasValue);

    return GRootPage(
      title: l.familyTitle,
      actions: const [BellButton(), ChildSwitcherButton()],
      below: const NetBanner(),
      onRefresh: () async {
        ref
          ..invalidate(excusesProvider)
          ..invalidate(childrenProvider);
        await ref.read(childrenProvider.future).then((_) {}, onError: (Object _) {});
      },
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: g),
          sliver: SliverList.list(
            children: [
              if (current != null)
                GCard(
                  color: c.primarySoft,
                  onTap: () => showExcuseSheet(context, studentId: current.id),
                  semanticLabel: l.familyExcuseCard,
                  child: Row(
                    children: [
                      GIcon(GIcons.excuse, size: 28, color: c.primarySoftText),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.familyExcuseCard, style: context.t.bodyStrong.copyWith(color: c.primarySoftText)),
                            const SizedBox(height: 2),
                            Text(l.familyExcuseHint, style: context.t.footnote.copyWith(color: c.primarySoftText)),
                          ],
                        ),
                      ),
                      GIcon(GIcons.chevron, size: 22, color: c.primarySoftText),
                    ],
                  ),
                ),
              GSectionTitle(title: l.requests),
              if (loading && requests.isEmpty)
                const GSkeleton(hero: false, rows: 2)
              else if (requests.isEmpty)
                GCard(child: GEmpty(title: l.reqEmpty, message: l.reqEmptyHint))
              else
                GGroup(
                  children: [
                    for (final r in requests.take(30)) _RequestRow(excuse: r, showName: children.length > 1),
                  ],
                ),
              if (children.isNotEmpty) ...[
                GSectionTitle(title: l.profileChildren),
                GGroup(
                  inset: 68,
                  children: [
                    for (final ch in children)
                      GRow(
                        leading: GAvatar(name: ch.fullName, url: ch.avatarUrl, size: 40, color: childColor(ch.id)),
                        title: Text(ch.fullName),
                        subtitle: Text(
                          [?ch.className, '${l.photoConsent}: ${ch.photoConsent ? l.consentOn : l.consentOff}'].join(' · '),
                        ),
                        trailing: ch.photoConsent
                            ? null
                            : GButton(
                                label: l.actAllow,
                                size: GButtonSize.s,
                                variant: GButtonVariant.tinted,
                                onPressed: () => showConsentSheet(context, ref, studentId: ch.id, name: ch.shortName),
                              ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow({required this.excuse, required this.showName});
  final Excuse excuse;
  final bool showName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final e = excuse;
    final loc = context.localeTag;
    final from = Fmt.dayMonth(DateTime.parse(e.startDate), loc);
    final to = Fmt.dayMonth(DateTime.parse(e.endDate), loc);
    final (GTone tone, String label, IconData icon) = switch (e.status) {
      ExcuseStatus.pending => (GTone.info, l.reqPending, GIcons.pending),
      ExcuseStatus.approved => (GTone.ok, l.reqApproved, GIcons.ok),
      ExcuseStatus.rejected => (GTone.bad, l.reqRejected, GIcons.error),
      ExcuseStatus.cancelled => (GTone.neutral, l.reqCancelled, GIcons.undo),
    };
    return GRow(
      title: Text([if (showName && e.studentName != null) e.studentName!, categoryName(l, e.category)].join(' · ')),
      subtitle: Text(
        [
          from == to ? from : '$from – $to',
          if (e.status == ExcuseStatus.rejected && e.reviewNote.isNotEmpty) e.reviewNote else if (e.reason.isNotEmpty) e.reason,
        ].join(' · '),
      ),
      subtitleMaxLines: 2,
      trailing: GStatusPill(label: label, tone: tone, icon: icon),
      onTap: e.status != ExcuseStatus.pending
          ? null
          : () async {
              final ok = await confirmSheet(
                context,
                title: l.reqWithdrawConfirm,
                confirm: l.reqWithdraw,
                cancel: l.cancel,
                destructive: true,
              );
              if (!ok) return;
              try {
                await ref.read(dioProvider).patch<void>('/excuses/${e.id}/', data: {'status': 'cancelled'});
                ref.invalidate(excusesProvider(e.studentId));
              } catch (_) {
                GHaptics.error();
                if (context.mounted) GToast.show(context, l.errorGeneric, icon: GIcons.error);
              }
            },
    );
  }
}
