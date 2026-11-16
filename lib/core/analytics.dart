import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import 'api/api_client.dart';
import 'env.dart';
import 'providers.dart';
import 'storage/json_cache.dart';

/// Event names the backend accepts (`CONTRACTS-stage2.md`, first-party
/// analytics). Anything else is not even queued.
abstract final class AnalyticsEvents {
  static const appOpen = 'app_open';
  static const login = 'login';
  static const checkinStart = 'checkin_start';
  static const checkinSuccess = 'checkin_success';
  static const checkinFail = 'checkin_fail';
  static const rollCallDone = 'roll_call_done';
  static const homeworkCreated = 'homework_created';
  static const pushOpen = 'push_open';
  static const excuseSent = 'excuse_sent';
  static const reportCardDownload = 'report_card_download';
  static const feedbackSent = 'feedback_sent';

  static const all = {
    appOpen,
    login,
    checkinStart,
    checkinSuccess,
    checkinFail,
    rollCallDone,
    homeworkCreated,
    pushOpen,
    excuseSent,
    reportCardDownload,
    feedbackSent,
  };

  /// The only property keys the server stores: `reason` (checkin_fail),
  /// `seconds` and `absent` (roll_call_done), `type` (push_open).
  static const props = {'reason', 'seconds', 'absent', 'type'};
}

class AnalyticsEvent {
  const AnalyticsEvent(this.name, this.at, [this.props = const {}]);
  final String name;
  final DateTime at;
  final Map<String, Object> props;

  Map<String, Object?> toJson() => {'name': name, 'at': at.toUtc().toIso8601String(), 'props': props};

  static AnalyticsEvent? fromJson(Object? j) {
    if (j is! Map) return null;
    final name = j['name'];
    final at = DateTime.tryParse('${j['at']}');
    if (name is! String || at == null || !AnalyticsEvents.all.contains(name)) return null;
    return AnalyticsEvent(name, at, cleanProps(j['props']));
  }
}

/// Whitelisted keys, scalar values only (strings cut short): no free text and
/// nothing that identifies a child can slip into an event.
final _slug = RegExp(r'^[a-z0-9_.-]{1,40}$');

Map<String, Object> cleanProps(Object? raw) {
  if (raw is! Map) return const {};
  final out = <String, Object>{};
  for (final e in raw.entries) {
    final k = e.key;
    final v = e.value;
    if (k is! String || !AnalyticsEvents.props.contains(k)) continue;
    if (v is num) {
      out[k] = v;
    } else if (v is bool) {
      out[k] = v;
    } else if (v is String && _slug.hasMatch(v)) {
      // The server only stores [a-z0-9_.-]{1,40}: codes, never free text.
      out[k] = v;
    }
  }
  return out;
}

/// First-party usage events: `POST /analytics/events/`. No user id leaves the
/// phone, no third party sees anything (children's app). Fire-and-forget:
/// events wait in a small queue (memory + prefs), go out in batches of ≤ 50
/// and are dropped, never retried forever; while the endpoint is missing (404)
/// or the user is signed out nothing is sent.
class Analytics {
  Analytics({
    required Dio dio,
    required bool Function() canSend,
    JsonCache? store,
    String? platform,
    String version = appVersion,
    DateTime Function()? clock,
    this.maxQueue = 100,
    this.batch = 50,
    this.delay = const Duration(seconds: 5),
  }) : _dio = dio,
       _canSend = canSend,
       _store = store,
       _platform = platform ?? (Platform.isIOS ? 'ios' : 'android'),
       _version = version,
       _clock = clock ?? DateTime.now;

  static const _key = 'analytics_queue';
  static const retryAfter404 = Duration(minutes: 30);

  final Dio _dio;
  final bool Function() _canSend;
  final JsonCache? _store;
  final String _platform;
  final String _version;
  final DateTime Function() _clock;
  final int maxQueue;
  final int batch;
  final Duration delay;

  final _queue = <AnalyticsEvent>[];
  Timer? _timer;
  Future<void>? _sending;
  DateTime? _offUntil;
  Future<void>? _loading;

  List<AnalyticsEvent> get pending => List.unmodifiable(_queue);

  /// Queue an event; never throws, never waits.
  void track(String name, [Map<String, Object?> props = const {}]) {
    if (!AnalyticsEvents.all.contains(name)) return;
    _queue.add(AnalyticsEvent(name, _clock(), cleanProps(props)));
    if (_queue.length > maxQueue) _queue.removeRange(0, _queue.length - maxQueue);
    unawaited(_persist());
    _timer ??= Timer(delay, () {
      _timer = null;
      unawaited(flush());
    });
  }

  Future<void> _load() => _loading ??= _read();

  Future<void> _read() async {
    final raw = await _store?.read(_key);
    if (raw is List) {
      // track() may have run (and persisted) before the store was read.
      final old = raw
          .map(AnalyticsEvent.fromJson)
          .whereType<AnalyticsEvent>()
          .where((e) => !_queue.any((q) => q.name == e.name && q.at == e.at))
          .toList();
      _queue.insertAll(0, old);
      if (_queue.length > maxQueue) _queue.removeRange(0, _queue.length - maxQueue);
    }
  }

  Future<void> _persist() async {
    try {
      // Never overwrite what an earlier run left in the store.
      await _load();
      await _store?.write(_key, [for (final e in _queue) e.toJson()]);
    } on Object {
      // the queue is a convenience, not a record
    }
  }

  /// Sign-out: the next account must not inherit this one's events.
  Future<void> clear() async {
    _timer?.cancel();
    _timer = null;
    _queue.clear();
    await _persist();
  }

  void dispose() => _timer?.cancel();

  /// Sends what is queued, ≤ [batch] per request. Safe to call any time.
  Future<void> flush() => _sending ??= _flush().whenComplete(() => _sending = null);

  Future<void> _flush() async {
    await _load();
    final off = _offUntil;
    if (_queue.isEmpty || !_canSend() || (off != null && _clock().isBefore(off))) return;
    while (_queue.isNotEmpty) {
      final chunk = _queue.take(batch).toList();
      try {
        await _dio.post<void>(
          '/analytics/events/',
          data: {
            'events': [for (final e in chunk) e.toJson()],
            'platform': _platform,
            'app_version': _version,
          },
          options: Options(sendTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)),
        );
        _queue.removeRange(0, chunk.length);
      } catch (e) {
        final code = e is DioException ? e.response?.statusCode : null;
        if (code == 404) {
          // Not deployed yet: keep quiet, try again much later.
          _offUntil = _clock().add(retryAfter404);
        } else if (isOffline(e) || code == null || code >= 500 || code == 401 || code == 429) {
          // Keep for the next flush.
        } else {
          // The server refuses this batch (400): drop it, do not loop.
          _queue.removeRange(0, chunk.length);
        }
        break;
      }
    }
    await _persist();
  }
}

final analyticsProvider = Provider<Analytics>((ref) {
  final a = Analytics(
    dio: ref.watch(dioProvider),
    store: ref.watch(prefsProvider),
    canSend: () => ref.read(authProvider).value != null,
  );
  final life = AppLifecycleListener(onHide: () => unawaited(a.flush()), onResume: () => unawaited(a.flush()));
  ref
    ..onDispose(a.dispose)
    ..onDispose(life.dispose)
    ..listen(authProvider, (prev, next) {
      if (prev?.value != null && next.value == null) {
        unawaited(a.clear());
      } else if (prev?.value == null && next.value != null) {
        unawaited(a.flush());
      }
    });
  return a;
});
