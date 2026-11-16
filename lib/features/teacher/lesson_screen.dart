import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/offline/outbox.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../learner/models.dart';
import 'models.dart';
import 'teacher_providers.dart';

/// Running a lesson in a few taps: start, topic, attendance (one tap per
/// student, «Все на месте» for the rest), marks from a number pad that jumps
/// to the next student. Works offline — everything goes through the outbox.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonProvider(lessonId));
    return Scaffold(
      appBar: AppBar(title: Text(lesson.value?.subject ?? ''), actions: const [_SyncBadge()]),
      body: GAsync(
        value: lesson,
        onRetry: () => ref.invalidate(lessonProvider(lessonId)),
        data: (l) => _LessonBody(lesson: l),
      ),
    );
  }
}

class _SyncBadge extends ConsumerWidget {
  const _SyncBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(outboxPendingProvider).value?.length ?? 0;
    if (n == 0) return const SizedBox.shrink();
    return IconButton(
      tooltip: context.l10n.syncPending(n),
      onPressed: () {
        ref.read(outboxProvider).flush();
        showGToast(context, context.l10n.offlineSaved);
      },
      icon: GCountBadge(
        count: n,
        child: Icon(Icons.cloud_upload_outlined, color: context.c.warningText),
      ),
    );
  }
}

/// Per-student state shown in the roster.
typedef _Cell = ({Presence status, String code, bool saved, String source, num? grade});

class _LessonBody extends ConsumerStatefulWidget {
  const _LessonBody({required this.lesson});
  final Lesson lesson;

  @override
  ConsumerState<_LessonBody> createState() => _LessonBodyState();
}

class _LessonBodyState extends ConsumerState<_LessonBody> {
  late final LessonActions _actions = LessonActions(ref.read(outboxProvider), widget.lesson);
  late final TextEditingController _topic = TextEditingController(text: widget.lesson.topic);
  Timer? _topicDebounce;
  LessonStatus? _status; // optimistic start/finish
  String? _type;

  Lesson get lesson => widget.lesson;

  @override
  void dispose() {
    _topicDebounce?.cancel();
    if (_topic.text != lesson.topic) _actions.setTopic(_topic.text.trim());
    _topic.dispose();
    super.dispose();
  }

  void _onTopic(String v) {
    _topicDebounce?.cancel();
    _topicDebounce = Timer(const Duration(milliseconds: 900), () => _actions.setTopic(v.trim()));
  }

