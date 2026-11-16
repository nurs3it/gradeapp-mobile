import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/lesson_widgets.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import '../learner/learner_providers.dart';
import '../shell/header.dart';
import 'excuse_sheet.dart';
import 'verdict.dart';
import '../common/presence.dart';

/// Parent «Сегодня» (P1/P2): one child — verdict, «требует внимания», feed;
/// two or more — the family overview until a child is picked.
class ParentTodayScreen extends ConsumerWidget {
  const ParentTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final childrenAsync = ref.watch(childrenProvider);
    final children = childrenAsync.value ?? const <Child>[];
    final family = ref.watch(familyModeProvider) && children.length > 1;
    final now = ref.now;
    final child = ref.watch(currentChildProvider);

    Future<void> refresh() async {
      ref
        ..invalidate(learnerDayProvider)
        ..invalidate(childrenProvider);
      await ref.read(childrenProvider.future).then((_) {}, onError: (Object _) {});
    }

    if (family) {
      return GRootPage(
        eyebrow: Fmt.weekdayDayMonth(now, context.localeTag),
        title: l.familyTitle,
        actions: const [BellButton(), ChildSwitcherButton()],
        onRefresh: refresh,
        below: const NetBanner(),
        slivers: [_Family(children: children, now: now)],
      );
    }
    return GRootPage(
      eyebrow: child == null
          ? Fmt.weekdayDayMonth(now, context.localeTag)
          : [child.shortName, ?child.className].join(' · '),
      title: l.tabToday,
      actions: const [BellButton(), ChildSwitcherButton()],
      onRefresh: refresh,
      below: const NetBanner(),
      slivers: [
        if (childrenAsync.isLoading && !childrenAsync.hasValue)
          const SliverToBoxAdapter(child: GSkeleton())
        else if (child == null)
          SliverToBoxAdapter(
            child: childrenAsync.hasError
                ? GEmpty(error: true, title: l.errorTitle, message: l.errorOffline, action: l.retry, onAction: refresh)
                : GEmpty(title: l.noChildrenTitle, message: l.noChildrenMessage, icon: GIcons.family),
          )
        else
          _ChildDay(child: child, now: now),
      ],
    );
  }
}

class _ChildDay extends ConsumerWidget {
  const _ChildDay({required this.child, required this.now});
  final Child child;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final today = isoDate(now);
    final day = ref.watch(learnerDayProvider((studentId: child.id, date: today)));
    if (!day.hasValue) {
      return SliverToBoxAdapter(
        child: day.hasError
            ? GEmpty(
                error: true,
                title: l.errorTitle,
                message: l.errorOffline,
                action: l.retry,
                onAction: () => ref.invalidate(learnerDayProvider),
              )
            : const GSkeleton(),
      );
    }
    final d = day.value!;
    final grading = ref.watch(gradingProvider);
    final checkin = ref.watch(schoolProvider.select((s) => s.value?.checkinEnabled ?? true));
    final v = verdictOf(d, now, grading: grading, checkinEnabled: checkin);
    final net = ref.watch(netProvider);
    final tomorrow = isoDate(now.add(const Duration(days: 1)));
    final tomorrowHw = d.homework.where((h) => h.dueDate == tomorrow).toList();
    final tomorrowDay = v.level == VerdictLevel.noLessons
        ? ref.watch(learnerDayProvider((studentId: child.id, date: tomorrow))).value
        : null;

