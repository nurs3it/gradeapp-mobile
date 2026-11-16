import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';

/// What an id in `GET /presence/` refers to: the user account, a student
/// record or a staff record (lessons carry the staff id of the teacher).
enum PresenceKind { user, student, staff }

@immutable
class PresenceRef {
  const PresenceRef(this.kind, this.id);
  const PresenceRef.user(this.id) : kind = PresenceKind.user;
  const PresenceRef.student(this.id) : kind = PresenceKind.student;
  const PresenceRef.staff(this.id) : kind = PresenceKind.staff;

  final PresenceKind kind;
  final String id;

  @override
  bool operator ==(Object other) => other is PresenceRef && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Pure part of the presence client: which ids are on screen, how they are
/// cut into requests and how the answer is read (contract: ≤ 200 per list).
class PresenceBatcher {
  static const maxPerList = 200;

  final _counts = <PresenceRef, int>{};

  Set<PresenceRef> get wanted => _counts.keys.toSet();
  bool get isEmpty => _counts.isEmpty;

  /// Registers one more avatar for [ref]; true when the id is new.
  bool add(PresenceRef ref) {
    final n = _counts[ref] ?? 0;
    _counts[ref] = n + 1;
    return n == 0;
  }

  void remove(PresenceRef ref) {
    final n = _counts[ref];
    if (n == null) return;
    if (n <= 1) {
      _counts.remove(ref);
    } else {
      _counts[ref] = n - 1;
    }
  }

  /// Query maps for [wanted], one per request. Ids are comma-joined; a list
  /// longer than [maxPerList] spills into the next request.
  List<Map<String, String>> queries() {
    final byKind = {
      for (final k in PresenceKind.values) k: _counts.keys.where((r) => r.kind == k).map((r) => r.id).toList(),
    };
    final longest = byKind.values.fold<int>(0, (m, l) => l.length > m ? l.length : m);
    return [
      for (var from = 0; from < longest; from += maxPerList)
        {
          for (final e in byKind.entries)
            if (e.value.length > from) '${e.key.name}s': e.value.skip(from).take(maxPerList).join(','),
        },
    ];
  }

  /// `{"users": [...], "students": [...], "staff": [...]}` → online refs.
  static Set<PresenceRef> parse(Object? data) {
    if (data is! Map) return const {};
    Iterable<PresenceRef> of(String key, PresenceKind kind) {
      final v = data[key];
      return v is List ? v.whereType<String>().map((id) => PresenceRef(kind, id)) : const [];
    }

    return {
      ...of('users', PresenceKind.user),
      ...of('students', PresenceKind.student),
      ...of('staff', PresenceKind.staff),
    };
  }
}

/// Who is online among the avatars on screen: one batched request after the
/// set of avatars settles, then every 30 s while the app is resumed. While the
/// endpoint is not deployed (404) the dots just stay off.
class PresenceController extends Notifier<Set<PresenceRef>> {
  static const poll = Duration(seconds: 30);
  static const debounce = Duration(milliseconds: 150);
  static const retryAfter404 = Duration(minutes: 10);

  final _batcher = PresenceBatcher();
  Timer? _debounce;
  Timer? _timer;
  AppLifecycleListener? _life;
  DateTime? _offUntil;
  bool _resumed = true;

  @override
  Set<PresenceRef> build() {
    final signedIn = ref.watch(authProvider.select((u) => u.value != null));
    void stop() {
      _debounce?.cancel();
      _timer?.cancel();
      _life?.dispose();
      _life = null;
    }

    stop();
    ref.onDispose(stop);
    if (!signedIn) return const {};
    final s = WidgetsBinding.instance.lifecycleState;
    _resumed = s == null || s == AppLifecycleState.resumed;
    _life = AppLifecycleListener(
      onResume: () {
        _resumed = true;
        unawaited(refresh());
      },
      onHide: () {
        _resumed = false;
        _timer?.cancel();
      },
    );
    if (_resumed && !_batcher.isEmpty) scheduleMicrotask(refresh);
    return const {};
  }

  void acquire(PresenceRef r) {
    if (_batcher.add(r)) {
      _debounce?.cancel();
      _debounce = Timer(debounce, () => unawaited(refresh()));
    }
  }

  void release(PresenceRef r) => _batcher.remove(r);

  /// One round of requests for everything on screen, then re-arms the poll.
  Future<void> refresh() async {
    _debounce?.cancel();
    _timer?.cancel();
    if (!_resumed || _batcher.isEmpty || ref.read(authProvider).value == null) return;
    final off = _offUntil;
    if (off == null || DateTime.now().isAfter(off)) {
      final online = <PresenceRef>{};
      try {
        for (final q in _batcher.queries()) {
          final res = await ref.read(dioProvider).get<Object?>('/presence/', queryParameters: q);
          online.addAll(PresenceBatcher.parse(res.data));
        }
        _offUntil = null;
        final next = online.intersection(_batcher.wanted);
        if (next.length != state.length || !next.containsAll(state)) state = next;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) _offUntil = DateTime.now().add(retryAfter404);
        // Any other failure: keep the last answer, try again on the next tick.
      } catch (_) {}
    }
    _timer = Timer(poll, () => unawaited(refresh()));
  }
}

final presenceProvider = NotifierProvider<PresenceController, Set<PresenceRef>>(PresenceController.new);

/// [GAvatar] of a person with the green «в сети» dot (contract: Presence).
class PersonAvatar extends ConsumerStatefulWidget {
  const PersonAvatar({
    super.key,
    required this.presence,
    required this.name,
    this.url,
    this.size = 40,
    this.tone = GAvatarTone.colored,
    this.color,
    this.ring,
    this.dotRing,
    this.dotTop = false,
  });

  /// Null when the person cannot be identified (nothing is requested).
  final PresenceRef? presence;
  final String name;
  final String? url;
  final double size;
  final GAvatarTone tone;
  final Color? color;
  final Color? ring;

  /// Surface the avatar sits on (the dot's cut-out ring); defaults to `surface`.
  final Color? dotRing;
  final bool dotTop;

  @override
  ConsumerState<PersonAvatar> createState() => _PersonAvatarState();
}

class _PersonAvatarState extends ConsumerState<PersonAvatar> {
  late final PresenceController _presence = ref.read(presenceProvider.notifier);
  PresenceRef? _held;

  void _hold() {
    final next = widget.presence;
    if (next == _held) return;
    if (_held != null) _presence.release(_held!);
    _held = next;
    if (next != null) _presence.acquire(next);
  }

  @override
  void initState() {
    super.initState();
    _hold();
  }

  @override
  void didUpdateWidget(PersonAvatar old) {
    super.didUpdateWidget(old);
    _hold();
  }

  @override
  void dispose() {
    if (_held != null) _presence.release(_held!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.presence;
    final online = p != null && ref.watch(presenceProvider.select((s) => s.contains(p)));
    return GAvatar(
      name: widget.name,
      url: widget.url,
      size: widget.size,
      tone: widget.tone,
      color: widget.color,
      ring: widget.ring,
      online: online,
      onlineLabel: online ? context.l10n.presenceOnline : null,
      dotRing: widget.dotRing,
      dotTop: widget.dotTop,
    );
  }
}