  void _refreshServerState() {
    ref
      ..invalidate(attendanceDefaultsProvider(lesson.id))
      ..invalidate(lessonGradesProvider(lesson.id))
      ..invalidate(teacherDayProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final grading = ref.watch(gradingOrDefaultProvider);
    final classId = lesson.classGroupId;
    final roster = classId == null ? const AsyncData(<RosterStudent>[]) : ref.watch(rosterProvider(classId));
    final defaults = ref.watch(attendanceDefaultsProvider(lesson.id)).value ?? const {};
    final grades = ref.watch(lessonGradesProvider(lesson.id)).value ?? const <Grade>[];
    final overlay = ref.watch(lessonOverlayProvider(lesson.id));

    // Once this lesson's queued writes are all sent, re-read the server truth.
    ref.listen<AsyncValue<List<OutboxItem>>>(outboxPendingProvider, (prev, next) {
      bool mine(List<OutboxItem>? items) => (items ?? const []).any((i) => i.key.contains(lesson.id));
      if (mine(prev?.value) && !mine(next.value)) _refreshServerState();
    });

    final types = grading.lessonTypes;
    final type =
        _type ?? grades.where((g) => g.type.isNotEmpty).firstOrNull?.type ?? (types.isEmpty ? 'fo' : types.first.code);
    final status = _status ?? lesson.status;
    final readOnly = lesson.isCancelled;

    _Cell cell(String sid) {
      final o = overlay.attendance[sid];
      final d = defaults[sid];
      final serverGrade = grades.where((g) => g.studentId == sid && g.type == type).firstOrNull?.value;
      return (
        status: o?.status ?? d?.status ?? Presence.present,
        code: o?.code ?? d?.code ?? '',
        saved: o != null || d?.source == 'lesson',
        source: o != null ? 'lesson' : (d?.source ?? ''),
        grade: overlay.grades.containsKey(sid) ? overlay.grades[sid] : serverGrade,
      );
    }

    return GAsync(
      value: roster,
      onRetry: () => ref.invalidate(rosterProvider(classId!)),
      data: (students) {
        final cells = {for (final s in students) s.id: cell(s.id)};
        final present = cells.values.where((x) => x.status == Presence.present || x.status == Presence.tardy).length;
        final unsaved = students.where((s) => !cells[s.id]!.saved).map((s) => s.id).toList();

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: GSpace.lg),
                children: [
                  _Header(
                    lesson: lesson,
                    status: status,
                    onStart: () {
                      unawaited(HapticFeedback.mediumImpact());
                      setState(() => _status = LessonStatus.inProgress);
                      _actions.start();
                    },
                    onFinish: () {
                      unawaited(HapticFeedback.mediumImpact());
                      setState(() => _status = LessonStatus.completed);
                      _actions.finish();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.md, GSpace.page, 0),
                    child: TextField(
                      controller: _topic,
                      enabled: !readOnly,
                      onChanged: _onTopic,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l.topic,
                        hintText: l.topicHint,
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.xl, GSpace.sm, GSpace.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text(l.presentCount(present, students.length), style: context.t.titleSmall)),
                        if (types.length > 1)
                          ActionChip(
                            avatar: const Icon(Icons.tune_rounded, size: 16),
                            label: Text(grading.typeName(type)),
                            onPressed: () async {
                              final picked = await showGSheet<String>(
                                context,
                                (ctx) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l.workType, style: ctx.t.titleMedium),
                                    const SizedBox(height: GSpace.sm),
                                    for (final w in types)
                                      ListTile(
                                        title: Text(w.name),
                                        trailing: w.code == type
                                            ? Icon(Icons.check_rounded, color: ctx.c.primaryText)
                                            : null,
                                        onTap: () => Navigator.pop(ctx, w.code),
                                      ),
                                    const SizedBox(height: GSpace.lg),
                                  ],
                                ),
                              );
                              if (picked != null) setState(() => _type = picked);
                            },
                          ),
                      ],
                    ),
                  ),
                  if (students.isEmpty)
                    GEmptyState(icon: Icons.groups_outlined, title: l.rosterEmpty)
                  else
                    GGroup(
                      inset: 68,
                      children: [
                        for (var i = 0; i < students.length; i++)
                          _StudentRow(
                            student: students[i],
                            cell: cells[students[i].id]!,
                            grading: grading,
                            readOnly: readOnly,
                            onPresence: (p, code) {
                              unawaited(HapticFeedback.selectionClick());
                              _actions.mark(students[i].id, p, code: code);
                            },
                            onGrade: () => _openPad(context, students, i, cells, grading, type),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            if (!readOnly && unsaved.isNotEmpty)
              _BottomBar(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  icon: const Icon(Icons.done_all_rounded),
                  label: Text('${l.allPresent} · ${unsaved.length}'),
                  onPressed: () {
                    unawaited(HapticFeedback.mediumImpact());
                    // Keep check-in / homeroom marks; the rest are present.
                    final byStatus = <Presence, List<String>>{};
                    for (final id in unsaved) {
                      (byStatus[cells[id]!.status] ??= []).add(id);
                    }
                    byStatus.forEach((p, ids) => _actions.markAll(ids, p));
                  },
                ),
              )
            else
              Container(height: MediaQuery.paddingOf(context).bottom, color: c.background),
          ],
        );
      },
    );
  }

  Future<void> _openPad(
    BuildContext context,
    List<RosterStudent> students,
    int index,
    Map<String, _Cell> cells,
    Grading grading,
    String type,
  ) {
    return showGSheet<void>(
      context,
      (_) => _GradePad(
        students: students,
        start: index,
        grading: grading,
        cellOf: (id) => cells[id]!,
        onPick: (id, v) {
          unawaited(HapticFeedback.mediumImpact());
          _actions.grade(id, v, type: type, scaleMax: grading.max);
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.lesson, required this.status, required this.onStart, required this.onFinish});
  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback onStart;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final started = lesson.isNow(now) || lesson.isPast(now);
    final action = switch (status) {
      LessonStatus.cancelled || LessonStatus.moved => GPill(l.lessonCancelled, tone: GTone.danger),
      LessonStatus.completed => GPill(l.lessonFinished, tone: GTone.success, icon: Icons.check_rounded),
      LessonStatus.inProgress => FilledButton.tonalIcon(
        onPressed: onFinish,
        icon: const Icon(Icons.stop_circle_outlined),
        label: Text(l.lessonFinish),
      ),
      LessonStatus.scheduled =>
        started || lesson.date == isoDate(now)
            ? FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l.lessonStart),
              )
            : null,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.sm, GSpace.page, 0),
      child: GCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: context.c.subject(lesson.subject),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: GSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.classGroupName ?? '', style: context.t.titleMedium),
                  Text(
                    [
                      dayMonth(DateTime.parse(lesson.date), context.localeTag),
                      '${hm(lesson.start)}–${hm(lesson.end)}',
                      if (lesson.room != null) l.room(lesson.room!),
                    ].join(' · '),
                    style: context.t.bodySmall,
                  ),
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.cell,
    required this.grading,
    required this.readOnly,
    required this.onPresence,
    required this.onGrade,
  });

  final RosterStudent student;
  final _Cell cell;
  final Grading grading;
  final bool readOnly;
  final void Function(Presence, String code) onPresence;
  final VoidCallback onGrade;

  static const _cycle = [Presence.present, Presence.absent, Presence.tardy];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hint = switch (cell.source) {
      'checkin' => l.fromCheckIn,
      'homeroom' => l.fromHomeroom,
      _ => null,
    };
    return GRow(
      leading: GAvatar(name: student.name, url: student.avatarUrl, size: 40),
      title: Text(student.name),
      subtitle: hint == null ? null : Text(hint),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PresenceButton(
            cell: cell,
            onTap: readOnly
                ? null
                : () {
                    final i = _cycle.indexOf(cell.status);
                    onPresence(_cycle[(i + 1) % _cycle.length], '');
                  },
            onLongPress: readOnly ? null : () => _codes(context),
          ),
          const SizedBox(width: GSpace.sm),
          _GradeButton(value: cell.grade, grading: grading, onTap: readOnly ? null : onGrade),
        ],
      ),
    );
  }

  /// Long press: full list incl. «уважительная» and the school's own codes.
  Future<void> _codes(BuildContext context) async {
    unawaited(HapticFeedback.heavyImpact());
    final l = context.l10n;
    final options = [
      (Presence.present, '', l.presencePresent),
      (Presence.absent, '', l.presenceAbsentLong),
      (Presence.tardy, '', l.presenceTardy),
      (Presence.excused, '', l.presenceExcusedLong),
      for (final code in grading.attendanceCodes) (code.status, code.code, '${code.code} — ${code.name}'),
    ];
    final picked = await showGSheet<(Presence, String)>(
      context,
      (ctx) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(student.name, style: ctx.t.titleMedium),
            Text(l.attendanceCodes, style: ctx.t.bodySmall),
            const SizedBox(height: GSpace.sm),
            for (final (p, code, label) in options)
              ListTile(
                title: Text(label),
                trailing: p == cell.status && code == cell.code
                    ? Icon(Icons.check_rounded, color: ctx.c.primaryText)
                    : null,
                onTap: () => Navigator.pop(ctx, (p, code)),
              ),
            const SizedBox(height: GSpace.lg),
          ],
        ),
      ),
    );
    if (picked != null) onPresence(picked.$1, picked.$2);
  }
}

