import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/lesson_widgets.dart';
import '../common/models.dart';
import '../common/now_next.dart';
import '../shell/header.dart';
import 'teacher_models.dart';
import 'teacher_providers.dart';

enum _Filter { unmarked, noTopic }

/// Teacher «Сегодня» (T1, §5.1): the lesson as the loud sheet with one button,
/// debt counters as filters, lessons of the day, debts of 14 days.
class TeacherTodayScreen extends ConsumerStatefulWidget {
  const TeacherTodayScreen({super.key});

  @override
  ConsumerState<TeacherTodayScreen> createState() => _TeacherTodayScreenState();
}

class _TeacherTodayScreenState extends ConsumerState<TeacherTodayScreen> {
  _Filter? _filter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = ref.now;
    final date = isoDate(now);
    final day = ref.watch(teacherDayProvider(date));
    return GRootPage(
      eyebrow: Fmt.weekdayDayMonth(now, context.localeTag),
      title: l.tabToday,
      actions: const [SyncIndicator(), AvatarButton()],
      below: const NetBanner(),
      onRefresh: () async {
        ref.invalidate(teacherDayProvider(date));
        unawaited(ref.read(outboxProvider).flush());
        await ref.read(teacherDayProvider(date).future).then((_) {}, onError: (Object _) {});
      },
      slivers: [
        switch (day) {
          AsyncValue(:final value?) => _Body(
            day: value,
            now: now,
            filter: _filter,
            onFilter: (f) => setState(() => _filter = _filter == f ? null : f),
          ),
          AsyncValue(hasError: true) => SliverToBoxAdapter(
            child: GEmpty(
              error: true,
              title: l.errorTitle,
              message: l.errorOffline,
              action: l.retry,
              onAction: () => ref.invalidate(teacherDayProvider(date)),
            ),
          ),
          _ => const SliverToBoxAdapter(child: GSkeleton()),
        },
      ],
    );
  }
}

String lessonTitle(Lesson l) => [?l.classLabel, l.subject].join(' · ');

/// Marks every student of a lesson present, through the queue (swipe on a
/// past lesson, «Закрыть все без отсутствующих»). Returns the queued item
/// keys for «Отменить».
Future<List<String>> markLessonAllPresent(WidgetRef ref, String lessonId) async {
  final lesson = await ref.read(lessonProvider(lessonId).future);
  final parts = await Future.wait(lesson.classIds.map((id) => ref.read(classStudentsProvider(id).future)));
  final roster = mergeRoster(lesson.classIds, {for (var i = 0; i < parts.length; i++) lesson.classIds[i]: parts[i]});
  if (roster.isEmpty) return const [];
  final outbox = ref.read(outboxProvider);
  final actions = LessonActions(outbox, lesson);
  if (lesson.status == LessonStatus.scheduled) await actions.start();
  await actions.markMany({for (final s in roster) s.id: (status: Presence.present, code: '')});
  return [
    for (final i in outbox.pending)
      if (i.label['lesson_id'] == lessonId) i.key,
  ];
}

class _Body extends ConsumerWidget {
  const _Body({required this.day, required this.now, required this.filter, required this.onFilter});
  final TeacherDay day;
  final DateTime now;
  final _Filter? filter;
  final ValueChanged<_Filter> onFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final today = isoDate(now);
    final lessons = day.today;
    final state = computeNowNext([for (final t in lessons) t.lesson], now);
    final todoById = {for (final t in lessons) t.lesson.id: t};
    final unmarked = lessons.where((t) => t.needsAttendance && t.lesson.isPast(now)).length;
    final noTopic = lessons.where((t) => t.needsTopic && !now.isBefore(t.lesson.startsAt())).length;
    final debtsToday = lessons
        .where((t) => t.lesson.isPast(now) && t.debts.isNotEmpty && !t.lesson.isCancelled)
        .toList();
    final overdue = day.overdue.where((t) => t.lesson.date != today && t.needsAttendance).toList();
    final visible = lessons.where((t) {
      return switch (filter) {
        _Filter.unmarked => t.needsAttendance && t.lesson.isPast(now),
        _Filter.noTopic => t.needsTopic,
        null => true,
      };
    }).toList();

