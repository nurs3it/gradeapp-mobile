import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/attachments.dart';
import '../common/models.dart';
import '../common/presence.dart';
import '../common/pulse.dart';
import '../common/school_providers.dart';
import '../shell/header.dart';
import 'lesson_screen.dart' show AttendanceToggle;
import 'lesson_sheets.dart' show showCodesSheet;
import 'my_class_logic.dart';
import 'my_class_providers.dart';
import 'teacher_models.dart';
import 'teacher_providers.dart';

const _webUrl = 'https://grade-app.kz/teacher';

/// T8 «Мой класс»: the homeroom teacher's morning — who came (prefilled from
/// check-ins and approved requests), absence requests to decide, the class's
/// week. Shown as a tab only for a homeroom teacher.
class MyClassScreen extends ConsumerStatefulWidget {
  const MyClassScreen({super.key});

  @override
  ConsumerState<MyClassScreen> createState() => _MyClassScreenState();
}

class _MyClassScreenState extends ConsumerState<MyClassScreen> {
  /// Marks tapped here and not sent yet, for [_editsFor].
  final _edits = <String, DayCell>{};
  String? _editsFor;
  final _busy = <String>{};
  final _handled = <String>{};

  void _scope(String key) {
    if (_editsFor != key) {
      _editsFor = key;
      _edits.clear();
    }
  }

  void _set(String id, DayCell cell) => setState(() => _edits[id] = cell);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final g = GSpace.gutter(context);
    final now = ref.now;
    final today = isoDate(now);
    final cls = ref.watch(activeHomeroomProvider);
    final classes = ref.watch(homeroomClassesProvider);
    final mine = ref.watch(myClassesProvider);

    Future<void> refresh() async {
      ref
        ..invalidate(myClassesProvider)
        ..invalidate(classStudentsProvider)
        ..invalidate(classCheckInsProvider)
        ..invalidate(classDayMarksProvider)
        ..invalidate(classPendingExcusesProvider)
        ..invalidate(classApprovedExcusesProvider)
        ..invalidate(classOverviewProvider)
        ..invalidate(classWeekProvider);
      await ref.read(myClassesProvider.future).then((_) {}, onError: (Object _) {});
    }

    Widget body;
    if (cls == null) {
      body = mine.isLoading && !mine.hasValue
          ? const GSkeleton()
          : mine.hasError && !mine.hasValue
          ? GEmpty(error: true, title: l.errorTitle, message: l.errorOffline, action: l.retry, onAction: refresh)
          : GEmpty(title: l.t8NotHomeroom, icon: GIcons.school);
    } else {
      _scope('${cls.id}|$today');
      body = _ClassBody(
        key: ValueKey(cls.id),
        cls: cls,
        classes: classes,
        today: today,
        now: now,
        edits: _edits,
        busy: _busy,
        handled: _handled,
        onEdit: _set,
        onSent: () => setState(_edits.clear),
        onRebuild: () => setState(() {}),
      );
    }
    return GRootPage(
      eyebrow: cls == null || cls.name.isEmpty
          ? Fmt.weekdayDayMonth(now, context.localeTag)
          : '${cls.name} · ${Fmt.weekdayDayMonth(now, context.localeTag)}',
      title: l.t8Tab,
      actions: const [SyncIndicator(), AvatarButton()],
      below: const NetBanner(),
      onRefresh: refresh,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: g),
          sliver: SliverToBoxAdapter(child: body),
        ),
      ],
    );
  }
}

class _ClassBody extends ConsumerWidget {
  const _ClassBody({
    super.key,
    required this.cls,
    required this.classes,
    required this.today,
    required this.now,
    required this.edits,
    required this.busy,
    required this.handled,
    required this.onEdit,
    required this.onSent,
    required this.onRebuild,
  });

