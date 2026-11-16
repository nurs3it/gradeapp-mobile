import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/grading.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../common/lesson_widgets.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import '../shell/header.dart';
import 'grades_logic.dart';
import 'learner_providers.dart';
import 'seen.dart';

/// Quarter picked in «Оценки» (null = the current one).
class SelectedTerm extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final selectedTermProvider = NotifierProvider<SelectedTerm, String?>(SelectedTerm.new);

/// The quarter in view.
final viewTermProvider = Provider<Term?>((ref) {
  final terms = ref.watch(termsProvider).value ?? const <Term>[];
  final picked = ref.watch(selectedTermProvider);
  return terms.where((t) => t.id == picked).firstOrNull ?? currentTermOf(terms, DateTime.now());
});

/// Class of the learner in view (for the grade-1 % table).
final learnerGradeLevelProvider = Provider<int?>((ref) {
  if (ref.watch(activeRoleProvider) == AppRole.parent) return gradeLevelOf(ref.watch(currentChildProvider)?.className);
  final id = ref.watch(myStudentIdProvider);
  if (id == null) return null;
  return gradeLevelOf(ref.watch(learnerDayProvider((studentId: id, date: isoDate(DateTime.now())))).value?.className);
});

/// Subjects of the quarter in view with their quarter marks.
final quarterSummaryProvider = Provider<AsyncValue<List<SubjectSummary>>>((ref) {
  final id = ref.watch(learnerIdProvider);
  final term = ref.watch(viewTermProvider);
  if (id == null || term == null) {
    final terms = ref.watch(termsProvider);
    return terms.hasError ? AsyncError(terms.error!, terms.stackTrace!) : const AsyncLoading();
  }
  final args = (studentId: id, termId: term.id);
  final grades = ref.watch(termGradesProvider(args));
  final periods = ref.watch(periodGradesProvider(args));
  if (!grades.hasValue) {
    return grades.hasError ? AsyncError(grades.error!, grades.stackTrace!) : const AsyncLoading();
  }
  return AsyncData(
    summarizeQuarter(
      grades: grades.value!,
      periods: periods.value ?? const [],
      grading: ref.watch(gradingProvider),
      formulaKnown: ref.watch(gradingLoadedProvider),
      gradeLevel: ref.watch(learnerGradeLevelProvider),
    ),
  );
});

enum _View { subjects, feed }

