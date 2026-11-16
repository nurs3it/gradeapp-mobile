import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/grading.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import 'learner_providers.dart';
import 'models.dart';

/// Attendance mark of a lesson; nothing for an ordinary «present».
Widget? presencePill(BuildContext context, Presence? p) {
  final l = context.l10n;
  return switch (p) {
    Presence.absent => GPill(l.presenceAbsentLong, tone: GTone.danger, icon: Icons.close_rounded),
    Presence.tardy => GPill(l.presenceTardy, tone: GTone.warning, icon: Icons.schedule_rounded),
    Presence.excused => GPill(l.presenceExcusedLong, tone: GTone.info),
    _ => null,
  };
}

String dueLabel(BuildContext context, String due) {
  final l = context.l10n;
  final today = DateTime.now();
  final d = DateTime.parse(due);
  final days = DateTime(d.year, d.month, d.day).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (days < 0) return l.overdue;
  if (days == 0) return l.dueToday;
  if (days == 1) return l.dueTomorrow;
  return l.dueOn(dayMonth(d, context.localeTag));
}

/// Homework row. Students tick it done (optimistic, haptic); parents see state.
class HomeworkTile extends ConsumerStatefulWidget {
  const HomeworkTile({super.key, required this.homework});
  final Homework homework;

  @override
  ConsumerState<HomeworkTile> createState() => _HomeworkTileState();
}

class _HomeworkTileState extends ConsumerState<HomeworkTile> {
  bool? _optimistic;

  Future<void> _toggle() async {
    final next = !(_optimistic ?? widget.homework.isDone);
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _optimistic = next);
    try {
      await setHomeworkDone(ref, widget.homework, next);
    } catch (_) {
      if (!mounted) return;
      setState(() => _optimistic = null);
      showGToast(context, context.l10n.errorMessage, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hw = widget.homework;
    final done = _optimistic ?? hw.isDone;
    final isStudent = ref.watch(activeRoleProvider) == AppRole.student;
    final c = context.c;
    final overdue = !done && dueLabel(context, hw.dueDate) == context.l10n.overdue;
    return GRow(
      onTap: () => showGSheet<void>(context, (_) => HomeworkSheet(homework: hw)),
      leading: isStudent
          ? _CheckCircle(done: done, onTap: _toggle)
          : Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: done ? c.successText : c.subtleForeground,
            ),
      title: Text(
        hw.title.isEmpty ? hw.courseName : hw.title,
        style: TextStyle(decoration: done ? TextDecoration.lineThrough : null, color: done ? c.mutedForeground : null),
      ),
      subtitle: Text(
        [
          hw.courseName,
          dueLabel(context, hw.dueDate),
          if (hw.minutes != null) context.l10n.homeworkMinutes(hw.minutes!),
        ].join(' · '),
      ),
      trailing: overdue
          ? GPill(context.l10n.overdue, tone: GTone.danger)
          : (hw.attachments.isNotEmpty ? Icon(Icons.attach_file_rounded, size: 18, color: c.mutedForeground) : null),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done, required this.onTap});
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      checked: done,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: AnimatedContainer(
          duration: GMotion.fast,
          curve: GMotion.easeOut,
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? c.success : Colors.transparent,
            border: Border.all(color: done ? c.success : c.inputBorder, width: 2),
          ),
          child: done ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
        ),
      ),
    );
  }
}

class HomeworkSheet extends ConsumerWidget {
  const HomeworkSheet({super.key, required this.homework});
  final Homework homework;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hw = homework;
    final l = context.l10n;
    final isStudent = ref.watch(activeRoleProvider) == AppRole.student;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(GSpace.xl, 0, GSpace.xl, GSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hw.courseName.toUpperCase(),
            style: context.t.labelSmall!.copyWith(color: context.c.subject(hw.courseName)),
          ),
          const SizedBox(height: GSpace.xs),
          Text(hw.title, style: context.t.titleLarge),
          const SizedBox(height: GSpace.sm),
          Wrap(
            spacing: GSpace.sm,
            children: [
              GPill(dueLabel(context, hw.dueDate), tone: GTone.primary, icon: Icons.event_rounded),
              if (hw.minutes != null) GPill(l.homeworkMinutes(hw.minutes!), icon: Icons.timer_outlined),
            ],
          ),
          if (hw.description.isNotEmpty) ...[
            const SizedBox(height: GSpace.lg),
            SelectableText(hw.description, style: context.t.bodyLarge),
          ],
          if (hw.attachments.isNotEmpty) ...[
            const SizedBox(height: GSpace.lg),
            Text(l.attachments, style: context.t.titleSmall),
            const SizedBox(height: GSpace.sm),
            for (final a in hw.attachments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: a.url == null ? null : () => launchUrl(Uri.parse(a.url!), mode: LaunchMode.externalApplication),
              ),
          ],
          if (isStudent) ...[
            const SizedBox(height: GSpace.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () async {
                  Navigator.pop(context);
                  await setHomeworkDone(ref, hw, !hw.isDone);
                },
                child: Text(hw.isDone ? l.markUndone : l.markDone),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact grade card for horizontal lists («Последние оценки»).
class GradeCard extends StatelessWidget {
  const GradeCard({super.key, required this.grade, required this.grading});
  final Grade grade;
  final Grading grading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: GCard(
        padding: const EdgeInsets.all(GSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GGradeChip(value: grade.value, maxValue: grade.maxValue, grading: grading, size: 40),
            const SizedBox(height: GSpace.sm),
            Text(grade.courseName, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.titleSmall),
            Text(
              [
                DateFormat('d MMM', context.localeTag).format(DateTime.parse(grade.date)),
                if (grade.type.isNotEmpty) grading.typeName(grade.type),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.t.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
