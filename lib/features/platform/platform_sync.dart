import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../core/storage/json_cache.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/models.dart';
import '../teacher/teacher_models.dart';
import 'reminders.dart';
import 'widget_snapshot.dart';

/// Shared storage with the native widgets (iOS App Group, Android
/// SharedPreferences «HomeWidgetPreferences») and the reload calls.
abstract final class WidgetBridge {
  static const appGroup = 'group.kz.gradeapp.gradeapp';
  static const _key = 'snapshot';

  /// WidgetKit `kind`s and Android provider classes of the two widgets.
  static const _ios = ['NextLessonWidget', 'DayWidget'];
  static const _android = ['kz.gradeapp.gradeapp.widgets.NextLessonWidget', 'kz.gradeapp.gradeapp.widgets.DayWidget'];

  static bool get supported => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  static Future<void> publish(Json snapshot) async {
    if (!supported) return;
    try {
      if (Platform.isIOS) await HomeWidget.setAppGroupId(appGroup);
      await HomeWidget.saveWidgetData<String>(_key, jsonEncode(snapshot));
      for (var i = 0; i < _ios.length; i++) {
        await HomeWidget.updateWidget(iOSName: _ios[i], qualifiedAndroidName: _android[i]);
      }
    } catch (e) {
      debugPrint('widget publish: $e');
    }
  }
}

/// Keeps what the phone shows outside the app fresh (W1, W2, W9, T10): the
/// cached «today» and week, the widget snapshot, the teacher's reminders.
/// Runs in the app (start, resume, child/role switch) and in the background
/// isolate when a silent push arrives.
class PlatformSync {
  PlatformSync(this.dio, this.cache, this.prefs);

  final Dio dio;
  final JsonCache cache;
  final JsonCache prefs;

  static const targetKey = 'platform_target';

  Future<WidgetTarget?> savedTarget() async => WidgetTarget.fromJson(await prefs.read(targetKey));

  /// Refetches the data behind «Сегодня» and the week for [target] (or the
  /// last one saved), writes it to the cache the screens read, then
  /// republishes the widgets. Returns false when nothing could be fetched.
  Future<bool> refresh({
    WidgetTarget? target,
    required AppLocalizations l,
    required String langCode,
    DateTime? at,
    bool remind = true,
  }) async {
    final now = at ?? DateTime.now();
    if (target != null) await prefs.write(targetKey, target.toJson());
    final t = target ?? await savedTarget();
    if (t == null || !t.usable) return false;
    final today = isoDate(now);
    final monday = isoDate(mondayOf(now));
    final sunday = isoDate(mondayOf(now).add(const Duration(days: 6)));
    final ahead = isoDate(dateOnly(now).add(const Duration(days: snapshotDays - 1)));
    try {
      if (t.role == 'teacher') {
        final todo = '/teacher/todo/';
        final todoQ = {'date': today};
        final dayJson = await _get(todo, todoQ);
        await cache.write(cacheKeyOf(todo, todoQ), dayJson);
        final weekQ = <String, Object?>{
          'teacher_id': t.staffId,
          'date_from': monday,
          'date_to': sunday,
          'page_size': 500,
        };
        unawaited(
          _get(
            '/lessons/',
            weekQ,
          ).then((j) => cache.write(cacheKeyOf('/lessons/', weekQ), j)).catchError((Object _) {}),
        );
        final aheadQ = <String, Object?>{
          'teacher_id': t.staffId,
          'date_from': today,
          'date_to': ahead,
          'page_size': 500,
        };
        final lessons = parseList(await _get('/lessons/', aheadQ), Lesson.fromJson);
        await WidgetBridge.publish(
          buildSnapshot(target: t, lessons: lessons, homework: const [], now: now, l: l, langCode: langCode),
        );
        if (remind && dayJson is Json) await Reminders.reschedule(TeacherDay.fromJson(dayJson), now, l, prefs);
      } else {
        _refreshStudentCaches(t.learnerId!, today, monday, sunday);
        // Sync pushes carry no child id and a parent may have several:
        // every child's cached day and week are refreshed.
        if (t.role == 'parent') unawaited(_refreshOtherChildren(t.learnerId!, today, monday, sunday));
        final aheadQ = <String, Object?>{
          'student_id': t.learnerId,
          'date_from': today,
          'date_to': ahead,
          'page_size': 500,
        };
        final lessons = parseList(await _get('/lessons/', aheadQ), Lesson.fromJson);
        final hwQ = <String, Object?>{'student': t.learnerId, 'page_size': 300};
        final hwJson = await _get('/homework/', hwQ);
        await cache.write(cacheKeyOf('/homework/', hwQ), hwJson);
        final homework = parseList(hwJson, Homework.fromJson);
        await WidgetBridge.publish(
          buildSnapshot(target: t, lessons: lessons, homework: homework, now: now, l: l, langCode: langCode),
        );
      }
      return true;
    } catch (e) {
      // Offline or refused: the widgets keep the last snapshot, and say how
      // old it is.
      debugPrint('platform sync: $e');
      return false;
    }
  }

  /// Cached «today» and week of one student, under the keys the screens read.
  void _refreshStudentCaches(String id, String today, String monday, String sunday) {
    final dayPath = '/students/$id/today/';
    final dayQ = {'date': today};
    final weekQ = <String, Object?>{'student_id': id, 'date_from': monday, 'date_to': sunday, 'page_size': 500};
    unawaited(_get(dayPath, dayQ).then((j) => cache.write(cacheKeyOf(dayPath, dayQ), j)).catchError((Object _) {}));
    unawaited(
      _get('/lessons/', weekQ).then((j) => cache.write(cacheKeyOf('/lessons/', weekQ), j)).catchError((Object _) {}),
    );
  }

  Future<void> _refreshOtherChildren(String selected, String today, String monday, String sunday) async {
    try {
      final kids = parseList(await _get('/users/me/children/', const {}), (j) => j.str('id'));
      for (final id in kids.where((k) => k.isNotEmpty && k != selected)) {
        _refreshStudentCaches(id, today, monday, sunday);
      }
    } catch (_) {}
  }

  Future<Object?> _get(String path, Map<String, Object?> q) async =>
      (await dio.get<Object?>(path, queryParameters: q)).data;

  /// Sign-out: another account must never see this one's lessons.
  Future<void> clear(AppLocalizations l, String langCode) async {
    await prefs.write(targetKey, null);
    await WidgetBridge.publish(signedOutSnapshot(l, langCode, DateTime.now()));
    await Reminders.cancelAll();
  }
}
