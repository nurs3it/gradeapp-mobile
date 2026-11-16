import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/analytics.dart';
import 'package:gradeapp/core/crash_reporting.dart';
import 'package:gradeapp/core/storage/json_cache.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.answer);
  ResponseBody Function(RequestOptions o) answer;
  final calls = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    calls.add(o);
    return answer(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _empty(int status) => ResponseBody.fromString('', status);

void main() {
  late _Adapter adapter;
  var signedIn = true;
  var now = DateTime.utc(2026, 11, 17, 9);

  Analytics make({JsonCache? store, int maxQueue = 100}) {
    adapter = _Adapter((_) => _empty(204));
    return Analytics(
      dio: Dio(BaseOptions(baseUrl: 'http://x/api'))..httpClientAdapter = adapter,
      canSend: () => signedIn,
      store: store,
      platform: 'android',
      version: '1.2.3',
      clock: () => now,
      maxQueue: maxQueue,
      delay: const Duration(hours: 1),
    );
  }

  setUp(() {
    signedIn = true;
    now = DateTime.utc(2026, 11, 17, 9);
  });

  test('props are whitelisted, scalar and short; unknown events are not queued', () {
    final a = make();
    a.track('roll_call_done', {
      'seconds': 95,
      'absent': 2,
      'student_name': 'Алия',
      'type': 'x' * 100,
      'list': [1],
    });
    a.track('made_up_event');
    expect(a.pending, hasLength(1));
    expect(a.pending.single.props, {'seconds': 95, 'absent': 2, 'type': 'x' * 40});
  });

  test('a flush sends the contract body and empties the queue', () async {
    final a = make();
    a.track(AnalyticsEvents.appOpen);
    a.track(AnalyticsEvents.checkinFail, {'reason': 'outside_geofence'});
    await a.flush();
    expect(a.pending, isEmpty);
    final call = adapter.calls.single;
    expect(call.method, 'POST');
    expect(call.path, '/analytics/events/');
    final body = call.data as Map<String, Object?>;
    expect(body['platform'], 'android');
    expect(body['app_version'], '1.2.3');
    final events = body['events']! as List<Object?>;
    expect(events, hasLength(2));
    expect(events.first, {'name': 'app_open', 'at': '2026-11-17T09:00:00.000Z', 'props': <String, Object?>{}});
    expect((events.last! as Map)['props'], {'reason': 'outside_geofence'});
    expect(jsonEncode(body), isNot(contains('user')));
  });

  test('more than 50 events go out in batches of 50', () async {
    final a = make(maxQueue: 200);
    for (var i = 0; i < 120; i++) {
      a.track(AnalyticsEvents.appOpen);
    }
    await a.flush();
    expect(adapter.calls.map((c) => ((c.data as Map)['events'] as List).length), [50, 50, 20]);
  });

  test('offline keeps the queue, the queue is capped, signed-out sends nothing', () async {
    final a = make(maxQueue: 3);
    adapter.answer = (o) => throw DioException(requestOptions: o, type: DioExceptionType.connectionError);
    for (var i = 0; i < 5; i++) {
      a.track(AnalyticsEvents.appOpen);
    }
    await a.flush();
    expect(a.pending, hasLength(3));
    expect(adapter.calls, hasLength(1));
    signedIn = false;
    adapter.answer = (_) => _empty(204);
    await a.flush();
    expect(adapter.calls, hasLength(1));
    signedIn = true;
    await a.flush();
    expect(a.pending, isEmpty);
  });

  test('a missing endpoint (404) keeps quiet for half an hour', () async {
    final a = make();
    adapter.answer = (_) => _empty(404);
    a.track(AnalyticsEvents.appOpen);
    await a.flush();
    await a.flush();
    expect(adapter.calls, hasLength(1));
    now = now.add(const Duration(minutes: 31));
    adapter.answer = (_) => _empty(204);
    await a.flush();
    expect(adapter.calls, hasLength(2));
    expect(a.pending, isEmpty);
  });

  test('a refused batch (400) is dropped instead of looping', () async {
    final a = make();
    adapter.answer = (_) => _empty(400);
    a.track(AnalyticsEvents.appOpen);
    await a.flush();
    expect(a.pending, isEmpty);
  });

  test('the queue survives a restart and is wiped at sign-out', () async {
    final dir = Directory.systemTemp.createTempSync('an');
    addTearDown(() => dir.deleteSync(recursive: true));
    final store = JsonCache.inDirectory(dir);
    final a = make(store: store);
    a.track(AnalyticsEvents.login);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final b = make(store: store);
    b.track(AnalyticsEvents.appOpen);
    await b.flush();
    expect((adapter.calls.single.data as Map)['events'], hasLength(2));
    final c = make(store: store);
    c.track(AnalyticsEvents.appOpen);
    await c.clear();
    expect(c.pending, isEmpty);
  });

  test('an event tracked before the store is read is not sent twice', () async {
    final dir = Directory.systemTemp.createTempSync('an');
    addTearDown(() => dir.deleteSync(recursive: true));
    final a = make(store: JsonCache.inDirectory(dir));
    a.track(AnalyticsEvents.appOpen);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await a.flush();
    expect((adapter.calls.single.data as Map)['events'], hasLength(1));
  });

  test('crash reports lose query strings from URLs', () {
    expect(scrubUrl('https://grade-app.kz/api/grades/?student_id=abc&term=1'), 'https://grade-app.kz/api/grades/');
    expect(scrubUrl('https://grade-app.kz/api/me/#x'), 'https://grade-app.kz/api/me/');
    expect(scrubUrl('https://grade-app.kz/api/me/'), 'https://grade-app.kz/api/me/');
    expect(scrubCrumbData({'url': 'https://x/a?token=1', 'method': 'GET', 'query': 'token=1', 'status_code': 200}), {
      'url': 'https://x/a',
      'method': 'GET',
      'status_code': 200,
    });
    expect(scrubCrumbData(null), isNull);
  });
}