  final MyClass cls;
  final List<MyClass> classes;
  final String today;
  final DateTime now;
  final Map<String, DayCell> edits;
  final Set<String> busy;
  final Set<String> handled;
  final void Function(String id, DayCell cell) onEdit;
  final VoidCallback onSent;
  final VoidCallback onRebuild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final grading = ref.watch(gradingProvider);
    final day = (classId: cls.id, date: today);
    final roster = ref.watch(classStudentsProvider(cls.id));
    final checkIns = ref.watch(classCheckInsProvider(day)).value ?? const <ClassCheckIn>[];
    final saved = ref.watch(classDayMarksProvider(day)).value ?? const <DayMark>[];
    final approved = ref.watch(classApprovedExcusesProvider(cls.id)).value ?? const <Excuse>[];
    final pendingAsync = ref.watch(classPendingExcusesProvider(cls.id));
    final queued = ref.watch(queuedDayMarksProvider(day));

    // Once the queued day is sent, read the server truth again.
    ref.listen(queuedDayMarksProvider(day), (prev, next) {
      if ((prev?.isNotEmpty ?? false) && next.isEmpty) {
        ref
          ..invalidate(classDayMarksProvider(day))
          ..invalidate(classOverviewProvider(cls.id));
      }
    });

    if (!roster.hasValue) {
      return roster.hasError
          ? GEmpty(
              error: true,
              title: l.errorTitle,
              message: l.errorOffline,
              action: l.retry,
              onAction: () => ref.invalidate(classStudentsProvider(cls.id)),
            )
          : const GSkeleton();
    }
    final students = roster.value!;
    if (students.isEmpty) return GEmpty(title: l.t8Empty, icon: GIcons.school);

    final pending = [
      for (final x in pendingAsync.value ?? const <ClassExcuse>[])
        if (!handled.contains(x.id) && students.any((s) => s.id == x.excuse.studentId)) x,
    ];
    final base = mergeDayMarks(
      students: students,
      date: today,
      checkIns: checkIns,
      excuses: [...approved, for (final x in pending) x.excuse],
      saved: saved,
      queued: queued,
      codeFor: (p) => codeOfStatus(grading, p),
    );
    final cells = {for (final e in base.entries) e.key: edits[e.key] ?? e.value};
    final counts = dayCounts(cells);
    final ordered = dayOrder(students, cells);
    final sendable = cells.values.any((c) => c.status != null && !c.recorded);
    final overview = ref.watch(classOverviewProvider(cls.id)).value;

    Future<void> send() async {
      GHaptics.medium();
      await DayActions(
        ref.read(outboxProvider),
      ).markClass(classId: cls.id, className: cls.name, date: today, cells: cells);
      onSent();
      GHaptics.success();
      if (context.mounted) GToast.show(context, l.t8MarkSent);
    }

    void allCame() {
      GHaptics.light();
      for (final s in students) {
        final c = cells[s.id]!;
        if (c.unmarked) onEdit(s.id, DayCell(status: Presence.present, checkedAt: c.checkedAt));
      }
    }

    Future<void> codes(RosterStudent s) async {
      GHaptics.medium();
      final c = cells[s.id]!;
      final pick = await showCodesSheet(
        context,
        name: s.name,
        grading: grading,
        cell: RollCell(status: c.status ?? Presence.present, code: c.code),
      );
      if (pick != null) {
        onEdit(s.id, DayCell(status: pick.status, code: pick.code, reason: pick.reason, checkedAt: c.checkedAt));
      }
    }

    void tap(RosterStudent s) {
      GHaptics.selection();
      final c = cells[s.id]!;
      if (c.status == Presence.present) {
        onEdit(
          s.id,
          DayCell(status: Presence.absent, code: codeOfStatus(grading, Presence.absent), checkedAt: c.checkedAt),
        );
      } else {
        onEdit(s.id, DayCell(status: Presence.present, checkedAt: c.checkedAt));
      }
    }

