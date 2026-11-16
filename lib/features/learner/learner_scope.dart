import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import 'learner_providers.dart';

/// Shown while the learner id is unknown: loading, error, or a parent with
/// no linked children.
class LearnerPending extends ConsumerWidget {
  const LearnerPending({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isParent = ref.watch(activeRoleProvider) == AppRole.parent;
    final loaded = isParent ? ref.watch(childrenProvider) : ref.watch(myStudentIdProvider);
    if (isParent && loaded.hasValue) {
      final l = context.l10n;
      return GEmptyState(icon: Icons.family_restroom_rounded, title: l.noChildrenTitle, message: l.noChildrenMessage);
    }
    return GAsync(
      value: loaded,
      data: (_) => const GSkeletonList(),
      onRetry: () => ref.invalidate(isParent ? childrenProvider : myStudentIdProvider),
    );
  }
}

/// Parent only: chips with each child; hidden for students and single-child
/// parents with nothing to switch.
class ChildSwitcher extends ConsumerWidget {
  const ChildSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(activeRoleProvider) != AppRole.parent) return const SizedBox.shrink();
    final children = ref.watch(childrenProvider).value ?? const [];
    if (children.length < 2) return const SizedBox.shrink();
    final current = ref.watch(learnerIdProvider);
    final c = context.c;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GSpace.page, vertical: 4),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: GSpace.sm),
        itemBuilder: (context, i) {
          final child = children[i];
          final selected = child.id == current;
          return Material(
            color: selected ? c.primarySoft : c.card,
            shape: StadiumBorder(side: BorderSide(color: selected ? c.primary : c.border)),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                ref.read(selectedChildProvider.notifier).select(child.id);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
                child: Row(
                  children: [
                    GAvatar(name: child.fullName, url: child.avatarUrl, size: 34),
                    const SizedBox(width: GSpace.sm),
                    Text(
                      child.firstName.isEmpty ? child.fullName : child.firstName,
                      style: context.t.titleSmall!.copyWith(color: selected ? c.primarySoftForeground : null),
                    ),
                    if (child.className != null) ...[
                      const SizedBox(width: 6),
                      Text(child.className!, style: context.t.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
