import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../common/attachments.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import '../shell/header.dart';
import 'grades_screen.dart' show learnerGradeLevelProvider;
import 'learner_providers.dart';

enum _Section { overdue, today, tomorrow, week, later }

/// «Задания» (S9, §3.7): by due date, with the evening's minutes against the
/// norm; done with a tap or a swipe, undo in a toast.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? _course;
  bool _showDone = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final g = GSpace.gutter(context);
    final id = ref.watch(learnerIdProvider);
    final parent = ref.watch(activeRoleProvider) == AppRole.parent;
    final now = ref.now;
    if (id == null) return const Scaffold(body: Center(child: GLoader()));
    final hw = ref.watch(homeworkProvider(id));
    final overrides = ref.watch(homeworkOverridesProvider);
    final all = [
      for (final h in hw.value ?? const <Homework>[]) overrides.containsKey(h.id) ? h.withDone(overrides[h.id]!) : h,
    ];
    final today = dateOnly(now);
    final monday = mondayOf(now);
    final sunday = monday.add(const Duration(days: 6));
    final weekCount = all.where((h) {
      final d = DateTime.parse(h.dueDate);
      return !d.isBefore(monday) && !d.isAfter(sunday);
    }).length;
    final courses = {for (final h in all) h.courseId: h.courseName};
    final visible = all.where((h) => _course == null || h.courseId == _course).toList();

    _Section sectionOf(Homework h) {
      final d = DateTime.parse(h.dueDate);
      final diff = d.difference(today).inDays;
      if (diff < 0) return _Section.overdue;
      if (diff == 0) return _Section.today;
      if (diff == 1) return _Section.tomorrow;
      if (!d.isAfter(sunday)) return _Section.week;
      return _Section.later;
    }

    final open = visible.where((h) => !h.isDone).toList();
    // Overdue only within the current quarter's reach (last 30 days).
    final sections = <_Section, List<Homework>>{};
    for (final h in open) {
      final s = sectionOf(h);
      if (s == _Section.overdue && today.difference(DateTime.parse(h.dueDate)).inDays > 30) continue;
      (sections[s] ??= []).add(h);
    }
    final done = visible.where((h) => h.isDone).toList()..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    final norm = ref.watch(gradingProvider).homeworkNorms[ref.watch(learnerGradeLevelProvider) ?? -1];

    return GRootPage(
      eyebrow: l.tasksEyebrow(weekCount),
      title: l.tabTasks,
      actions: [const BellButton(), if (parent) const ChildSwitcherButton() else const AvatarButton()],
      below: const NetBanner(),
      onRefresh: () async {
        ref.invalidate(homeworkProvider(id));
        await ref.read(homeworkProvider(id).future).then((_) {}, onError: (Object _) {});
      },
      slivers: [
        if (courses.length > 1)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: g),
                children: [
                  GChip(label: l.allSubjects, selected: _course == null, onTap: () => setState(() => _course = null)),
                  for (final e in courses.entries)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GChip(
                        label: e.value,
                        dot: context.c.subjectMarker(e.value),
                        selected: _course == e.key,
                        onTap: () => setState(() => _course = _course == e.key ? null : e.key),
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (hw.isLoading && !hw.hasValue)
          const SliverToBoxAdapter(child: GSkeleton(hero: false))
        else if (hw.hasError && !hw.hasValue)
          SliverToBoxAdapter(
            child: GEmpty(
              error: true,
              title: l.errorTitle,
              message: l.errorOffline,
              action: l.retry,
              onAction: () => ref.invalidate(homeworkProvider(id)),
            ),
          )
        else if (open.isEmpty && done.isEmpty)
          SliverToBoxAdapter(
            child: GEmpty(title: l.tasksEmpty, message: l.tasksEmptyHint),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: g),
            sliver: SliverList.list(
              children: [
                for (final s in _Section.values)
                  if (sections[s]?.isNotEmpty ?? false) ...[
                    _SectionHeader(section: s, items: sections[s]!, norm: norm),
                    GGroup(
                      inset: 60,
                      children: [for (final h in sections[s]!) _TaskRow(hw: h, parent: parent, studentId: id)],
                    ),
                  ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GGroup(
                    children: [
                      GRow(
                        minHeight: GSpace.rowCompact,
                        leading: GIcon(GIcons.ok, size: 22, color: context.c.ok, fill: 1),
                        title: Text(l.sectionDone(done.length)),
                        trailing: AnimatedRotation(
                          turns: _showDone ? 0.25 : 0,
                          duration: GMotion.quick,
                          child: GIcon(GIcons.chevron, size: 22, color: context.c.ink3),
                        ),
                        onTap: () => setState(() => _showDone = !_showDone),
                      ),
                      if (_showDone)
                        for (final h in done.take(40)) _TaskRow(hw: h, parent: parent, studentId: id),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section, required this.items, required this.norm});
  final _Section section;
  final List<Homework> items;
  final int? norm;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final minutes = items.fold<int>(0, (s, h) => s + (h.minutes ?? 0));
    final title = switch (section) {
      _Section.overdue => l.sectionOverdue,
      _Section.today => l.sectionToday,
      _Section.tomorrow => l.sectionTomorrow,
      _Section.week => l.sectionWeek,
      _Section.later => l.sectionLater,
    };
    final showLoad =
        (section == _Section.tomorrow || section == _Section.today) && norm != null && norm! > 0 && minutes > 0;
    return Padding(
      padding: const EdgeInsets.only(top: GSpace.sectionTop, bottom: GSpace.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (section == _Section.overdue) ...[
                GIcon(GIcons.error, size: 20, color: c.bad, fill: 1),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    minutes > 0 && section != _Section.overdue ? '$title · ${l.approxMinutes(minutes)}' : title,
                    style: context.t.title2.copyWith(color: section == _Section.overdue ? c.bad : null),
                  ),
                ),
              ),
            ],
          ),
          if (showLoad) ...[
            const SizedBox(height: 8),
            GBar(value: minutes / norm!, color: minutes > norm! ? GColors.warnFill : GColors.brand, height: 4),
            const SizedBox(height: 4),
            Text(l.loadToday(minutes, norm!), style: context.t.footnote.copyWith(color: c.ink2)),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.hw, required this.parent, required this.studentId});
  final Homework hw;
  final bool parent;
  final String studentId;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final done = !hw.isDone;
    GHaptics.light();
    final ok = await setHomeworkDone(ref, hw, done);
    if (!context.mounted) return;
    if (!ok) {
      GHaptics.error();
      GToast.show(context, l.errorGeneric, icon: GIcons.error);
      return;
    }
    GToast.show(
      context,
      done ? l.doneToast : l.undoneToast,
      actionLabel: l.undo,
      onAction: () => unawaited(setHomeworkDone(ref, hw, !done)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = context.l10n;
    final sub = [
      hw.courseName,
      if (hw.minutes != null) l.approxMinutes(hw.minutes!),
      if (hw.attachments.isNotEmpty) l.attachmentsCount(hw.attachments.length),
      l.dueBy(Fmt.dayMonth(DateTime.parse(hw.dueDate), context.localeTag)),
    ].join(' · ');
    final row = GRow(
      minHeight: 72,
      onTap: () => showTaskSheet(context, ref, hw, parent: parent),
      leading: parent
          ? null
          : _CheckCircle(
              done: hw.isDone,
              label: hw.isDone ? l.taskToggleUndone(hw.title) : l.taskToggleDone(hw.title),
              onTap: () => _toggle(context, ref),
            ),
      marker: c.subjectMarker(hw.courseName),
      title: Text(
        hw.title,
        style: hw.isDone ? TextStyle(color: c.ink2, decoration: TextDecoration.lineThrough) : null,
      ),
      titleMaxLines: 2,
      subtitle: Text(sub),
      trailing: parent
          ? GStatusPill(
              label: hw.isDone ? l.hwDone : l.hwNotDone,
              tone: hw.isDone ? GTone.ok : GTone.neutral,
              icon: hw.isDone ? GIcons.ok : null,
            )
          : null,
    );
    if (parent) return row;
    return Dismissible(
      key: ValueKey('hw-${hw.id}'),
      direction: hw.isDone ? DismissDirection.none : DismissDirection.startToEnd,
      dismissThresholds: const {DismissDirection.startToEnd: 0.3},
      background: Container(
        color: c.okSoft,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: GIcon(GIcons.ok, color: c.ok, fill: 1),
      ),
      confirmDismiss: (_) async {
        await _toggle(context, ref);
        return false;
      },
      child: Semantics(
        customSemanticsActions: {CustomSemanticsAction(label: l.markDone): () => unawaited(_toggle(context, ref))},
        child: row,
      ),
    );
  }
}

/// 28 pt circle in a 44 pt target: fills with `ok` and draws the check.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done, required this.label, required this.onTap});
  final bool done;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GPressable(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: SizedBox.square(
        dimension: 44,
        child: Center(
          child: AnimatedContainer(
            duration: GMotion.quick,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? GColors.okFill : Colors.transparent,
              border: Border.all(color: done ? GColors.okFill : c.ink3, width: 2),
            ),
            child: AnimatedScale(
              scale: done ? 1 : 0,
              duration: GMotion.base,
              curve: SpringCurve.snap,
              child: const GIcon(GIcons.check, size: 18, color: GColors.onFill),
            ),
          ),
        ),
      ),
    );
  }
}

