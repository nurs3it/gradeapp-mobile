import 'dart:async';

import 'package:flutter/services.dart';

/// Haptics by meaning (design-system §2.7). One haptic per action at most.
/// Notification-style feedback (success / warning / error) goes through a
/// tiny platform channel: `UINotificationFeedbackGenerator` on iOS,
/// `HapticFeedbackConstants.CONFIRM / REJECT` on Android.
abstract final class GHaptics {
  static const _channel = MethodChannel('kz.gradeapp/haptics');

  /// Tab, segment, filter, arrow keys.
  static void selection() => unawaited(HapticFeedback.selectionClick());

  /// Attendance toggle, homework done, swipe threshold.
  static void light() => unawaited(HapticFeedback.lightImpact());

  /// Grade placed, long press opened the codes.
  static void medium() => unawaited(HapticFeedback.mediumImpact());

  /// Check-in done, lesson finished, request sent.
  static void success() => _notify('success', HapticFeedback.mediumImpact);

  /// Rejected by the server (outside_area, soch_lock, 403).
  static void error() => _notify('error', HapticFeedback.heavyImpact);

  /// Grading an absent student.
  static void warning() => _notify('warning', HapticFeedback.mediumImpact);

  static void _notify(String kind, Future<void> Function() fallback) {
    unawaited(
      _channel.invokeMethod<void>('notify', kind).catchError((Object _) => fallback()),
    );
  }
}