    void excuse({Lesson? lesson}) => showExcuseSheet(context, studentId: child.id, lesson: lesson);
    void openLesson(Lesson lesson) => showLessonSheet(
      context,
      lesson: lesson,
      number: lessonNumber(d.lessons, lesson),
      mark: d.attendance[lesson.id],
      grades: d.recentGrades.where((gr) => gr.lessonId == lesson.id).toList(),
      homework: d.homework.where((h) => h.lessonId == lesson.id).toList(),
      parent: true,
      onExplain: () => excuse(lesson: lesson),
    );

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: g),
      sliver: SliverList.list(
        children: [
          VerdictSheet(
            verdict: v,
            day: d,
            tomorrow: tomorrowDay,
            updatedAt: net.offline ? net.lastFresh : null,
            onExcuse: () => excuse(),
          ),
          if (v.attention.isNotEmpty || v.pendingExcuse != null) ...[
            GSectionTitle(title: l.attentionTitle),
            GGroup(
              inset: 68,
              children: [
                if (v.pendingExcuse != null)
                  GRow(
                    background: c.primarySoft,
                    leading: _Plate(child: GIcon(GIcons.pending, size: 22, color: c.primarySoftText)),
                    title: Text(l.attPending, style: TextStyle(color: c.primarySoftText)),
                    titleMaxLines: 2,
                    subtitle: Text(categoryName(l, v.pendingExcuse!.category)),
                  ),
                for (final a in v.attention)
                  switch (a.kind) {
                    AttentionKind.absentNoReason => GRow(
                      leading: _Plate(
                        tone: GTone.bad,
                        child: Text(
                          _absentLetter(ref),
                          style: context.t.bodyStrong.copyWith(color: c.bad, fontWeight: FontWeight.w800),
                        ),
                      ),
                      title: Text(l.attAbsent(hm(a.lesson!.start))),
                      subtitle: Text(a.lesson!.subject),
                      trailing: GButton(
                        label: l.actExplain,
                        size: GButtonSize.s,
                        variant: GButtonVariant.tinted,
                        onPressed: () => excuse(lesson: a.lesson),
                      ),
                    ),
                    AttentionKind.noConsent => GRow(
                      leading: _Plate(
                        tone: GTone.warn,
                        child: GIcon(GIcons.checkIn, size: 22, color: c.warn),
                      ),
                      title: Text(l.attNoConsent),
                      subtitle: Text(l.attNoConsentSub),
                      trailing: GButton(
                        label: l.actAllow,
                        size: GButtonSize.s,
                        variant: GButtonVariant.tinted,
                        onPressed: () => showConsentSheet(context, ref, studentId: child.id, name: child.shortName),
                      ),
                    ),
                    AttentionKind.excuseRejected => GRow(
                      leading: _Plate(
                        tone: GTone.bad,
                        child: GIcon(GIcons.excuse, size: 22, color: c.bad),
                      ),
                      title: Text(l.attRejected),
                      subtitle: Text(
                        a.excuse!.reviewNote.isEmpty ? categoryName(l, a.excuse!.category) : a.excuse!.reviewNote,
                      ),
                      trailing: GButton(
                        label: l.actExcuse,
                        size: GButtonSize.s,
                        variant: GButtonVariant.tinted,
                        onPressed: excuse,
                      ),
                    ),
                  },
              ],
            ),
          ],
          _FeedSection(day: d, now: now, onTapLesson: openLesson),
          if (tomorrowHw.isNotEmpty) ...[
            GSectionTitle(title: l.heroForTomorrow),
            GGroup(
              children: [
                GRow(
                  title: Text(
                    l.forTomorrowLine(
                      l.tasksCount(tomorrowHw.length),
                      tomorrowHw.fold<int>(0, (s, h) => s + (h.minutes ?? 0)),
                      tomorrowHw.where((h) => h.isDone).length,
                    ),
                  ),
                  chevron: true,
                  onTap: () => StatefulNavigationShell.maybeOf(context)?.goBranch(2),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _absentLetter(WidgetRef ref) =>
      ref.read(gradingProvider).attendanceCodes.where((c) => c.status == Presence.absent).firstOrNull?.code ?? 'Н';
}

class _Plate extends StatelessWidget {
  const _Plate({required this.child, this.tone});
  final Widget child;
  final GTone? tone;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    alignment: Alignment.center,
    decoration: ShapeDecoration(color: tone?.soft(context.c) ?? context.c.surface, shape: GRadius.surface(13)),
    child: child,
  );
}

/// The parent's loud sheet is a tinted verdict (§3.26): icon + word + colour,
/// facts with times and counts in bold, quick actions.
class VerdictSheet extends StatelessWidget {
  const VerdictSheet({
    super.key,
    required this.verdict,
    required this.day,
    required this.onExcuse,
    this.tomorrow,
    this.updatedAt,
  });

  final DayVerdict verdict;
  final LearnerDay day;
  final LearnerDay? tomorrow;
  final DateTime? updatedAt;
  final VoidCallback onExcuse;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final v = verdict;
    final (GTone tone, IconData icon, String title) = switch (v.level) {
      VerdictLevel.alarm => (GTone.bad, GIcons.error, l.verdictAlarm),
      VerdictLevel.action => (GTone.warn, GIcons.info, l.verdictAction),
      VerdictLevel.question => (GTone.warn, GIcons.info, l.verdictQuestion),
      VerdictLevel.ok => (GTone.ok, GIcons.ok, l.verdictOk),
      VerdictLevel.noLessons => (GTone.neutral, GIcons.clock, l.verdictNoLessons),
    };
    final bold = t.body.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]);
    final facts = <InlineSpan>[];
    void add(String text, {List<String> strong = const []}) {
      if (facts.isNotEmpty) facts.add(const TextSpan(text: ' '));
      var rest = text;
      for (final s in strong) {
        final i = rest.indexOf(s);
        if (i < 0) continue;
        facts
          ..add(TextSpan(text: rest.substring(0, i)))
          ..add(TextSpan(text: s, style: bold));
        rest = rest.substring(i + s.length);
      }
      facts.add(TextSpan(text: rest));
    }

    switch (v.level) {
      case VerdictLevel.noLessons:
        final tl = tomorrow?.lessons.where((x) => !x.isCancelled).toList() ?? const <Lesson>[];
        if (tl.isNotEmpty) {
          add(l.factTomorrow(l.lessonsCount(tl.length), hm(tl.first.start)), strong: [hm(tl.first.start)]);
        }
      case VerdictLevel.alarm:
        add(l.factAlarm(hm(v.firstLesson!.start)), strong: [hm(v.firstLesson!.start)]);
      default:
        if (v.arrivedAt != null) {
          final time = Fmt.clock(v.arrivedAt!);
          add(v.late ? l.factLate(time) : l.factArrived(time), strong: [time]);
        } else if (v.excusedToday) {
          add(l.factExcused);
        } else if (v.firstLesson != null && v.lessonsDone == 0) {
          add(l.factBeforeLessons(hm(v.firstLesson!.start)), strong: [hm(v.firstLesson!.start)]);
        }
        if (v.lessonsDone > 0) {
          add(l.factLessons(v.lessonsDone, v.lessonsTotal), strong: ['${v.lessonsDone}', '${v.lessonsTotal}']);
        }
        for (final a in v.absent) {
          add('${l.factAbsent(a.subject)}, ${l.factNoReason}');
        }
        for (final g in v.lowGrades) {
          add(l.factLowGrade(g.courseName, g.display));
        }
        if (v.attention.any((a) => a.kind == AttentionKind.noConsent)) add(l.factNoConsent);
    }

    return Container(
      padding: const EdgeInsets.all(GSpace.heroPad),
      decoration: ShapeDecoration(
        color: v.level == VerdictLevel.noLessons ? c.surface : tone.soft(c),
        shape: GRadius.surface(GRadius.hero),
        shadows: v.level == VerdictLevel.noLessons ? GDepth.level1(c) : null,
      ),
      child: Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: tone.fill(c), shape: BoxShape.circle),
                  child: GIcon(icon, size: 24, color: GColors.onFill, fill: 1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(header: true, child: Text(title, style: t.title1, maxLines: 2)),
                ),
              ],
            ),
            if (facts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(children: facts),
                style: t.body.copyWith(height: 23 / 16),
              ),
            ],
            if (updatedAt != null) ...[
              const SizedBox(height: 6),
              Text(l.verdictUpdated(Fmt.clock(updatedAt!)), style: t.footnote.copyWith(color: c.ink2)),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GButton(
                  label: l.actExcuse,
                  icon: GIcons.excuse,
                  size: GButtonSize.s,
                  variant: v.level == VerdictLevel.alarm ? GButtonVariant.primary : GButtonVariant.surface,
                  onPressed: onExcuse,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// «Лента дня», newest first (§3.13 timeline density).
class _FeedSection extends ConsumerWidget {
  const _FeedSection({required this.day, required this.now, required this.onTapLesson});
  final LearnerDay day;
  final DateTime now;
  final ValueChanged<Lesson> onTapLesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final items = <(DateTime, Widget)>[];
    final ci = day.checkIn;
    if (ci?.checkedIn ?? false) {
      final at = ci!.checkedAt ?? now;
      items.add((
        at,
        _TimelineRow(
          time: Fmt.clock(at),
          node: GIcon(GIcons.checkIn, size: 16, color: c.ok),
          nodeColor: c.okSoft,
          title: l.feedArrived,
          subtitle: l.feedArrivedSub(ci.late ? l.feedLate : l.feedOnTime),
        ),
      ));
    }
    final date = DateTime.parse(day.date);
    for (final lesson in day.lessons.where((x) => !x.isCancelled && !now.isBefore(x.startsAt()))) {
      final mark = day.attendance[lesson.id];
      final grades = day.recentGrades.where((g) => g.lessonId == lesson.id).toList();
      final absent = mark?.status == Presence.absent;
      final sub = lesson.isNow(now)
          ? [l.feedNow, if (lesson.room != null) l.room(lesson.room!)].join(' · ')
          : absent
          ? l.feedMarkedAbsent
          : mark != null && mark.status != Presence.present
          ? presenceLabel(l, mark.status)
          : grades.where((g) => g.comment.isNotEmpty).map((g) => '«${g.comment}»').firstOrNull ??
                (lesson.topic.isEmpty ? '' : lesson.topic);
      items.add((
        lesson.startsAt(),
        _TimelineRow(
          time: hm(lesson.start),
          node: absent
              ? Text(
                  _ChildDay._absentLetter(ref),
                  style: t.footnote.copyWith(color: c.bad, fontWeight: FontWeight.w800),
                )
              : null,
          nodeColor: absent ? c.badSoft : c.subjectTint(lesson.colorKey),
          title: lesson.subject,
          subtitle: sub,
          trailing: grades.isEmpty ? null : GradeChipOf(grade: grades.first),
          onTap: () => onTapLesson(lesson),
        ),
      ));
    }
    for (final g in day.recentGrades.where((g) => g.date == day.date && g.lessonId == null)) {
      items.add((
        g.createdAt ?? date,
        _TimelineRow(
          time: g.createdAt == null ? '' : Fmt.clock(g.createdAt!),
          nodeColor: c.subjectTint(g.courseName),
          title: g.courseName,
          subtitle: g.comment.isEmpty ? '' : '«${g.comment}»',
          trailing: GradeChipOf(grade: g),
        ),
      ));
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(
          title: l.feedTitle,
          trailing: Text(l.feedNewest, style: t.footnote.copyWith(color: c.ink2)),
        ),
        GGroup(inset: 120, children: [for (final (_, w) in items) w]),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.nodeColor,
    required this.title,
    required this.subtitle,
    this.node,
    this.trailing,
    this.onTap,
  });

  final String time;
  final Widget? node;
  final Color nodeColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GRow(
      onTap: onTap,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            child: Text(time, style: context.t.callout.copyWith(fontWeight: FontWeight.w600)),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: nodeColor, shape: BoxShape.circle),
            child: node,
          ),
        ],
      ),
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, style: TextStyle(color: c.ink2)),
      trailing: trailing,
    );
  }
}

