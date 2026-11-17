import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android notification features that flutter_local_notifications cannot
/// express. The plugin registers itself in every Flutter engine, so the same
/// calls work from firebase_messaging's background isolate. A no-op elsewhere.
abstract final class GradeappNative {
  static const _ch = MethodChannel('kz.gradeapp/notif_native');

  /// Re-posts the active notification [id]/[tag] with a public version: what
  /// a secure lock screen shows instead of the real text. Actions and
  /// PendingIntents are kept. Returns false when the notification is not
  /// (or no longer) in the shade.
  static Future<bool> addPublicVersion({
    required int id,
    String? tag,
    required String title,
    required String body,
  }) => _call('addPublicVersion', {'id': id, 'tag': tag, 'title': title, 'body': body});

  /// Android 16 (API 36+): turns the ongoing lesson notification into a Live
  /// Update — progress style from [startMs] to [endMs], promoted ongoing, with
  /// [shortText] in the status-bar chip. Returns false below API 36 (the plain
  /// ongoing notification stays) or when the notification is not posted.
  static Future<bool> promoteLessonLive({
    required int id,
    String? tag,
    required int startMs,
    required int endMs,
    required String shortText,
    String? publicTitle,
    String? publicBody,
  }) => _call('promoteLessonLive', {
    'id': id,
    'tag': tag,
    'startMs': startMs,
    'endMs': endMs,
    'shortText': shortText,
    'publicTitle': publicTitle,
    'publicBody': publicBody,
  });

  static Future<bool> _call(String method, Map<String, Object?> args) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      return await _ch.invokeMethod<bool>(method, args) ?? false;
    } on MissingPluginException {
      return false; // Tests.
    } on PlatformException catch (e) {
      debugPrint('gradeapp_native $method: ${e.message}');
      return false;
    }
  }
}
