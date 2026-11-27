import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/grading.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import 'grades_logic.dart';
import 'grades_screen.dart';
import 'learner_providers.dart';
import 'weekly_summary.dart';

/// Fewer scored works than this: a forecast would be a guess (S7).
const forecastMinWorks = 3;

/// Why the forecast is not shown.
enum ForecastHidden { noFormula, fewWorks }

/// «Чтобы выйти на [mark], нужно набрать не меньше [need] из [max]».
typedef ForecastStep = ({num mark, int need});

class Forecast {
  const Forecast({required this.current, required this.kind, required this.max, required this.steps});

  /// Quarter by the school formula on the works so far.
  final QuarterResult current;
  final WorkKind kind;
  final int max;

  /// Higher marks that this work can still reach, lowest first.
  final List<ForecastStep> steps;
}

/// Work-type code the formula buckets by [kind] (the school's own code if any).
String codeOfKind(Grading g, WorkKind kind) =>
    g.workTypes.where((w) => w.kind == kind).firstOrNull?.code ?? (kind == WorkKind.sor ? 'sor' : 'soch');

/// Quarter result if one more work of [kind], [score] of [max], is added.
/// Goes through [Grading.quarter], so it matches the server's formula.
QuarterResult quarterWith(
  Grading g,
  Iterable<GradeInput> grades, {
  required WorkKind kind,
  required int score,
  required int max,
  int? gradeLevel,
}) => g.quarter([...grades, (value: score, maxValue: max, type: codeOfKind(g, kind))], gradeLevel: gradeLevel);

/// Null result = [hidden] says why. Marks of the scale above the current one
/// are offered only when some score up to [max] reaches them.
({Forecast? forecast, ForecastHidden? hidden}) buildForecast(
  Grading g,
  Iterable<GradeInput> grades, {
  required bool formulaKnown,
  required WorkKind kind,
  int max = 20,
  int? gradeLevel,
}) {
  if (!formulaKnown) return (forecast: null, hidden: ForecastHidden.noFormula);
  final list = grades.toList();
  final scored = list.where((x) => g.gradePercent(x.value, x.maxValue) != null).length;
  final current = g.quarter(list, gradeLevel: gradeLevel);
  if (scored < forecastMinWorks || current.mark == null) return (forecast: null, hidden: ForecastHidden.fewWorks);
  final scale = gradeLevel == 1 && g.criterionScaleGrade1.isNotEmpty ? g.criterionScaleGrade1 : g.criterionScale;
  final higher = {for (final r in scale) r.mark}.where((m) => m > current.mark!).toList()..sort();
  final steps = <ForecastStep>[];
  for (final m in higher) {
    for (var s = 0; s <= max; s++) {
      final r = quarterWith(g, list, kind: kind, score: s, max: max, gradeLevel: gradeLevel);
      if (r.mark != null && r.mark! >= m) {
        steps.add((mark: m, need: s));
        break;
      }
    }
  }
  return (forecast: Forecast(current: current, kind: kind, max: max, steps: steps), hidden: null);
}

/// Nearest upcoming СОР/СОЧ of a course from this week's summary.
WeekAssessment? nextAssessmentOf(String courseName, Iterable<WeekAssessment> list, String today) =>
    (list.where((a) => a.courseName == courseName && a.date.compareTo(today) >= 0).toList()
          ..sort((a, b) => a.date.compareTo(b.date)))
        .firstOrNull;

/// «Прогноз» on the subject screen (S7): current percent and mark, what is
/// needed for the next marks, «если получу…».
class ForecastBlock extends ConsumerStatefulWidget {
  const ForecastBlock({super.key, required this.summary});
  final SubjectSummary summary;

  @override
  ConsumerState<ForecastBlock> createState() => _ForecastBlockState();
}

