import '../../core/json.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../ui/tokens/colors.dart';
import '../common/models.dart';
import 'child_status.dart';

/// Who the widgets are for. Saved with the snapshot so a background refresh
/// (silent push) knows what to fetch without the UI.
class WidgetTarget {
  const WidgetTarget({required this.role, this.learnerId, this.staffId, this.who = ''});

  /// `student` / `parent` / `teacher`.
  final String role;
  final String? learnerId;
  final String? staffId;

  /// The child's first name for a parent; empty otherwise.
  final String who;

  Json toJson() => {'role': role, 'learner_id': learnerId, 'staff_id': staffId, 'who': who};

  static WidgetTarget? fromJson(Object? j) {
    if (j is! Map) return null;
    final role = j['role'] as String?;
    if (role == null) return null;
    return WidgetTarget(
      role: role,
      learnerId: j['learner_id'] as String?,
      staffId: j['staff_id'] as String?,
      who: (j['who'] as String?) ?? '',
    );
  }

  bool get usable => role == 'teacher' ? staffId != null : learnerId != null;
}

/// How many days ahead the snapshot reaches: enough for the next lesson after
/// a weekend even if the phone stays offline.
const snapshotDays = 4;

/// The data both native widget families draw (iOS WidgetKit, Android
/// AppWidget). Everything is decided here — labels in the app language, the
/// colour index of each subject, absolute times — so the native side only
/// lays out and never invents: it picks the lesson for *its* current time and
/// says «обновлено в …» from [generatedAt].
///
/// Schema version 2 (v1 + `children` for the parent widget «Статус ребёнка»,
/// W3). A v1 snapshot is still valid: the natives treat a missing `children`
/// as none. Keep ios/GradeAppWidgets/Snapshot.swift and
/// android/.../widgets/WidgetData.kt in step.
const snapshotVersion = 2;

Json buildSnapshot({
  required WidgetTarget target,
  required List<Lesson> lessons,
  required List<Homework> homework,
  required DateTime now,
  required AppLocalizations l,
  required String langCode,
  List<ChildStatus> children = const [],
}) {
  final today = dateOnly(now);
  final dates = [for (var i = 0; i < snapshotDays; i++) isoDate(today.add(Duration(days: i)))];
  final live = lessons.where((x) => !x.isCancelled).toList()
    ..sort((a, b) => '${a.date}${a.start}'.compareTo('${b.date}${b.start}'));
  final tomorrow = isoDate(today.add(const Duration(days: 1)));
  final due = homework.where((h) => h.dueDate == tomorrow && !h.isDone).toList();
  final teacher = target.role == 'teacher';
  return {
    'v': snapshotVersion,
    'role': target.role,
    'who': target.who,
    'lang': langCode,
    'generatedAt': now.toUtc().toIso8601String(),
    'generatedLabel': _clock(now),
    'labels': {
      'next': l.wgNext,
      'nextShort': l.wgNextShort,
      'now': l.wgNow,
      'day': l.wgDay,
      'updated': l.wgUpdated(_clock(now)),
      'stale': l.wgStale,
      'noMore': l.wgNoMore,
      'noLessons': l.wgNoLessons,
      'homework': l.wgHomeworkTomorrow,
      'noHomework': l.wgNoHomework,
      'signedOut': l.wgSignedOut,
      'tomorrow': l.wgTomorrow,
      'startsIn': l.wgStartsIn,
      'endsIn': l.wgEndsIn,
      // `%s` is replaced natively.
      'roomFmt': l.room('%s'),
      'minFmt': l.minutesShort(0).replaceFirst('0', '%s'),
    },
    'days': [
      for (final d in dates)
        {
          'date': d,
          'lessons': [
            for (final x in live.where((x) => x.date == d))
              {
                'id': x.id,
                'subject': x.subject,
                'start': hm(x.start),
                'end': hm(x.end),
                'room': x.room ?? '',
                // Teacher: the class matters more than the teacher's name.
                'cls': teacher ? (x.classGroupName ?? '') : '',
                'ci': subjectIndex(x.colorKey),
              },
          ],
        },
    ],
    'homework': {
      'date': tomorrow,
      'minutes': due.fold<int>(0, (s, h) => s + (h.minutes ?? 0)),
      'items': [
        for (final h in due.take(4)) {'course': h.courseName, 'title': h.title},
      ],
    },
    // W3: one entry per child, the selected one first; status only, never a
    // grade value.
    if (target.role == 'parent') 'children': [for (final c in children) c.toJson()],
  };
}

/// The empty snapshot of a signed-out phone: widgets say «Войдите».
Json signedOutSnapshot(AppLocalizations l, String langCode, DateTime now) => {
  'v': snapshotVersion,
  'role': 'none',
  'who': '',
  'lang': langCode,
  'generatedAt': now.toUtc().toIso8601String(),
  'generatedLabel': _clock(now),
  'labels': {'signedOut': l.wgSignedOut},
  'days': const <Object>[],
  'homework': const {'date': '', 'minutes': 0, 'items': <Object>[]},
};

String _clock(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// What a widget shows at [at]: the lesson in progress, else the next one.
/// Mirrors the native pickers; used for tests and the in-app preview of the
/// rule «never lie when stale».
({Json? lesson, bool now, bool stale}) pickLesson(Json snapshot, DateTime at) {
  final generated = DateTime.tryParse('${snapshot['generatedAt']}')?.toLocal();
  final stale = generated == null || at.difference(generated) > const Duration(hours: 24);
  Json? next;
  for (final day in (snapshot['days'] as List<dynamic>? ?? const []).whereType<Json>()) {
    final date = '${day['date']}';
    for (final x in (day['lessons'] as List<dynamic>? ?? const []).whereType<Json>()) {
      final start = DateTime.parse(date).add(Duration(minutes: minutesOf('${x['start']}')));
      final end = DateTime.parse(date).add(Duration(minutes: minutesOf('${x['end']}')));
      if (!at.isBefore(start) && at.isBefore(end)) return (lesson: {...x, 'date': date}, now: true, stale: stale);
      if (next == null && start.isAfter(at)) next = {...x, 'date': date};
    }
  }
  return (lesson: next, now: false, stale: stale);
}