    void open(String id) => context.push('/lesson/$id');

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: g),
      sliver: SliverList.list(
        children: [
          RepaintBoundary(
            child: _TeacherHero(state: state, todo: todoById, debts: debtsToday, onOpen: open, now: now),
          ),
          if (unmarked > 0 || noTopic > 0) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                if (unmarked > 0)
                  GChip(
                    label: l.tUnmarked,
                    count: unmarked,
                    tone: GTone.warn,
                    selected: filter == _Filter.unmarked,
                    onTap: () => onFilter(_Filter.unmarked),
                  ),
                if (noTopic > 0)
                  GChip(
                    label: l.tNoTopic,
                    count: noTopic,
                    selected: filter == _Filter.noTopic,
                    onTap: () => onFilter(_Filter.noTopic),
                  ),
              ],
            ),
          ],
          if (lessons.isNotEmpty) ...[
            GSectionTitle(
              title: l.tLessons,
              trailing: Text(l.tTodayCount(lessons.length), style: context.t.footnote.copyWith(color: c.ink2)),
            ),
            GGroup(
              inset: 76,
              children: [for (final t in visible) _TodoRow(todo: t, now: now, onOpen: () => open(t.lesson.id))],
            ),
          ],
          if (overdue.isNotEmpty) ...[
            GSectionTitle(title: l.tDebts),
            GGroup(
              children: [
                GRow(
                  leading: const _Plate(icon: GIcons.info, tone: GTone.warn),
                  title: Text(l.tDebtsUnmarked(overdue.length)),
                  subtitle: Text(overdue.take(3).map((t) => lessonTitle(t.lesson)).join(', ')),
                  subtitleMaxLines: 2,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GButton(
                      label: l.tCloseAll,
                      variant: GButtonVariant.tinted,
                      size: GButtonSize.s,
                      onPressed: () => _closeAll(context, ref, overdue),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _closeAll(BuildContext context, WidgetRef ref, List<TodoLesson> lessons) async {
    final l = context.l10n;
    final ok = await showGSheet<bool>(
      context,
      title: l.tCloseAllConfirm,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.tCloseAllBody, style: ctx.t.body.copyWith(color: ctx.c.ink2)),
            const SizedBox(height: 12),
            GGroup(
              children: [
                for (final t in lessons)
                  GRow(
                    minHeight: GSpace.rowCompact,
                    marker: ctx.c.subjectMarker(t.lesson.colorKey),
                    title: Text(lessonTitle(t.lesson)),
                    subtitle: Text(
                      '${Fmt.dayMonth(DateTime.parse(t.lesson.date), ctx.localeTag)} · ${hm(t.lesson.start)}',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: Builder(
        builder: (ctx) =>
            GButton(label: l.tAllPresent, size: GButtonSize.l, expand: true, onPressed: () => Navigator.pop(ctx, true)),
      ),
    );
    if (ok != true) return;
    for (final t in lessons) {
      try {
        await markLessonAllPresent(ref, t.lesson.id);
      } catch (_) {
        // Offline without a cached roster: that lesson stays in the debts.
      }
    }
    GHaptics.success();
    ref.invalidate(teacherDayProvider);
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.icon, required this.tone});
  final IconData icon;
  final GTone tone;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: ShapeDecoration(color: tone.soft(context.c), shape: GRadius.surface(13)),
    child: GIcon(icon, size: 22, color: tone.fg(context.c), fill: 1),
  );
}

class _TodoRow extends ConsumerWidget {
  const _TodoRow({required this.todo, required this.now, required this.onOpen});
  final TodoLesson todo;
  final DateTime now;
  final VoidCallback onOpen;

  String _debt(AppLocalizations l, String m) => switch (m) {
    'attendance' => l.missingAttendance,
    'topic' => l.missingTopic,
    'homework' => l.missingHomework,
    _ => l.missingGrades,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final lesson = todo.lesson;
    final past = lesson.isPast(now);
    final current = lesson.isNow(now);
    final debts = todo.debts;
    final subtitle = past || current
        ? [
            if (todo.attendanceMarked) l.tRollDone else l.tRollNotDone,
            if (lesson.topic.isNotEmpty) lesson.topic,
          ].join(' · ')
        : [if (lesson.room != null) l.room(lesson.room!), if (lesson.topic.isNotEmpty) lesson.topic].join(' · ');
    final trailing = lesson.isCancelled
        ? null
        : current
        ? GStatusPill(label: l.pillNow, tone: GTone.info)
        : past && debts.isEmpty
        ? GIcon(GIcons.ok, size: 24, color: c.ok, fill: 1, semanticLabel: l.tAllFilled)
        : past
        ? GStatusPill(label: _debt(l, debts.first), tone: GTone.warn)
        : null;
    final row = LessonRow(
      lesson: lesson,
      now: now,
      title: lessonTitle(lesson),
      subtitle: subtitle,
      trailing: trailing,
      onTap: onOpen,
      semanticLabel: l.tLessonRowSemantic(hm(lesson.start), lesson.classGroupName ?? '', lesson.subject, subtitle),
    );
    if (!past || !todo.needsAttendance || lesson.isCancelled) return row;
    Future<void> allPresent() async {
      GHaptics.light();
      try {
        final keys = await markLessonAllPresent(ref, lesson.id);
        if (!context.mounted) return;
        GToast.show(
          context,
          l.tAllPresentToast(lesson.classGroupName ?? lesson.subject),
          actionLabel: l.undo,
          onAction: () async {
            final outbox = ref.read(outboxProvider);
            for (final i in [...outbox.pending]) {
              if (keys.contains(i.key)) await outbox.remove(i);
            }
          },
        );
      } catch (_) {
        GHaptics.error();
      }
    }

    return Dismissible(
      key: ValueKey('todo-${lesson.id}'),
      direction: DismissDirection.startToEnd,
      dismissThresholds: const {DismissDirection.startToEnd: 0.3},
      background: Container(
        color: c.okSoft,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            GIcon(GIcons.ok, color: c.ok, fill: 1),
            const SizedBox(width: 8),
            Text(l.tAllPresent, style: context.t.bodyStrong.copyWith(color: c.ok)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        await allPresent();
        return false;
      },
      child: Semantics(
        customSemanticsActions: {CustomSemanticsAction(label: l.tAllPresent): () => unawaited(allPresent())},
        child: row,
      ),
    );
  }
}

/// Loud sheet of the teacher (§3.14, last rows): class 48 pt, one button.
class _TeacherHero extends ConsumerWidget {
  const _TeacherHero({
    required this.state,
    required this.todo,
    required this.debts,
    required this.onOpen,
    required this.now,
  });
  final NowNext state;
  final Map<String, TodoLesson> todo;
  final List<TodoLesson> debts;
  final ValueChanged<String> onOpen;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    const on = GColors.onFill;
    final on88 = on.withValues(alpha: 0.88);
    final s = state;

    if (s.phase == DayPhase.none) {
      return GCard(
        child: GEmpty(title: l.tNoLessons, icon: GIcons.today),
      );
    }
    if (s.phase == DayPhase.after) {
      if (debts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(GSpace.heroPad),
          decoration: ShapeDecoration(color: c.okSoft, shape: GRadius.surface(GRadius.hero)),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: GColors.okFill, shape: BoxShape.circle),
                child: const GIcon(GIcons.ok, color: on, fill: 1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.tDayClosed, style: t.title1),
                    Text(l.tDayClosedHint, style: t.callout.copyWith(color: c.ink2)),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return GHeroSheet(
        color: GColors.brand,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${l.tCloseDay} · ${l.tActions(debts.length)}'.toUpperCase(), style: t.eyebrow.copyWith(color: on88)),
            const SizedBox(height: 10),
            for (final d in debts.take(5))
              GPressable(
                onTap: () => onOpen(d.lesson.id),
                semanticLabel: lessonTitle(d.lesson),
                excludeChildSemantics: true,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: ShapeDecoration(color: on.withValues(alpha: 0.14), shape: GRadius.surface(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.tMissingWhat(
                            d.debts.map((m) => m == 'attendance' ? l.missingAttendance : l.missingTopic).join(', '),
                            lessonTitle(d.lesson),
                          ),
                          style: t.bodyStrong.copyWith(color: on),
                        ),
                      ),
                      const GIcon(GIcons.chevron, size: 20, color: on),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final lesson = s.focus!;
    final td = todo[lesson.id];
    final running = s.phase == DayPhase.lesson;
    final eyebrow = running ? '${l.heroNow} · ${l.tUntilBell(s.minutes)}' : '${l.heroNext} · ${l.tStartsIn(s.minutes)}';
    final rollDone = td?.attendanceMarked ?? false;
    final status = [rollDone ? l.tRollDone : l.tRollNotDone, if (lesson.topic.isNotEmpty) l.tTopicDone].join(' · ');
    final fill = c.subjectFill(lesson.colorKey);
    return GHeroSheet(
      color: fill,
      fan: [for (final u in s.upcoming) c.subjectFill(u.colorKey)],
      heroTag: 'lesson-${lesson.id}',
      onTap: () => onOpen(lesson.id),
      semanticLabel: [
        eyebrow,
        lesson.classGroupName ?? '',
        lesson.subject,
        if (lesson.room != null) l.room(lesson.room!),
        status,
      ].join('. '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(eyebrow.toUpperCase(), style: t.eyebrow.copyWith(color: on88), maxLines: 1),
              ),
              Text('${hm(lesson.start)}–${hm(lesson.end)}', style: t.eyebrow.copyWith(color: on88)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 10,
            children: [
              CappedText(lesson.classLabel ?? '', style: t.titleXl.copyWith(color: on)),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(lesson.subject, style: t.title2.copyWith(color: on)),
              ),
            ],
          ),
          if (lesson.room != null || lesson.isJoint) ...[
            const SizedBox(height: 4),
            Text(
              [if (lesson.room != null) l.room(lesson.room!), if (lesson.isJoint) l.pillJoint].join(' · '),
              style: t.callout.copyWith(color: on88),
            ),
          ],
          if (running) ...[const SizedBox(height: 14), GHeroProgress(value: s.progress)],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(status, style: t.subhead.copyWith(color: on), maxLines: 2),
              ),
              const SizedBox(width: 12),
              GButton(
                label: l.openLesson,
                icon: GIcons.forward,
                variant: GButtonVariant.onColor,
                color: fill,
                size: GButtonSize.m,
                onPressed: () => onOpen(lesson.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
