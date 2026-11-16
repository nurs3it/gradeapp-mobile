import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/grading.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/lesson_widgets.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import '../shell/header.dart';
import 'grade_pad.dart';
import 'lesson_sheets.dart';
import 'sync_sheet.dart';
import 'teacher_models.dart';
import 'teacher_providers.dart';

/// The whole lesson on one screen (T2–T7, §5.2): topic, roll call by
/// exceptions, grades from the dock pad, homework and summary in the dock.
/// Works offline — every write goes through the outbox.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lesson = ref.watch(lessonProvider(lessonId));
    return switch (lesson) {
      AsyncValue(:final value?) => _LessonBody(key: ValueKey(value.id), lesson: value),
      AsyncValue(:final error?) when !lesson.hasValue => Scaffold(
        appBar: GNavBar(backLabel: l.tabToday),
        body: GEmpty(
          error: true,
          title: l.errorTitle,
          message: '$error'.contains('404') ? l.notifUnavailable : l.errorOffline,
          action: l.retry,
          onAction: () => ref.invalidate(lessonProvider(lessonId)),
        ),
      ),
      _ => Scaffold(
        appBar: GNavBar(backLabel: l.tabToday),
        body: const Center(child: GLoader()),
      ),
    };
  }
}

enum _View { list, faces }

class _LessonBody extends ConsumerStatefulWidget {
  const _LessonBody({super.key, required this.lesson});
  final Lesson lesson;

  @override
  ConsumerState<_LessonBody> createState() => _LessonBodyState();
}

class _LessonBodyState extends ConsumerState<_LessonBody> {
  late final LessonActions _actions = LessonActions(ref.read(outboxProvider), widget.lesson);
  late final TextEditingController _topic = TextEditingController(text: widget.lesson.topic);
  final _scroll = ScrollController();
  final _rowKeys = <String, GlobalKey>{};
  bool _editTopic = false;
  String? _savedTopic;
  LessonStatus? _status;
  String? _type;
  bool _padOpen = false;
  int _padIndex = 0;
  String? _inline;
  final _selected = <String>{};
  _View _view = _View.list;
  bool _search = false;
  String _query = '';

