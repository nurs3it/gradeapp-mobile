import 'dart:math' as math;

import '../features/learner/models.dart' show Presence, presenceOf;
import 'json.dart';

/// School attendance code (Н/Б/П/О…) mapped to a status.
class AttendanceCode {
  const AttendanceCode({required this.code, required this.name, required this.status});
  final String code;
  final String name;
  final Presence status;

  factory AttendanceCode.fromJson(Json j) =>
      AttendanceCode(code: j.str('code'), name: j.str('name'), status: presenceOf(j.str('status')));
}

class WorkType {
  const WorkType({required this.code, required this.name, required this.kind});
  final String code;
  final String name;
  final String kind; // formative / sor / soch / other
  factory WorkType.fromJson(Json j) => WorkType(code: j.str('code'), name: j.str('name'), kind: j.str('kind'));
}

enum GradeTone { excellent, good, fair, poor }

/// Effective grading config of the active school (KZ preset + override).
class Grading {
  const Grading({
    required this.min,
    required this.max,
    required this.passing,
    required this.qualityMin,
    required this.workTypes,
    required this.attendanceCodes,
  });

  final int min;
  final int max;
  final int passing;

  /// Lowest «quality» mark (4 of 5): splits fair from good.
  final int qualityMin;
  final List<WorkType> workTypes;
  final List<AttendanceCode> attendanceCodes;

  /// Work types a teacher grades inside a lesson (СОР/СОЧ have own flows).
  List<WorkType> get lessonTypes => workTypes.where((w) => w.kind != 'sor' && w.kind != 'soch').toList();

  static const fallback = Grading(min: 1, max: 5, passing: 3, qualityMin: 4, workTypes: [], attendanceCodes: []);

  /// Human name of a work-type code (`fo` → «ФО»); unknown codes as is.
  String typeName(String code) => workTypes.where((w) => w.code == code).firstOrNull?.name ?? code;

  /// Same rule as the web journal (shared/lib/grading.ts → gradeTone).
  GradeTone tone(num v) {
    if (v < passing) return GradeTone.poor;
    if (v < qualityMin) return GradeTone.fair;
    if (qualityMin >= max) return GradeTone.excellent;
    return v >= (qualityMin + max) / 2 && v > qualityMin ? GradeTone.excellent : GradeTone.good;
  }

  factory Grading.fromSchool(Json school) {
    final cfg = (school['grading_config'] ?? school['grading_system'] ?? const <String, dynamic>{}) as Json;
    final max = cfg.number('max')?.toInt() ?? 5;
    final passing = cfg.number('passing')?.toInt() ?? (max * 0.6).ceil();
    return Grading(
      min: cfg.number('min')?.toInt() ?? 1,
      max: max,
      passing: passing,
      qualityMin: cfg.number('quality_min')?.toInt() ?? math.max(passing, math.min(max, 4)),
      workTypes: cfg.list('work_types', WorkType.fromJson),
      attendanceCodes: cfg.list('attendance_codes', AttendanceCode.fromJson),
    );
  }
}
