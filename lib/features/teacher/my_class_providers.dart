import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/grading.dart';
import '../../core/json.dart';
import '../../core/offline/outbox.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import 'my_class_logic.dart';

/// Classes of the teacher (`/classes/mine/`), homeroom or not.
final myClassesProvider = StreamProvider<List<MyClass>>(
  (ref) => cachedGet(ref, '/classes/mine/', parse: (d) => parseList(d, MyClass.fromJson)),
);

/// The homeroom classes. Until `/classes/mine/` answers (or offline without
/// a cache) the ids of `/users/me/` stand in, so the tab does not flicker.
final homeroomClassesProvider = Provider<List<MyClass>>((ref) {
  final mine = ref.watch(myClassesProvider).value;
  if (mine != null) return mine.where((c) => c.isHomeroom).toList();
  final ids = ref.watch(authProvider.select((u) => u.value?.homeroomClassIds)) ?? const <String>[];
  return [for (final id in ids) MyClass(id: id, name: '', isHomeroom: true)];
});

/// Whether the teacher gets the «Мой класс» tab (T8).
final hasHomeroomProvider = Provider<bool>((ref) => ref.watch(homeroomClassesProvider).isNotEmpty);

/// Which homeroom class the tab shows (a teacher can lead several).
class SelectedHomeroom extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String id) => state = id;
}

final selectedHomeroomProvider = NotifierProvider<SelectedHomeroom, String?>(SelectedHomeroom.new);

final activeHomeroomProvider = Provider<MyClass?>((ref) {
  final all = ref.watch(homeroomClassesProvider);
  final picked = ref.watch(selectedHomeroomProvider);
  return all.where((c) => c.id == picked).firstOrNull ?? all.firstOrNull;
});

typedef ClassDay = ({String classId, String date});

final classCheckInsProvider = StreamProvider.family<List<ClassCheckIn>, ClassDay>(
  (ref, a) => cachedGet(
    ref,
    '/attendance/check-ins/',
    query: {'class_group': a.classId, 'date': a.date},
    parse: (d) => parseList(d, ClassCheckIn.fromJson),
  ),
);

final classDayMarksProvider = StreamProvider.family<List<DayMark>, ClassDay>(
  (ref, a) => cachedGet(
    ref,
    '/attendance/day_marks/',
    query: {'class_group_id': a.classId, 'date': a.date},
    parse: (d) => parseList(d, DayMark.fromJson),
  ),
);

/// Absence requests of the class waiting for a decision.
final classPendingExcusesProvider = StreamProvider.family<List<ClassExcuse>, String>(
  (ref, classId) => cachedGet(
    ref,
    '/excuses/pending/',
    query: {'class_group_id': classId, 'page_size': 100},
    parse: (d) => parseList(d, ClassExcuse.fromJson),
  ),
);

/// Approved requests, to prefill the day (a student excused for the day).
final classApprovedExcusesProvider = StreamProvider.family<List<Excuse>, String>(
  (ref, classId) => cachedGet(
    ref,
    '/excuses/',
    query: {'status': 'approved', 'class_group_id': classId, 'page_size': 200},
    parse: (d) => parseList(d, Excuse.fromJson),
  ),
);

final classOverviewProvider = StreamProvider.family<ClassOverview, String>(
  (ref, classId) => cachedGet(ref, '/classes/$classId/overview/', parse: (d) => ClassOverview.fromJson(d as Json)),
);

typedef ClassRange = ({String classId, String from, String to});

final classWeekProvider = StreamProvider.family<ClassWeek, ClassRange>(
  (ref, a) => cachedGet(
    ref,
    '/attendance/statistics/',
    query: {'class_group_id': a.classId, 'date_from': a.from, 'date_to': a.to},
    parse: (d) => ClassWeek.fromJson(d as Json),
  ),
);

/// Status of a school code: no code = present, an unknown one = absent (as
/// the server resolves it).
Presence statusOfCode(Grading g, String code) {
  if (code.isEmpty) return Presence.present;
  return g.attendanceCodes.where((c) => c.code == code).firstOrNull?.status ?? Presence.absent;
}

/// The first school code with this status (`''` for present).
String codeOfStatus(Grading g, Presence p) =>
    p == Presence.present ? '' : g.attendanceCodes.where((c) => c.status == p).firstOrNull?.code ?? '';

/// Queued «Отметить класс» of the class and date, student → mark.
final queuedDayMarksProvider = Provider.family<Map<String, ({Presence status, String code, String reason})>, ClassDay>((
  ref,
  a,
) {
  final grading = ref.watch(gradingProvider);
  final pending = ref.watch(outboxStateProvider.select((s) => s.value?.pending ?? const <OutboxItem>[]));
  return queuedDayMarks(
    [for (final i in pending) (path: i.path, data: i.data)],
    a.classId,
    a.date,
    statusOfCode: (code) => statusOfCode(grading, code),
  );
});

/// Writes of the homeroom day. Goes through the outbox like lesson marks:
/// one request per class and date (a newer one replaces a queued one).
class DayActions {
  DayActions(this._outbox);
  final Outbox _outbox;

  Future<void> markClass({
    required String classId,
    required String className,
    required String date,
    required Map<String, DayCell> cells,
  }) => _outbox.add(
    OutboxItem(
      key: 'day:$classId:$date',
      method: 'POST',
      path: '/attendance/mark_day/',
      label: {
        'what': 'day_marks',
        'lesson': className,
        'state': '${cells.values.where((c) => c.status != null).length}',
      },
      data: markDayBody(classId: classId, date: date, cells: cells),
    ),
  );
}