/// «Оценки» (S6, §3.5): quarters as a fan, subjects with the quarter mark by
/// the school formula (never a plain average), or a feed by day.
class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  _View _view = _View.subjects;
  bool _alpha = false;

  @override
  void initState() {
    super.initState();
    // «Новое» is computed against the previous visit; the dots stay for this one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(gradesSeenProvider.notifier).markSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final g = GSpace.gutter(context);
    final parent = ref.watch(activeRoleProvider) == AppRole.parent;
    final terms = ref.watch(termsProvider).value ?? const <Term>[];
    final term = ref.watch(viewTermProvider);
    final summary = ref.watch(quarterSummaryProvider);
    final grading = ref.watch(gradingProvider);
    final seen = ref.watch(gradesSeenProvider).previous;
    final now = ref.now;
    final week = term == null ? null : (now.difference(DateTime.parse(term.start)).inDays ~/ 7 + 1);
    final current = term != null && term.contains(isoDate(now));
    final child = parent ? ref.watch(currentChildProvider) : null;

    return GRootPage(
      eyebrow: [
        ?child?.shortName,
        if (term != null) current && week != null ? l.gradesEyebrow(term.name, week) : term.name,
      ].join(' · '),
      title: l.tabGrades,
      actions: [const BellButton(), if (parent) const ChildSwitcherButton() else const AvatarButton()],
      below: const NetBanner(),
      onRefresh: () async {
        ref
          ..invalidate(termGradesProvider)
          ..invalidate(periodGradesProvider)
          ..invalidate(termsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: g),
          sliver: SliverList.list(
            children: [
              if (terms.isNotEmpty) ...[
                _QuarterFan(terms: terms, selected: term, now: now),
                const SizedBox(height: 12),
              ],
              GSegmented<_View>(
                values: _View.values,
                selected: _view,
                labels: [l.segSubjects, l.segFeed],
                onChanged: (v) => setState(() => _view = v),
              ),
            ],
          ),
        ),
        ...switch (summary) {
          AsyncData(:final value) => _content(context, value, grading, seen, term),
          AsyncError() => [
            SliverToBoxAdapter(
              child: GEmpty(
                error: true,
                title: l.errorTitle,
                message: l.errorOffline,
                action: l.retry,
                onAction: () => ref.invalidate(termGradesProvider),
              ),
            ),
          ],
          _ => [const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(top: 16), child: GSkeleton(hero: false, rows: 5)))],
        },
      ],
    );
  }

  List<Widget> _content(BuildContext context, List<SubjectSummary> list, Grading grading, DateTime? seen, Term? term) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    if (list.isEmpty) {
      return [SliverToBoxAdapter(child: GEmpty(title: l.gradesEmpty, message: l.gradesEmptyHint))];
    }
    if (_view == _View.feed) return [_Feed(list: list, seen: seen)];
    final sorted = _alpha ? ([...list]..sort((a, b) => a.name.compareTo(b.name))) : sortByAttention(list, grading);
    final insight = insightOf(list);
    final closed = list.isNotEmpty && list.every((s) => s.isFinal);
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: g),
        sliver: SliverList.list(
          children: [
            if (closed && term != null) ...[const SizedBox(height: 12), _Results(list: list, term: term)],
            if (insight != null) ...[
              const SizedBox(height: 12),
              GCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GIcon(GIcons.grades, size: 22, color: c.primaryText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: l.insightStrong(insight.strong.name), style: const TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: ' ${l.insightWeak(insight.weak.name, insight.weak.percent!.round())}'),
                          ],
                        ),
                        style: context.t.callout,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            GSectionTitle(
              title: l.subjectsCount(list.length),
              action: _alpha ? l.sortAlpha : l.sortAttention,
              onAction: () {
                GHaptics.selection();
                setState(() => _alpha = !_alpha);
              },
            ),
          ],
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: g),
        sliver: SliverToBoxAdapter(
          child: GGroup(
            children: [for (final s in sorted) _SubjectRow(summary: s, grading: grading, seen: seen)],
          ),
        ),
      ),
    ];
  }
}

