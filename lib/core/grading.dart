import 'dart:math' as math;

import '../ui/widgets/grade_chip.dart' show GradeTone;
import 'json.dart';

export '../ui/widgets/grade_chip.dart' show GradeTone;

/// Attendance status as the backend names it.
enum Presence { present, absent, tardy, excused }

Presence presenceOf(String s) => switch (s) {
  'absent' => Presence.absent,
  'tardy' => Presence.tardy,
  'excused' => Presence.excused,
  _ => Presence.present,
};

/// School attendance code (Н/Б/П/О…) mapped to a status.
class AttendanceCode {
  const AttendanceCode({required this.code, required this.name, required this.status});
  final String code;
  final String name;
  final Presence status;

  factory AttendanceCode.fromJson(Json j) =>
      AttendanceCode(code: j.str('code'), name: j.str('name'), status: presenceOf(j.str('status')));
}

/// Assessment kind of a work type; drives the quarter formula.
enum WorkKind { formative, sor, soch, other }

class WorkType {
  const WorkType({required this.code, required this.name, required this.kind});
  final String code;
  final String name;
  final WorkKind kind;

  factory WorkType.fromJson(Json j) => WorkType(
    code: j.str('code'),
    name: j.str('name'),
    kind: WorkKind.values.asNameMap()[j.str('kind')] ?? WorkKind.other,
  );
}

/// One row of the «% → mark» table.
typedef CriterionRow = ({num mark, num minPct});

/// Weights of the quarter mark (ФО / СОР / СОЧ).
typedef QuarterFormula = ({double fo, double sor, double soch});

/// Result of the quarter formula; every part may be missing.
class QuarterResult {
  const QuarterResult({this.fo, this.sor, this.soch, this.percent, this.mark});
  final double? fo;
  final double? sor;
  final double? soch;
  final double? percent;
  final num? mark;

  static const empty = QuarterResult();
}

/// A grade as the quarter formula needs it.
typedef GradeInput = ({num value, num? maxValue, String type});

/// Effective grading config of the active school (KZ preset + overrides),
/// mirroring `backend/schools/grading.py` so the app shows the same numbers
/// as the web and the report card.
class Grading {
  const Grading({
    required this.min,
    required this.max,
    required this.passing,
    required this.qualityMin,
    required this.workTypes,
    required this.attendanceCodes,
    this.criterionScale = const [],
    this.criterionScaleGrade1 = const [],
    this.formula = (fo: 0.25, sor: 0.25, soch: 0.5),
    this.marksInQuarter = false,
    this.homeworkNorms = const {},
  });

  final num min;
  final num max;
  final num passing;

  /// Lowest «quality» mark: splits fair from good.
  final num qualityMin;
  final List<WorkType> workTypes;
  final List<AttendanceCode> attendanceCodes;
  final List<CriterionRow> criterionScale;
  final List<CriterionRow> criterionScaleGrade1;
  final QuarterFormula formula;
  final bool marksInQuarter;

  /// grade level → daily homework minutes (СанПиН).
  final Map<int, int> homeworkNorms;

  static const fallback = Grading(
    min: 2,
    max: 5,
    passing: 3,
    qualityMin: 4,
    workTypes: [],
    attendanceCodes: [],
    criterionScale: [(mark: 5, minPct: 85), (mark: 4, minPct: 65), (mark: 3, minPct: 40), (mark: 2, minPct: 0)],
  );

  /// Work types a teacher grades inside a lesson (СОР/СОЧ go through the web).
  List<WorkType> get lessonTypes => workTypes.where((w) => w.kind == WorkKind.formative).toList();

  /// Pad layout by scale (design-system §3.10): ≤ 5 marks inline chips,
  /// 6–10 the 2 × 5 dock pad, more — view only.
  int get scaleSize => (max - min).round() + 1;

  /// Integer marks of the scale, low to high.
  List<int> get marks => [for (var v = min.ceil(); v <= max.floor(); v++) v];

  String typeName(String code) => workTypes.where((w) => w.code == code).firstOrNull?.name ?? code;

  WorkKind kindOf(String code) => workTypes.where((w) => w.code == code).firstOrNull?.kind ?? _kindByCode(code);

  static WorkKind _kindByCode(String code) => switch (code) {
    'fo' => WorkKind.formative,
    'sor' => WorkKind.sor,
    'soch' => WorkKind.soch,
    _ => WorkKind.other,
  };

  /// Same rule as the web journal (`shared/lib/grading.ts → gradeTone`).
  /// Pilot 1–10 (passing 4, quality 8): 1–3 poor, 4–7 fair, 8 good, 9–10 excellent.
  GradeTone tone(num v) {
    if (v < passing) return GradeTone.poor;
    if (v < qualityMin) return GradeTone.fair;
    if (qualityMin >= max) return GradeTone.excellent;
    return v >= (qualityMin + max) / 2 && v > qualityMin ? GradeTone.excellent : GradeTone.good;
  }

  /// Tone of a scored work by its percent.
  GradeTone toneOfPercent(double pct, {int? gradeLevel}) => tone(pctToMark(pct, gradeLevel: gradeLevel) ?? min);