class _ForecastBlockState extends ConsumerState<ForecastBlock> {
  WorkKind? _kind;
  int _max = 20;
  int? _score;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final s = widget.summary;
    if (s.isFinal) return const SizedBox.shrink();
    final grading = ref.watch(gradingProvider);
    final known = ref.watch(gradingLoadedProvider);
    final level = ref.watch(learnerGradeLevelProvider);
    final id = ref.watch(learnerIdProvider);
    final now = DateTime.now();
    final upcoming = id == null
        ? null
        : ref.watch(weeklySummaryProvider((studentId: id, week: isoWeekId(now)))).value?.assessments;
    final next = upcoming == null ? null : nextAssessmentOf(s.name, upcoming, isoDate(now));
    final nextKind = next == null ? null : (next.kind == 'sor' ? WorkKind.sor : WorkKind.soch);
    final kind = _kind ?? nextKind ?? WorkKind.soch;
    final inputs = s.grades.map((x) => x.input).toList();
    final res = buildForecast(grading, inputs, formulaKnown: known, kind: kind, max: _max, gradeLevel: level);
    final kindName = kind == WorkKind.sor ? l.kindSor : l.kindSoch;

    Widget wrap(List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.s7Title),
        ...children,
      ],
    );

    final hidden = res.hidden;
    if (hidden != null) {
      return wrap([
        GStateRow(
          title: l.s7Hidden,
          message: hidden == ForecastHidden.noFormula ? l.s7HiddenFormula : l.s7HiddenFew(forecastMinWorks),
          icon: GIcons.info,
        ),
      ]);
    }
    final f = res.forecast!;
    final score = (_score ?? (f.max * 0.8).round()).clamp(0, f.max);
    final what = quarterWith(grading, inputs, kind: kind, score: score, max: f.max, gradeLevel: level);

    return wrap([
      GCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.s7Now.toUpperCase(), style: t.eyebrow.copyWith(color: c.ink2)),
                      const SizedBox(height: 4),
                      Text(
                        l.s7NowLine(fmtNum(f.current.percent!.round()), fmtNum(f.current.mark!)),
                        style: t.title2.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                      ),
                    ],
                  ),
                ),
                GGradeChip(text: fmtNum(f.current.mark!), tone: grading.tone(f.current.mark!), size: GGradeSize.l),
              ],
            ),
            const SizedBox(height: 14),
            if (next != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  l.s7NextWork(
                    next.title.isEmpty ? kindName : next.title,
                    Fmt.dayMonth(DateTime.parse(next.date), context.localeTag),
                  ),
                  style: t.footnote.copyWith(color: c.ink2),
                ),
              ),
            GSegmented<WorkKind>(
              values: const [WorkKind.sor, WorkKind.soch],
              labels: [l.kindSor, l.kindSoch],
              selected: kind,
              onChanged: (k) => setState(() {
                _kind = k;
                _score = null;
              }),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Text(l.s7MaxScore, style: t.callout.copyWith(color: c.ink2))),
                GIconButton(
                  icon: Icons.remove_rounded,
                  label: l.s7Less,
                  size: 36,
                  background: c.surface2,
                  onPressed: _max <= 5
                      ? null
                      : () => setState(() {
                          _max -= 5;
                          _score = null;
                        }),
                ),
                SizedBox(
                  width: 44,
                  child: Text('$_max', textAlign: TextAlign.center, style: t.bodyStrong),
                ),
                GIconButton(
                  icon: GIcons.add,
                  label: l.s7More,
                  size: 36,
                  background: c.surface2,
                  onPressed: _max >= 100
                      ? null
                      : () => setState(() {
                          _max += 5;
                          _score = null;
                        }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (f.steps.isEmpty)
              Text(f.current.mark! >= grading.max ? l.s7Top : l.s7NoStep, style: t.body.copyWith(color: c.ink2))
            else
              for (final st in f.steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(l.s7Need(fmtNum(st.mark), kindName, st.need, f.max), style: t.body),
                ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      GCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.s7IfIGet(kindName, score, f.max), style: t.bodyStrong),
            Slider(
              value: score.toDouble(),
              max: f.max.toDouble(),
              divisions: f.max,
              label: '$score',
              activeColor: GColors.brand,
              onChanged: (v) => setState(() => _score = v.round()),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    what.mark == null ? '' : l.s7Result(fmtNum(what.mark!), fmtNum(what.percent!.round())),
                    style: t.callout.copyWith(color: c.ink2),
                  ),
                ),
                if (what.mark != null)
                  GGradeChip(text: fmtNum(what.mark!), tone: grading.tone(what.mark!), size: GGradeSize.m),
              ],
            ),
            const SizedBox(height: 6),
            Text(l.s7Disclaimer, style: t.footnote.copyWith(color: c.ink3)),
          ],
        ),
      ),
    ]);
  }
}
