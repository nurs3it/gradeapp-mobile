import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/storage/json_cache.dart';
import '../common/models.dart';

/// W6 «Мой учебный день»: the student's Live Activity (iOS, opt-in, only for
/// schools with `live_activity_enabled`). The app starts it on a school day
/// and keeps it current while open; the server (B6) starts it by push and
/// updates it at each bell. The state below is the B6 content-state contract.
class DayLiveState {
  const DayLiveState({
    required this.phase,
    required this.subject,
    required this.room,
    required this.startsAt,
    required this.endsAt,
    required this.nextSubject,
    required this.left,
    this.nextStartsAt,
  });

  /// before | lesson | break | done
  final String phase;
  final String subject;
  final String room;

  /// Unix seconds.
  final int startsAt;
  final int endsAt;
  final String nextSubject;
  final int? nextStartsAt;
  final int left;

  Map<String, Object?> toJson() => {
    'phase': phase,
    'subject': subject,
    'room': room,
    'startsAt': startsAt,
    'endsAt': endsAt,
    'nextSubject': nextSubject,
    'nextStartsAt': nextStartsAt,
    'left': left,
  };
}

int _unix(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

/// Today's picture at [now]: the running lesson, the next one (before the
/// first or in a break), or `done`. Null without lessons.
DayLiveState? dayLiveState(List<Lesson> lessons, DateTime now) {
  final active = lessons.where((l) => !l.isCancelled).toList()..sort((a, b) => a.startsAt().compareTo(b.startsAt()));
  if (active.isEmpty) return null;
  final left = active.where((l) => l.endsAt().isAfter(now)).length;
  final current = active.where((l) => !now.isBefore(l.startsAt()) && now.isBefore(l.endsAt())).firstOrNull;
  if (current != null) {
    final next = active.where((l) => !l.startsAt().isBefore(current.endsAt())).firstOrNull;
    return DayLiveState(
      phase: 'lesson',
      subject: current.subject,
      room: current.room ?? '',
      startsAt: _unix(current.startsAt()),
      endsAt: _unix(current.endsAt()),
      nextSubject: next?.subject ?? '',
      nextStartsAt: next == null ? null : _unix(next.startsAt()),
      left: left,
    );
  }
  final next = active.where((l) => l.startsAt().isAfter(now)).firstOrNull;
  if (next == null) {
    final last = active.last;
    return DayLiveState(
      phase: 'done',
      subject: '',
      room: '',
      startsAt: _unix(last.startsAt()),
      endsAt: _unix(last.endsAt()),
      nextSubject: '',
      left: 0,
    );
  }
  final after = active.where((l) => l.startsAt().isAfter(next.startsAt())).firstOrNull;
  return DayLiveState(
    phase: identical(next, active.first) ? 'before' : 'break',
    subject: next.subject,
    room: next.room ?? '',
    startsAt: _unix(next.startsAt()),
    endsAt: _unix(next.endsAt()),
    nextSubject: after?.subject ?? '',
    nextStartsAt: after == null ? null : _unix(after.startsAt()),
    left: left,
  );
}

/// The activity is started by the app no earlier than an hour before the
/// first lesson (the server's push-to-start comes 15 minutes before).
bool shouldStartDay(List<Lesson> lessons, DateTime now) {
  final s = dayLiveState(lessons, now);
  if (s == null || s.phase == 'done') return false;
  final first = lessons.where((l) => !l.isCancelled).map((l) => l.startsAt()).reduce((a, b) => a.isBefore(b) ? a : b);
  return !now.isBefore(first.subtract(const Duration(hours: 1)));
}

abstract final class DayLive {
  static const _ch = MethodChannel('kz.gradeapp/live');
  static const prefKey = 'day_live_on';
  static const _tokensKey = 'day_live_tokens';

  static Dio? _dio;
  static String? _studentId;
  static JsonCache? _prefs;
  static bool _bound = false;

  static bool get supported => !kIsWeb && Platform.isIOS;

  /// Off until the student turns it on.
  static Future<bool> enabled(JsonCache prefs) async => await prefs.read(prefKey) == true;

  /// Binds the token callbacks for the signed-in student and asks iOS for
  /// the push-to-start token and server-started activities.
  static Future<void> bind({required Dio dio, required String studentId, required JsonCache prefs}) async {
    _dio = dio;
    _studentId = studentId;
    _prefs = prefs;
    if (!supported || !await enabled(prefs)) return;
    if (!_bound) {
      _bound = true;
      _ch.setMethodCallHandler(_onNative);
    }
    await _native('dayObserve', const {});
  }

  /// Keeps the activity in step with today while the app is open.
  static Future<void> sync({required List<Lesson> lessons, required String firstName, required DateTime now}) async {
    final prefs = _prefs;
    if (!supported || prefs == null || !await enabled(prefs)) return;
    final s = dayLiveState(lessons, now);
    if (s == null) return;
    final create = shouldStartDay(lessons, now);
    await _native(create ? 'dayStart' : 'dayUpdate', {'name': firstName, 'state': s.toJson()});
  }

  static Future<void> setEnabled(bool on, {required JsonCache prefs}) async {
    await prefs.write(prefKey, on);
    _prefs = prefs;
    if (on) {
      final dio = _dio;
      final id = _studentId;
      if (dio != null && id != null) await bind(dio: dio, studentId: id, prefs: prefs);
      return;
    }
    await _native('dayEnd', const {});
    final tokens = ((await prefs.read(_tokensKey)) as List<dynamic>? ?? const []).whereType<String>();
    for (final t in tokens) {
      try {
        await _dio?.delete<void>('/push/live-activity/', data: {'token': t});
      } catch (_) {
        // The server drops dead tokens itself (410 from APNs).
      }
    }
    await prefs.write(_tokensKey, <String>[]);
  }

  static Future<dynamic> _onNative(MethodCall call) async {
    final args = (call.arguments as Map<dynamic, dynamic>?) ?? const {};
    final token = args['token'] as String?;
    if (token == null) return null;
    final kind = switch (call.method) {
      'dayToken' => 'update',
      'dayStartToken' => 'start',
      _ => null,
    };
    if (kind == null) return null;
    await _register(kind, token, args['activityId'] as String?);
    return null;
  }

  static Future<void> _register(String kind, String token, String? activityId) async {
    final dio = _dio;
    final id = _studentId;
    final prefs = _prefs;
    if (dio == null || id == null || prefs == null) return;
    try {
      await dio.post<void>(
        '/push/live-activity/',
        data: {'student': id, 'kind': kind, 'token': token, 'activity_id': ?activityId},
      );
      final tokens = {...((await prefs.read(_tokensKey)) as List<dynamic>? ?? const []).whereType<String>(), token};
      await prefs.write(_tokensKey, tokens.toList());
    } catch (e) {
      debugPrint('day live token: $e');
    }
  }

  static Future<void> _native(String method, Map<String, Object?> args) async {
    if (!supported) return;
    try {
      await _ch.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Tests.
    } on PlatformException catch (e) {
      debugPrint('day activity $method: ${e.message}');
    }
  }
}
