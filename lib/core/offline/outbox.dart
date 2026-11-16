import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';

/// Why the server refused a queued write. Shown to the teacher (T11).
enum RejectReason {
  /// 409 `soch_lock`: СОЧ day, current marks and attendance are closed.
  sochLock,

  /// 403: no rights on this lesson (e.g. the lesson was reassigned).
  forbidden,

  /// 404: the lesson or student is gone.
  notFound,

  /// Other 4xx: validation and the like; [OutboxItem.detail] has the text.
  invalid,
}

/// A write waiting to reach the server.
class OutboxItem {
  OutboxItem({
    required this.key,
    required this.method,
    required this.path,
    required this.data,
    DateTime? createdAt,
    this.label = const {},
    this.reason,
    this.detail,
    this.rejectedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Same key = same cell (e.g. one student's mark on one lesson): a newer
  /// write replaces the queued one instead of piling up.
  final String key;
  final String method;
  final String path;
  final Object? data;
  final DateTime createdAt;

  /// Human context for the queue sheet: `lesson`, `student`, `what`.
  final Map<String, String> label;

  /// Set when the server refused the item; it then waits for the teacher.
  final RejectReason? reason;
  final String? detail;
  final DateTime? rejectedAt;

  bool get isRejected => reason != null;

  OutboxItem rejectedWith(RejectReason r, String? d) => OutboxItem(
    key: key,
    method: method,
    path: path,
    data: data,
    createdAt: createdAt,
    label: label,
    reason: r,
    detail: d,
    rejectedAt: DateTime.now(),
  );

  OutboxItem requeued() =>
      OutboxItem(key: key, method: method, path: path, data: data, createdAt: createdAt, label: label);

  Map<String, Object?> toJson() => {
    'key': key,
    'method': method,
    'path': path,
    'data': data,
    'created_at': createdAt.toIso8601String(),
    'label': label,
    if (reason != null) 'reason': reason!.name,
    'detail': ?detail,
    if (rejectedAt != null) 'rejected_at': rejectedAt!.toIso8601String(),
  };

  factory OutboxItem.fromJson(Map<String, dynamic> j) => OutboxItem(
    key: j['key'] as String,
    method: j['method'] as String,
    path: j['path'] as String,
    data: j['data'],
    createdAt: DateTime.tryParse('${j['created_at']}'),
    label: {for (final e in ((j['label'] as Map<String, dynamic>?) ?? const {}).entries) e.key: '${e.value}'},
    reason: RejectReason.values.asNameMap()[j['reason']],
    detail: j['detail'] as String?,
    rejectedAt: DateTime.tryParse('${j['rejected_at']}'),
  );
}

/// Snapshot of the queue for the UI.
class OutboxState {
  const OutboxState({required this.pending, required this.rejected, required this.sending, this.lastSentAt});

  /// Waiting for the network, in send order.
  final List<OutboxItem> pending;

  /// Refused by the server; stays until the teacher retries or deletes it.
  final List<OutboxItem> rejected;
  final bool sending;
  final DateTime? lastSentAt;

  bool get isEmpty => pending.isEmpty && rejected.isEmpty;
  int get total => pending.length + rejected.length;
}

/// Teacher writes (attendance, grades, topic, start/finish) go here first,
/// then to the server. The UI overlays [pending] on server data, so a
/// classroom without Wi-Fi never blocks marking the lesson. A write the server
/// refuses is kept in [rejected] with its reason — never dropped silently.
class Outbox {
  Outbox._(this._file, this._items, this._rejected, this._lastSentAt);

  final File? _file;
  final List<OutboxItem> _items;
  final List<OutboxItem> _rejected;
  DateTime? _lastSentAt;
  final _changes = StreamController<OutboxState>.broadcast();
  Dio? _dio;
  Future<void>? _running;
  Timer? _retry;

  /// Fires once per newly refused item (for the haptic and the indicator pulse).
  final rejectedEvents = StreamController<OutboxItem>.broadcast();

  static Future<Outbox> open() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/outbox.json');
    final items = <OutboxItem>[];
    final rejected = <OutboxItem>[];
    DateTime? last;
    if (await file.exists()) {
      try {
        final raw = jsonDecode(await file.readAsString());
        // v1 was a bare list of pending items.
        final list = raw is List ? raw : (raw as Map<String, dynamic>)['items'] as List<dynamic>;
        for (final e in list) {
          final item = OutboxItem.fromJson(e as Map<String, dynamic>);
          (item.isRejected ? rejected : items).add(item);
        }
        if (raw is Map) last = DateTime.tryParse('${raw['last_sent_at']}');
      } on Object {
        // Corrupt file: start clean rather than crash the teacher's app.
      }
    }
    return Outbox._(file, items, rejected, last);
  }

  /// In-memory queue for tests.
  factory Outbox.memory() => Outbox._(null, [], [], null);

  void attach(Dio dio) => _dio = dio;

  List<OutboxItem> get pending => List.unmodifiable(_items);
  List<OutboxItem> get rejected => List.unmodifiable(_rejected);
  OutboxState get state =>
      OutboxState(pending: pending, rejected: rejected, sending: _running != null, lastSentAt: _lastSentAt);
  Stream<OutboxState> get changes => _changes.stream;

  Future<void> add(OutboxItem item) async {
    _items
      ..removeWhere((i) => i.key == item.key)
      ..add(item);
    // A fresh write to the same cell supersedes an old refusal.
    _rejected.removeWhere((i) => i.key == item.key);
    await _persist();
    unawaited(flush());
  }

  /// Puts a refused item back in the queue and sends it again.
  Future<void> retry(OutboxItem item) async {
    _rejected.removeWhere((i) => i.key == item.key);
    _items
      ..removeWhere((i) => i.key == item.key)
      ..add(item.requeued());
    await _persist();
    await flush();
  }

  /// Drops an item (pending or refused) without sending it.
  Future<void> remove(OutboxItem item) async {
    _rejected.removeWhere((i) => i.key == item.key);
    _items.removeWhere((i) => i.key == item.key);
    await _persist();
  }

  /// Sends queued writes in order. Stops at the first network or 5xx failure
  /// and retries later; a 4xx answer moves only that item to [rejected].
  /// Concurrent calls share the run in progress.
  Future<void> flush() {
    if (_dio == null || _items.isEmpty) return _running ?? Future.value();
    return _running ??= _flush().whenComplete(() {
      _running = null;
      _emit();
    });
  }

  Future<void> _flush() async {
    final dio = _dio!;
    _retry?.cancel();
    _emit();
    try {
      while (_items.isNotEmpty) {
        final item = _items.first;
        try {
          await dio.request<void>(item.path, data: item.data, options: Options(method: item.method));
          _items.remove(item);
          _lastSentAt = DateTime.now();
        } catch (e) {
          if (isOffline(e) || _isServerError(e) || _isUnauthorized(e)) {
            _retry = Timer(const Duration(seconds: 20), flush);
            break;
          }
          _items.remove(item);
          final refused = item.rejectedWith(reasonOf(e), detailOf(e));
          _rejected.add(refused);
          rejectedEvents.add(refused);
        }
        await _persist();
      }
    } finally {
      _emit();
    }
  }

  /// Sign-out: the next account must not send this one's writes.
  Future<void> clear() async {
    _items.clear();
    _rejected.clear();
    await _persist();
  }

  static RejectReason reasonOf(Object e) {
    if (e is! DioException) return RejectReason.invalid;
    final code = e.response?.statusCode ?? 0;
    final body = e.response?.data;
    final err = body is Map ? (body['error'] ?? body['code']) : null;
    if (code == 409 && err == 'soch_lock') return RejectReason.sochLock;
    if (code == 403) return RejectReason.forbidden;
    if (code == 404) return RejectReason.notFound;
    return RejectReason.invalid;
  }

  static String? detailOf(Object e) {
    if (e is! DioException) return '$e';
    final body = e.response?.data;
    if (body is Map) {
      final d = body['detail'] ?? body['error'] ?? body.values.firstOrNull;
      return d is List ? d.join(' ') : d?.toString();
    }
    return body is String && body.length < 200 ? body : null;
  }

  static bool _isServerError(Object e) => e is DioException && (e.response?.statusCode ?? 0) >= 500;

  /// 401 after a failed refresh: the session is ending — keep the item.
  static bool _isUnauthorized(Object e) => e is DioException && e.response?.statusCode == 401;

  void _emit() {
    if (!_changes.isClosed) _changes.add(state);
  }

  Future<void> _persist() async {
    _emit();
    final file = _file;
    if (file == null) return;
    await file.writeAsString(
      jsonEncode({
        'version': 2,
        'last_sent_at': _lastSentAt?.toIso8601String(),
        'items': [for (final i in [..._items, ..._rejected]) i.toJson()],
      }),
    );
  }
}
