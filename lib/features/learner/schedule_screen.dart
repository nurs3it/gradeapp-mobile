import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'learner_providers.dart';
import 'learner_scope.dart';
import 'models.dart';

/// Week strip + the chosen day's lessons. Swipe left/right to change day.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _day = DateTime.now();

  void _shift(int days) {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _day = _day.add(Duration(days: days)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final id = ref.watch(learnerIdProvider);
    final monday = mondayOf(_day);
    final args = id == null ? null : (studentId: id, monday: isoDate(monday));
    final now = DateTime.now();

    return GPage(
      title: l.tabSchedule,
      subtitle: dayMonth(_day, context.localeTag, weekday: true),
      actions: [
        if (isoDate(_day) != isoDate(now))
          TextButton(onPressed: () => setState(() => _day = now), child: Text(l.today)),
        IconButton(tooltip: l.weekPrev, onPressed: () => _shift(-7), icon: const Icon(Icons.chevron_left_rounded)),
        IconButton(tooltip: l.weekNext, onPressed: () => _shift(7), icon: const Icon(Icons.chevron_right_rounded)),
      ],
      header: Column(
        children: [
          const ChildSwitcher(),
          GWeekStrip(monday: monday, selected: _day, onSelect: (d) => setState(() => _day = d)),
          const SizedBox(height: GSpace.sm),
        ],
      ),
      onRefresh: args == null ? null : () => ref.refresh(weekLessonsProvider(args).future),
      slivers: [
        if (args == null)
          const SliverToBoxAdapter(child: LearnerPending())
        else
          SliverToBoxAdapter(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v.abs() > 300) _shift(v < 0 ? 1 : -1);
              },
              child: GAsync(
                value: ref.watch(weekLessonsProvider(args)),
                onRetry: () => ref.invalidate(weekLessonsProvider(args)),
                data: (week) {
                  final lessons = week.where((x) => x.date == isoDate(_day)).toList();
                  if (lessons.isEmpty) {
                    return GEmptyState(
                      icon: Icons.free_breakfast_outlined,
                      title: l.noLessonsTitle,
                      message: l.noLessonsMessage,
                    );
                  }
                  return Column(
                    children: [
                      for (final lesson in lessons)
                        GLessonTile(
                          subject: lesson.subject,
                          start: lesson.start,
                          end: lesson.end,
                          subtitle: [if (lesson.room != null) l.room(lesson.room!), ?lesson.teacherName].join(' · '),
                          now: lesson.isNow(now),
                          past: lesson.isPast(now),
                          cancelled: lesson.isCancelled,
                          status: lesson.topic.isEmpty
                              ? null
                              : Text(
                                  lesson.topic,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.t.bodySmall,
                                ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