  /// Mark of a grade on the school scale (a scored work via the % table).
  num? markOf(num value, num? maxValue, {int? gradeLevel}) =>
      (maxValue != null && maxValue > 0) ? pctToMark(value / maxValue * 100, gradeLevel: gradeLevel) : value;

  /// Percent a grade contributes to the quarter (`grade_percent`).
  double? gradePercent(num value, num? maxValue) {
    if (maxValue != null && maxValue > 0) return _r2(value / maxValue * 100);
    if (marksInQuarter) return markPercent(value);
    return null;
  }

  double? markPercent(num v) {
    if (max <= min || v < min || v > max) return null;
    return _r2((v - min) / (max - min) * 100);
  }

  /// `pct_to_mark`: the first row (highest min_pct first) the percent reaches.
  num? pctToMark(double? pct, {int? gradeLevel}) {
    if (pct == null) return null;
    var scale = criterionScale.isEmpty ? fallback.criterionScale : criterionScale;
    if (gradeLevel == 1 && criterionScaleGrade1.isNotEmpty) scale = criterionScaleGrade1;
    final rows = [...scale]..sort((a, b) => b.minPct.compareTo(a.minPct));
    for (final r in rows) {
      if (pct >= r.minPct) return r.mark;
    }
    return rows.isEmpty ? null : rows.last.mark;
  }

  /// The quarter formula (`aggregate_component_percents` + `compute_quarter`):
  /// average percent per kind, weighted; missing parts are dropped and the
  /// remaining weights renormalised, so a quarter without СОЧ yet still gets a
  /// preliminary mark.
  QuarterResult quarter(Iterable<GradeInput> grades, {int? gradeLevel}) {
    final buckets = {WorkKind.formative: <double>[], WorkKind.sor: <double>[], WorkKind.soch: <double>[]};
    for (final g in grades) {
      final pct = gradePercent(g.value, g.maxValue);
      if (pct == null) continue;
      buckets[kindOf(g.type)]?.add(pct);
    }
    double? avg(List<double> v) => v.isEmpty ? null : _r2(v.reduce((a, b) => a + b) / v.length);
    final fo = avg(buckets[WorkKind.formative]!);
    final sor = avg(buckets[WorkKind.sor]!);
    final soch = avg(buckets[WorkKind.soch]!);
    final active = [(fo, formula.fo), (sor, formula.sor), (soch, formula.soch)].where((p) => p.$1 != null && p.$2 > 0);
    final weight = active.fold<double>(0, (s, p) => s + p.$2);
    if (active.isEmpty || weight == 0) return QuarterResult(fo: fo, sor: sor, soch: soch);
    final pct = _r2(active.fold<double>(0, (s, p) => s + p.$1! * p.$2) / weight);
    return QuarterResult(
      fo: fo,
      sor: sor,
      soch: soch,
      percent: pct,
      mark: pctToMark(pct, gradeLevel: gradeLevel),
    );
  }

  static double _r2(num v) => (v * 100).roundToDouble() / 100;

  factory Grading.fromSchool(Json school) {
    final cfg = (school['grading_config'] ?? school['grading_system'] ?? const <String, dynamic>{}) as Json;
    final max = cfg.number('max') ?? 5;
    final min = cfg.number('min') ?? 2;
    final passing = cfg.number('passing') ?? (max * 0.6).ceil();
    List<CriterionRow> rows(String key) =>
        cfg.list(key, (r) => (mark: r.number('mark') ?? 0, minPct: r.number('min_pct') ?? 0));
    final f = cfg['quarter_formula'];
    final formula = f is Json
        ? (
            fo: (f.number('fo') ?? 0).toDouble(),
            sor: (f.number('sor') ?? 0).toDouble(),
            soch: (f.number('soch') ?? 0).toDouble(),
          )
        : (fo: 0.25, sor: 0.25, soch: 0.5);
    return Grading(
      min: min,
      max: max,
      passing: passing,
      qualityMin: cfg.number('quality_min') ?? math.max(passing, math.min(max, 4)),
      workTypes: cfg.list('work_types', WorkType.fromJson),
      attendanceCodes: cfg.list('attendance_codes', AttendanceCode.fromJson),
      criterionScale: rows('criterion_scale'),
      criterionScaleGrade1: rows('criterion_scale_grade1'),
      formula: formula,
      marksInQuarter: cfg.flag('marks_in_quarter'),
      homeworkNorms: {
        for (final n in cfg.list('homework_norms', (r) => r))
          (n.number('grade_level') ?? 0).toInt(): (n.number('minutes') ?? 0).toInt(),
      },
    );
  }
}

/// Grade level from a class name: «10 «А»», «1A», «7Б» → 10, 1, 7.
int? gradeLevelOf(String? className) {
  final m = RegExp(r'^\s*(\d{1,2})').firstMatch(className ?? '');
  return m == null ? null : int.tryParse(m.group(1)!);
}

/// «9.0» → «9», «8.5» → «8,5» (decimal comma for ru/kk).
String fmtNum(num v, {String sep = ','}) {
  if (v == v.roundToDouble()) return v.round().toString();
  return v.toStringAsFixed(1).replaceAll('.', sep);
}
