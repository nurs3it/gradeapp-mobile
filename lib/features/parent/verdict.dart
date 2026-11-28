import '../../core/grading.dart';
import '../common/models.dart';

/// Level of the parent's «итог дня» (design-system §3.26). Order = priority.
enum VerdictLevel { alarm, action, question, ok, noLessons }

enum AttentionKind {
  /// Absent from a lesson, no reason and no request — «Объяснить».
  absentNoReason,

  /// The school uses selfie check-in and the parent has not allowed it.
  noConsent,

  /// A request for today or later was declined — «Отпросить».
  excuseRejected,
}

class Attention {
  const Attention(this.kind, {this.lesson, this.excuse});
  final AttentionKind kind;
  final Lesson? lesson;
  final Excuse? excuse;
}

/// Everything the verdict sheet and the family card need, without strings.
class DayVerdict {
  const DayVerdict({
    required this.level,
    this.arrivedAt,
    this.late = false,
    this.lessonsDone = 0,
    this.lessonsTotal = 0,
    this.firstLesson,
    this.absent = const [],
    this.lowGrades = const [],
    this.attention = const [],
    this.pendingExcuse,
    this.excusedToday = false,
  });

  final VerdictLevel level;
  final DateTime? arrivedAt;
  final bool late;
  final int lessonsDone;
  final int lessonsTotal;

  /// Every lesson of the day has ended: «В школе» is no longer true.
  bool get dayOver => lessonsTotal > 0 && lessonsDone == lessonsTotal;
  final Lesson? firstLesson;

  /// Lessons marked absent without a reason or request.
  final List<Lesson> absent;
  final List<Grade> lowGrades;
  final List<Attention> attention;
  final Excuse? pendingExcuse;
  final bool excusedToday;
}

/// The rules of the parent's verdict (P1), explicit and tested
/// (`test/verdict_test.dart`). Each rule has a level and one action:
///
/// | Rule | Level | Action |
/// |---|---|---|
/// | no lessons today | noLessons | — |
/// | lessons started, no check-in, no attendance mark, no request (school uses check-in) | alarm | Отпросить |
/// | selfie check-in needs the parent's consent | action | Разрешить |
/// | a request for today or later was declined | action | Отпросить |
/// | absent without a reason | question | Объяснить |
/// | late check-in | question | — |
/// | a grade below passing today | question | — |
/// | otherwise | ok | Отпросить |
DayVerdict verdictOf(LearnerDay day, DateTime now, {required Grading grading, bool checkinEnabled = true}) {
  final today = day.date;
  final active = day.lessons.where((l) => !l.isCancelled).toList()..sort((a, b) => a.startMin.compareTo(b.startMin));
  final excuses = day.excuses;
  bool wholeDay(Excuse e, Set<ExcuseStatus> ok) =>
      e.scope != 'specific_lessons' && ok.contains(e.status) && e.covers(today);
  // «Отпрошен» only once approved; a pending request already calms the alarm.
  final excusedToday = excuses.any((e) => wholeDay(e, {ExcuseStatus.approved}));
  final requestedToday = excuses.any((e) => wholeDay(e, {ExcuseStatus.approved, ExcuseStatus.pending}));
  final pending = excuses.where((e) => e.status == ExcuseStatus.pending && e.endDate.compareTo(today) >= 0).firstOrNull;
  final rejected = excuses.where((e) => e.status == ExcuseStatus.rejected && e.endDate.compareTo(today) >= 0).toList();

  final checkIn = day.checkIn;
  final useCheckIn = checkinEnabled && (checkIn?.enabled ?? false);
  final attention = <Attention>[];

  final absent = <Lesson>[];
  for (final l in active) {
    final mark = day.attendance[l.id];
    if (mark == null || mark.status != Presence.absent) continue;
    final explained =
        mark.reason.isNotEmpty ||
        excuses.any(
          (e) =>
              e.status != ExcuseStatus.rejected &&
              e.status != ExcuseStatus.cancelled &&
              e.covers(today, lessonId: l.id),
        );
    if (!explained) {
      absent.add(l);
      attention.add(Attention(AttentionKind.absentNoReason, lesson: l));
    }
  }
  if (useCheckIn && !(checkIn?.consent ?? true) && !day.photoConsent) {
    attention.add(const Attention(AttentionKind.noConsent));
  }
  for (final e in rejected) {
    attention.add(Attention(AttentionKind.excuseRejected, excuse: e));
  }

  final lowGrades = day.recentGrades
      .where((g) => g.date == today && !g.isScore && grading.tone(g.value) == GradeTone.poor)
      .toList();
  final started = active.where((l) => !now.isBefore(l.startsAt())).toList();
  final done = active.where((l) => l.isPast(now)).length;
  final arrived = checkIn?.checkedIn ?? false;
  final anyPresent = day.attendance.values.any((m) => m.status == Presence.present || m.status == Presence.tardy);

  final base = DayVerdict(
    level: VerdictLevel.ok,
    arrivedAt: checkIn?.checkedAt,
    late: checkIn?.late ?? false,
    lessonsDone: done,
    lessonsTotal: active.length,
    firstLesson: active.firstOrNull,
    absent: absent,
    lowGrades: lowGrades,
    attention: attention,
    pendingExcuse: pending,
    excusedToday: excusedToday,
  );

  VerdictLevel level;
  if (active.isEmpty) {
    level = VerdictLevel.noLessons;
  } else if (useCheckIn &&
      (checkIn?.consent ?? false) &&
      !arrived &&
      started.isNotEmpty &&
      !anyPresent &&
      !requestedToday) {
    level = VerdictLevel.alarm;
  } else if (attention.any((a) => a.kind != AttentionKind.absentNoReason)) {
    level = VerdictLevel.action;
  } else if (absent.isNotEmpty || (arrived && base.late) || lowGrades.isNotEmpty) {
    level = VerdictLevel.question;
  } else {
    level = VerdictLevel.ok;
  }
  return DayVerdict(
    level: level,
    arrivedAt: base.arrivedAt,
    late: base.late,
    lessonsDone: done,
    lessonsTotal: active.length,
    firstLesson: base.firstLesson,
    absent: absent,
    lowGrades: lowGrades,
    attention: attention,
    pendingExcuse: pending,
    excusedToday: excusedToday,
  );
}