/// Four quarters as capsules (§3.23 `GQuarterFan`): picker and the year's
/// progress at once.
class _QuarterFan extends ConsumerWidget {
  const _QuarterFan({required this.terms, required this.selected, required this.now});
  final List<Term> terms;
  final Term? selected;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final t = context.t;
    final l = context.l10n;
    final today = isoDate(now);
    return Row(
      children: [
        for (final term in terms.take(4))
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Builder(
                builder: (context) {
                  final isSel = term.id == selected?.id;
                  final running = term.contains(today);
                  final future = term.start.compareTo(today) > 0;
                  final start = DateTime.parse(term.start);
                  final end = DateTime.parse(term.end);
                  final progress = future
                      ? 0.0
                      : running
                      ? now.difference(start).inDays / end.difference(start).inDays.clamp(1, 1000)
                      : 1.0;
                  final value = future ? Fmt.monthShort(start, context.localeTag) : running ? l.termRunning : '';
                  final (bg, fg, track, fill) = isSel
                      ? (c.ink, c.canvas, c.canvas.withValues(alpha: 0.25), c.canvas)
                      : future
                      ? (c.surface2, c.ink2, c.surface3, c.surface3)
                      : (c.surface, c.ink, c.surface2, GColors.brand.withValues(alpha: 0.48));
                  return GPressable(
                    onTap: future
                        ? null
                        : () {
                            GHaptics.selection();
                            ref.read(selectedTermProvider.notifier).set(term.id);
                          },
                    selected: isSel,
                    semanticLabel: l.termPick(term.name),
                    excludeChildSemantics: true,
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      decoration: ShapeDecoration(
                        color: bg,
                        shape: GRadius.surface(18),
                        shadows: isSel || future ? null : GDepth.level1(c),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l.termShort(term.number), style: t.footnote.copyWith(color: fg, fontWeight: FontWeight.w600), textScaler: TextScaler.noScaling),
                          GBar(value: progress, color: fill, track: track, height: 6),
                          Text(
                            value,
                            style: t.footnote.copyWith(color: fg, fontWeight: FontWeight.w800),
                            textScaler: TextScaler.noScaling,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.summary, required this.grading, required this.seen});
  final SubjectSummary summary;
  final Grading grading;
  final DateTime? seen;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final l = context.l10n;
    final s = summary;
    final q = s.quarter;
    final marker = c.subjectMarker(s.name);
    final markTone = s.mark == null ? null : grading.tone(s.mark!);
    final bars = [
      (l.kindFo, q.fo, s.countOf(grading, WorkKind.formative)),
      (l.kindSor, q.sor, s.countOf(grading, WorkKind.sor)),
      (l.kindSoch, q.soch, s.countOf(grading, WorkKind.soch)),
    ];
    return GRow(
      onTap: () => context.push('${GoRouterState.of(context).uri.path}/${s.courseId}'),
      semanticLabel: [
        s.name,
        if (s.mark != null) l.gradeSemantic(fmtNum(s.mark!), toneWord(l, markTone!)),
        if (s.preliminary) l.prelim,
      ].join(', '),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      title: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: marker, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (label, pct, n) in bars) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pct == null ? '$label —' : '$label ${pct.round()} %',
                        style: t.caption.copyWith(fontSize: 12, color: pct == null ? c.ink3 : c.ink2),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      GBar(value: (pct ?? 0) / 100, color: marker, track: n == 0 ? c.surface2 : null),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final gr in s.grades.take(4)) GradeChipOf(grade: gr, isNew: isNewGrade(gr, seen))],
          ),
        ],
      ),
      subtitleMaxLines: 10,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GGradeChip(text: s.mark == null ? '—' : fmtNum(s.mark!), tone: markTone, size: GGradeSize.l),
          if (s.preliminary) ...[
            const SizedBox(height: 4),
            Text(l.prelim, style: t.caption.copyWith(color: c.ink2)),
          ],
        ],
      ),
    );
  }
}

