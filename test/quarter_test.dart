import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/grading.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/learner/grades_logic.dart';

/// KZ preset as `/schools/{id}/` returns it (`grading_config`).
Grading kz({num min = 2, num max = 5, bool marksInQuarter = false}) => Grading.fromSchool({
  'grading_config': {
    'min': min,
    'max': max,
    'passing': 3,
    'quality_min': 4,
    'marks_in_quarter': marksInQuarter,
    'quarter_formula': {'fo': 0.25, 'sor': 0.25, 'soch': 0.5},
    'criterion_scale': [
      {'mark': 5, 'min_pct': 85},
      {'mark': 4, 'min_pct': 65},
      {'mark': 3, 'min_pct': 40},
      {'mark': 2, 'min_pct': 0},
    ],
    'criterion_scale_grade1': [
      {'mark': 5, 'min_pct': 81},
      {'mark': 4, 'min_pct': 51},
      {'mark': 3, 'min_pct': 21},
      {'mark': 2, 'min_pct': 0},
    ],
    'work_types': [
      {'code': 'fo', 'name': 'ФО', 'kind': 'formative'},
      {'code': 'sor', 'name': 'СОР', 'kind': 'sor'},
      {'code': 'soch', 'name': 'СОЧ', 'kind': 'soch'},
      {'code': 'test', 'name': 'Тест', 'kind': 'other'},
    ],
  },
});

Grade g(num value, num? max, String type, {String course = 'c1', String date = '2026-11-10'}) => Grade(
  id: '$value$type$date',
  studentId: 's',
  courseId: course,
  courseName: course,
  value: value,
  maxValue: max,
  type: type,
  date: date,
);

void main() {
  test('quarter = weighted ФО/СОР/СОЧ like journal.grading_service (78.75 → 4)', () {
    final r = kz().quarter([
      g(8, 10, 'fo').input,
      g(4, 5, 'fo').input,
      g(13, 20, 'sor').input,
      g(17, 20, 'soch').input,
      g(5, null, 'test').input, // informational, ignored
    ]);
    expect(r.fo, 80);
    expect(r.sor, 65);
    expect(r.soch, 85);
    expect(r.percent, 78.75);
    expect(r.mark, 4);
  });

  test('missing СОЧ: weights renormalised, preliminary mark still given', () {
    final r = kz().quarter([g(60, 100, 'fo').input, g(80, 100, 'sor').input]);
    expect(r.soch, isNull);
    expect(r.percent, 70);
    expect(r.mark, 4);
  });

  test('grade 1 uses its own % table', () {
    final r = kz().quarter([g(82, 100, 'fo').input], gradeLevel: 1);
    expect(r.mark, 5);
    expect(kz().quarter([g(82, 100, 'fo').input]).mark, 4);
  });

  test('plain marks count only with marks_in_quarter (own scale 1–10)', () {
    expect(kz().quarter([g(5, null, 'fo').input]).percent, isNull);
    final ten = Grading.fromSchool({
      'grading_config': {
        'min': 1,
        'max': 10,
        'passing': 4,
        'quality_min': 8,
        'marks_in_quarter': true,
        'criterion_scale': [
          for (var m = 10; m >= 2; m--) {'mark': m, 'min_pct': ((m - 0.5 - 1) / 9 * 100 * 100).round() / 100},
          {'mark': 1, 'min_pct': 0},
        ],
      },
    });
    final r = ten.quarter([g(10, null, 'fo').input, g(8, null, 'fo').input]);
    expect(r.fo, closeTo(88.89, 0.01));
    expect(r.mark, 9);
  });

  test('pilot 1–10 tones: 1–3 poor, 4–7 fair, 8 good, 9–10 excellent', () {
    final ten = Grading.fromSchool({
      'grading_config': {'min': 1, 'max': 10, 'passing': 4, 'quality_min': 8},
    });
    expect(
      [for (var v = 1; v <= 10; v++) ten.tone(v)],
      [
        ...List.filled(3, GradeTone.poor),
        ...List.filled(4, GradeTone.fair),
        GradeTone.good,
        GradeTone.excellent,
        GradeTone.excellent,
      ],
    );
  });

  test('summary prefers the school effective_mark, else the formula (never a plain average)', () {
    final grades = [g(5, null, 'fo'), g(2, null, 'fo'), g(18, 20, 'soch', course: 'c2')];
    final list = summarizeQuarter(
      grades: grades,
      periods: const [PeriodGrade(courseId: 'c2', courseName: 'c2', effectiveMark: 5, percent: 90, isFinal: true)],
      grading: kz(),
      formulaKnown: true,
    );
    final c1 = list.firstWhere((s) => s.courseId == 'c1');
    final c2 = list.firstWhere((s) => s.courseId == 'c2');
    // c1: plain marks without max are informational in the KZ preset → no mark,
    // not the 3.5 a plain average would show.
    expect(c1.mark, isNull);
    expect(c2.mark, 5);
    expect(c2.official, isTrue);
    expect(c2.preliminary, isFalse);
  });

  test('a quarter that is over shows final marks even when the school never closed it', () {
    const open = [PeriodGrade(courseId: 'c1', courseName: 'c1', effectiveMark: 4, percent: 70)];
    List<SubjectSummary> sum({required bool ended}) =>
        summarizeQuarter(grades: [g(7, 10, 'fo')], periods: open, grading: kz(), formulaKnown: true, termEnded: ended);
    expect(sum(ended: false).single.isFinal, isFalse);
    expect(sum(ended: false).single.preliminary, isTrue);
    expect(sum(ended: true).single.isFinal, isTrue);
    expect(sum(ended: true).single.preliminary, isFalse);
    expect(sum(ended: true).single.mark, 4);
  });

  test('attention sort puts below-quality subjects first', () {
    final g5 = kz();
    final list = summarizeQuarter(
      grades: [
        g(9, 10, 'fo', course: 'a'),
        g(5, 10, 'fo', course: 'b'),
      ],
      periods: const [],
      grading: g5,
      formulaKnown: true,
    );
    expect(sortByAttention(list, g5).map((s) => s.courseId), ['b', 'a']);
  });

  test('«до N не хватает»', () {
    expect(toNextMark(kz(), 78), (mark: 5, missing: 7.0));
    expect(toNextMark(kz(), 90), isNull);
  });
}