  Lesson get lesson => widget.lesson;
  String get _typeKey => 'worktype:${lesson.courseId}';

  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(prefsProvider).read(_typeKey).then((v) {
        if (v is String && mounted) setState(() => _type = v);
      }),
    );
  }

  @override
  void dispose() {
    _topic.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _refreshServer() {
    ref
      ..invalidate(lessonDefaultsProvider(lesson.id))
      ..invalidate(lessonGradesProvider(lesson.id))
      ..invalidate(teacherDayProvider);
  }

  /// First write starts the lesson (as the web does).
  Future<void> _ensureStarted() async {
    if ((_status ?? lesson.status) != LessonStatus.scheduled) return;
    setState(() => _status = LessonStatus.inProgress);
    await _actions.start();
  }

  Future<void> _mark(
    RosterStudent s,
    RollCell before,
    Presence p,
    String code, {
    String reason = '',
    bool toast = true,
  }) async {
    final l = context.l10n;
    GHaptics.light();
    await _ensureStarted();
    final label = p == Presence.present ? l.statePresent : (code.isEmpty ? l.stateAbsent : code);
    await _actions.mark(s.id, p, code: code, reason: reason, name: s.name, label: label);
    if (!toast || !mounted) return;
    GToast.show(
      context,
      l.markedToast(s.lastName.isEmpty ? s.name : s.lastName, label),
      actionLabel: l.undo,
      bottomOffset: GSpace.tabbarH + GSpace.tabbarBottom + 12,
      onAction: () => _actions.mark(s.id, before.status, code: before.code, name: s.name),
    );
  }

  /// One tap on the row: «есть» ↔ «Н» only (no third state, T2).
  void _toggle(RosterStudent s, RollCell cell, Grading g) {
    final absentCode = g.attendanceCodes.where((c) => c.status == Presence.absent).firstOrNull?.code ?? '';
    if (cell.status == Presence.absent) {
      unawaited(_mark(s, cell, Presence.present, ''));
    } else if (cell.status == Presence.present) {
      unawaited(_mark(s, cell, Presence.absent, absentCode));
    } else {
      unawaited(_mark(s, cell, Presence.present, ''));
    }
  }

  Future<void> _codes(RosterStudent s, RollCell cell, Grading g) async {
    GHaptics.medium();
    final pick = await showCodesSheet(context, name: s.name, grading: g, cell: cell);
    if (pick != null) await _mark(s, cell, pick.status, pick.code, reason: pick.reason);
  }

  Future<void> _rollCall(List<RosterStudent> roster, Map<String, RollCell> cells) async {
    final l = context.l10n;
    final unsaved = {
      for (final s in roster)
        if (!cells[s.id]!.saved) s.id: (status: cells[s.id]!.status, code: cells[s.id]!.code),
    };
    if (unsaved.isNotEmpty) {
      await _ensureStarted();
      await _actions.markMany(unsaved);
    }
    GHaptics.light();
    if (mounted) GToast.show(context, l.rollSaved, bottomOffset: GSpace.tabbarH + GSpace.tabbarBottom + 12);
  }

  Future<void> _setTopic(String topic) async {
    final t = topic.trim();
    if (t.isEmpty) return;
    GHaptics.light();
    setState(() {
      _savedTopic = t;
      _editTopic = false;
      _topic.text = t;
    });
    FocusScope.of(context).unfocus();
    await _actions.setTopic(t);
  }

  void _openPad(int index, List<RosterStudent> roster) {
    GHaptics.selection();
    setState(() {
      _padOpen = true;
      _padIndex = index;
      _inline = null;
    });
    _reveal(roster[index].id);
  }

  void _reveal(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _rowKeys[id]?.currentContext;
      if (ctx == null) return;
      unawaited(
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.55,
          duration: SpringCurve.smooth.duration,
          curve: SpringCurve.smooth,
        ),
      );
    });
  }

  Future<void> _pickType(Grading g, String current) async {
    final picked = await showWorkTypeSheet(context, grading: g, current: current);
    if (picked == null) return;
    setState(() => _type = picked);
    unawaited(ref.read(prefsProvider).write(_typeKey, picked));
  }

  Future<void> _finish(int present, int total, bool rollSaved, int grades, bool hasHw) async {
    final l = context.l10n;
    final done = await showSummarySheet(
      context,
      lesson: lesson.copyWith(topic: _savedTopic ?? lesson.topic),
      actions: _actions,
      present: present,
      total: total,
      rollSaved: rollSaved,
      grades: grades,
      hasTopic: (_savedTopic ?? lesson.topic).isNotEmpty,
      hasHomework: hasHw,
      onAddTopic: () => setState(() => _editTopic = true),
      onAddHomework: () => showHomeworkSheet(context, lesson: lesson, actions: _actions),
    );
    if (!done || !mounted) return;
    setState(() => _status = LessonStatus.completed);
    unawaited(Navigator.of(context).maybePop());
    GToast.show(context, l.lessonFinishedToast);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final grading = ref.watch(gradingProvider);
    final now = ref.now;
    final roster = ref.watch(rosterProvider(lesson));
    final defaults = ref.watch(lessonDefaultsProvider(lesson.id)).value ?? const LessonDefaults();
    final grades = ref.watch(lessonGradesProvider(lesson.id)).value ?? const <Grade>[];
    final overlay = ref.watch(lessonOverlayProvider(lesson.id));
    final hasHw =
        (ref.watch(courseHomeworkProvider(lesson.courseId)).value ?? const <Homework>[]).any(
          (h) => h.lessonId == lesson.id,
        ) ||
        ref.watch(outboxPendingProvider).any((i) => i.label['what'] == 'homework' && i.label['lesson_id'] == lesson.id);

    // Once this lesson's queued writes are all sent, re-read the server truth.
    ref.listen(outboxPendingProvider, (prev, next) {
      bool mine(List<dynamic>? items) => (items ?? const []).any((i) => '${i.key}'.contains(lesson.id));
      if (mine(prev) && !mine(next)) _refreshServer();
    });

    final types = grading.lessonTypes;
    final type =
        _type ?? grades.where((x) => x.type.isNotEmpty).firstOrNull?.type ?? (types.isEmpty ? 'fo' : types.first.code);
    final status = _status ?? lesson.status;
    final readOnly = lesson.isCancelled;
    final locked = defaults.sochLocked;
    final scale = grading.scaleSize;
    final ended = !now.isBefore(lesson.endsAt());

    return Scaffold(
      backgroundColor: c.canvas,
      resizeToAvoidBottomInset: false,
      appBar: GNavBar(
        backLabel: l.tabToday,
        actions: [
          const SyncIndicator(),
          GIconButton(
            icon: GIcons.more,
            label: l.menuMore,
            size: 40,
            background: c.surface,
            onPressed: () => _menu(context, roster.value ?? const [], grading, type, status),
          ),
        ],
      ),
      body: switch (roster) {
        AsyncValue(:final value?) => _content(
          context,
          value,
          defaults,
          grades,
          overlay,
          grading,
          type,
          status,
          readOnly,
          locked,
          scale,
          ended,
          now,
          hasHw,
          g,
        ),
        AsyncValue(:final error?) => GEmpty(
          error: true,
          title: l.errorTitle,
          message: '$error',
          action: l.retry,
          onAction: () => ref.invalidate(classStudentsProvider),
        ),
        _ => const Center(child: GLoader()),
      },
    );
  }

  Widget _content(
    BuildContext context,
    List<RosterStudent> students,
    LessonDefaults defaults,
    List<Grade> grades,
    LessonOverlay overlay,
    Grading grading,
    String type,
    LessonStatus status,
    bool readOnly,
    bool locked,
    int scale,
    bool ended,
    DateTime now,
    bool hasHw,
    double g,
  ) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final cells = rollCall(students: students, defaults: defaults, overlay: overlay, grades: grades, type: type);
    final ordered = rollCallOrder(students, defaults.students);
    final visible = _query.isEmpty
        ? ordered
        : ordered.where((s) => s.name.toLowerCase().contains(_query.toLowerCase())).toList();
    final present = presentCount(cells);
    final saved = cells.values.where((x) => x.saved).length;
    final anySaved = saved > 0;
    final allSaved = saved == students.length && students.isNotEmpty;
    final failed = cells.values.where((x) => x.failed != null).length;
    final queued = overlay.queued.length;
    final classNames = <String>[];
    for (final s in ordered) {
      final n = s.className ?? '';
      if (n.isNotEmpty && !classNames.contains(n)) classNames.add(n);
    }
    final joint = lesson.isJoint && classNames.length > 1;
    final title = joint ? classNames.join(' + ') : (lesson.classGroupName ?? lesson.subject);
    final minutesLeft = (lesson.endsAt().difference(now).inSeconds / 60).ceil();
    final minutesTo = (lesson.startsAt().difference(now).inSeconds / 60).ceil();
    final timePill = lesson.isNow(now)
        ? l.tUntilBell(minutesLeft)
        : minutesTo > 0 && minutesTo < 180
        ? l.tStartsIn(minutesTo)
        : ended && lesson.date == isoDate(now)
        ? l.lessonOver
        : null;
    final topic = _savedTopic ?? lesson.topic;
    final bottomPad =
        (_padOpen ? GradePad.height : GSpace.tabbarH + GSpace.tabbarBottom + 24) + MediaQuery.paddingOf(context).bottom;

    // Dock primary (§3.27).
    final (String primary, VoidCallback? onPrimary) = locked
        ? (l.dockSochDay, null)
        : readOnly
        ? (l.pillCancelled, null)
        : ended && status != LessonStatus.completed
        ? (
            l.dockFinish,
            () => _finish(present, students.length, allSaved, grades.length + overlay.grades.length, hasHw),
          )
        : !anySaved
        ? (l.dockAllPresent(students.length), () => _rollCall(students, cells))
        : (l.dockDone(present, students.length), () => _rollCall(students, cells));

    final rows = <Widget>[];
    String? lastClass;
    for (final s in visible) {
      if (joint && s.className != lastClass) {
        lastClass = s.className;
        final count = ordered.where((x) => x.className == lastClass).length;
        rows.add(
          Container(
            color: c.surface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(l.classHeader(lastClass ?? '', count), style: t.subhead.copyWith(color: c.ink2)),
          ),
        );
      }
      final cell = cells[s.id]!;
      final index = ordered.indexOf(s);
      rows.add(
        KeyedSubtree(
          key: _rowKeys.putIfAbsent(s.id, GlobalKey.new),
          child: _StudentRow(
            student: s,
            cell: cell,
            lesson: lesson,
            grading: grading,
            readOnly: readOnly || locked,
            gradeMode: locked
                ? _GradeMode.locked
                : scale <= 5
                ? _GradeMode.inline
                : scale <= 10
                ? _GradeMode.pad
                : _GradeMode.view,
            highlighted: _padOpen && index == _padIndex,
            selecting: _selected.isNotEmpty,
            selected: _selected.contains(s.id),
            inlineOpen: _inline == s.id,
            onTap: () {
              if (_selected.isNotEmpty) {
                setState(() => _selected.contains(s.id) ? _selected.remove(s.id) : _selected.add(s.id));
                return;
              }
              _toggle(s, cell, grading);
            },
            onLongPress: () => _codes(s, cell, grading),
            onSelect: scale <= 10 && scale > 5
                ? () {
                    GHaptics.medium();
                    setState(() {
                      _selected.add(s.id);
                      _padOpen = true;
                    });
                  }
                : null,
            onGradeSlot: () {
              if (scale <= 5) {
                GHaptics.selection();
                setState(() => _inline = _inline == s.id ? null : s.id);
              } else {
                _openPad(index, ordered);
              }
            },
            onInlinePick: (v) {
              GHaptics.medium();
              unawaited(_ensureStarted());
              unawaited(
                _actions.grade(s.id, cell.grade == v ? null : v, type: type, scaleMax: grading.max, name: s.name),
              );
              setState(() => _inline = null);
            },
          ),
        ),
      );
    }

    return Stack(
      children: [
        CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(g, 4, g, 0),
              sliver: SliverList.list(
                children: [
                  // Header (§5.2 item 2).
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: c.subjectMarker(lesson.colorKey), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            lesson.subject,
                            if (lesson.subgroup.isNotEmpty) lesson.subgroup,
                            if (lesson.room != null) l.room(lesson.room!),
                            '${hm(lesson.start)}–${hm(lesson.end)}',
                          ].join(' · ').toUpperCase(),
                          style: t.eyebrow.copyWith(color: c.ink2),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(title, style: t.largeTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      if (joint) ...[
                        GStatusPill(label: l.jointPill(students.length), tone: GTone.neutral),
                        const SizedBox(width: 6),
                      ],
                      if (timePill != null) GStatusPill(label: timePill, tone: GTone.info, icon: GIcons.timer),
                    ],
                  ),
                  if (locked) ...[
                    const SizedBox(height: 12),
                    GStateRow(
                      title: l.sochBanner(lesson.subject),
                      message: l.sochBannerBody,
                      tone: GTone.warn,
                      icon: GIcons.lock,
                    ),
                  ],
                  if (failed > 0) ...[
                    const SizedBox(height: 12),
                    GStateRow(
                      title: l.rejectedBanner(failed),
                      tone: GTone.bad,
                      icon: GIcons.syncFailed,
                      action: l.openQueue,
                      onAction: () => showSyncSheet(context),
                    ),
                  ] else if (queued > 0) ...[
                    const SizedBox(height: 12),
                    GStateRow(
                      title: l.pendingBanner(queued),
                      message: l.pendingBannerBody,
                      tone: GTone.warn,
                      icon: GIcons.syncing,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _TopicCard(
                    lesson: lesson,
                    topic: topic,
                    editing: _editTopic || topic.isEmpty,
                    controller: _topic,
                    readOnly: readOnly,
                    onEdit: () => setState(() => _editTopic = true),
                    onSave: _setTopic,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l.presentLabel, style: t.footnote.copyWith(color: c.ink2)),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$present',
                                      style: t.title1.copyWith(
                                        fontSize: 30,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / ${students.length}',
                                      style: t.headline.copyWith(color: c.ink2),
                                    ),
                                  ],
                                ),
                                semanticsLabel: l.nOfM(present, students.length),
                              ),
                            ],
                          ),
                        ),
                        if (students.length > 15)
                          GIconButton(
                            icon: _search ? GIcons.close : GIcons.search,
                            label: l.searchStudent,
                            onPressed: () => setState(() {
                              _search = !_search;
                              _query = '';
                            }),
                          ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 112,
                          child: GSegmented<_View>(
                            values: _View.values,
                            selected: _view,
                            icons: const [GIcons.listView, GIcons.gridView],
                            semanticLabels: [l.viewList, l.viewFaces],
                            onChanged: (v) => setState(() => _view = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_search) ...[
                    GField(hint: l.searchStudent, autofocus: true, onChanged: (v) => setState(() => _query = v)),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
            if (students.isEmpty)
              SliverToBoxAdapter(child: GEmpty(title: l.rosterEmpty))
            else if (_view == _View.faces)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(g, 0, g, bottomPad),
                sliver: SliverGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.72,
                  children: [
                    for (final s in visible)
                      _Face(
                        student: s,
                        cell: cells[s.id]!,
                        onTap: readOnly || locked ? null : () => _toggle(s, cells[s.id]!, grading),
                        onLongPress: readOnly || locked ? null : () => _codes(s, cells[s.id]!, grading),
                      ),
                  ],
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(g, 0, g, bottomPad),
                sliver: SliverToBoxAdapter(child: GGroup(inset: 68, children: rows)),
              ),
          ],
        ),
        // Dock or grade pad (they replace each other).
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcherFree(
            showFirst: !_padOpen,
            first: GDock(
              children: [
                GButton(
                  label: l.dockHomework,
                  icon: GIcons.homework,
                  variant: hasHw ? GButtonVariant.secondary : GButtonVariant.tinted,
                  size: GButtonSize.s,
                  onPressed: readOnly ? null : () => showHomeworkSheet(context, lesson: lesson, actions: _actions),
                ),
                const SizedBox(width: 6),
                GButton(
                  label: l.dockSummary,
                  icon: GIcons.summary,
                  variant: GButtonVariant.tinted,
                  size: GButtonSize.s,
                  onPressed: readOnly
                      ? null
                      : () => _finish(present, students.length, allSaved, grades.length + overlay.grades.length, hasHw),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GButton(label: primary, size: GButtonSize.m, expand: true, onPressed: onPrimary),
                ),
              ],
            ),
            second: ordered.isEmpty
                ? const SizedBox.shrink()
                : GradePad(
                    students: ordered,
                    cells: cells,
                    grading: grading,
                    index: _padIndex.clamp(0, ordered.length - 1),
                    typeLabel: grading.typeName(type),
                    selected: _selected,
                    onIndex: (i) {
                      setState(() => _padIndex = i);
                      _reveal(ordered[i].id);
                    },
                    onPick: (s, v, comment) {
                      unawaited(_ensureStarted());
                      unawaited(
                        _actions.grade(s.id, v, type: type, scaleMax: grading.max, comment: comment, name: s.name),
                      );
                    },
                    onPickMany: (v) {
                      unawaited(_ensureStarted());
                      unawaited(_actions.gradeMany(_selected.toList(), v, type: type, scaleMax: grading.max));
                      setState(() {
                        _selected.clear();
                        _padOpen = false;
                      });
                    },
                    onType: () => _pickType(grading, type),
                    onClose: () => setState(() {
                      _padOpen = false;
                      _selected.clear();
                    }),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _menu(
    BuildContext context,
    List<RosterStudent> roster,
    Grading g,
    String type,
    LessonStatus status,
  ) async {
    final l = context.l10n;
    final c = context.c;
    final choice = await showGSheet<int>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: GGroup(
          inset: 48,
          children: [
            if (g.scaleSize > 5 && g.scaleSize <= 10 && roster.isNotEmpty)
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.grades, size: 20, color: c.ink2),
                title: Text(l.menuGradeAll),
                onTap: () => Navigator.pop(ctx, 0),
              ),
            GRow(
              minHeight: GSpace.rowCompact,
              leading: GIcon(GIcons.tasks, size: 20, color: c.ink2),
              title: Text(l.workType),
              trailing: Text(g.typeName(type), style: ctx.t.callout.copyWith(color: c.ink2)),
              onTap: () => Navigator.pop(ctx, 1),
            ),
            if (status == LessonStatus.scheduled)
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.timer, size: 20, color: c.ink2),
                title: Text(l.menuStart),
                onTap: () => Navigator.pop(ctx, 2),
              ),
            GRow(
              minHeight: GSpace.rowCompact,
              leading: GIcon(GIcons.openInNew, size: 20, color: c.ink2),
              title: Text(l.menuOpenWeb),
              onTap: () => Navigator.pop(ctx, 3),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 0:
        _openPad(
          0,
          rollCallOrder(roster, (ref.read(lessonDefaultsProvider(lesson.id)).value ?? const LessonDefaults()).students),
        );
      case 1:
        await _pickType(g, type);
      case 2:
        await _ensureStarted();
        if (context.mounted) GToast.show(context, l.lessonStartedToast, bottomOffset: 100);
      case 3:
        unawaited(
          launchUrl(
            Uri.parse('https://grade-app.kz/teacher/lesson/${lesson.id}'),
            mode: LaunchMode.externalApplication,
          ),
        );
    }
  }
}