class _PresenceButton extends StatelessWidget {
  const _PresenceButton({required this.cell, this.onTap, this.onLongPress});
  final _Cell cell;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final (label, tone) = switch (cell.status) {
      Presence.present => (l.presencePresent, GTone.success),
      Presence.absent => (cell.code.isEmpty ? l.presenceAbsent : cell.code, GTone.danger),
      Presence.tardy => (l.presenceTardy, GTone.warning),
      Presence.excused => (cell.code.isEmpty ? l.presenceExcused : cell.code, GTone.info),
    };
    final fg = tone.fg(c);
    // Unsaved (only a suggestion yet) = outlined; saved = tinted fill.
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: cell.saved ? fg.withValues(alpha: 0.12) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GRadius.control),
          side: BorderSide(color: cell.saved ? Colors.transparent : fg.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(GRadius.control),
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedSwitcher(
            duration: GMotion.fast,
            child: Container(
              key: ValueKey('$label${cell.saved}'),
              width: 84,
              height: 40,
              alignment: Alignment.center,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: context.t.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({required this.value, required this.grading, this.onTap});
  final num? value;
  final Grading grading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(GRadius.control),
      onTap: onTap,
      child: value == null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GRadius.control),
                border: Border.all(color: c.border),
              ),
              child: Icon(Icons.add_rounded, color: c.mutedForeground, size: 20),
            )
          : GGradeChip(value: value!, grading: grading, size: 40),
    );
  }
}

