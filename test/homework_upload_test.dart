import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/teacher/homework_upload.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.answer);
  final ResponseBody Function(RequestOptions o) answer;
  final calls = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    calls.add(o);
    return answer(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

const _lesson = Lesson(id: 'l1', courseId: 'c1', subject: 'Физика', date: '2026-11-17', start: '09:00', end: '09:45');

void main() {
  late Directory dir;
  late List<HomeworkFile> files;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('hw');
    files = [
      for (final n in ['a.jpg', 'b.pdf'])
        (() {
          File('${dir.path}/$n').writeAsStringSync('x');
          return HomeworkFile(path: '${dir.path}/$n', name: n);
        })(),
    ];
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Dio dioFor(_Adapter a) => Dio(BaseOptions(baseUrl: 'http://x/api'))..httpClientAdapter = a;

  test('the body is the same as the queued one', () {
    expect(homeworkBody(_lesson, title: 'T', description: 'D', due: '2026-11-18', minutes: 20), {
      'course': 'c1',
      'lesson': 'l1',
      'title': 'T',
      'description': 'D',
      'due_date': '2026-11-18',
      'estimated_minutes': 20,
    });
    expect(
      homeworkBody(_lesson, title: 'T', description: 'D', due: '2026-11-18'),
      isNot(contains('estimated_minutes')),
    );
  });

  test('creates the homework, then uploads every file to its attachments endpoint', () async {
    final a = _Adapter((o) => o.path == '/homework/' ? _json({'id': 'hw1'}, 201) : _json({'id': 'at'}, 201));
    final out = await createHomeworkWithFiles(
      dioFor(a),
      _lesson,
      title: 'T',
      description: 'D',
      due: '2026-11-18',
      files: files,
    );
    expect(out.state, HomeworkUpload.done);
    expect(a.calls.map((c) => c.path), ['/homework/', '/homework/hw1/attachments/', '/homework/hw1/attachments/']);
    final form = a.calls[1].data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'a.jpg');
  });

  test('a refused file does not stop the others and is reported', () async {
    final a = _Adapter((o) {
      if (o.path == '/homework/') return _json({'id': 'hw1'}, 201);
      final name = (o.data as FormData).files.single.value.filename;
      return name == 'a.jpg' ? _json({'error': 'File type not allowed'}, 400) : _json({'id': 'at'}, 201);
    });
    final out = await createHomeworkWithFiles(
      dioFor(a),
      _lesson,
      title: 'T',
      description: 'D',
      due: '2026-11-18',
      files: files,
    );
    expect(out.state, HomeworkUpload.filesFailed);
    expect(out.failedFiles.map((f) => f.name), ['a.jpg']);
    expect(a.calls, hasLength(3));
  });

  test('no network before the homework exists: nothing is uploaded, the caller queues the text', () async {
    final a = _Adapter((o) => throw DioException(requestOptions: o, type: DioExceptionType.connectionError));
    final out = await createHomeworkWithFiles(
      dioFor(a),
      _lesson,
      title: 'T',
      description: 'D',
      due: '2026-11-18',
      files: files,
    );
    expect(out.state, HomeworkUpload.offline);
    expect(a.calls, hasLength(1));
  });
}