/// Task detail (full sheet, §3.7).
Future<void> showTaskSheet(BuildContext context, WidgetRef ref, Homework hw, {required bool parent}) {
  final l = context.l10n;
  return showGSheet<void>(
    context,
    full: true,
    closeLabel: l.close,
    builder: (ctx) {
      final c = ctx.c;
      final t = ctx.t;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(color: c.subjectTint(hw.courseName), shape: GRadius.surface(GRadius.card)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hw.courseName, style: t.headline.copyWith(color: c.subjectMarker(hw.courseName))),
                  Text(
                    l.dueBy(Fmt.shortWeekdayDayMonth(DateTime.parse(hw.dueDate), ctx.localeTag)),
                    style: t.footnote.copyWith(color: c.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(hw.title, style: t.title1),
            if (hw.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelectableText(hw.description, style: t.body),
            ],
            if (hw.attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              AttachmentsView(attachments: hw.attachments),
            ],
            const SizedBox(height: 16),
            Text(
              [?hw.teacherName, if (hw.minutes != null) l.approxMinutes(hw.minutes!)].join(' · '),
              style: t.footnote.copyWith(color: c.ink2),
            ),
          ],
        ),
      );
    },
    actions: parent
        ? null
        : Consumer(
            builder: (ctx, ref, _) {
              final done = ref.watch(homeworkOverridesProvider)[hw.id] ?? hw.isDone;
              return GButton(
                label: done ? l.markUndone : l.markDone,
                variant: done ? GButtonVariant.secondary : GButtonVariant.primary,
                size: GButtonSize.l,
                expand: true,
                onPressed: () async {
                  GHaptics.light();
                  await setHomeworkDone(ref, hw, !done);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              );
            },
          ),
  );
}
