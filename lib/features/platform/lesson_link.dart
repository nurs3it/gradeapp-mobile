/// «Все на месте» from the lock screen (W5): the Live Activity and the
/// ongoing notification open the lesson with `all_present=1`
/// (`gradeapp://app/lesson/<id>?all_present=1`; the app route has no host).
const allPresentParam = 'all_present';

/// App route of a lesson, with the roll-call request when [allPresent].
String lessonPath(String lessonId, {bool allPresent = false}) => allPresent
    ? '/lesson/${Uri.encodeComponent(lessonId)}?$allPresentParam=1'
    : '/lesson/${Uri.encodeComponent(lessonId)}';

class LessonLink {
  const LessonLink(this.lessonId, {this.allPresent = false});
  final String lessonId;
  final bool allPresent;

  @override
  bool operator ==(Object other) => other is LessonLink && other.lessonId == lessonId && other.allPresent == allPresent;

  @override
  int get hashCode => Object.hash(lessonId, allPresent);
}

/// Reads `gradeapp://app/lesson/<id>[?all_present=1]`, the bare route
/// `/lesson/<id>[?…]` go_router sees, and the web `…/teacher/lesson/<id>`.
/// Anything else is null. Only the exact value `1` asks for the roll call.
LessonLink? parseLessonLink(Uri uri) {
  final seg = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final at = seg.indexOf('lesson');
  if (at < 0 || at + 1 >= seg.length) return null;
  // `teacher/lesson/<id>` on the web, `lesson/<id>` in the app.
  if (at > 0 && !(at == 1 && seg.first == 'teacher')) return null;
  return LessonLink(seg[at + 1], allPresent: uri.queryParameters[allPresentParam] == '1');
}

/// A lesson-id the roll call was already sent for. A second open of the same
/// link (a double tap, the app coming back to the foreground with the intent
/// still attached) must not send again; the roll-call itself only writes
/// unsaved students, this is the second guard for the gap before the queue
/// shows them as saved.
class AllPresentGate {
  AllPresentGate({this.window = const Duration(minutes: 10)});
  final Duration window;
  final _at = <String, DateTime>{};

  /// True the first time within [window]; false for repeats.
  bool claim(String lessonId, DateTime now) {
    final last = _at[lessonId];
    if (last != null && now.difference(last) < window) return false;
    _at[lessonId] = now;
    return true;
  }

  /// The request found nothing to do (not loaded, locked): leave it claimable.
  void release(String lessonId) => _at.remove(lessonId);
}

final allPresentGate = AllPresentGate();
