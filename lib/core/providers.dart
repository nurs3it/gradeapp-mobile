import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'api/session_store.dart';
import 'json.dart';
import 'offline/outbox.dart';
import 'storage/json_cache.dart';

/// Opened in `main()` before the first frame and injected via overrides.
final sessionStoreProvider = Provider<SessionStore>((_) => throw UnimplementedError());
final jsonCacheProvider = Provider<JsonCache>((_) => throw UnimplementedError());
final outboxProvider = Provider<Outbox>((_) => throw UnimplementedError());
final apiClientProvider = Provider<ApiClient>((_) => throw UnimplementedError());

final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);

final outboxPendingProvider = StreamProvider<List<OutboxItem>>((ref) async* {
  final outbox = ref.watch(outboxProvider);
  yield outbox.pending;
  yield* outbox.changes;
});

/// Stale-while-revalidate: emits the cached answer at once (if any), then the
/// fresh one. Offline with a cache — the cached value simply stays on screen;
/// offline without one — the error surfaces.
Stream<T> cachedGet<T>(
  Ref ref,
  String path, {
  Map<String, Object?>? query,
  required T Function(Object? data) parse,
}) async* {
  final cache = ref.read(jsonCacheProvider);
  final key = '$path?${query ?? const {}}';
  final cached = await cache.read(key);
  if (cached != null) yield parse(cached);
  try {
    final res = await ref.read(dioProvider).get<Object?>(path, queryParameters: query);
    await cache.write(key, res.data);
    yield parse(res.data);
  } catch (e) {
    if (cached == null || !isOffline(e)) rethrow;
  }
}

/// Plain list endpoint helper (handles DRF's paginated envelope).
List<T> parseList<T>(Object? data, T Function(Json) parse) =>
    resultsOf(data).map(parse).toList(growable: false);
