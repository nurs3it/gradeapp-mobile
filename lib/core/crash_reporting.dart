import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'env.dart';
import 'storage/json_cache.dart';

/// Limits of the backend contract (`POST /api/analytics/crashes/`); the
/// server cuts again after its own scrubbing.
const crashMessageMax = 500;
const crashStackMax = 8000;
const crashQueueMax = 20;

final _jwt = RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]+');
final _bearer = RegExp(r'(bearer|token|password|secret|authorization)(["\x27=: ]+)\S+', caseSensitive: false);
final _email = RegExp(r'[\w.+-]{1,64}@[\w-]{1,63}\.[\w.-]{1,63}');
// 10+ digits with optional spaces, dashes and brackets; not part of a word or
// of `file.dart:12:3` positions.
final _phone = RegExp(r'(?<![\w:])\+?\d(?:[\s()-]?\d){9,}(?!\w)');
final _query = RegExp(r'\?[^\s)"\x27]*|#[\w-]{8,}');

/// `https://host/path?token=…#x` → `https://host/path`: query strings carry
/// ids and tokens, and a stack trace needs neither.
String scrubUrl(String url) {
  final cut = url.indexOf(RegExp('[?#]'));
  return cut < 0 ? url : url.substring(0, cut);
}

/// Strips what could identify a person from free text: tokens, e-mails, phone
/// numbers, query strings. Then cuts to [limit]. The cut comes last so it can
/// never leave half of a secret in the text.
String scrubText(String text, int limit) {
  var s = text
      .replaceAll(_jwt, '<jwt>')
      .replaceAllMapped(_bearer, (m) => '${m[1]}=<redacted>')
      .replaceAll(_email, '<email>')
      .replaceAll(_phone, '<number>')
      .replaceAll(_query, '?<query>');
  if (s.length > limit) s = s.substring(0, limit);
  return s;
}

/// One error, already scrubbed. No user, no device id, nothing else.
class CrashReport {
  const CrashReport({required this.errorType, required this.message, required this.stack, required this.fatal});

  factory CrashReport.from(Object error, StackTrace? stack, {required bool fatal}) => CrashReport(
    errorType: scrubText(error.runtimeType.toString(), 120),
    message: scrubText(error.toString(), crashMessageMax),
    stack: scrubText((stack ?? StackTrace.empty).toString(), crashStackMax),
    fatal: fatal,
  );

  final String errorType;
  final String message;
  final String stack;
  final bool fatal;

  Map<String, Object?> toJson() => {'error_type': errorType, 'message': message, 'stack': stack, 'fatal': fatal};

  static CrashReport? fromJson(Object? j) {
    if (j is! Map || j['error_type'] is! String) return null;
    return CrashReport(
      errorType: scrubText(j['error_type'] as String, 120),
      message: scrubText('${j['message'] ?? ''}', crashMessageMax),
      stack: scrubText('${j['stack'] ?? ''}', crashStackMax),
      fatal: j['fatal'] == true,
    );
  }
}

/// Crash reports to our own backend (children's data never goes to a third
/// party, `docs/product/privacy.md`). A small queue (≤ [maxQueue], oldest
/// dropped) survives a restart; sending needs no sign-in. Never throws.
class CrashReporter {
  CrashReporter({
    required Dio dio,
    JsonCache? store,
    String? platform,
    String version = appVersion,
    String? osVersion,
    this.maxQueue = crashQueueMax,
    this.delay = const Duration(seconds: 2),
  }) : _dio = dio,
       _store = store,
       _platform = platform ?? (Platform.isIOS ? 'ios' : 'android'),
       _version = version,
       _os = osVersion ?? _osVersion();

  static const _key = 'crash_queue';

  final Dio _dio;
  final JsonCache? _store;
  final String _platform;
  final String _version;
  final String _os;
  final int maxQueue;
  final Duration delay;

  final _queue = <CrashReport>[];
  final _seen = <String, DateTime>{};
  Timer? _timer;
  Future<void>? _sending;
  Future<void>? _loading;

  List<CrashReport> get pending => List.unmodifiable(_queue);

  static String _osVersion() => scrubText(Platform.operatingSystemVersion, 32);