/// Two or more children: a card per child, the alarming one first (P2).
class _Family extends ConsumerWidget {
  const _Family({required this.children, required this.now});
  final List<Child> children;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final g = GSpace.gutter(context);
    final today = isoDate(now);
    final tomorrow = isoDate(now.add(const Duration(days: 1)));
    final grading = ref.watch(gradingProvider);
    final checkin = ref.watch(schoolProvider.select((s) => s.value?.checkinEnabled ?? true));
    // All /today/ requests run in parallel; each card shows its own skeleton.
    final days = {for (final ch in children) ch.id: ref.watch(learnerDayProvider((studentId: ch.id, date: today)))};
    final verdicts = {
      for (final e in days.entries)
        if (e.value.hasValue) e.key: verdictOf(e.value.value!, now, grading: grading, checkinEnabled: checkin),
    };
    final ordered = [...children]
      ..sort((a, b) => (verdicts[a.id]?.level.index ?? 9).compareTo(verdicts[b.id]?.level.index ?? 9));
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: g),
      sliver: SliverList.list(
        children: [
          for (final ch in ordered) ...[
            _ChildCard(child: ch, day: days[ch.id]!.value, verdict: verdicts[ch.id]),
            const SizedBox(height: GSpace.stackGap),
          ],
          GSectionTitle(title: l.heroForTomorrow),
          GGroup(
            inset: 36,
            children: [
              for (final ch in children)
                Builder(
                  builder: (context) {
                    final hw = (days[ch.id]!.value?.homework ?? const <Homework>[])
                        .where((h) => h.dueDate == tomorrow)
                        .toList();
                    return GRow(
                      leading: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: childColor(ch.id), shape: BoxShape.circle),
                      ),
                      title: Text('${ch.shortName} · ${l.tasksCount(hw.length)}'),
                      subtitle: hw.isEmpty
                          ? null
                          : Text(
                              [
                                l.approxMinutes(hw.fold<int>(0, (s, h) => s + (h.minutes ?? 0))),
                                '${l.hwDone} ${hw.where((h) => h.isDone).length}',
                              ].join(' · '),
                            ),
                      onTap: () {
                        ref.read(selectedChildProvider.notifier).select(ch.id);
                        ref.read(familyModeProvider.notifier).set(false);
                      },
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  const _ChildCard({required this.child, required this.day, required this.verdict});
  final Child child;
  final LearnerDay? day;
  final DayVerdict? verdict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final v = verdict;
    final alarm = v?.level == VerdictLevel.alarm;
    final (GTone tone, String pill) = switch (v?.level) {
      VerdictLevel.alarm => (GTone.bad, l.familyNotChecked),
      VerdictLevel.action || VerdictLevel.question => (GTone.warn, l.familyQuestion),
      VerdictLevel.ok => (GTone.ok, l.familyAllGood),
      _ => (GTone.neutral, l.familyNoLessons),
    };
    final fresh = day?.recentGrades.where((g) => g.date == day!.date).firstOrNull;
    final fact = v == null
        ? ''
        : alarm
        ? l.factAlarm(hm(v.firstLesson!.start))
        : [
            if (v.arrivedAt != null) l.factArrived(Fmt.clock(v.arrivedAt!)),
            if (v.lessonsTotal > 0 && v.lessonsDone > 0) l.factLessons(v.lessonsDone, v.lessonsTotal),
            for (final a in v.absent) '${l.factAbsent(a.subject)}.',
          ].join(' ');
    void focus() {
      GHaptics.selection();
      ref.read(selectedChildProvider.notifier).select(child.id);
      ref.read(familyModeProvider.notifier).set(false);
    }

    return GCard(
      onTap: focus,
      radius: 30,
      padding: const EdgeInsets.all(18),
      border: alarm ? BorderSide(color: c.bad, width: 2) : null,
      semanticLabel: [child.fullName, pill, fact].join('. '),
      child: day == null
          ? const SizedBox(height: 96, child: Center(child: GLoader(size: 28)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PersonAvatar(
                      presence: PresenceRef.student(child.id),
                      name: child.fullName,
                      url: child.avatarUrl,
                      size: 44,
                      color: childColor(child.id),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(child.shortName, style: t.title2, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (child.className != null)
                            Text(child.className!, style: t.footnote.copyWith(color: c.ink2)),
                        ],
                      ),
                    ),
                    GStatusPill(label: pill, tone: tone),
                  ],
                ),
                if (fact.isNotEmpty) ...[const SizedBox(height: 12), Text(fact, style: t.body)],
                if (fresh != null && !alarm) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GradeChipOf(grade: fresh, isNew: true),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l.factNewGrade(fresh.courseName), style: t.footnote.copyWith(color: c.ink2)),
                      ),
                    ],
                  ),
                ],
                if (alarm) ...[
                  const SizedBox(height: 14),
                  GButton(
                    label: l.actExcuse,
                    size: GButtonSize.s,
                    onPressed: () => showExcuseSheet(context, studentId: child.id),
                  ),
                ],
              ],
            ),
    );
  }
}
