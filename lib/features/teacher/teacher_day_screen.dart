import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../learner/learner_providers.dart' show mondayOf;
import '../learner/models.dart';
import 'models.dart';
import 'teacher_providers.dart';

/// Teacher home: the day's lessons with what's left to fill in, plus the
/// debts of the last two weeks. One tap opens the lesson.
class TeacherDayScreen extends ConsumerStatefulWidget {
  const TeacherDayScreen({super.key});

  @override
  ConsumerState<TeacherDayScreen> createState() => _TeacherDayScreenState();
}

class _TeacherDayScreenState extends ConsumerState<TeacherDayScreen> {
  DateTime _day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final date = isoDate(_day);
    final now = DateTime.now();
    final isToday = date == isoDate(now);
    final pending = ref.watch(outboxPendingProvider).value?.length ?? 0;

    return GPage(
      title: l.tabLessons,
      subtitle: dayMonth(_day, context.localeTag, weekday: true),
      actions: [
        if (pending > 0)
          IconButton(
            tooltip: l.syncPending(pending),
            onPressed: () {
              ref.read(outboxProvider).flush();
              showGToast(context, l.syncPending(pending));
            },
            icon: GCountBadge(
              count: pending,
              child: Icon(Icons.cloud_upload_outlined, color: context.c.warningText),
            ),
          ),
        if (!isToday) TextButton(onPressed: () => setState(() => _day = now), child: Text(l.today)),
      ],
      header: Padding(
        padding: const EdgeInsets.only(bottom: GSpace.sm),
        child: GWeekStrip(monday: mondayOf(_day), selected: _day, onSelect: (d) => setState(() => _day = d)),
      ),
      onRefresh: () => ref.refresh(teacherDayProvider(date).future),
      slivers: [
        SliverToBoxAdapter(
          child: GAsync(
            value: ref.watch(teacherDayProvider(date)),
            onRetry: () => ref.invalidate(teacherDayProvider(date)),
            data: (day) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (day.today.isEmpty)
                  GEmptyState(icon: Icons.free_breakfast_outlined, title: l.teacherTodayEmpty)
                else
                  for (final x in day.today) _TodoTile(lesson: x, now: now),
                if (isToday && day.overdue.isNotEmpty) ...[
                  GSectionHeader('${l.overdueTitle} · ${day.overdue.length}'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GSpace.page, 0, GSpace.page, GSpace.sm),
                    child: Text(l.overdueHint, style: context.t.bodySmall),
                  ),
                  for (final x in day.overdue) _TodoTile(lesson: x, now: now, showDate: true),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({required this.lesson, required this.now, this.showDate = false});
  final TodoLesson lesson;
  final DateTime now;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final asLesson = Lesson.fromJson({'date': lesson.date, 'start_time': lesson.start, 'end_time': lesson.end});
    final started = asLesson.isNow(now) || asLesson.isPast(now);
    final cancelled = lesson.status == LessonStatus.cancelled || lesson.status == LessonStatus.moved;
    String label(String m) => switch (m) {
      'attendance' => l.missingAttendance,
      'topic' => l.missingTopic,
      'homework' => l.missingHomework,
      'grades' => l.missingGrades,
      _ => m,
    };
    // Only attendance and topic are real debts; homework/grades are hints.
    final debts = lesson.missing.where((m) => m == 'attendance' || m == 'topic').toList();

    return GLessonTile(
      subject: lesson.subject,
      start: lesson.start,
      end: lesson.end,
      subtitle: [
        if (showDate) dayMonth(DateTime.parse(lesson.date), context.localeTag),
        lesson.classGroupName,
        if (lesson.room != null) l.room(lesson.room!),
        if (lesson.topic.isNotEmpty) lesson.topic,
      ].join(' · '),
      now: asLesson.isNow(now),
      past: false,
      cancelled: cancelled,
      status: cancelled || !started
          ? null
          : debts.isEmpty
          ? GPill(l.allFilled, tone: GTone.success, icon: Icons.check_rounded)
          : Wrap(spacing: 6, runSpacing: 4, children: [for (final m in debts) GPill(label(m), tone: GTone.warning)]),
      trailing: Icon(Icons.chevron_right_rounded, color: context.c.subtleForeground),
      onTap: () => context.push('/t/lesson/${lesson.lessonId}'),
    );
  }
}
