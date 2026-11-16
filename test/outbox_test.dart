import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/offline/outbox.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/teacher/teacher_providers.dart';

/// Dio whose answers are scripted per path.
Dio fakeDio(Map<String, (int, Object?)> answers, List<String> calls) {
  final dio = Dio();
  dio.httpClientAdapter = _Adapter(answers, calls);
  return dio;
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.answers, this.calls);
  final Map<String, (int, Object?)> answers;
  final List<String> calls;

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<List<int>>? body, Future<void>? cancel) async {
    calls.add(o.path);
    final a = answers[o.path];
    if (a == null) throw DioException.connectionError(requestOptions: o, reason: 'offline');
    final (code, data) = a;
    return ResponseBody.fromString(
      data == null ? '' : '{"error":"$data","detail":"СОЧ"}',
      code,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

OutboxItem mark(String lesson, String student, String status) => OutboxItem(
  key: 'att:$lesson:$student',
  method: 'POST',
  path: '/attendance/mark/$lesson',
  data: {
    'lesson_id': lesson,
    'records': [
      {'student_id': student, 'status': status, 'code': ''},
    ],
  },
);

void main() {
  test('a refused write is kept with its reason, the rest is sent', () async {
    final calls = <String>[];
    final box = Outbox.memory()
      ..attach(fakeDio({'/attendance/mark/L1': (409, 'soch_lock'), '/attendance/mark/L2': (200, null)}, calls));
    final events = <OutboxItem>[];
    box.rejectedEvents.stream.listen(events.add);
    await box.add(mark('L1', 'a', 'absent'));
    await box.add(mark('L2', 'b', 'absent'));
    await box.flush();
    expect(box.pending, isEmpty);
    expect(box.rejected.single.reason, RejectReason.sochLock);
    expect(box.rejected.single.key, 'att:L1:a');
    expect(events.single.key, 'att:L1:a');
  });

  test('403 → forbidden; offline keeps everything queued in order', () async {
    final calls = <String>[];
    final box = Outbox.memory()..attach(fakeDio({'/attendance/mark/L1': (403, 'denied')}, calls));
    await box.add(mark('L1', 'a', 'absent'));
    await box.flush();
    expect(box.rejected.single.reason, RejectReason.forbidden);

    final offline = Outbox.memory()..attach(fakeDio({}, []));
    await offline.add(mark('L3', 'a', 'absent'));
    await offline.add(mark('L3', 'b', 'present'));
    await offline.flush();
    expect(offline.pending.length, 2);
    expect(offline.rejected, isEmpty);
  });

  test('retry re-sends a refused item; delete drops it; a new write to the cell clears the refusal', () async {
    final answers = <String, (int, Object?)>{'/attendance/mark/L1': (409, 'soch_lock')};
    final box = Outbox.memory()..attach(fakeDio(answers, []));
    await box.add(mark('L1', 'a', 'absent'));
    await box.flush();
    expect(box.rejected, hasLength(1));

    answers['/attendance/mark/L1'] = (200, null);
    await box.retry(box.rejected.single);
    expect(box.rejected, isEmpty);
    expect(box.pending, isEmpty);

    answers['/attendance/mark/L1'] = (409, 'soch_lock');
    await box.add(mark('L1', 'a', 'absent'));
    await box.flush();
    await box.remove(box.rejected.single);
    expect(box.state.isEmpty, isTrue);

    await box.add(mark('L1', 'a', 'absent'));
    await box.flush();
    answers.remove('/attendance/mark/L1'); // offline now
    await box.add(mark('L1', 'a', 'present'));
    await box.flush();
    expect(box.rejected, isEmpty, reason: 'the newer write supersedes the refusal');
    expect(box.pending.single.key, 'att:L1:a');
  });

  test('refused items survive as JSON (restart) with their reason', () {
    final item = mark('L1', 'a', 'absent').rejectedWith(RejectReason.sochLock, 'СОЧ');
    final back = OutboxItem.fromJson(item.toJson());
    expect(back.reason, RejectReason.sochLock);
    expect(back.detail, 'СОЧ');
    expect(back.isRejected, isTrue);
  });

  test('the lesson overlay marks refused students', () {
    final refused = OutboxItem(
      key: 'att:L1:a',
      method: 'POST',
      path: '/attendance/mark/',
      data: {
        'lesson_id': 'L1',
        'records': [
          {'student_id': 'a', 'status': 'absent', 'code': 'Н'},
        ],
      },
    ).rejectedWith(RejectReason.forbidden, null);
    final o = LessonOverlay.of(const [], 'L1', rejected: [refused]);
    expect(o.failed.keys, ['a']);
    expect(o.attendance, isEmpty);
    expect(Presence.values, contains(Presence.absent));
  });
}
