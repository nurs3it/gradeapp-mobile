/// What a push (or a local notification, or a tapped action button) asks the
/// app to do. Pure: parsing only, so it is tested without a device.
sealed class PushIntent {
  const PushIntent();
}

/// Tap on a notification or the «Открыть» button: route by the §4.3 map.
class OpenIntent extends PushIntent {
  const OpenIntent(this.data);
  final Map<String, dynamic> data;
}

/// «Объяснить пропуск» on `attendance.flagged`: excuse form for that miss.
class ExplainIntent extends PushIntent {
  const ExplainIntent({required this.studentId, this.attendanceId, this.date});
  final String? studentId;
  final String? attendanceId;

  /// `YYYY-MM-DD` when the push carries it.
  final String? date;
}

/// «Одобрить» on `excuse.pending`: `POST /excuses/<id>/approve/`.
class ApproveIntent extends PushIntent {
  const ApproveIntent(this.excuseId);
  final String excuseId;
}

/// Data-only `sync.today` / `sync.schedule`: refresh caches and widgets.
class SyncIntent extends PushIntent {
  const SyncIntent({required this.today, required this.schedule, this.studentId, this.date});
  final bool today;
  final bool schedule;
  final String? studentId;
  final String? date;
}

/// Action ids shared by the iOS categories and the Android buttons.
abstract final class PushActions {
  static const explain = 'EXPLAIN';
  static const approve = 'APPROVE';
  static const open = 'OPEN';

  static const attendanceCategory = 'ATTENDANCE_FLAGGED';
  static const excuseCategory = 'EXCUSE_PENDING';
}

/// Push types the Android app renders itself (data-only, with buttons).
const renderedTypes = {'attendance.flagged', 'excuse.pending'};

String? _s(Map<String, dynamic> d, String k) {
  final v = d[k];
  if (v == null) return null;
  final s = '$v';
  return s.isEmpty ? null : s;
}

/// [data] is `RemoteMessage.data` (or the payload of a local notification);
/// [actionId] the tapped button, null or the system default for a plain tap.
PushIntent intentFor(Map<String, dynamic> data, {String? actionId}) {
  final type = _s(data, 'type') ?? '';
  if (type == 'sync.today' || type == 'sync.schedule') {
    return SyncIntent(
      today: type == 'sync.today',
      schedule: type == 'sync.schedule',
      studentId: _s(data, 'student_id'),
      date: _s(data, 'date'),
    );
  }
  switch (actionId) {
    case PushActions.explain when type == 'attendance.flagged':
      final kind = _s(data, 'target_kind');
      return ExplainIntent(
        studentId: _s(data, 'student_id'),
        attendanceId: kind == null || kind == 'attendance' ? (_s(data, 'target_id') ?? _s(data, 'attendance_id')) : null,
        date: _s(data, 'date'),
      );
    case PushActions.approve when type == 'excuse.pending':
      final id = _s(data, 'excuse_id') ?? _s(data, 'target_id');
      if (id != null) return ApproveIntent(id);
  }
  return OpenIntent(data);
}

/// The system's default tap is not an action button.
bool isDefaultAction(String? id) => id == null || id.isEmpty || id.contains('DefaultActionIdentifier');
