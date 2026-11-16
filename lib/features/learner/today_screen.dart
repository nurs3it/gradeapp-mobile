import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../school/school_providers.dart';
import 'check_in_card.dart';
import 'learner_providers.dart';
import 'learner_scope.dart';
import 'models.dart';
import 'widgets.dart';

/// The learner's day in one screen: check-in, what's on now, lessons with
/// marks, homework due soon, fresh grades.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  // Re-render each minute so «now» and countdowns stay true.
  late final Timer _tick = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final id = ref.watch(learnerIdProvider);
    final args = id == null ? null : (studentId: id, date: isoDate(now));
    final user = ref.watch(authProvider).value;
    final isStudent = ref.watch(activeRoleProvider) == AppRole.student;
    final greeting = switch (now.hour) {
      < 12 => l.greetingMorning,
      < 18 => l.greetingDay,
      _ => l.greetingEvening,
    }(user?.firstName ?? '');

    return GPage(
      title: l.tabToday,
      subtitle: '$greeting · ${dayMonth(now, context.localeTag, weekday: true)}',
      header: const ChildSwitcher(),
      onRefresh: args == null ? null : () => ref.refresh(learnerDayProvider(args).future),
      slivers: [
        if (args == null)
          const SliverToBoxAdapter(child: LearnerPending())
        else
          Consumer(
            builder: (context, ref, _) {
              final day = ref.watch(learnerDayProvider(args));
              return SliverToBoxAdapter(
                child: GAsync(
                  value: day,
                  onRetry: () => ref.invalidate(learnerDayProvider(args)),
                  data: (d) => _DayBody(day: d, now: now, actionable: isStudent),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _DayBody extends ConsumerWidget {
  const _DayBody({required this.day, required this.now, required this.actionable});
  final LearnerDay day;
  final DateTime now;
  final bool actionable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final grading = ref.watch(gradingOrDefaultProvider);
    final lessons = day.lessons;
    final gradesByLesson = <String, List<Grade>>{};
    for (final g in day.recentGrades) {
      if (g.lessonId != null) (gradesByLesson[g.lessonId!] ??= []).add(g);
    }
    final due = day.homework.where((h) => !h.isDone).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (day.checkIn?.enabled ?? false) ...[
          const SizedBox(height: GSpace.sm),
          CheckInCard(status: day.checkIn!, actionable: actionable),
        ],
        _NowBanner(lessons: lessons, now: now),
        GSectionHeader('${l.tabSchedule} · ${l.lessonsCount(lessons.length)}'),
        if (lessons.isEmpty)
          GEmptyState(icon: Icons.free_breakfast_outlined, title: l.noLessonsTitle, message: l.noLessonsMessage)
        else
          for (final lesson in lessons)
            GLessonTile(
              subject: lesson.subject,
              start: lesson.start,
              end: lesson.end,
              subtitle: [if (lesson.room != null) l.room(lesson.room!), ?lesson.teacherName].join(' · '),
              now: lesson.isNow(now),
              past: lesson.isPast(now),
              cancelled: lesson.isCancelled,
              status: presencePill(context, day.attendance[lesson.id]),
              trailing: gradesByLesson[lesson.id] == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final g in gradesByLesson[lesson.id]!.take(2))
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: GGradeChip(value: g.value, maxValue: g.maxValue, grading: grading, size: 32),
                          ),
                      ],
                    ),
            ),
        if (due.isNotEmpty) ...[
          GSectionHeader(l.homeworkDue, action: l.all, onAction: () => context.go('/l/homework')),
          GGroup(inset: 56, children: [for (final h in due) HomeworkTile(homework: h)]),
        ],
        if (day.recentGrades.isNotEmpty) ...[
          GSectionHeader(l.recentGrades, action: l.all, onAction: () => context.go('/l/grades')),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: GSpace.page),
              itemCount: day.recentGrades.length,
              separatorBuilder: (_, _) => const SizedBox(width: GSpace.sm),
              itemBuilder: (_, i) => GradeCard(grade: day.recentGrades[i], grading: grading),
            ),
          ),
        ],
      ],
    );
  }
}

/// «Сейчас: Алгебра · закончится через 12 мин» / «Далее: … через 5 мин».
class _NowBanner extends StatelessWidget {
  const _NowBanner({required this.lessons, required this.now});
  final List<Lesson> lessons;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final m = now.hour * 60 + now.minute;
    final active = lessons.where((x) => !x.isCancelled).toList();
    final current = active.where((x) => x.isNow(now)).firstOrNull;
    final next = active.where((x) => minutesOf(x.start) > m).firstOrNull;
    if (active.isEmpty) return const SizedBox.shrink();

    final (label, lesson, hint) = current != null
        ? (l.now, current, l.lessonEndsIn(minutesOf(current.end) - m))
        : next != null
        ? (l.next, next, l.lessonStartsIn(minutesOf(next.start) - m))
        : (null, null, l.dayDone);

    return Padding(
      padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.md, GSpace.page, 0),
      child: GCard(
        color: lesson == null ? null : c.primarySoft,
        borderColor: lesson == null ? null : c.primary.withValues(alpha: 0.3),
        child: Row(
          children: [
            Icon(
              lesson == null ? Icons.nightlight_round : Icons.play_circle_fill_rounded,
              color: lesson == null ? c.mutedForeground : c.primaryText,
              size: 32,
            ),
            const SizedBox(width: GSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(label.toUpperCase(), style: context.t.labelSmall!.copyWith(color: c.primaryText)),
                  Text(
                    lesson == null ? hint : [lesson.subject, if (lesson.room != null) l.room(lesson.room!)].join(' · '),
                    style: context.t.titleMedium,
                  ),
                  if (lesson != null) Text(hint, style: context.t.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