/// Feed: all grades by day, newest first.
class _Feed extends StatelessWidget {
  const _Feed({required this.list, required this.seen});
  final List<SubjectSummary> list;
  final DateTime? seen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final all = [for (final s in list) ...s.grades]..sort((a, b) => b.date.compareTo(a.date));
    final byDay = <String, List<Grade>>{};
    for (final gr in all) {
      (byDay[gr.date] ??= []).add(gr);
    }
    final today = isoDate(DateTime.now());
    final yesterday = isoDate(DateTime.now().subtract(const Duration(days: 1)));
    final days = byDay.keys.toList();
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: g),
      sliver: SliverList.builder(
        itemCount: days.length,
        itemBuilder: (context, i) {
          final d = days[i];
          final title = d == today
              ? l.todayWord
              : d == yesterday
              ? l.yesterday
              : Fmt.dayMonth(DateTime.parse(d), context.localeTag);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GSectionTitle(title: title),
              GGroup(
                inset: 33,
                children: [
                  for (final gr in byDay[d]!)
                    GRow(
                      marker: c.subjectMarker(gr.courseName),
                      title: Text(gr.courseName),
                      subtitle: Row(
                        children: [
                          WorkBadge(type: gr.type),
                          if (gr.comment.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Expanded(child: Text('«${gr.comment}»', maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ],
                      ),
                      trailing: GradeChipOf(grade: gr, size: GGradeSize.m, isNew: isNewGrade(gr, seen)),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Closed quarter: all subjects' marks in a grid (§3.5).
class _Results extends StatelessWidget {
  const _Results({required this.list, required this.term});
  final List<SubjectSummary> list;
  final Term term;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.quarterResults(term.name), style: context.t.headline),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) => Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                for (final s in list)
                  SizedBox(
                    width: (box.maxWidth - 16) / 3,
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, _) => GGradeChip(
                            text: s.mark == null ? '—' : fmtNum(s.mark!),
                            tone: s.mark == null ? null : ref.watch(gradingProvider).tone(s.mark!),
                            size: GGradeSize.l,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.name,
                          style: context.t.footnote.copyWith(color: context.c.ink2),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Subject breakdown (§3.6): hero with the quarter mark, ФО/СОР/СОЧ tiles with
/// the school weights, works newest first, «Как считается».
class SubjectScreen extends ConsumerWidget {
  const SubjectScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final g = GSpace.gutter(context);
    final grading = ref.watch(gradingProvider);
    final term = ref.watch(viewTermProvider);
    final level = ref.watch(learnerGradeLevelProvider);
    final s = ref.watch(quarterSummaryProvider).value?.where((x) => x.courseId == courseId).firstOrNull;
    final seen = ref.watch(gradesSeenProvider).previous;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(
        backLabel: l.tabGrades,
        actions: [
          GIconButton(
            icon: GIcons.info,
            label: l.howCalculated,
            size: 40,
            background: c.surface,
            onPressed: () => showFormulaSheet(context, ref),
          ),
        ],
      ),
      body: s == null
          ? const Center(child: GLoader())
          : ListView(
              padding: EdgeInsets.fromLTRB(g, 8, g, GSpace.contentBottom + MediaQuery.paddingOf(context).bottom),
              children: [
                _SubjectHero(summary: s, term: term, grading: grading, gradeLevel: level),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, (kind, label, w, pct)) in [
                        (WorkKind.formative, l.kindFo, grading.formula.fo, s.quarter.fo),
                        (WorkKind.sor, l.kindSor, grading.formula.sor, s.quarter.sor),
                        (WorkKind.soch, l.kindSoch, grading.formula.soch, s.quarter.soch),
                      ].indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: GCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GTypeBadge(label: '$label · ${(w * 100).round()} %', kind: kind.name),
                                const SizedBox(height: 10),
                                CappedText(
                                  pct == null ? '—' : '${pct.round()} %',
                                  style: t.title1.copyWith(fontSize: 26, fontFeatures: const [FontFeature.tabularFigures()]),
                                ),
                                Text(l.worksCount(s.countOf(grading, kind)), style: t.footnote.copyWith(color: c.ink2)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GButton(
                    label: l.howCalculated,
                    variant: GButtonVariant.plain,
                    size: GButtonSize.s,
                    onPressed: () => showFormulaSheet(context, ref),
                  ),
                ),
                GSectionTitle(title: l.works, trailing: Text(l.newestFirst, style: t.footnote.copyWith(color: c.ink2))),
                GGroup(
                  children: [
                    for (final gr in s.grades)
                      GRow(
                        title: Text(grading.typeName(gr.type)),
                        subtitle: Row(
                          children: [
                            WorkBadge(type: gr.type),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                [
                                  Fmt.dayMonth(DateTime.parse(gr.date), context.localeTag),
                                  if (gr.percent != null) '${gr.percent!.round()} %',
                                  if (gr.comment.isNotEmpty) '«${gr.comment}»',
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: GradeChipOf(grade: gr, size: GGradeSize.m, isNew: isNewGrade(gr, seen)),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SubjectHero extends StatelessWidget {
  const _SubjectHero({required this.summary, required this.term, required this.grading, required this.gradeLevel});
  final SubjectSummary summary;
  final Term? term;
  final Grading grading;
  final int? gradeLevel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.t;
    final c = context.c;
    final s = summary;
    const on = GColors.onFill;
    final next = s.isFinal ? null : toNextMark(grading, s.percent, gradeLevel: gradeLevel);
    final termName = term?.name ?? '';
    return GHeroSheet(
      color: c.subjectFill(s.name),
      fan: [c.subjectFill(s.name)],
      semanticLabel: [
        s.name,
        if (s.mark != null) l.gradeSemantic(fmtNum(s.mark!), toneWord(l, grading.tone(s.mark!))),
        if (s.percent != null) '${s.percent!.round()} %',
        if (s.preliminary) l.prelim,
      ].join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (s.isFinal ? l.subjectFinal(termName) : l.subjectPrelim(termName)).toUpperCase(),
            style: t.eyebrow.copyWith(color: on.withValues(alpha: 0.88)),
          ),
          const SizedBox(height: 6),
          Text(s.name, style: t.heroTitle.copyWith(color: on), maxLines: 2),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CappedText(s.mark == null ? '—' : fmtNum(s.mark!), style: t.displayXl.copyWith(color: on)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.percent != null)
                      Text(
                        '${fmtNum(s.percent!.round())} %',
                        style: t.title1.copyWith(color: on, fontSize: 24, fontFeatures: const [FontFeature.tabularFigures()]),
                      ),
                    if (next != null)
                      Text(
                        l.toNextMark(fmtNum(next.mark), next.missing.ceil()),
                        style: t.callout.copyWith(color: on.withValues(alpha: 0.88)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// «Как считается четвертная» (§3.6): weights bar and the % → mark table.
Future<void> showFormulaSheet(BuildContext context, WidgetRef ref) {
  final l = context.l10n;
  final g = ref.read(gradingProvider);
  final known = ref.read(gradingLoadedProvider);
  final level = ref.read(learnerGradeLevelProvider);
  final scale = level == 1 && g.criterionScaleGrade1.isNotEmpty ? g.criterionScaleGrade1 : g.criterionScale;
  final rows = [...scale]..sort((a, b) => b.minPct.compareTo(a.minPct));
  return showGSheet<void>(
    context,
    title: l.howCalculated,
    builder: (ctx) {
      final c = ctx.c;
      final t = ctx.t;
      if (!known) {
        return Padding(padding: const EdgeInsets.all(20), child: GStateRow(title: l.formulaMissing, tone: GTone.warn));
      }
      final parts = [
        (l.kindFo, g.formula.fo, 'formative'),
        (l.kindSor, g.formula.sor, 'sor'),
        (l.kindSoch, g.formula.soch, 'soch'),
      ].where((p) => p.$2 > 0).toList();
      Color colorOf(String kind) => switch (kind) {
        'sor' => GColors.warnFill,
        'soch' => gSubjects[3].fill,
        _ => GColors.brand,
      };
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    for (final p in parts)
                      Expanded(
                        flex: (p.$2 * 100).round(),
                        child: Container(
                          color: colorOf(p.$3),
                          alignment: Alignment.center,
                          child: Text(
                            '${p.$1} ${(p.$2 * 100).round()} %',
                            style: t.caption.copyWith(color: GColors.onFill),
                            maxLines: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(l.howCalcMissing, style: t.footnote.copyWith(color: c.ink2)),
            const SizedBox(height: 16),
            Text(l.pctToMark, style: t.subhead.copyWith(color: c.ink2)),
            const SizedBox(height: 8),
            GGroup(
              children: [
                for (final r in rows)
                  SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: Text(l.pctFrom(r.minPct.round()), style: t.callout)),
                          GGradeChip(text: fmtNum(r.mark), tone: g.tone(r.mark)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l.howCalcBody, style: t.footnote.copyWith(color: c.ink2)),
          ],
        ),
      );
    },
  );
}
