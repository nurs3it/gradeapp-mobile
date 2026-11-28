import '../../core/json.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/models.dart';

/// Where a child is, as the parent widget «Статус ребёнка» (W3) says it.
enum ChildKind {
  /// Checked in (or marked present at a lesson).
  inSchool,

  /// A school day with no check-in yet.
  notYet,

  /// Marked absent (or excused) for today's lessons.
  absent,

  /// No lessons today.
  noLessons,

  /// The day could not be loaded.
  unknown,
}

const _kindNames = {
  ChildKind.inSchool: 'in',
  ChildKind.notYet: 'notyet',
  ChildKind.absent: 'absent',
  ChildKind.noLessons: 'none',
  ChildKind.unknown: 'unknown',
};

/// One child in the widget snapshot (schema v2, `children`). Everything the
/// widget says is decided here: [text] is the status in the app language and
/// [gradesText] says how many grades are new — never which, so the widget can
/// sit on a lock screen.
class ChildStatus {
  const ChildStatus({
    required this.id,
    required this.name,
    required this.kind,
    required this.text,
    this.cls = '',
    this.since = '',
    this.newGrades = 0,
    this.gradesText = '',
    this.until,
    this.afterText = '',
  });

  final String id;
  final String name;
  final String cls;
  final ChildKind kind;

  /// «В школе с 07:52».
  final String text;

  /// `HH:MM` of the check-in, when known.
  final String since;
  final int newGrades;

  /// «2 новые оценки».
  final String gradesText;

  /// End of the last lesson today, while the child is still [ChildKind.inSchool]:
  /// the widget shows [afterText] from then on without waiting for the app.
  final DateTime? until;

  /// «Уроки закончились».
  final String afterText;

  Json toJson() => {
    'id': id,
    'name': name,
    'cls': cls,
    'kind': _kindNames[kind],
    'text': text,
    'since': since,
    'newGrades': newGrades,
    'gradesText': gradesText,
    if (until != null) 'until': until!.toUtc().toIso8601String(),
    if (until != null) 'afterText': afterText,
  };

  factory ChildStatus.fromJson(Json j) => ChildStatus(
    id: j.str('id'),
    name: j.str('name'),
    cls: j.str('cls'),
    kind: _kindNames.entries.where((e) => e.value == j.str('kind')).firstOrNull?.key ?? ChildKind.unknown,
    text: j.str('text'),
    since: j.str('since'),
    newGrades: (j.number('newGrades') ?? 0).toInt(),
    gradesText: j.str('gradesText'),
    until: DateTime.tryParse(j.str('until'))?.toLocal(),
    afterText: j.str('afterText'),
  );
}

/// Grades created after the parent last looked at «Оценки» (the app's own
/// `grades_seen_at`); never looked — the last two days. Counts only.
int newGradesCount(List<Grade> grades, DateTime now, DateTime? seenAt) => grades.where((g) {
  final created = g.createdAt;
  if (created == null) return false;
  return seenAt == null ? now.difference(created).inHours < 48 : created.isAfter(seenAt);
}).length;

/// The widget's line for one child on [day] (null — the day failed to load).
ChildStatus childStatusOf({
  required Child child,
  required LearnerDay? day,
  required DateTime now,
  required AppLocalizations l,
  DateTime? gradesSeenAt,
}) {
  ChildStatus make(
    ChildKind kind,
    String text, {
    String since = '',
    int grades = 0,
    DateTime? until,
    String afterText = '',
  }) => ChildStatus(
    id: child.id,
    name: child.shortName,
    cls: child.className ?? '',
    kind: kind,
    text: text,
    since: since,
    newGrades: grades,
    gradesText: kind == ChildKind.unknown ? '' : (grades > 0 ? l.wgChildNewGrades(grades) : l.wgChildNoNew),
    until: until,
    afterText: afterText,
  );
  if (day == null) return make(ChildKind.unknown, '');
  final grades = newGradesCount(day.recentGrades, now, gradesSeenAt);
  if (!day.lessons.any((x) => !x.isCancelled)) return make(ChildKind.noLessons, l.wgNoLessons, grades: grades);
  // «В школе» stops being true after the last lesson (there is no check-out).
  final lastEnd = day.lessons.where((x) => !x.isCancelled).map((x) => x.endsAt()).reduce((a, b) => a.isAfter(b) ? a : b);
  ChildStatus inSchool(String time) {
    final during = time.isEmpty ? l.wgChildInNoTime : l.wgChildIn(time);
    // Short on purpose: the small widget has three lines for the status.
    final after = l.wgChildDayOver;
    if (!now.isBefore(lastEnd)) return make(ChildKind.inSchool, after, since: time, grades: grades);
    return make(ChildKind.inSchool, during, since: time, grades: grades, until: lastEnd, afterText: after);
  }

  final checkedAt = day.checkIn?.checkedIn == true ? day.checkIn!.checkedAt : null;
  if (day.checkIn?.checkedIn == true) return inSchool(checkedAt == null ? '' : _clock(checkedAt));
  final marks = day.attendance.values.toList();
  if (marks.any((m) => m.status == Presence.present || m.status == Presence.tardy)) return inSchool('');
  if (marks.isNotEmpty) return make(ChildKind.absent, l.wgChildAbsent, grades: grades);
  return make(ChildKind.notYet, l.wgChildNotYet, grades: grades);
}

String _clock(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Children of a snapshot (empty for a v1 snapshot or a non-parent one).
List<ChildStatus> childrenOf(Json snapshot) => snapshot.list('children', ChildStatus.fromJson);

/// Which child a widget shows: the configured one, else the first.
ChildStatus? pickChild(Json snapshot, {String? id}) {
  final kids = childrenOf(snapshot);
  if (kids.isEmpty) return null;
  return kids.where((k) => k.id == id).firstOrNull ?? kids.first;
}

/// The selected child first, the rest in the given order.
List<Child> selectedFirst(List<Child> children, String? selectedId) => [
  ...children.where((c) => c.id == selectedId),
  ...children.where((c) => c.id != selectedId),
];
