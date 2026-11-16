import 'dart:async';

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

/// Device-level preferences; survive sign-out (unlike the API cache).
final prefsProvider = Provider<JsonCache>((_) => throw UnimplementedError());
/// Small preferences read before the first frame (active role, chosen
/// child), so the app does not flash another role's screen at start.
final bootPrefsProvider = Provider<Map<String, Object?>>((_) => const {});
final outboxProvider = Provider<Outbox>((_) => throw UnimplementedError());
final apiClientProvider = Provider<ApiClient>((_) => throw UnimplementedError());

final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);

final outboxStateProvider = StreamProvider<OutboxState>((ref) async* {
  final outbox = ref.watch(outboxProvider);
  yield outbox.state;
  yield* outbox.changes;
});

/// Unsent writes only (what the lesson overlays on server data).
final outboxPendingProvider = Provider<List<OutboxItem>>(
  (ref) => ref.watch(outboxStateProvider.select((s) => s.value?.pending ?? const <OutboxItem>[])),
);

/// Whether the last request reached the server, and when data was last fresh.
class NetState {
  const NetState({this.offline = false, this.lastFresh});
  final bool offline;
  final DateTime? lastFresh;
}

class NetStatus extends Notifier<NetState> {
  static const _key = 'last_fresh';

  @override
  NetState build() {
    _load();
    return const NetState();
  }

  Future<void> _load() async {
    final raw = await ref.read(prefsProvider).read(_key);
    final at = raw is String ? DateTime.tryParse(raw) : null;
    if (at != null && state.lastFresh == null) state = NetState(offline: state.offline, lastFresh: at);
  }

  void online() {
    final now = DateTime.now();
    // Throttle writes: the time only matters to the minute.
    if (!state.offline && state.lastFresh != null && now.difference(state.lastFresh!).inSeconds < 30) return;
    state = NetState(lastFresh: now);
    unawaited(ref.read(prefsProvider).write(_key, now.toIso8601String()));
  }

  void offline() {
    if (!state.offline) state = NetState(offline: true, lastFresh: state.lastFresh);
  }
}

final netProvider = NotifierProvider<NetStatus, NetState>(NetStatus.new);

/// Stale-while-revalidate: emits the cached answer at once (if any), then the
/// fresh one. Offline with a cache — the cached value simply stays on screen
/// (and the offline bar says how old it is); offline without one — the error
/// surfaces.
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
    ref.read(netProvider.notifier).online();
    await cache.write(key, res.data);
    yield parse(res.data);
  } catch (e) {
    if (isOffline(e)) ref.read(netProvider.notifier).offline();
    if (cached == null || !isOffline(e)) rethrow;
  }
}

/// Plain list endpoint helper (handles DRF's paginated envelope).
List<T> parseList<T>(Object? data, T Function(Json) parse) => resultsOf(data).map(parse).toList(growable: false);

/// Wall clock that ticks on minute boundaries — enough for countdowns,
/// cheap for the battery. Override in tests.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  while (true) {
    final now = DateTime.now();
    await Future<void>.delayed(Duration(seconds: 60 - now.second, milliseconds: -now.millisecond + 50));
    yield DateTime.now();
  }
});

DateTime nowOf(Ref ref) => ref.watch(clockProvider).value ?? DateTime.now();

extension ClockX on WidgetRef {
  /// Current time; the widget rebuilds on every minute boundary.
  DateTime get now => watch(clockProvider).value ?? DateTime.now();
}
