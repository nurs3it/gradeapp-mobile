import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../common/lesson_widgets.dart';
import '../common/models.dart';
import '../common/week_view.dart';
import '../parent/excuse_sheet.dart';
import '../shell/header.dart';
import 'learner_providers.dart';

/// Student and parent «Неделя» (S4).
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(learnerIdProvider);
    final parent = ref.watch(activeRoleProvider) == AppRole.parent;
    if (id == null) return const _Pending();
    final l = context.l10n;
    final c = context.c;
    return WeekView(
      actions: [const BellButton(), if (parent) const ChildSwitcherButton() else const AvatarButton()],
      watchWeek: (ref, monday) => ref.watch(weekLessonsProvider((studentId: id, monday: monday))),
      homeworkDays: (ref, monday) =>
          (ref.watch(homeworkProvider(id)).value ?? const <Homework>[]).map((h) => h.dueDate).toSet(),
      onRefresh: (monday) async {
        ref
          ..invalidate(weekLessonsProvider((studentId: id, monday: monday)))
          ..invalidate(homeworkProvider(id));
        await ref
            .read(weekLessonsProvider((studentId: id, monday: monday)).future)
            .then((_) {}, onError: (Object _) {});
      },
      rowBuilder: (context, lesson, day, now) {
        final hw = (ref.read(homeworkProvider(id)).value ?? const <Homework>[])
            .where((h) => h.lessonId == lesson.id || (h.dueDate == lesson.date && h.courseId == lesson.courseId))
            .toList();
        return LessonRow(
          lesson: lesson,
          now: now,
          twoLineTime: true,
          secondLine: lesson.topic,
          trailing: hw.isEmpty || lesson.isCancelled
              ? null
              : Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: ShapeDecoration(color: c.primarySoft, shape: const StadiumBorder()),
                  alignment: Alignment.center,
                  child: Text(
                    '${l.hwShort} ${hw.length}',
                    style: context.t.footnote.copyWith(color: c.primarySoftText, fontWeight: FontWeight.w700),
                  ),
                ),
          onTap: () => showLessonSheet(
            context,
            lesson: lesson,
            number: lessonNumber(day, lesson),
            homework: hw,
            parent: parent,
            onExplain: parent ? () => showExcuseSheet(context, studentId: id, lesson: lesson) : null,
          ),
        );
      },
    );
  }
}

class _Pending extends ConsumerWidget {
  const _Pending();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final children = ref.watch(childrenProvider);
    return Scaffold(
      body: Center(
        child: children.hasValue ? GEmpty(title: l.noChildrenTitle, message: l.noChildrenMessage) : const GLoader(),
      ),
    );
  }
}
