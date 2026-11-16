import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import 'models.dart';

/// Student mode: own student profile id.
final myStudentIdProvider = StreamProvider<String>(
  (ref) => cachedGet(ref, '/users/me/student/', parse: (d) => (d as Json).str('id')),
);

/// Parent mode: linked children.
final childrenProvider = StreamProvider<List<Child>>(
  (ref) => cachedGet(ref, '/users/me/children/', parse: (d) => parseList(d, Child.fromJson)),
);

class SelectedChild extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String id) => state = id;
}

final selectedChildProvider = NotifierProvider<SelectedChild, String?>(SelectedChild.new);

/// Whose data the learner screens show: self (student) or the chosen child.
final learnerIdProvider = Provider<String?>((ref) {
  if (ref.watch(activeRoleProvider) == AppRole.student) {
    return ref.watch(myStudentIdProvider).value;
  }
  final children = ref.watch(childrenProvider).value ?? const [];
  final picked = ref.watch(selectedChildProvider);
  if (children.any((c) => c.id == picked)) return picked;
  return children.isEmpty ? null : children.first.id;
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

/// Whole year of grades, newest first (filtered by subject on device).
final gradesProvider = StreamProvider.family<List<Grade>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/grades/',
    query: {'student_id': studentId, 'page_size': 1000, 'ordering': '-date'},
    parse: (d) => parseList(d, Grade.fromJson),
  ),
);

final homeworkProvider = StreamProvider.family<List<Homework>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/homework/',
    query: {'student': studentId, 'upcoming': true, 'page_size': 500},
    parse: (d) => parseList(d, Homework.fromJson)..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
  ),
);

/// Student only: marks own homework done / not done.
Future<void> setHomeworkDone(WidgetRef ref, Homework hw, bool done) async {
  final dio = ref.read(dioProvider);
  final path = '/homework/${hw.id}/complete/';
  await (done ? dio.post<void>(path) : dio.delete<void>(path));
  ref.invalidate(homeworkProvider);
  ref.invalidate(learnerDayProvider);
}

/// Student only: self check-in («Я в школе»).
Future<void> checkIn(WidgetRef ref, {required String photoPath, double? latitude, double? longitude}) async {
  final form = FormData.fromMap({
    'photo': await MultipartFile.fromFile(photoPath, filename: 'check-in.jpg'),
    'latitude': ?latitude?.toString(),
    'longitude': ?longitude?.toString(),
  });
  await ref.read(dioProvider).post<void>('/attendance/check-in/', data: form);
  ref.invalidate(learnerDayProvider);
}

/// Refused check-in reasons the UI explains (backend `code`).
String? checkInErrorCode(Object e) {
  if (e is! DioException) return null;
  final body = e.response?.data;
  return body is Map ? body['code'] as String? : null;
}

/// Monday of the week containing [d].
DateTime mondayOf(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
