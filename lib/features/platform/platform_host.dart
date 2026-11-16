import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../learner/learner_providers.dart';
import '../teacher/teacher_providers.dart';
import 'lesson_live.dart';
import 'local_notifications.dart';
import 'platform_sync.dart';
import 'push_intent.dart';
import 'widget_snapshot.dart';

/// Who the widgets show right now, from the signed-in user, the active role
/// and (for a parent) the selected child. Null when signed out.
WidgetTarget? widgetTargetFor({AppUser? user, AppRole? role, String? learnerId, String? childName}) {
  if (user == null || role == null) return null;
  return switch (role) {
    AppRole.teacher => WidgetTarget(role: 'teacher', staffId: user.staffId),
    AppRole.student => WidgetTarget(role: 'student', learnerId: user.studentId),
    AppRole.parent => WidgetTarget(role: 'parent', learnerId: learnerId, who: childName ?? ''),
  };
}

/// App side of the platform features: keeps widgets, cache and reminders in
/// step with the account, role, child and silent pushes (W1, W2, W9, T10).
class PlatformHost {
  PlatformHost(this.ref);
  final WidgetRef ref;

  DateTime? _last;
  bool _busy = false;

  PlatformSync get _sync => PlatformSync(ref.read(dioProvider), ref.read(jsonCacheProvider), ref.read(prefsProvider));

  /// Refreshes cache + widgets + reminders. Throttled to once a minute
  /// unless [force]; [invalidate] also redraws the open screens.
  Future<void> refresh({bool force = false, bool invalidate = false}) async {
    final target = widgetTargetFor(
      user: ref.read(authProvider).value,
      role: ref.read(activeRoleProvider),
      learnerId: ref.read(learnerIdProvider),
      childName: ref.read(currentChildProvider)?.shortName,
    );
    if (target == null || !target.usable || _busy) return;
    final last = _last;
    if (!force && last != null && DateTime.now().difference(last) < const Duration(minutes: 1)) return;
    _busy = true;
    try {
      final l = await resolveL10n(ref.read(prefsProvider));
      final ok = await _sync.refresh(target: target, l: l, langCode: l.localeName);
      if (ok) _last = DateTime.now();
      if (ok && invalidate) invalidateSchedule();
    } finally {
      _busy = false;
    }
  }

  /// `sync.today` / `sync.schedule` while the app is open (W9).
  Future<void> onSync(SyncIntent intent) => refresh(force: true, invalidate: true);

  /// Screens that show lessons re-read the cache the sync just rewrote.
  void invalidateSchedule() {
    ref
      ..invalidate(learnerDayProvider)
      ..invalidate(weekLessonsProvider)
      ..invalidate(homeworkProvider)
      ..invalidate(teacherDayProvider)
      ..invalidate(teacherWeekProvider)
      ..invalidate(lessonProvider);
  }

  /// Sign-out: widgets, reminders and the lock-screen lesson go.
  Future<void> onSignedOut() async {
    final l = await resolveL10n(ref.read(prefsProvider));
    await _sync.clear(l, l.localeName);
    _last = null;
    final live = LessonLive.current;
    if (live != null) await LessonLive.finish(live.lessonId);
  }
}
