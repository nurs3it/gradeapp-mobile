import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'learner_providers.dart';
import 'learner_scope.dart';
import 'models.dart';
import 'widgets.dart';

class HomeworkScreen extends ConsumerStatefulWidget {
  const HomeworkScreen({super.key});

  @override
  ConsumerState<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends ConsumerState<HomeworkScreen> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final id = ref.watch(learnerIdProvider);
    return GPage(
      title: l.tabHomework,
      header: Column(
        children: [
          const ChildSwitcher(),
          Padding(
            padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.xs, GSpace.page, GSpace.sm),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: false, label: Text(l.homeworkActive)),
                  ButtonSegment(value: true, label: Text(l.homeworkDoneTab)),
                ],
                selected: {_done},
                onSelectionChanged: (s) => setState(() => _done = s.first),
              ),
            ),
          ),
        ],
      ),
      onRefresh: id == null ? null : () => ref.refresh(homeworkProvider(id).future),
      slivers: [
        if (id == null)
          const SliverToBoxAdapter(child: LearnerPending())
        else
          SliverToBoxAdapter(
            child: GAsync(
              value: ref.watch(homeworkProvider(id)),
              onRetry: () => ref.invalidate(homeworkProvider(id)),
              data: (all) {
                final list = all.where((h) => h.isDone == _done).toList();
                if (list.isEmpty) {
                  return GEmptyState(
                    icon: Icons.task_alt_rounded,
                    title: l.homeworkEmptyTitle,
                    message: l.homeworkEmptyMessage,
                  );
                }
                // Group by due date: one card per day.
                final byDay = <String, List<Homework>>{};
                for (final h in list) {
                  (byDay[h.dueDate] ??= []).add(h);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final MapEntry(key: day, value: items) in byDay.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.lg, GSpace.page, GSpace.sm),
                        child: Text(dueLabel(context, day).toUpperCase(), style: context.t.labelSmall),
                      ),
                      GGroup(
                        inset: 56,
                        children: [for (final h in items) HomeworkTile(key: ValueKey(h.id), homework: h)],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
