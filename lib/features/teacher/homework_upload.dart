import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../../core/json.dart';
import '../common/models.dart';

/// A photo or file the teacher attached to a homework.
class HomeworkFile {
  const HomeworkFile({required this.path, required this.name});
  final String path;
  final String name;
}

/// Body of `POST /homework/` — the same whether it goes through the queue or
/// straight to the server.
Map<String, Object?> homeworkBody(
  Lesson lesson, {
  required String title,
  required String description,
  required String due,
  int? minutes,
}) => {
  'course': lesson.courseId,
  'lesson': lesson.id,
  'title': title,
  'description': description,
  'due_date': due,
  'estimated_minutes': ?minutes,
};

enum HomeworkUpload {
  /// Homework and every file are on the server.
  done,

  /// Homework is created, some files did not go (see [HomeworkOutcome.failedFiles]).
  filesFailed,

  /// No network: nothing was created (the caller queues the text).
  offline,
}

class HomeworkOutcome {
  const HomeworkOutcome(this.state, {this.failedFiles = const []});
  final HomeworkUpload state;
  final List<HomeworkFile> failedFiles;
}

/// Files need the homework's id, so this goes online: create, then upload each
/// file to `/homework/<id>/attachments/`. A refused file does not stop the
/// others. Offline before the homework exists → [HomeworkUpload.offline].
Future<HomeworkOutcome> createHomeworkWithFiles(
  Dio dio,
  Lesson lesson, {
  required String title,
  required String description,
  required String due,
  required List<HomeworkFile> files,
  int? minutes,
  void Function(int sent, int total)? onProgress,
}) async {
  final String id;
  try {
    final res = await dio.post<Json>(
      '/homework/',
      data: homeworkBody(lesson, title: title, description: description, due: due, minutes: minutes),
    );
    id = res.data!.str('id');
  } on DioException catch (e) {
    if (isOffline(e)) return const HomeworkOutcome(HomeworkUpload.offline);
    rethrow;
  }
  final failed = <HomeworkFile>[];
  for (var i = 0; i < files.length; i++) {
    onProgress?.call(i, files.length);
    final f = files[i];
    try {
      await dio.post<void>(
        '/homework/$id/attachments/',
        data: FormData.fromMap({'file': await MultipartFile.fromFile(f.path, filename: f.name)}),
        options: Options(sendTimeout: const Duration(seconds: 60), receiveTimeout: const Duration(seconds: 60)),
      );
    } catch (_) {
      failed.add(f);
    }
  }
  onProgress?.call(files.length, files.length);
  return HomeworkOutcome(failed.isEmpty ? HomeworkUpload.done : HomeworkUpload.filesFailed, failedFiles: failed);
}
