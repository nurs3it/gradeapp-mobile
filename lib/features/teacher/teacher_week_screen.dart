import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../auth/auth_controller.dart';
import '../common/models.dart';
import '../common/lesson_widgets.dart';
import '../common/week_view.dart';
import '../shell/header.dart';
import 'teacher_providers.dart';
import 'teacher_today_screen.dart' show lessonTitle;

/// T9: who the substitution is about, from the viewer's side — «за Иванов»
/// when I stand in, «ведёт Петров» when someone stands in for me.
String? substitutionNoteFor(AppLocalizations l, Lesson lesson, String? myStaffId) {
  if (!lesson.isSubstitution) return null;
  final mine = myStaffId != null && lesson.teacherId == myStaffId;
  if (mine) return lesson.courseTeacherName == null ? null : l.t9ForTeacher(lesson.courseTeacherName!);
  return lesson.teacherName == null ? null : l.t9TaughtBy(lesson.teacherName!);
}

/// Teacher «Неделя» in 1.0 (§5.4): the same week with classes instead of
/// teachers; any lesson opens the lesson screen.
class TeacherWeekScreen extends ConsumerWidget {
  const TeacherWeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffId = ref.watch(authProvider.select((u) => u.value?.staffId));
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
        substitutionNote: substitutionNoteFor(context.l10n, lesson, staffId),
        onTap: () => context.push('/lesson/${lesson.id}'),
      ),
    );
  }
}