/// Cross-fade between two fixed children without keys: both stay mounted in
/// a stack, only opacity and a slide change. (Keyed switchers that re-enter
/// the same key mid-animation caused the v0 red screen.)
class AnimatedSwitcherFree extends StatelessWidget {
  const AnimatedSwitcherFree({super.key, required this.showFirst, required this.first, required this.second});
  final bool showFirst;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    final reduce = GMotion.reduce(context);
    final d = reduce ? GMotion.reduced : SpringCurve.sheet.duration;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IgnorePointer(
          ignoring: !showFirst,
          child: AnimatedOpacity(opacity: showFirst ? 1 : 0, duration: GMotion.quick, child: first),
        ),
        IgnorePointer(
          ignoring: showFirst,
          child: AnimatedSlide(
            offset: showFirst ? const Offset(0, 1.05) : Offset.zero,
            duration: d,
            curve: reduce ? Curves.linear : SpringCurve.sheet,
            child: ExcludeSemantics(excluding: showFirst, child: second),
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends ConsumerWidget {
  const _TopicCard({
    required this.lesson,
    required this.topic,
    required this.editing,
    required this.controller,
    required this.readOnly,
    required this.onEdit,
    required this.onSave,
  });

  final Lesson lesson;
  final String topic;
  final bool editing;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback onEdit;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    if (!editing) {
      return GCard(
        child: Row(
          children: [
            GIcon(GIcons.plan, size: 22, color: c.ink2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.topicCard, style: t.footnote.copyWith(color: c.ink2)),
                  Text(topic, style: t.bodyStrong),
                ],
              ),
            ),
            if (!readOnly)
              GButton(label: l.change, size: GButtonSize.s, variant: GButtonVariant.plain, onPressed: onEdit),
          ],
        ),
      );
    }
    final ktp = lesson.classGroupId == null
        ? null
        : ref
              .watch(ktpTopicProvider((classId: lesson.classGroupId!, subject: lesson.subject, date: lesson.date)))
              .value;
    final around =
        ref.watch(courseLessonsProvider((courseId: lesson.courseId, date: lesson.date))).value ?? const <Lesson>[];
    final last = around.where((x) => x.date.compareTo(lesson.date) < 0 && x.topic.isNotEmpty).lastOrNull?.topic;
    return GCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.topicCard, style: t.subhead.copyWith(color: c.ink2)),
          const SizedBox(height: 10),
          if (ktp != null || last != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (ktp != null) GSuggestChip(label: l.ktpChip(ktp), icon: GIcons.plan, onTap: () => onSave(ktp)),
                if (last != null) GSuggestChip(label: l.sameAsLast, icon: GIcons.undo, onTap: () => onSave(last)),
              ],
            ),
            const SizedBox(height: 10),
          ],
          GField(
            controller: controller,
            hint: l.topicHint,
            enabled: !readOnly,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: onSave,
            suffix: GIconButton(
              icon: GIcons.check,
              label: l.save,
              size: 36,
              background: Colors.transparent,
              color: c.primaryText,
              onPressed: () => onSave(controller.text),
            ),
          ),
        ],
      ),
    );
  }
}

