import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../common/lesson_widgets.dart';
import '../common/week_view.dart';
import '../shell/header.dart';
import 'teacher_providers.dart';
import 'teacher_today_screen.dart' show lessonTitle;

/// Teacher «Неделя» in 1.0 (§5.4): the same week with classes instead of
/// teachers; any lesson opens the lesson screen.
class TeacherWeekScreen extends ConsumerWidget {
  const TeacherWeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WeekView(
      actions: const [SyncIndicator(), AvatarButton()],
      watchWeek: (ref, monday) => ref.watch(teacherWeekProvider(monday)),
      onRefresh: (monday) async {
        ref.invalidate(teacherWeekProvider(monday));
        await ref.read(teacherWeekProvider(monday).future).then((_) {}, onError: (Object _) {});
      },
      rowBuilder: (context, lesson, day, now) => LessonRow(
        lesson: lesson,
        now: now,
        twoLineTime: true,
        title: lessonTitle(lesson),
        subtitle: lesson.room == null ? '' : context.l10n.room(lesson.room!),
        secondLine: lesson.topic,
        onTap: () => context.push('/lesson/${lesson.id}'),
      ),
    );
  }
}