    Future<void> review(ClassExcuse x, {required bool approve}) async {
      String note = '';
      if (!approve) {
        final r = await _askRejectNote(context, x);
        if (r == null) return;
        note = r;
      }
      busy.add(x.id);
      onRebuild();
      try {
        await ref
            .read(dioProvider)
            .post<Object?>(
              '/excuses/${x.id}/${approve ? 'approve' : 'reject'}/',
              data: approve ? null : {'review_note': note},
            );
        handled.add(x.id);
        GHaptics.success();
        ref
          ..invalidate(classPendingExcusesProvider(cls.id))
          ..invalidate(classApprovedExcusesProvider(cls.id))
          ..invalidate(classOverviewProvider(cls.id))
          ..invalidate(classDayMarksProvider(day));
        unawaited(ref.read(pulseProvider.notifier).refresh());
        if (context.mounted) GToast.show(context, approve ? l.t8Approved : l.t8Rejected);
      } catch (_) {
        GHaptics.error();
        if (context.mounted) GToast.show(context, l.t8ReviewFailed, icon: GIcons.error);
      } finally {
        busy.remove(x.id);
        onRebuild();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (classes.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in classes)
                GChip(
                  label: k.name.isEmpty ? '—' : k.name,
                  selected: k.id == cls.id,
                  onTap: () => ref.read(selectedHomeroomProvider.notifier).select(k.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        _Hero(counts: counts, overview: overview, now: now),
        const SizedBox(height: 12),
        GButton(
          label: l.t8MarkClass,
          icon: GIcons.check,
          size: GButtonSize.l,
          expand: true,
          onPressed: sendable ? () => unawaited(send()) : null,
        ),
        if (pending.isNotEmpty) ...[
          GSectionTitle(title: l.t8Requests),
          for (final x in pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExcuseCard(
                excuse: x,
                busy: busy.contains(x.id),
                onApprove: () => unawaited(review(x, approve: true)),
                onReject: () => unawaited(review(x, approve: false)),
              ),
            ),
        ],
        GSectionTitle(
          title: l.t8RollCall,
          action: counts.unmarked > 0 ? l.t8AllCame : null,
          onAction: counts.unmarked > 0 ? allCame : null,
        ),
        GGroup(
          inset: 68,
          children: [
            for (final s in ordered)
              _DayRow(
                student: s,
                cell: cells[s.id]!,
                absentCode: codeOfStatus(grading, Presence.absent).isEmpty
                    ? 'Н'
                    : codeOfStatus(grading, Presence.absent),
                onTap: () => tap(s),
                onCodes: () => unawaited(codes(s)),
              ),
          ],
        ),
        _WeekSection(classId: cls.id, now: now),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: GButton(
            label: l.t8OpenWeb,
            icon: GIcons.openInNew,
            variant: GButtonVariant.plain,
            size: GButtonSize.s,
            onPressed: () => unawaited(launchUrl(Uri.parse(_webUrl), mode: LaunchMode.externalApplication)),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.counts, required this.overview, required this.now});
  final ({int came, int total, int unmarked}) counts;
  final ClassOverview? overview;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final next = overview?.nextSubject;
    final at = overview?.nextStartsAt;
    final done = counts.unmarked == 0;
    return GCard(
      child: Semantics(
        container: true,
        label: [l.t8Came(counts.came, counts.total), done ? l.t8AllMarked : l.t8Unmarked(counts.unmarked)].join(', '),
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.t8Came(counts.came, counts.total), style: t.title1),
            const SizedBox(height: 10),
            GBar(value: counts.total == 0 ? 0 : counts.came / counts.total, color: GColors.brand, height: 8),
            const SizedBox(height: 12),
            Row(
              children: [
                GStatusPill(
                  label: done ? l.t8AllMarked : l.t8Unmarked(counts.unmarked),
                  tone: done ? GTone.ok : GTone.warn,
                  icon: done ? GIcons.ok : GIcons.info,
                ),
              ],
            ),
            if (next != null && at != null) ...[
              const SizedBox(height: 10),
              Text(l.t8NextLesson(next, Fmt.clock(at)), style: t.footnote.copyWith(color: c.ink2)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.student,
    required this.cell,
    required this.absentCode,
    required this.onTap,
    required this.onCodes,
  });
  final RosterStudent student;
  final DayCell cell;
  final String absentCode;
  final VoidCallback onTap;
  final VoidCallback onCodes;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final absent = cell.status == Presence.absent;
    final sub = <Widget>[
      if (cell.source == DaySource.checkin && cell.checkedAt != null) ...[
        GIcon(GIcons.checkIn, size: 16, color: c.ink3),
        const SizedBox(width: 4),
        Text(Fmt.clock(cell.checkedAt!), style: t.footnote.copyWith(color: c.ink2)),
      ] else if (cell.source == DaySource.excuse) ...[
        GIcon(GIcons.excuse, size: 16, color: c.ink3),
        const SizedBox(width: 4),
        Text(l.t8SourceExcuse, style: t.footnote.copyWith(color: c.ink2)),
      ],
      if (cell.pendingExcuse) ...[
        if (cell.source == DaySource.checkin || cell.source == DaySource.excuse) const SizedBox(width: 8),
        Text(l.t8SourcePending, style: t.footnote.copyWith(color: c.primarySoftText)),
      ],
    ];
    final state = cell.unmarked
        ? l.t8Unmarked(1)
        : switch (cell.status!) {
            Presence.present => l.statePresent,
            Presence.absent => l.codeAbsent,
            Presence.tardy => l.codeLate,
            Presence.excused => cell.code.isEmpty ? l.codeExcused : cell.code,
          };
    return Semantics(
      customSemanticsActions: {CustomSemanticsAction(label: l.actionCodes): onCodes},
      child: GRow(
        semanticLabel: '${student.name}, $state',
        onTap: onTap,
        onLongPress: onCodes,
        leading: PersonAvatar(
          presence: PresenceRef.student(student.id),
          name: student.name,
          url: student.avatarUrl,
          size: 40,
          tone: GAvatarTone.neutral,
        ),
        title: Text(
          student.name,
          style: t.bodyStrong.copyWith(color: absent ? c.bad : c.ink),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: sub.isEmpty ? null : Row(children: sub),
        trailing: cell.unmarked
            ? _UnmarkedToggle(onTap: onTap, onLongPress: onCodes)
            : AttendanceToggle(
                cell: RollCell(status: cell.status!, code: cell.code, queued: cell.source == DaySource.queued),
                absentCode: absentCode,
                enabled: true,
                onTap: onTap,
                onLongPress: onCodes,
              ),
      ),
    );
  }
}

/// «Ещё не отмечен»: an empty capsule in the place of the attendance toggle.
class _UnmarkedToggle extends StatelessWidget {
  const _UnmarkedToggle({required this.onTap, required this.onLongPress});
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 56,
        height: 44,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          shape: StadiumBorder(side: BorderSide(color: c.ink3, width: 1.5)),
        ),
        child: GIcon(GIcons.add, size: 20, color: c.ink3),
      ),
    );
  }
}

