import 'models.dart';

/// Where the day stands (design-system §3.14). Pure: computed from the cached
/// schedule, no network — the same logic will feed widgets later.
enum DayPhase {
  /// Before the first lesson.
  before,

  /// A lesson is running.
  lesson,

  /// Between two lessons.
  pause,

  /// All lessons are over.
  after,

  /// No lessons at all today.
  none,
}

class NowNext {
  const NowNext({
    required this.phase,
    this.current,
    this.next,
    this.upcoming = const [],
    this.minutes = 0,
    this.progress = 0,
    this.number = 0,
    this.isLast = false,
  });

  final DayPhase phase;

  /// Running lesson (also when it was cancelled — the hero shows that).
  final Lesson? current;

  /// Next lesson that takes place.
  final Lesson? next;

  /// Up to two lessons after [focus] (the fan of sheets under the hero).
  final List<Lesson> upcoming;

  /// Minutes to the bell (lesson) or to the next start (before / pause).
  final int minutes;

  /// 0…1 of the running lesson or pause.
  final double progress;

  /// 1-based number of the running lesson in the day.
  final int number;

  /// The running lesson is the last one.
  final bool isLast;

  /// The lesson the hero is about.
  Lesson? get focus => current ?? next;
}

int _ceilMinutes(Duration d) => (d.inSeconds / 60).ceil().clamp(0, 24 * 60);

NowNext computeNowNext(List<Lesson> lessons, DateTime now) {
  final day = [...lessons]..sort((a, b) => a.startMin.compareTo(b.startMin));
  final active = day.where((l) => !l.isCancelled).toList();
  if (day.isEmpty) return const NowNext(phase: DayPhase.none);

  final current = day.where((l) => l.isNow(now)).firstOrNull;
  final future = active.where((l) => now.isBefore(l.startsAt())).toList();
  final next = future.firstOrNull;
  final upcoming = future.skip(1).take(2).toList();

  if (current != null) {
    final total = current.endsAt().difference(current.startsAt()).inSeconds;
    final done = now.difference(current.startsAt()).inSeconds;
    return NowNext(
      phase: DayPhase.lesson,
      current: current,
      next: next,
      upcoming: [?next, ...upcoming].take(2).toList(),
      minutes: _ceilMinutes(current.endsAt().difference(now)),
      progress: total <= 0 ? 0 : done / total,
      number: active.indexOf(current) + 1,
      isLast: next == null,
    );
  }
  if (next == null) return NowNext(phase: active.isEmpty ? DayPhase.none : DayPhase.after);

  final previous = active.where((l) => l.isPast(now)).lastOrNull;
  if (previous == null) {
    return NowNext(
      phase: DayPhase.before,
      next: next,
      upcoming: upcoming,
      minutes: _ceilMinutes(next.startsAt().difference(now)),
    );
  }
  final gap = next.startsAt().difference(previous.endsAt()).inSeconds;
  final passed = now.difference(previous.endsAt()).inSeconds;
  return NowNext(
    phase: DayPhase.pause,
    next: next,
    upcoming: upcoming,
    minutes: _ceilMinutes(next.startsAt().difference(now)),
    progress: gap <= 0 ? 0 : passed / gap,
    number: active.indexOf(next) + 1,
  );
}
