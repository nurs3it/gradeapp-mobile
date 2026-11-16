import '../../core/grading.dart';
import '../common/models.dart';

/// One subject of a quarter as «Оценки» shows it (S6).
class SubjectSummary {
  const SubjectSummary({
    required this.courseId,
    required this.name,
    required this.grades,
    required this.quarter,
    this.mark,
    this.percent,
    this.official = false,
    this.isFinal = false,
  });

  final String courseId;
  final String name;

  /// Newest first.
  final List<Grade> grades;

  /// Component percents (server row when present, else the client formula).
  final QuarterResult quarter;

  /// Quarter mark: the school's `effective_mark`, else the preliminary one by
  /// the school formula. Never a plain average.
  final num? mark;
  final double? percent;

  /// The mark comes from `/grades/period/` (the same as the web and report card).
  final bool official;

  /// The quarter is closed for this subject.
  final bool isFinal;

  /// «предв.» under the mark while the quarter is still open.
  bool get preliminary => mark != null && !isFinal;

  int countOf(Grading g, WorkKind kind) => grades.where((x) => g.kindOf(x.type) == kind).length;
}

/// Groups a quarter's grades by subject and puts the quarter mark on each:
/// the server's `effective_mark` where it exists (S6-минимум), otherwise the
/// preliminary mark by the school formula (`Grading.quarter`).
List<SubjectSummary> summarizeQuarter({
  required List<Grade> grades,
  required List<PeriodGrade> periods,
  required Grading grading,
  required bool formulaKnown,
  int? gradeLevel,
}) {
  final byCourse = <String, List<Grade>>{};
  final names = <String, String>{};
  for (final g in grades) {
    (byCourse[g.courseId] ??= []).add(g);
    names[g.courseId] = g.courseName;
  }
  final periodBy = {for (final p in periods) p.courseId: p};
  for (final p in periods) {
    byCourse.putIfAbsent(p.courseId, () => []);
    names.putIfAbsent(p.courseId, () => p.courseName);
  }
  return [
    for (final e in byCourse.entries)
      () {
        final list = [...e.value]..sort((a, b) => b.date.compareTo(a.date));
        final p = periodBy[e.key];
        final computed = formulaKnown
            ? grading.quarter(list.map((x) => x.input), gradeLevel: gradeLevel)
            : QuarterResult.empty;
        final official = p?.effectiveMark != null;
        return SubjectSummary(
          courseId: e.key,
          name: names[e.key] ?? '—',
          grades: list,
          quarter: p == null
              ? computed
              : QuarterResult(fo: p.fo, sor: p.sor, soch: p.soch, percent: p.percent, mark: p.effectiveMark),
          mark: official ? p!.effectiveMark : computed.mark,
          percent: official ? p!.percent : computed.percent,
          official: official,
          isFinal: p?.isFinal ?? false,
        );
      }(),
  ];
}

/// «Сначала требующие внимания»: below the quality mark first, then by percent.
List<SubjectSummary> sortByAttention(List<SubjectSummary> list, Grading g) {
  int rank(SubjectSummary s) => s.mark == null ? 1 : (s.mark! < g.qualityMin ? 0 : 2);
  return [...list]..sort((a, b) {
    final r = rank(a).compareTo(rank(b));
    if (r != 0) return r;
    return (a.percent ?? 101).compareTo(b.percent ?? 101);
  });
}

/// Percent still missing to reach the next mark (S7 light, «до 9 не хватает 4 %»).
({num mark, double missing})? toNextMark(Grading g, double? percent, {int? gradeLevel}) {
  if (percent == null) return null;
  var scale = g.criterionScale;
  if (gradeLevel == 1 && g.criterionScaleGrade1.isNotEmpty) scale = g.criterionScaleGrade1;
  final above = scale.where((r) => r.minPct > percent).toList()..sort((a, b) => a.minPct.compareTo(b.minPct));
  if (above.isEmpty) return null;
  final next = above.first;
  return (mark: next.mark, missing: (next.minPct - percent).toDouble());
}

/// One-line insight (§3.23), only with 6+ works: strongest and weakest.
({SubjectSummary strong, SubjectSummary weak})? insightOf(List<SubjectSummary> list) {
  final rated = list.where((s) => s.percent != null).toList();
  final works = list.fold<int>(0, (n, s) => n + s.grades.length);
  if (rated.length < 2 || works < 6) return null;
  rated.sort((a, b) => b.percent!.compareTo(a.percent!));
  return (strong: rated.first, weak: rated.last);
}