/// Number pad sheet: tap a mark → saved, jumps to the next student.
class _GradePad extends StatefulWidget {
  const _GradePad({
    required this.students,
    required this.start,
    required this.grading,
    required this.cellOf,
    required this.onPick,
  });
  final List<RosterStudent> students;
  final int start;
  final Grading grading;
  final _Cell Function(String id) cellOf;
  final void Function(String id, num? value) onPick;

  @override
  State<_GradePad> createState() => _GradePadState();
}

class _GradePadState extends State<_GradePad> {
  late int _i = widget.start;
  bool _autoNext = true;
  final _picked = <String, num?>{};

  void _pick(num? v) {
    final s = widget.students[_i];
    widget.onPick(s.id, v);
    setState(() => _picked[s.id] = v);
    if (!_autoNext) return Navigator.pop(context);
    if (_i + 1 < widget.students.length) {
      setState(() => _i++);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final s = widget.students[_i];
    final cell = widget.cellOf(s.id);
    final current = _picked.containsKey(s.id) ? _picked[s.id] : cell.grade;
    final g = widget.grading;
    final marks = [for (var v = g.max; v >= g.min; v--) v];
    final cols = marks.length <= 5 ? marks.length : (marks.length / 2).ceil();
    final absent = cell.status == Presence.absent || cell.status == Presence.excused;

    return Padding(
      padding: const EdgeInsets.fromLTRB(GSpace.lg, 0, GSpace.lg, GSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _i > 0 ? () => setState(() => _i--) : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: GMotion.fast,
                  child: Column(
                    key: ValueKey(s.id),
                    children: [
                      GAvatar(name: s.name, url: s.avatarUrl, size: 48),
                      const SizedBox(height: GSpace.xs),
                      Text(
                        s.name,
                        style: context.t.titleMedium,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('${_i + 1} / ${widget.students.length}', style: context.t.bodySmall),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: _i + 1 < widget.students.length ? () => setState(() => _i++) : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          if (absent)
            Padding(
              padding: const EdgeInsets.only(top: GSpace.sm),
              child: Text(
                l.gradeAbsentWarn(s.name),
                textAlign: TextAlign.center,
                style: context.t.bodySmall!.copyWith(color: c.warningText),
              ),
            ),
          const SizedBox(height: GSpace.md),
          GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: GSpace.sm,
            crossAxisSpacing: GSpace.sm,
            childAspectRatio: cols <= 5 ? 1.25 : 1,
            children: [
              for (final v in marks) _PadKey(value: v, grading: g, selected: current == v, onTap: () => _pick(v)),
            ],
          ),
          const SizedBox(height: GSpace.md),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch.adaptive(value: _autoNext, onChanged: (v) => setState(() => _autoNext = v)),
                    const SizedBox(width: GSpace.xs),
                    Flexible(child: Text(l.autoNext, style: context.t.bodySmall)),
                  ],
                ),
              ),
              if (current != null)
                TextButton(
                  onPressed: () => _pick(null),
                  child: Text(l.removeGrade, style: TextStyle(color: c.destructiveText)),
                ),
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l.done)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({required this.value, required this.grading, required this.selected, required this.onTap});
  final int value;
  final Grading grading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = switch (grading.tone(value)) {
      GradeTone.excellent => c.successText,
      GradeTone.good => c.gradeGood,
      GradeTone.fair => c.warningText,
      GradeTone.poor => c.destructiveText,
    };
    return Material(
      color: selected ? fg : fg.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(GRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(GRadius.card),
        onTap: onTap,
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: selected ? Colors.white : fg),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.c.card,
      border: Border(top: BorderSide(color: context.c.border)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.md, GSpace.page, GSpace.md), child: child),
    ),
  );
}
