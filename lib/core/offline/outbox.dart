import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';

/// A write waiting to reach the server.
class OutboxItem {
  OutboxItem({
    required this.key,
    required this.method,
    required this.path,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Same key = same cell (e.g. one student's mark on one lesson): a newer
  /// write replaces the queued one instead of piling up.
  final String key;
  final String method;
  final String path;
  final Object? data;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'key': key,
        'method': method,
        'path': path,
        'data': data,
        'created_at': createdAt.toIso8601String(),
      };

  factory OutboxItem.fromJson(Map<String, dynamic> j) => OutboxItem(
        key: j['key'] as String,
        method: j['method'] as String,
        path: j['path'] as String,
        data: j['data'],
        createdAt: DateTime.tryParse('${j['created_at']}'),
      );
}

/// Teacher writes (attendance, grades) go here first, then to the server.
/// The UI reads [pending] to show local values and a "not synced" badge, so a
/// classroom without Wi-Fi never blocks marking the lesson.
class Outbox {
  Outbox._(this._file, this._items);

  final File _file;
  final List<OutboxItem> _items;
  final _changes = StreamController<List<OutboxItem>>.broadcast();
  Dio? _dio;
  bool _flushing = false;
  Timer? _retry;

  /// Server refused an item (4xx): it is dropped and reported here.
  final rejected = StreamController<OutboxItem>.broadcast();

  static Future<Outbox> open() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/outbox.json');
    var items = <OutboxItem>[];
    if (await file.exists()) {
      try {
        items = (jsonDecode(await file.readAsString()) as List<dynamic>)
            .map((e) => OutboxItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } on FormatException {
        items = [];
      }
    }
    return Outbox._(file, items);
  }

  void attach(Dio dio) => _dio = dio;

  List<OutboxItem> get pending => List.unmodifiable(_items);
  Stream<List<OutboxItem>> get changes => _changes.stream;

  Future<void> add(OutboxItem item) async {
    _items
      ..removeWhere((i) => i.key == item.key)
      ..add(item);
    await _persist();
    unawaited(flush());
  }

  /// Sends queued writes in order. Stops at the first network failure and
  /// retries later; a 4xx answer drops only that item.
  Future<void> flush() async {
    final dio = _dio;
    if (dio == null || _flushing || _items.isEmpty) return;
    _flushing = true;
    _retry?.cancel();
    try {
      while (_items.isNotEmpty) {
        final item = _items.first;
        try {
          await dio.request<void>(
            item.path,
            data: item.data,
            options: Options(method: item.method),
          );
          _items.remove(item);
        } catch (e) {
          if (isOffline(e) || _isServerError(e)) {
            _retry = Timer(const Duration(seconds: 20), flush);
            break;
          }
          _items.remove(item);
          rejected.add(item);
        }
        await _persist();
      }
    } finally {
      _flushing = false;
    }
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
  }

  static bool _isServerError(Object e) =>
      e is DioException && (e.response?.statusCode ?? 0) >= 500;

  Future<void> _persist() async {
    _changes.add(pending);
    await _file.writeAsString(jsonEncode(_items.map((i) => i.toJson()).toList()));
  }
}
