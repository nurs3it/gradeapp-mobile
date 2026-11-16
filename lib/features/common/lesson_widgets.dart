import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/grading.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'attachments.dart';
import 'models.dart';
import 'school_providers.dart';
import 'presence.dart';

/// Lesson row (§3.12): time · subject marker · subject / room · tail.
class LessonRow extends StatelessWidget {
  const LessonRow({
    super.key,
    required this.lesson,
    required this.now,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.twoLineTime = false,
    this.secondLine,
    this.semanticLabel,
  });

  final Lesson lesson;
  final DateTime now;

  /// Defaults to the subject; teachers pass «9 «В» · Геометрия».
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Week density: start over end.
  final bool twoLineTime;

  /// Week density: topic under the subtitle.
  final String? secondLine;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final l = context.l10n;
    final current = lesson.isNow(now) && !lesson.isCancelled;
    final past = lesson.isPast(now);
    final timeStyle = t.callout.copyWith(fontWeight: FontWeight.w600, color: past ? c.ink3 : c.ink);
    final sub = subtitle ?? [if (lesson.room != null) l.room(lesson.room!), ?lesson.teacherName].join(' · ');
    return GRow(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      minHeight: twoLineTime ? 72 : GSpace.rowMin,
      background: current ? c.subjectTint(lesson.colorKey) : null,
      leading: SizedBox(
        width: 48,
        child: twoLineTime
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hm(lesson.start), style: timeStyle),
                  Text(hm(lesson.end), style: t.footnote.copyWith(color: c.ink3)),
                ],
              )
            : Text(hm(lesson.start), style: timeStyle),
      ),
      marker: lesson.isCancelled ? c.ink3 : c.subjectMarker(lesson.colorKey),
      title: Text(
        title ?? lesson.subject,
        style: lesson.isCancelled ? TextStyle(decoration: TextDecoration.lineThrough, color: c.ink2) : null,
      ),
      subtitle: secondLine == null || secondLine!.isEmpty
          ? (sub.isEmpty ? null : Text(sub))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sub.isNotEmpty) Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  secondLine!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.ink2),
                ),
              ],
            ),
      trailing:
          trailing ??
          (lesson.isCancelled
              ? GStatusPill(label: l.pillCancelled, tone: GTone.warn, icon: GIcons.excuse)
              : current
              ? GStatusPill(label: l.pillNow, tone: GTone.info)
              : lesson.isJoint
              ? GStatusPill(label: l.pillJoint, tone: GTone.neutral)
              : null),
    );
  }
}

/// «перемена 20 мин» divider between lessons when the break is > 15 min.
class BreakDivider extends StatelessWidget {
  const BreakDivider({super.key, required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 28,
    child: Padding(
      padding: const EdgeInsets.only(left: 76),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(context.l10n.breakLine(minutes), style: context.t.footnote.copyWith(color: context.c.ink3)),
      ),
    ),
  );
}

/// Day lessons interleaved with long breaks.
List<Widget> lessonRowsWithBreaks(List<Lesson> lessons, Widget Function(Lesson) row) {
  final out = <Widget>[];
  for (var i = 0; i < lessons.length; i++) {
    if (i > 0) {
      final gap = lessons[i].startMin - lessons[i - 1].endMin;
      if (gap > 15) out.add(BreakDivider(minutes: gap));
    }
    out.add(row(lessons[i]));
  }
  return out;
}

/// Ordinal of a lesson among the day's lessons (1-based).
int lessonNumber(List<Lesson> day, Lesson lesson) {
  final starts = day.where((l) => !l.isCancelled).map((l) => l.start).toSet().toList()..sort();
  return starts.indexOf(lesson.start) + 1;
}

String presenceLabel(AppLocalizations l, Presence p) => switch (p) {
  Presence.present => l.presencePresent,
  Presence.absent => l.presenceAbsent,
  Presence.tardy => l.presenceTardy,
  Presence.excused => l.presenceExcused,
};

GTone presenceTone(Presence p) => switch (p) {
  Presence.present => GTone.ok,
  Presence.absent => GTone.bad,
  Presence.tardy => GTone.warn,
  Presence.excused => GTone.info,
};

String toneWord(AppLocalizations l, GradeTone t) => switch (t) {
  GradeTone.excellent => l.toneExcellent,
  GradeTone.good => l.toneGood,
  GradeTone.fair => l.toneFair,
  GradeTone.poor => l.tonePoor,
};

/// Grade chip of a learner's grade (marks by tone, scores neutral).
class GradeChipOf extends ConsumerWidget {
  const GradeChipOf({super.key, required this.grade, this.size = GGradeSize.s, this.isNew = false});
  final Grade grade;
  final GGradeSize size;
  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gradingProvider);
    final l = context.l10n;
    final tone = grade.isScore ? null : g.tone(grade.value);
    final label = [
      tone == null ? grade.display : l.gradeSemantic(grade.display, toneWord(l, tone)),
      if (isNew) l.newWord,
    ].join(', ');
    return GGradeChip(text: grade.display, tone: tone, size: size, isNew: isNew, semanticLabel: label);
  }
}

/// Work-type badge with the school's kind.
class WorkBadge extends ConsumerWidget {
  const WorkBadge({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gradingProvider);
    final l = context.l10n;
    final kind = g.kindOf(type);
    final label = switch (kind) {
      WorkKind.formative => l.kindFo,
      WorkKind.sor => l.kindSor,
      WorkKind.soch => l.kindSoch,
      WorkKind.other => g.typeName(type),
    };
    return GTypeBadge(label: label, kind: kind.name);
  }
}