enum _GradeMode { pad, inline, view, locked }

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.cell,
    required this.lesson,
    required this.grading,
    required this.readOnly,
    required this.gradeMode,
    required this.highlighted,
    required this.selecting,
    required this.selected,
    required this.inlineOpen,
    required this.onTap,
    required this.onLongPress,
    required this.onGradeSlot,
    required this.onInlinePick,
    this.onSelect,
  });

  final RosterStudent student;
  final RollCell cell;
  final Lesson lesson;
  final Grading grading;
  final bool readOnly;
  final _GradeMode gradeMode;
  final bool highlighted;
  final bool selecting;
  final bool selected;
  final bool inlineOpen;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onGradeSlot;
  final ValueChanged<num> onInlinePick;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final absent = cell.status == Presence.absent;
    final late = cell.source == 'checkin' && cell.checkedAt != null && cell.checkedAt!.isAfter(lesson.startsAt())
        ? cell.checkedAt!.difference(lesson.startsAt()).inMinutes
        : 0;
    final failed = cell.failed;
    final sub = <Widget>[
      if (failed != null)
        Flexible(
          child: Text(
            l.notSaved(rejectText(l, failed)),
            style: t.footnote.copyWith(color: c.bad),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      else ...[
        if (cell.source == 'checkin' && cell.checkedAt != null && !absent) ...[
          GIcon(GIcons.checkIn, size: 16, color: c.ink3),
          const SizedBox(width: 4),
          Text(Fmt.clock(cell.checkedAt!), style: t.footnote.copyWith(color: c.ink2)),
          if (late > 0) Text(' · ${l.lateBy(late)}', style: t.footnote.copyWith(color: c.warn)),
        ] else if (cell.source == 'homeroom') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(4)),
            child: Text('К', style: t.caption.copyWith(color: c.ink2)),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(l.sourceHomeroom, style: t.footnote.copyWith(color: c.ink2), maxLines: 1),
          ),
        ],
      ],
    ];
    final semantic = [
      student.name,
      _stateWord(l),
      if (cell.source == 'checkin' && cell.checkedAt != null) l.sourceCheckIn(Fmt.clock(cell.checkedAt!)),
      if (failed != null) l.notSaved(rejectText(l, failed)),
      if (cell.grade != null) l.whatGrade(fmtNum(cell.grade!)),
    ].join(', ');
    final row = Semantics(
      label: semantic,
      hint: readOnly ? null : (absent ? l.rowAbsentHint : l.rowPresentHint),
      button: !readOnly,
      onTap: readOnly ? null : onTap,
      customSemanticsActions: readOnly ? null : {CustomSemanticsAction(label: l.actionCodes): onLongPress},
      excludeSemantics: !inlineOpen, // open inline chips stay reachable
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: readOnly ? null : onTap,
        onLongPress: readOnly ? null : (onSelect != null && selecting ? onSelect : onLongPress),
        child: AnimatedContainer(
          duration: GMotion.quick,
          color: highlighted || selected ? c.primarySoft : Colors.transparent,
          constraints: const BoxConstraints(minHeight: GSpace.rowMin),
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selecting) ...[
                    GIcon(
                      selected ? GIcons.ok : GIcons.add,
                      size: 22,
                      color: selected ? GColors.brand : c.ink3,
                      fill: selected ? 1 : 0,
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onLongPress: readOnly ? null : onSelect,
                    child: GAvatar(name: student.name, url: student.avatarUrl, size: 40, tone: GAvatarTone.neutral),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.name,
                          style: t.bodyStrong.copyWith(color: absent ? c.bad : c.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sub.isNotEmpty) ...[const SizedBox(height: 2), Row(children: sub)],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AttendanceToggle(
                    cell: cell,
                    absentCode: _absentCode(),
                    enabled: !readOnly,
                    onTap: onTap,
                    onLongPress: onLongPress,
                  ),
                  const SizedBox(width: 8),
                  _GradeSlot(cell: cell, grading: grading, mode: gradeMode, name: student.name, onTap: onGradeSlot),
                ],
              ),
              // 5-point scale: one tap to the mark, right under the name (T3-B).
              if (inlineOpen)
                Padding(
                  padding: const EdgeInsets.only(left: 52, top: 8, bottom: 4),
                  child: Semantics(
                    container: true,
                    child: Row(
                      children: [
                        for (final v in grading.marks) ...[
                          GPressable(
                            onTap: () => onInlinePick(v),
                            scale: 0.94,
                            semanticLabel: l.padKey('$v', toneWord(l, grading.tone(v))),
                            excludeChildSemantics: true,
                            child: GGradeChip(
                              text: '$v',
                              tone: grading.tone(v),
                              size: GGradeSize.l,
                              solid: cell.grade == v,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return row;
  }

  String _absentCode() => grading.attendanceCodes.where((c) => c.status == Presence.absent).firstOrNull?.code ?? 'Н';

  String _stateWord(AppLocalizations l) => switch (cell.status) {
    Presence.present => l.statePresent,
    Presence.absent => l.codeAbsent,
    Presence.tardy => l.codeLate,
    Presence.excused => cell.code.isEmpty ? l.codeExcused : cell.code,
  };
}

/// Attendance capsule 56 × 44 (§3.11): «есть» (grey check) ↔ «Н» (red).
/// Every state is a fixed layer in a stack whose opacity cross-fades —
/// no keyed `AnimatedSwitcher`, so rapid taps cannot produce duplicate keys
/// (the v0 red screen). The letter scales in on the `snap` spring.
class AttendanceToggle extends StatelessWidget {
  const AttendanceToggle({
    super.key,
    required this.cell,
    required this.absentCode,
    required this.enabled,
    required this.onTap,
    required this.onLongPress,
  });

  final RollCell cell;
  final String absentCode;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final absent = cell.status == Presence.absent;
    final coded = !absent && cell.status != Presence.present;
    final present = !absent && !coded;
    final letter = coded ? (cell.code.isNotEmpty ? cell.code : (cell.status == Presence.tardy ? 'О' : 'У')) : '';
    final reduce = GMotion.reduce(context);
    final d = reduce ? GMotion.reduced : GMotion.quick;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: SizedBox(
          width: 56,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: present ? 1 : 0,
                  duration: d,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(color: c.surface2, shape: const StadiumBorder()),
                    child: Center(child: GIcon(GIcons.check, size: 22, color: c.ink3)),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: absent ? 1 : 0,
                  duration: d,
                  child: DecoratedBox(
                    decoration: const ShapeDecoration(color: GColors.badFill, shape: StadiumBorder()),
                    child: Center(
                      child: AnimatedScale(
                        scale: absent || reduce ? 1 : 0.6,
                        duration: reduce ? Duration.zero : SpringCurve.snap.duration,
                        curve: SpringCurve.snap,
                        child: Text(
                          absentCode,
                          style: t.headline.copyWith(color: GColors.onFill, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: coded ? 1 : 0,
                  duration: d,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(color: c.warnSoft, shape: const StadiumBorder()),
                    child: Center(
                      child: Text(
                        letter,
                        style: t.headline.copyWith(color: c.warn, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ),
              if (cell.failed != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: StadiumBorder(side: BorderSide(color: c.bad, width: 2)),
                      ),
                    ),
                  ),
                )
              else if (cell.queued)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: c.warn, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeSlot extends StatelessWidget {
  const _GradeSlot({
    required this.cell,
    required this.grading,
    required this.mode,
    required this.name,
    required this.onTap,
  });
  final RollCell cell;
  final Grading grading;
  final _GradeMode mode;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l10n;
    if (mode == _GradeMode.locked) {
      return SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: GIcon(GIcons.lock, size: 20, color: c.ink3, semanticLabel: l.gradeLocked),
        ),
      );
    }
    final grade = cell.grade;
    final child = grade != null
        ? GGradeChip(text: fmtNum(grade), tone: grading.tone(grade), size: GGradeSize.m)
        : cell.isOut
        ? Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Text('—', style: context.t.headline.copyWith(color: c.ink3)),
          )
        : Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(GRadius.grade(44))),
            child: GIcon(GIcons.add, size: 22, color: c.ink2),
          );
    if (mode == _GradeMode.view) return Semantics(label: l.scaleViewOnly, child: child);
    return GPressable(
      onTap: onTap,
      scale: 0.94,
      semanticLabel: grade == null ? l.gradeSlot(name) : l.whatGrade(fmtNum(grade)),
      excludeChildSemantics: true,
      child: child,
    );
  }
}

/// «Лица» view (T2-B): avatar tiles; tap toggles, long press — codes.
class _Face extends StatelessWidget {
  const _Face({required this.student, required this.cell, this.onTap, this.onLongPress});
  final RosterStudent student;
  final RollCell cell;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final absent = cell.status == Presence.absent;
    return GestureDetector(
      onLongPress: onLongPress,
      child: GPressable(
        onTap: onTap,
        semanticLabel: '${student.name}, ${absent ? context.l10n.codeAbsent : context.l10n.statePresent}',
        excludeChildSemantics: true,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: absent ? GColors.badFill : Colors.transparent, width: 3),
              ),
              child: GAvatar(name: student.name, url: student.avatarUrl, size: 56, tone: GAvatarTone.neutral),
            ),
            const SizedBox(height: 4),
            Text(
              student.firstName.isEmpty ? student.name : student.firstName,
              style: context.t.footnote.copyWith(color: absent ? c.bad : c.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              student.lastName,
              style: context.t.caption.copyWith(color: c.ink2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
