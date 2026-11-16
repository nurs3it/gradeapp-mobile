import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../common/now_next.dart';

/// Hero «Сейчас / Дальше» of the student (§3.14): one loud sheet in the
/// colour of the subject with the fan of the next two lessons under it.
class LearnerHero extends StatelessWidget {
  const LearnerHero({
    super.key,
    required this.state,
    required this.lessons,
    this.tomorrowTasks = 0,
    this.tomorrowMinutes = 0,
    this.tomorrow,
    this.onTapLesson,
    this.onOpenTasks,
    this.quiet = false,
  });

  final NowNext state;
  final List<Lesson> lessons;
  final int tomorrowTasks;
  final int tomorrowMinutes;

  /// Tomorrow's lessons (after school / day off).
  final List<Lesson>? tomorrow;
  final ValueChanged<Lesson>? onTapLesson;
  final VoidCallback? onOpenTasks;

  /// The check-in is the loud one this morning: draw a white 96 pt sheet.
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final s = state;
    final focus = s.focus;
    const on = GColors.onFill;
    final on88 = on.withValues(alpha: 0.88);

    if (quiet && focus != null) {
      final text = [
        '${l.heroNext.toUpperCase()} · ${hm(focus.start)}',
        focus.subject,
        if (focus.room != null) l.room(focus.room!),
        l.inMinutes(s.minutes),
      ];
      return GCard(
        onTap: onTapLesson == null ? null : () => onTapLesson!(focus),
        semanticLabel: text.join(', '),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 56,
              decoration: ShapeDecoration(color: c.subjectMarker(focus.colorKey), shape: const StadiumBorder()),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text.first, style: t.eyebrow.copyWith(color: c.ink2)),
                  const SizedBox(height: 4),
                  Text(focus.subject, style: t.title2, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(text.skip(2).join(' · '), style: t.footnote.copyWith(color: c.ink2)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // After school and days off: plan for tomorrow on a brand sheet.
    if (s.phase == DayPhase.after || s.phase == DayPhase.none) {
      final hasTasks = tomorrowTasks > 0;
      final tl = tomorrow?.where((x) => !x.isCancelled).toList() ?? const <Lesson>[];
      final eyebrow = s.phase == DayPhase.after ? l.heroDayOver : l.heroNoLessons;
      final title = hasTasks
          ? '${l.heroForTomorrow} ${l.tasksCount(tomorrowTasks)}'
          : tl.isNotEmpty
          ? l.heroTomorrowPlan(tl.length, hm(tl.first.start))
          : l.heroRest;
      return GHeroSheet(
        color: GColors.brand,
        semanticLabel: [eyebrow, title, if (hasTasks && tomorrowMinutes > 0) l.approxMinutes(tomorrowMinutes)].join('. '),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow.toUpperCase(), style: t.eyebrow.copyWith(color: on88)),
            const SizedBox(height: 8),
            Text(title, style: t.heroTitle.copyWith(color: on), maxLines: 2),
            if (hasTasks && tomorrowMinutes > 0) ...[
              const SizedBox(height: 10),
              CappedText(l.approxMinutes(tomorrowMinutes), style: t.titleXl.copyWith(color: on, fontSize: 40)),
            ],
            if (hasTasks && onOpenTasks != null) ...[
              const SizedBox(height: 14),
              GButton(
                label: l.heroOpenTasks,
                variant: GButtonVariant.onColor,
                color: GColors.brand,
                size: GButtonSize.s,
                onPressed: onOpenTasks,
              ),
            ],
          ],
        ),
      );
    }

    final lesson = focus!;
    final cancelled = lesson.isCancelled && s.phase == DayPhase.lesson;
    final fill = cancelled ? c.surface2 : c.subjectFill(lesson.colorKey);
    final fg = cancelled ? c.ink : on;
    final fg88 = cancelled ? c.ink2 : on88;
    final eyebrow = switch (s.phase) {
      DayPhase.lesson when cancelled => '${l.heroNow} · ${l.heroCancelled}',
      DayPhase.lesson => '${l.heroNow} · ${s.isLast ? l.heroLast : l.heroLessonN(s.number)}',
      DayPhase.pause => '${l.heroPause} · ${l.heroPauseNext}',
      _ => '${l.heroNext} · ${hm(lesson.start)}',
    };
    final unit = switch (s.phase) {
      DayPhase.lesson => l.heroUntilBell,
      DayPhase.pause => l.heroUntilLesson,
      _ => l.heroUntilStart,
    };
    final meta = [if (lesson.room != null) l.room(lesson.room!), ?lesson.teacherName].join(' · ');
    final next = s.phase == DayPhase.lesson ? s.next : null;
    final semantic = [
      '$eyebrow. ${lesson.subject}',
      if (meta.isNotEmpty) meta,
      if (!cancelled) l.heroCountdown(unit, s.minutes),
      if (next != null) l.heroNextLine(hm(next.start), next.subject),
    ].join('. ');
    final bigNumber = s.minutes > 180 ? hm(lesson.start) : '${s.minutes}';

    return GHeroSheet(
      color: fill,
      fan: cancelled ? const [] : [for (final u in s.upcoming) c.subjectFill(u.colorKey)],
      heroTag: 'lesson-${lesson.id}',
      leaves: !cancelled,
      onTap: onTapLesson == null ? null : () => onTapLesson!(lesson),
      semanticLabel: semantic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  style: t.eyebrow.copyWith(color: fg88),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${hm(lesson.start)}–${hm(lesson.end)}', style: t.eyebrow.copyWith(color: fg88)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lesson.subject,
            style: t.heroTitle.copyWith(color: fg, decoration: cancelled ? TextDecoration.lineThrough : null),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(meta, style: t.callout.copyWith(color: fg88), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          if (!cancelled) ...[
            const SizedBox(height: 12),
            _Countdown(number: bigNumber, unit: s.minutes > 180 ? '' : '${l.heroMin}\n$unit', color: on),
            if (s.phase == DayPhase.lesson || s.phase == DayPhase.pause) ...[
              const SizedBox(height: 12),
              GHeroProgress(value: s.progress),
            ],
          ],
          if (next != null || (s.phase == DayPhase.lesson && s.isLast && tomorrowTasks > 0)) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: (cancelled ? c.ink : on).withValues(alpha: 0.22)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  (next != null ? l.heroNext : l.heroThen).toUpperCase(),
                  style: t.eyebrow.copyWith(color: fg88),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    next != null
                        ? '${hm(next.start)} ${next.subject}'
                        : '${l.heroForTomorrow} ${l.tasksCount(tomorrowTasks)} · ${l.approxMinutes(tomorrowMinutes)}',
                    style: t.bodyStrong.copyWith(color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (next != null) GIcon(GIcons.chevron, size: 20, color: fg88),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.number, required this.unit, required this.color});
  final String number;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final large = GScale.large(context);
    final unitText = Text(unit, style: t.callout.copyWith(color: color, fontWeight: FontWeight.w600, height: 1.15));
    final digits = GRollingText(number, style: t.display.copyWith(color: color));
    if (large) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [digits, unitText]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [digits, const SizedBox(width: 12), Flexible(child: unitText)],
    );
  }
}
