import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/grading.dart';
import 'package:gradeapp/features/learner/forecast.dart';

/// KZ preset as `/schools/{id}/` returns it.
Grading kz() => Grading.fromSchool({
  'grading_config': {
    'min': 2,
    'max': 5,
    'passing': 3,
    'quality_min': 4,
    'quarter_formula': {'fo': 0.25, 'sor': 0.25, 'soch': 0.5},
    'criterion_scale': [
      {'mark': 5, 'min_pct': 85},
      {'mark': 4, 'min_pct': 65},
      {'mark': 3, 'min_pct': 40},
      {'mark': 2, 'min_pct': 0},
    ],
    'work_types': [
      {'code': 'fo', 'name': 'ФО', 'kind': 'formative'},
      {'code': 'sor', 'name': 'СОР', 'kind': 'sor'},
      {'code': 'soch', 'name': 'СОЧ', 'kind': 'soch'},
    ],
  },
});

GradeInput w(num v, num max, String type) => (value: v, maxValue: max, type: type);

void main() {
  final g = kz();
  // FO 80, SOR 65 → 4 on the preliminary formula (no СОЧ yet).
  final works = [w(8, 10, 'fo'), w(4, 5, 'fo'), w(13, 20, 'sor')];

  test('current result is the server formula on the same works', () {
    final r = buildForecast(g, works, formulaKnown: true, kind: WorkKind.soch, max: 25).forecast!;
    expect(r.current.percent, g.quarter(works).percent);
    expect(r.current.mark, g.quarter(works).mark);
  });

  test('«нужно набрать» is the smallest score that reaches the mark', () {
    final f = buildForecast(g, works, formulaKnown: true, kind: WorkKind.soch, max: 25).forecast!;
    expect(f.steps, isNotEmpty);
    for (final s in f.steps) {
      final at = quarterWith(g, works, kind: WorkKind.soch, score: s.need, max: 25);
      expect(at.mark! >= s.mark, isTrue, reason: 'score ${s.need} must reach ${s.mark}');
      if (s.need > 0) {
        final below = quarterWith(g, works, kind: WorkKind.soch, score: s.need - 1, max: 25);
        expect(below.mark! < s.mark, isTrue, reason: 'score ${s.need - 1} must not reach ${s.mark}');
      }
    }
  });

  test('only marks above the current one are offered, ascending', () {
    final f = buildForecast(g, works, formulaKnown: true, kind: WorkKind.soch, max: 25).forecast!;
    expect(f.steps.map((s) => s.mark).toList(), [5]);
    expect(f.current.mark, 4);
  });

  test('«если получу»: result equals Grading.quarter with the work added', () {
    for (final score in [0, 10, 20, 25]) {
      final a = quarterWith(g, works, kind: WorkKind.soch, score: score, max: 25);
      final b = g.quarter([...works, w(score, 25, 'soch')]);
      expect(a.percent, b.percent);
      expect(a.mark, b.mark);
    }
  });

  test('a mark that no score reaches is not offered', () {
    final low = [w(1, 10, 'fo'), w(1, 10, 'fo'), w(1, 10, 'sor')];
    final f = buildForecast(g, low, formulaKnown: true, kind: WorkKind.soch, max: 20).forecast!;
    // 10 % FO/SOR + a perfect СОЧ (weight 0.5) cannot reach 85 %.
    expect(f.steps.where((s) => s.mark == 5), isEmpty);
  });

  test('hidden without the formula or with too few works', () {
    expect(buildForecast(g, works, formulaKnown: false, kind: WorkKind.soch).hidden, ForecastHidden.noFormula);
    expect(buildForecast(g, works.take(2), formulaKnown: true, kind: WorkKind.soch).hidden, ForecastHidden.fewWorks);
    // plain marks without a score do not count as works for the percent
    expect(
      buildForecast(g, [w(5, 0, 'fo'), w(4, 0, 'fo'), w(5, 0, 'fo')], formulaKnown: true, kind: WorkKind.soch).hidden,
      ForecastHidden.fewWorks,
    );
  });

  test('СОР kind uses the school work-type code', () {
    expect(codeOfKind(g, WorkKind.sor), 'sor');
    expect(codeOfKind(g, WorkKind.soch), 'soch');
    expect(codeOfKind(Grading.fallback, WorkKind.soch), 'soch');
  });
}
