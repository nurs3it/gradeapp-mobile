import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/shell.dart';
import '../../core/grading.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../school/school_providers.dart';
import 'learner_providers.dart';
import 'learner_scope.dart';
import 'models.dart';

/// One subject's marks, newest first.
class SubjectGrades {
  SubjectGrades(this.courseId, this.name, this.grades);
  final String courseId;
  final String name;
  final List<Grade> grades;

  /// Mean of plain marks; scored works (СОР/СОЧ x/N) are shown, not averaged.
  double? get average {
    final marks = grades.where((g) => g.maxValue == null).map((g) => g.value);
    return marks.isEmpty ? null : marks.reduce((a, b) => a + b) / marks.length;
  }
}

List<SubjectGrades> groupBySubject(List<Grade> grades) {
  final map = <String, SubjectGrades>{};
  for (final g in grades) {
    (map[g.courseId] ??= SubjectGrades(g.courseId, g.courseName, [])).grades.add(g);
  }
  return map.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final id = ref.watch(learnerIdProvider);
    final grading = ref.watch(gradingOrDefaultProvider);
    return GPage(
      title: l.tabGrades,
      header: const ChildSwitcher(),
      onRefresh: id == null ? null : () => ref.refresh(gradesProvider(id).future),
      slivers: [
        if (id == null)
          const SliverToBoxAdapter(child: LearnerPending())
        else
          SliverToBoxAdapter(
            child: GAsync(
              value: ref.watch(gradesProvider(id)),
              onRetry: () => ref.invalidate(gradesProvider(id)),
              data: (grades) {
                if (grades.isEmpty) {
                  return GEmptyState(
                    icon: Icons.star_outline_rounded,
                    title: l.gradesEmptyTitle,
                    message: l.gradesEmptyMessage,
                  );
                }
                return Column(
                  children: [
                    for (final s in groupBySubject(grades))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(GSpace.page, 0, GSpace.page, GSpace.sm),
                        child: _SubjectCard(
                          subject: s,
                          grading: grading,
                          onTap: () => context.push('/l/grades/${s.courseId}'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.grading, required this.onTap});
  final SubjectGrades subject;
  final Grading grading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avg = subject.average;
    final c = context.c;
    return GCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(color: c.subject(subject.name), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: GSpace.sm),
              Expanded(
                child: Text(subject.name, style: context.t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (avg != null) ...[
                Text(context.l10n.average, style: context.t.bodySmall),
                const SizedBox(width: 6),
                GGradeChip(value: double.parse(avg.toStringAsFixed(1)), grading: grading, size: 34),
              ],
            ],
          ),
          const SizedBox(height: GSpace.md),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subject.grades.length.clamp(0, 10),
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final g = subject.grades[i];
                return GGradeChip(value: g.value, maxValue: g.maxValue, grading: grading, size: 32);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectGradesScreen extends ConsumerWidget {
  const SubjectGradesScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(learnerIdProvider);
    final grading = ref.watch(gradingOrDefaultProvider);
    final all = id == null ? const <Grade>[] : (ref.watch(gradesProvider(id)).value ?? const <Grade>[]);
    final grades = all.where((g) => g.courseId == courseId).toList();
    final name = grades.isEmpty ? '' : grades.first.courseName;
    final fmt = DateFormat('d MMMM, EEE', context.localeTag);
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.only(top: GSpace.sm, bottom: GSpace.xxl),
        children: [
          GGroup(
            inset: 68,
            children: [
              for (final g in grades)
                GRow(
                  leading: GGradeChip(value: g.value, maxValue: g.maxValue, grading: grading, size: 40),
                  title: Text(fmt.format(DateTime.parse(g.date))),
                  subtitle: Text(
                    [
                      grading.typeName(g.type),
                      if (g.comment.isNotEmpty) g.comment,
                    ].where((s) => s.isNotEmpty).join(' · '),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