  /// Queues an error and schedules sending; the same error is not queued
  /// twice within a minute (a broken widget repeats itself every frame).
  void record(Object error, StackTrace? stack, {required bool fatal}) {
    try {
      final r = CrashReport.from(error, stack, fatal: fatal);
      final sig = '${r.errorType}|${r.message}';
      final last = _seen[sig];
      final now = DateTime.now();
      if (last != null && now.difference(last) < const Duration(minutes: 1)) return;
      _seen[sig] = now;
      if (_seen.length > 50) _seen.remove(_seen.keys.first);
      _queue.add(r);
      if (_queue.length > maxQueue) _queue.removeRange(0, _queue.length - maxQueue);
      unawaited(_persist());
      _timer ??= Timer(delay, () {
        _timer = null;
        unawaited(flush());
      });
    } on Object {
      // Reporting must never be the reason for another crash.
    }
  }

  Future<void> _load() => _loading ??= _read();

  Future<void> _read() async {
    try {
      final raw = await _store?.read(_key);
      if (raw is List) {
        _queue.insertAll(0, raw.map(CrashReport.fromJson).whereType<CrashReport>());
        if (_queue.length > maxQueue) _queue.removeRange(0, _queue.length - maxQueue);
      }
    } on Object {
      // A broken store is an empty queue.
    }
  }

  Future<void> _persist() async {
    try {
      await _load();
      await _store?.write(_key, [for (final r in _queue) r.toJson()]);
    } on Object {
      // the queue is a convenience, not a record
    }
  }

  /// Sends the queue in one request. 204 or a refusal (400/413) empties it;
  /// no network, 429 or 5xx keep it for the next start.
  Future<void> flush() => _sending ??= _flush().whenComplete(() => _sending = null);

  Future<void> _flush() async {
    await _load();
    if (_queue.isEmpty) return;
    final chunk = _queue.take(maxQueue).toList();
    try {
      await _dio.post<void>(
        '/analytics/crashes/',
        data: {
          'platform': _platform,
          'app_version': _version,
          'os_version': _os,
          'crashes': [for (final r in chunk) r.toJson()],
        },
        options: Options(sendTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)),
      );
      _queue.removeRange(0, chunk.length);
    } on Object catch (e) {
      final code = e is DioException ? e.response?.statusCode : null;
      if (code != null && code >= 400 && code < 500 && code != 429 && code != 404) {
        // The server refuses this batch: dropping beats looping.
        _queue.removeRange(0, chunk.length);
      }
    }
    await _persist();
  }

  void dispose() => _timer?.cancel();
}

/// The reporter of this process (set by [runWithCrashReporting]).
CrashReporter? crashReporter;

/// Debug builds only: raises an unhandled error to check the pipeline end to
/// end (long-press on the version row in the profile). Does nothing in release.
void debugTestCrash() {
  if (!kDebugMode) return;
  unawaited(
    Future<void>.delayed(
      Duration.zero,
      () => throw StateError('GradeApp debug test crash for user a.popov@goso-demo.kz +7 701 123 45 67 /x?token=abc'),
    ),
  );
}

/// Runs [app] with the first-party reporter: framework errors
/// (`FlutterError.onError`), uncaught async errors
/// (`PlatformDispatcher.onError`) and errors of the app's own zone all go to
/// [crashReporter]. Without it nothing is sent anywhere.
Future<void> runWithCrashReporting(FutureOr<void> Function() app) async {
  WidgetsFlutterBinding.ensureInitialized();
  final reporter = crashReporter ??= CrashReporter(
    dio: Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    ),
    store: await _openStore(),
  );
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    reporter.record(details.exception, details.stack, fatal: false);
    if (previous != null) {
      previous(details);
    } else {
      FlutterError.presentError(details);
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.record(error, stack, fatal: true);
    // Handled: the process keeps running; the console still shows it.
    debugPrint('Uncaught: $error\n$stack');
    return true;
  };
  // What an earlier run could not send.
  unawaited(reporter.flush());
  await app();
}

Future<JsonCache?> _openStore() async {
  try {
    return await JsonCache.open('crashes');
  } on Object {
    return null;
  }
}
