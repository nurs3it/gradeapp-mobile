import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/events.dart';
import '../common/lesson_widgets.dart';
import '../common/models.dart';
import '../common/now_next.dart';
import '../learner/learner_hero.dart';
import '../learner/learner_providers.dart';
import '../learner/school_life.dart';
import '../learner/seen.dart';
import '../learner/streaks.dart';
import '../learner/week_card.dart';
import '../shell/header.dart';
import 'check_in_card.dart';
import 'check_in_state.dart';

/// Student «Сегодня» (S1, §3.1): check-in → loud «Сейчас / Дальше» → smart
/// tiles → compact plan of the day.
class StudentTodayScreen extends ConsumerWidget {
  const StudentTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = ref.now;
    final id = ref.watch(myStudentIdProvider);
    final today = isoDate(now);
    final day = id == null ? null : ref.watch(learnerDayProvider((studentId: id, date: today)));

    Future<void> refresh() async {
      if (id == null) return;
      ref.invalidate(learnerDayProvider);
      ref.invalidate(homeworkProvider(id));
      await ref.read(learnerDayProvider((studentId: id, date: today)).future).then((_) {}, onError: (Object _) {});
    }

    return GRootPage(
      eyebrow: Fmt.weekdayDayMonth(now, context.localeTag),
      title: l.tabToday,
      actions: const [BellButton(), AvatarButton()],
      onRefresh: refresh,
      below: const NetBanner(),
      slivers: [
        if (day == null || (day.isLoading && !day.hasValue))
          const SliverToBoxAdapter(child: GSkeleton())
        else if (day.hasError && !day.hasValue)
          SliverToBoxAdapter(
            child: GEmpty(
              error: true,
              title: l.errorTitle,
              message: l.errorOffline,
              action: l.retry,
              onAction: () => ref.invalidate(learnerDayProvider),
            ),
          )
        else
          _Body(day: day.value!, now: now, studentId: id!),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.day, required this.now, required this.studentId});
  final LearnerDay day;
  final DateTime now;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final g = GSpace.gutter(context);
    final state = computeNowNext(day.lessons, now);
    final cardState = checkInCardState(day.checkIn, now);
    final checkInLoud = cardState == CheckInCardState.open;
    final tomorrow = isoDate(now.add(const Duration(days: 1)));
    final overrides = ref.watch(homeworkOverridesProvider);
    bool done(Homework h) => overrides[h.id] ?? h.isDone;
    final dueTomorrow = day.homework.where((h) => h.dueDate == tomorrow && !done(h)).toList();
    final tomorrowMinutes = dueTomorrow.fold<int>(0, (s, h) => s + (h.minutes ?? 0));
    final needTomorrow = state.phase == DayPhase.after || state.phase == DayPhase.none;
    final tomorrowDay = needTomorrow
        ? ref.watch(learnerDayProvider((studentId: studentId, date: tomorrow))).value
        : null;

    final allHw = ref.watch(homeworkProvider(studentId)).value ?? const <Homework>[];
    final overdue = allHw.where((h) => h.dueDate.compareTo(day.date) < 0 && !done(h)).length;
    final seen = ref.watch(gradesSeenProvider).at;
    final fresh = day.recentGrades.where((gr) => now.difference(DateTime.parse(gr.date)).inDays <= 1).take(3).toList();

    void goTab(int i) => StatefulNavigationShell.maybeOf(context)?.goBranch(i);
    void openLesson(Lesson lesson) => showLessonSheet(
      context,
      lesson: lesson,
      number: lessonNumber(day.lessons, lesson),
      mark: day.attendance[lesson.id],
      grades: day.recentGrades.where((gr) => gr.lessonId == lesson.id).toList(),
      homework: day.homework.where((h) => h.lessonId == lesson.id).toList(),
    );

    final tiles = <Widget>[
      if (overdue > 0)
        GTile(
          label: l.tileOverdue,
          icon: GIcons.error,
          value: '$overdue',
          unit: l.tasksUnit(overdue),
          onTap: () => goTab(3),
        )
      else if (dueTomorrow.isNotEmpty && !needTomorrow)
        GTile(
          label: l.tileTomorrow,
          icon: GIcons.tasks,
          value: '${dueTomorrow.length}',
          unit: l.tasksUnit(dueTomorrow.length),
          caption: tomorrowMinutes > 0 ? l.approxMinutes(tomorrowMinutes) : null,
          onTap: () => goTab(3),
        ),
      if (fresh.isNotEmpty)
        GTile(
          label: l.tileNewGrades,
          icon: GIcons.grades,
          onTap: () => goTab(2),
          caption: fresh.map((gr) => gr.courseName).toSet().join(' · '),
          child: Wrap(
            spacing: 8,
            children: [for (final gr in fresh) GradeChipOf(grade: gr, size: GGradeSize.m, isNew: isNewGrade(gr, seen))],
          ),
        ),
    ];

    final passed = day.lessons.where((x) => x.isPast(now)).toList();
    final rest = day.lessons.where((x) => !x.isPast(now)).toList();
    final passedGrades = day.recentGrades.where((gr) => passed.any((p) => p.id == gr.lessonId)).toList();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: g),
      sliver: SliverList.list(
        children: [
          const PinnedEventsLine(),
          if (cardState != CheckInCardState.hidden) ...[
            CheckInCard(
              status: day.checkIn!,
              state: cardState,
              dayOver: day.lessons.any((x) => !x.isCancelled) &&
                  day.lessons.where((x) => !x.isCancelled).every((x) => !now.isBefore(x.endsAt())),
            ),
            const SizedBox(height: 14),
          ],
          RepaintBoundary(
            child: LearnerHero(
              state: state,
              lessons: day.lessons,
              quiet: checkInLoud,
              tomorrowTasks: dueTomorrow.length,
              tomorrowMinutes: tomorrowMinutes,
              tomorrow: tomorrowDay?.lessons,
              onTapLesson: openLesson,
              onOpenTasks: () => goTab(3),
            ),
          ),
          if (tiles.isNotEmpty) ...[const SizedBox(height: 24), GTileRow(tiles: tiles)],
          const StreakCard(),
          WeekCard(studentId: studentId, lessons: day.lessons, now: now),
          BirthdayLine(myStudentId: studentId),
          MenuCard(date: day.date),
          if (day.lessons.isNotEmpty) ...[
            GSectionTitle(title: l.dayPlan, action: l.tabWeek, onAction: () => goTab(1)),
            GGroup(
              inset: 76,
              children: [
                if (passed.isNotEmpty)
                  GRow(
                    leading: SizedBox(
                      width: 48,
                      child: Text(
                        hm(passed.first.start),
                        style: context.t.callout.copyWith(color: context.c.ink3, fontWeight: FontWeight.w600),
                      ),
                    ),
                    marker: context.c.ink3,
                    title: Text(l.lessonsPassed(passed.length)),
                    subtitle: Text(passed.map((p) => p.subject).toSet().join(' · ')),
                    trailing: passedGrades.isEmpty
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final gr in passedGrades.take(2))
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: GradeChipOf(grade: gr),
                                ),
                            ],
                          ),
                  ),
                ...lessonRowsWithBreaks(rest, (x) => LessonRow(lesson: x, now: now, onTap: () => openLesson(x))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
