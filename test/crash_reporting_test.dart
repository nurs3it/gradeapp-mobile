import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/crash_reporting.dart';
import 'package:gradeapp/core/storage/json_cache.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status);
  int status;
  final calls = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    calls.add(o);
    return ResponseBody.fromString('', status);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('scrubText', () {
    test('removes e-mails, phones, tokens and query strings', () {
      const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMifQ.c2lnbmF0dXJl';
      final out = scrubText(
        'user a.popov@goso-demo.kz called +7 701 123 45 67 / 87011234567 with Bearer abc.def $jwt '
        'GET https://grade-app.kz/api/grades/?student_id=42&token=zzz',
        1000,
      );
      expect(out, isNot(contains('goso-demo')));
      expect(out, isNot(contains('701')));
      expect(out, isNot(contains('87011234567')));
      expect(out, isNot(contains('abc.def')));
      expect(out, isNot(contains('eyJ')));
      expect(out, isNot(contains('student_id')));
      expect(out, isNot(contains('zzz')));
      expect(out, contains('<email>'));
      expect(out, contains('https://grade-app.kz/api/grades/?<query>'));
    });

    test('keeps stack frames readable', () {
      const frame = '#0      _LessonBodyState._rollCall (package:gradeapp/features/teacher/lesson_screen.dart:212:13)';
      expect(scrubText(frame, 1000), frame);
    });

    test('cuts after scrubbing, so a secret is never half-cut', () {
      final out = scrubText('${'x' * 495} a.b@c.kz', 500);
      expect(out.length, 500);
      expect(out, isNot(contains('@')));
      expect(scrubText('y' * 9000, crashStackMax), hasLength(crashStackMax));
    });

    test('scrubUrl drops query and fragment', () {
      expect(scrubUrl('https://grade-app.kz/api/grades/?student_id=abc&term=1'), 'https://grade-app.kz/api/grades/');
      expect(scrubUrl('https://grade-app.kz/api/me/#x'), 'https://grade-app.kz/api/me/');
      expect(scrubUrl('https://grade-app.kz/api/me/'), 'https://grade-app.kz/api/me/');
    });
  });

  group('CrashReport', () {
    test('is built scrubbed and bounded', () {
      final r = CrashReport.from(StateError('mail me: a@b.kz ${'z' * 900}'), StackTrace.current, fatal: true);
      expect(r.errorType, 'StateError');
      expect(r.message.length, lessThanOrEqualTo(crashMessageMax));
      expect(r.message, isNot(contains('a@b.kz')));
      expect(r.stack.length, lessThanOrEqualTo(crashStackMax));
      expect(r.toJson().keys, {'error_type', 'message', 'stack', 'fatal'});
    });
  });

  group('CrashReporter', () {
    late Directory dir;
    late _Adapter adapter;

    setUp(() => dir = Directory.systemTemp.createTempSync('crashq'));
    tearDown(() => dir.deleteSync(recursive: true));

    CrashReporter make({int status = 204, int max = 20}) {
      adapter = _Adapter(status);
      return CrashReporter(
        dio: Dio(BaseOptions(baseUrl: 'http://x/api'))..httpClientAdapter = adapter,
        store: JsonCache.inDirectory(dir),
        platform: 'android',
        version: '1.2.3',
        osVersion: 'Android 15',
        maxQueue: max,
        delay: const Duration(days: 1),
      );
    }

    test('sends the contract body and empties the queue on 204', () async {
      final r = make()..record(StateError('boom'), StackTrace.current, fatal: true);
      await r.flush();
      final body = adapter.calls.single.data as Map;
      expect(adapter.calls.single.path, '/analytics/crashes/');
      expect(body['platform'], 'android');
      expect(body['app_version'], '1.2.3');
      expect(body['os_version'], 'Android 15');
      final c = (body['crashes'] as List).single as Map;
      expect(c['error_type'], 'StateError');
      expect(c['fatal'], true);
      expect(r.pending, isEmpty);
      expect(body.containsKey('user'), isFalse);
      r.dispose();
    });

    test('keeps at most 20, dropping the oldest', () async {
      final r = make(status: 503, max: 20);
      for (var i = 0; i < 25; i++) {
        r.record(StateError('e$i'), null, fatal: false);
      }
      expect(r.pending, hasLength(20));
      expect(r.pending.first.message, contains('e5'));
      expect(r.pending.last.message, contains('e24'));
      r.dispose();
    });

    test('survives a restart when the server was unreachable', () async {
      final a = make(status: 503)..record(StateError('lost?'), null, fatal: true);
      await a.flush();
      expect(a.pending, hasLength(1));
      a.dispose();

      final b = make();
      await b.flush();
      final crashes = (adapter.calls.single.data as Map)['crashes'] as List;
      expect((crashes.single as Map)['message'], contains('lost?'));
      expect(b.pending, isEmpty);
      b.dispose();
    });

    test('a refusal (400) drops the batch, 429 keeps it', () async {
      final bad = make(status: 400)..record(StateError('x'), null, fatal: false);
      await bad.flush();
      expect(bad.pending, isEmpty);
      bad.dispose();

      final slow = make(status: 429)..record(StateError('y'), null, fatal: false);
      await slow.flush();
      expect(slow.pending, hasLength(1));
      slow.dispose();
    });

    test('the same error is not queued twice within a minute', () {
      final r = make();
      r.record(StateError('same'), null, fatal: false);
      r.record(StateError('same'), null, fatal: false);
      expect(r.pending, hasLength(1));
      r.dispose();
    });
  });
}
