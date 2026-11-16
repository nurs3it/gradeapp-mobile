import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../common/models.dart';

/// S8 «новое»: grades created after the learner last opened «Оценки».
/// The grades screen keeps showing the dots of its own visit ([previous]).
class GradesSeen {
  const GradesSeen({this.at, this.previous});
  final DateTime? at;
  final DateTime? previous;
}

class GradesSeenController extends Notifier<GradesSeen> {
  static const _key = 'grades_seen_at';

  @override
  GradesSeen build() {
    unawaited(_load());
    return const GradesSeen();
  }

  Future<void> _load() async {
    final raw = await ref.read(prefsProvider).read(_key);
    final at = raw is String ? DateTime.tryParse(raw) : null;
    if (at != null && state.at == null) state = GradesSeen(at: at, previous: at);
  }

  void markSeen() {
    final now = DateTime.now();
    state = GradesSeen(at: now, previous: state.at);
    unawaited(ref.read(prefsProvider).write(_key, now.toIso8601String()));
  }
}

final gradesSeenProvider = NotifierProvider<GradesSeenController, GradesSeen>(GradesSeenController.new);

/// New = created after [seenAt]; never visited — the last two days.
bool isNewGrade(Grade g, DateTime? seenAt) {
  final created = g.createdAt;
  if (created == null) return false;
  return seenAt == null ? DateTime.now().difference(created).inHours < 48 : created.isAfter(seenAt);
}