class _ExcuseCard extends StatelessWidget {
  const _ExcuseCard({required this.excuse, required this.busy, required this.onApprove, required this.onReject});
  final ClassExcuse excuse;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  String _category(AppLocalizations l, String c) => switch (c) {
    'illness' => l.catIllness,
    'family' => l.catFamily,
    'appointment' => l.catAppointment,
    _ => l.catOther,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final e = excuse.excuse;
    final from = DateTime.tryParse(e.startDate);
    final to = DateTime.tryParse(e.endDate);
    final loc = context.localeTag;
    final dates = from == null
        ? e.startDate
        : to == null || to == from
        ? Fmt.dayMonth(from, loc)
        : Fmt.range(from, to, loc);
    final url = excuse.attachmentUrl;
    return GCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PersonAvatar(
                presence: PresenceRef.student(e.studentId),
                name: e.studentName ?? '',
                size: 40,
                tone: GAvatarTone.neutral,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.studentName ?? '—', style: t.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      '$dates · ${_category(l, e.category)}',
                      style: t.footnote.copyWith(color: c.ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (e.reason.isNotEmpty) ...[const SizedBox(height: 10), Text(e.reason, style: t.body)],
          if (excuse.requestedBy != null) ...[
            const SizedBox(height: 6),
            Text(l.t8From(excuse.requestedBy!), style: t.footnote.copyWith(color: c.ink3)),
          ],
          if (url != null) ...[
            const SizedBox(height: 10),
            if (excuse.attachmentIsImage)
              Align(
                alignment: Alignment.centerLeft,
                child: GPressable(
                  onTap: () => unawaited(showPhotoViewer(context, url, label: l.t8Photo)),
                  semanticLabel: l.t8Photo,
                  excludeChildSemantics: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      url,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      cacheWidth: (96 * MediaQuery.devicePixelRatioOf(context)).round(),
                      errorBuilder: (_, _, _) => SizedBox(
                        width: 96,
                        height: 96,
                        child: ColoredBox(
                          color: c.surface2,
                          child: Center(child: GIcon(GIcons.image, color: c.ink3)),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              GChip(
                label: l.t8Photo,
                icon: GIcons.file,
                onTap: () => unawaited(openAttachment(context, Attachment(url: url, name: l.t8Photo))),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GButton(
                  label: l.t8Reject,
                  variant: GButtonVariant.secondary,
                  expand: true,
                  onPressed: busy ? null : onReject,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GButton(label: l.t8Approve, expand: true, loading: busy, onPressed: busy ? null : onApprove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reason for a rejection; null when the teacher backs out.
Future<String?> _askRejectNote(BuildContext context, ClassExcuse x) {
  final l = context.l10n;
  final controller = TextEditingController();
  return showGSheet<String>(
    context,
    title: l.t8RejectTitle,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GField(
            controller: controller,
            hint: l.t8RejectHint,
            maxLines: 4,
            minLines: 2,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          GButton(
            label: l.t8RejectSend,
            size: GButtonSize.l,
            expand: true,
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          ),
        ],
      ),
    ),
  ).whenComplete(controller.dispose);
}

class _WeekSection extends ConsumerWidget {
  const _WeekSection({required this.classId, required this.now});
  final String classId;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final range = (classId: classId, from: isoDate(mondayOf(now)), to: isoDate(now));
    final week = ref.watch(classWeekProvider(range));
    final data = week.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.t8Week),
        if (data == null)
          week.hasError ? GStateRow(title: l.errorOffline, tone: GTone.warn) : const GSkeleton(hero: false, rows: 2)
        else ...[
          GCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.t8WeekRate(data.rate.toStringAsFixed(0)), style: t.headline),
                      const SizedBox(height: 4),
                      Text(
                        '${l.t8WeekAbsent(data.absent)} · ${l.t8WeekTardy(data.tardy)}',
                        style: t.footnote.copyWith(color: c.ink2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(l.t8AtRisk, style: t.subhead.copyWith(color: c.ink2)),
          const SizedBox(height: 6),
          if (data.atRisk.isEmpty)
            GStateRow(title: l.t8AtRiskNone, tone: GTone.ok)
          else
            GGroup(
              children: [
                for (final s in data.atRisk.take(6))
                  GRow(
                    minHeight: GSpace.rowCompact,
                    leading: PersonAvatar(
                      presence: PresenceRef.student(s.studentId),
                      name: s.name,
                      size: 36,
                      tone: GAvatarTone.neutral,
                    ),
                    title: Text(s.name),
                    trailing: GStatusPill(label: l.t8WeekAbsent(s.absent), tone: GTone.bad),
                  ),
              ],
            ),
        ],
      ],
    );
  }
}

/// Full-screen photo with pinch-to-zoom (an absence request's attachment).
Future<void> showPhotoViewer(BuildContext context, String url, {String? label}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: GMotion.reduce(context) ? Duration.zero : GMotion.quick,
      pageBuilder: (ctx, _, _) => _PhotoViewer(url: url, label: label),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.url, this.label});
  final String url;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              image: true,
              label: label,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, p) =>
                        p == null ? child : const Center(child: GLoader(color: Colors.white)),
                    errorBuilder: (_, _, _) => Center(
                      child: GEmpty(error: true, title: l.errorTitle, message: l.attachmentOpenFailed),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GIconButton(
                  icon: GIcons.close,
                  label: l.close,
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