/// Lesson card (S5, §3.12): the loud sheet flies up into the sheet header.
Future<void> showLessonSheet(
  BuildContext context, {
  required Lesson lesson,
  required int number,
  AttendanceMark? mark,
  List<Grade> grades = const [],
  List<Homework> homework = const [],
  bool parent = false,
  bool teacher = false,
  VoidCallback? onExplain,
  VoidCallback? onOpenLesson,
}) {
  final l = context.l10n;
  return showGSheet<void>(
    context,
    closeLabel: l.close,
    builder: (ctx) => _LessonSheet(
      lesson: lesson,
      number: number,
      mark: mark,
      grades: grades,
      homework: homework,
      parent: parent,
      teacher: teacher,
    ),
    actions: switch ((
      parent && mark?.status == Presence.absent && onExplain != null,
      teacher && onOpenLesson != null,
    )) {
      (true, _) => GButton(
        label: l.explainAbsence,
        size: GButtonSize.l,
        expand: true,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          onExplain!();
        },
      ),
      (_, true) => GButton(
        label: l.openLesson,
        size: GButtonSize.l,
        expand: true,
        icon: GIcons.forward,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          onOpenLesson!();
        },
      ),
      _ => null,
    },
  );
}

class _LessonSheet extends StatelessWidget {
  const _LessonSheet({
    required this.lesson,
    required this.number,
    required this.mark,
    required this.grades,
    required this.homework,
    required this.parent,
    required this.teacher,
  });

  final Lesson lesson;
  final int number;
  final AttendanceMark? mark;
  final List<Grade> grades;
  final List<Homework> homework;
  final bool parent;
  final bool teacher;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final l = context.l10n;
    final date = DateTime.parse(lesson.date);
    final fill = lesson.isCancelled ? c.surface2 : c.subjectFill(lesson.colorKey);
    final fg = lesson.isCancelled ? c.ink : GColors.onFill;
    final past = lesson.isPast(DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GHeroSheet(
            color: fill,
            heroTag: 'lesson-${lesson.id}',
            leaves: !lesson.isCancelled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.lessonOrdinal(Fmt.weekday(date, context.localeTag), number).toUpperCase(),
                  style: t.eyebrow.copyWith(color: fg.withValues(alpha: 0.88)),
                ),
                const SizedBox(height: 6),
                Text(
                  teacher && lesson.classGroupName != null
                      ? '${lesson.classGroupName} · ${lesson.subject}'
                      : lesson.subject,
                  style: t.heroTitle.copyWith(
                    color: fg,
                    decoration: lesson.isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ['${hm(lesson.start)}–${hm(lesson.end)}', if (lesson.room != null) l.room(lesson.room!)].join(' · '),
                  style: t.callout.copyWith(color: fg.withValues(alpha: 0.88)),
                ),
                if (lesson.isCancelled || lesson.isJoint) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (lesson.isCancelled)
                        GStatusPill(label: l.pillCancelled, tone: GTone.warn, icon: GIcons.excuse),
                      if (lesson.isJoint) GStatusPill(label: l.pillJoint, tone: GTone.neutral),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (lesson.teacherName != null && !teacher) ...[
            const SizedBox(height: 8),
            GRow(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              leading: PersonAvatar(
                presence: lesson.teacherId == null ? null : PresenceRef.staff(lesson.teacherId!),
                name: lesson.teacherName!,
                size: 40,
                color: subjectOf(lesson.teacherName!).fill,
              ),
              title: Text(lesson.teacherName!),
              subtitle: Text(l.teacher),
            ),
          ],
          _Section(
            title: l.topicLabel,
            child: Text(
              lesson.topic.isEmpty ? l.notFilledYet : lesson.topic,
              style: t.body.copyWith(color: lesson.topic.isEmpty ? c.ink3 : c.ink),
            ),
          ),
          if (homework.isNotEmpty)
            _Section(
              title: l.lessonHomework,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final hw in homework)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          GIcon(
                            hw.isDone ? GIcons.ok : GIcons.homework,
                            size: 20,
                            color: hw.isDone ? c.ok : c.ink2,
                            fill: hw.isDone ? 1 : 0,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(hw.title, style: t.body)),
                          if (hw.attachments.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            GIcon(GIcons.attach, size: 18, color: c.ink3),
                          ],
                        ],
                      ),
                    ),
                  for (final hw in homework)
                    if (hw.attachments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: AttachmentsView(attachments: hw.attachments),
                      ),
                ],
              ),
            ),
          if (!teacher && (mark != null || grades.isNotEmpty))
            _Section(
              title: parent ? l.childMarks : l.myMarks,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (mark != null)
                    GStatusPill(
                      label: mark!.code.isNotEmpty
                          ? '${mark!.code} · ${presenceLabel(l, mark!.status)}'
                          : presenceLabel(l, mark!.status),
                      tone: presenceTone(mark!.status),
                    ),
                  for (final g in grades) GradeChipOf(grade: g, size: GGradeSize.m),
                ],
              ),
            )
          else if (!teacher && past && !lesson.isCancelled)
            _Section(
              title: parent ? l.childMarks : l.myMarks,
              child: Text(l.notFilledYet, style: t.body.copyWith(color: c.ink3)),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.t.subhead.copyWith(color: context.c.ink2)),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}
