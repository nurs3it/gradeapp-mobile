import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../common/models.dart';

/// Student mode: own student profile id (from `/users/me/`).
final myStudentIdProvider = Provider<String?>((ref) => ref.watch(authProvider.select((u) => u.value?.studentId)));

/// Parent mode: linked children.
final childrenProvider = StreamProvider<List<Child>>(
  (ref) => cachedGet(ref, '/users/me/children/', parse: (d) => parseList(d, Child.fromJson)),
);

/// The parent's chosen child; remembered between launches (P2).
class SelectedChild extends Notifier<String?> {
  static const key = 'selected_child';

  @override
  String? build() => ref.read(bootPrefsProvider)[key] as String?;

  void select(String id) {
    state = id;
    unawaited(ref.read(prefsProvider).write(key, id));
  }
}

final selectedChildProvider = NotifierProvider<SelectedChild, String?>(SelectedChild.new);

/// Parent with 2+ children: «Сегодня» shows the whole family until a child
/// is picked (P2).
class FamilyMode extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool v) => state = v;
}

final familyModeProvider = NotifierProvider<FamilyMode, bool>(FamilyMode.new);

/// Whose data the learner screens show: self (student) or the chosen child.
final learnerIdProvider = Provider<String?>((ref) {
  if (ref.watch(activeRoleProvider) == AppRole.student) return ref.watch(myStudentIdProvider);
  final children = ref.watch(childrenProvider).value ?? const [];
  final picked = ref.watch(selectedChildProvider);
  if (children.any((c) => c.id == picked)) return picked;
  return children.isEmpty ? null : children.first.id;
});

/// The selected child (parent mode), for headers and the switcher.
final currentChildProvider = Provider<Child?>((ref) {
  final id = ref.watch(learnerIdProvider);
  return (ref.watch(childrenProvider).value ?? const <Child>[]).where((c) => c.id == id).firstOrNull;
});

typedef DayArgs = ({String studentId, String date});

final learnerDayProvider = StreamProvider.family<LearnerDay, DayArgs>(
  (ref, a) => cachedGet(
    ref,
    '/students/${a.studentId}/today/',
    query: {'date': a.date},
    parse: (d) => LearnerDay.fromJson(d as Json),
  ),
);

typedef WeekArgs = ({String studentId, String monday});

/// Lessons Mon..Sun of the week starting at [WeekArgs.monday].
final weekLessonsProvider = StreamProvider.family<List<Lesson>, WeekArgs>((ref, a) {
  final from = DateTime.parse(a.monday);
  return cachedGet(
    ref,
    '/lessons/',
    query: {
      'student_id': a.studentId,
      'date_from': a.monday,
      'date_to': isoDate(from.add(const Duration(days: 6))),
      'page_size': 500,
    },
    parse: (d) => parseList(d, Lesson.fromJson)..sort((x, y) => '${x.date}${x.start}'.compareTo('${y.date}${y.start}')),
  );
});

typedef TermArgs = ({String studentId, String termId});

/// Grades of one quarter only (S6: no 1000-row year download).
final termGradesProvider = StreamProvider.family<List<Grade>, TermArgs>(
  (ref, a) => cachedGet(
    ref,
    '/grades/',
    query: {'student_id': a.studentId, 'term': a.termId, 'page_size': 500, 'ordering': '-date'},
    parse: (d) => parseList(d, Grade.fromJson),
  ),
);

/// Official quarter marks (`effective_mark`) where the school has them.
final periodGradesProvider = StreamProvider.family<List<PeriodGrade>, TermArgs>(
  (ref, a) => cachedGet(
    ref,
    '/grades/period/',
    query: {'student': a.studentId, 'term': a.termId},
    parse: (d) => parseList(d, PeriodGrade.fromJson),
  ),
);

/// All homework of the learner's class with their done state.
final homeworkProvider = StreamProvider.family<List<Homework>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/homework/',
    query: {'student': studentId, 'page_size': 300},
    parse: (d) => parseList(d, Homework.fromJson)..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
  ),
);

/// Optimistic «done» marks not yet confirmed by the server (homework id → done).
class HomeworkOverrides extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => const {};

  void set(String id, bool done) => state = {...state, id: done};
  void clear(String id) => state = {...state}..remove(id);
}

final homeworkOverridesProvider = NotifierProvider<HomeworkOverrides, Map<String, bool>>(HomeworkOverrides.new);

/// Student only: marks homework done / not done. Optimistic; rolls back if
/// the server refuses (offline the mark stays and is re-sent on next toggle).
Future<bool> setHomeworkDone(WidgetRef ref, Homework hw, bool done) async {
  final overrides = ref.read(homeworkOverridesProvider.notifier)..set(hw.id, done);
  final dio = ref.read(dioProvider);
  final path = '/homework/${hw.id}/complete/';
  try {
    await (done ? dio.post<void>(path) : dio.delete<void>(path));
    ref
      ..invalidate(homeworkProvider)
      ..invalidate(learnerDayProvider);
    return true;
  } on DioException catch (e) {
    if (e.response != null) overrides.clear(hw.id);
    return false;
  }
}

/// Student only: self check-in («Я в школе») with upload progress.
Future<void> postCheckIn(
  Ref ref, {
  required String photoPath,
  double? latitude,
  double? longitude,
  void Function(double)? onProgress,
}) async {
  final form = FormData.fromMap({
    'photo': await MultipartFile.fromFile(photoPath, filename: 'check-in.jpg'),
    'latitude': ?latitude?.toStringAsFixed(6),
    'longitude': ?longitude?.toStringAsFixed(6),
  });
  await ref
      .read(dioProvider)
      .post<void>(
        '/attendance/check-in/',
        data: form,
        onSendProgress: (sent, total) => onProgress?.call(total <= 0 ? 0 : sent / total),
      );
}

/// Refused check-in reason (backend `code`) and its payload.
({String? code, int? distance}) checkInError(Object e) {
  if (e is! DioException) return (code: null, distance: null);
  final body = e.response?.data;
  if (body is! Map) return (code: null, distance: null);
  return (code: body['code'] as String?, distance: (body['distance_m'] as num?)?.round());
}
