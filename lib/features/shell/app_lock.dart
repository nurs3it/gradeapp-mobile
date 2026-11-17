import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';

/// Face ID / fingerprint with the phone's passcode as the fallback.
abstract class LockAuthenticator {
  /// False when the phone has no screen lock at all (nothing to ask).
  Future<bool> isSupported();
  Future<bool> authenticate(String reason);
}

class DeviceAuthenticator implements LockAuthenticator {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } on PlatformException {
      return false;
    }
  }
}

final lockAuthenticatorProvider = Provider<LockAuthenticator>((_) => DeviceAuthenticator());

/// The app is locked again when it was out of sight for longer than this.
const lockAfter = Duration(minutes: 5);

bool shouldLock({required DateTime? hiddenAt, required DateTime now, Duration after = lockAfter}) =>
    hiddenAt != null && now.difference(hiddenAt) > after;

class AppLockState {
  const AppLockState({this.enabled = false, this.locked = false, this.covered = false});
  final bool enabled;
  final bool locked;

  /// App is not in the foreground: hide the content from the app switcher.
  final bool covered;

  AppLockState copyWith({bool? enabled, bool? locked, bool? covered}) =>
      AppLockState(enabled: enabled ?? this.enabled, locked: locked ?? this.locked, covered: covered ?? this.covered);
}

/// Opt-in lock (profile → «Блокировка приложения»): locked at cold start and
/// after [lockAfter] in the background. Device-level, so it is forgotten at
/// sign-out and does not follow the next account.
class AppLockController extends Notifier<AppLockState> {
  static const key = 'app_lock';

  DateTime? _hiddenAt;
  bool _asking = false;
  AppLifecycleListener? _life;
  DateTime Function() clock = DateTime.now;

  @override
  AppLockState build() {
    ref.listen(authProvider, (prev, next) {
      if (prev?.value != null && next.value == null && state.enabled) unawaited(_forget());
    });
    _life?.dispose();
    _life = AppLifecycleListener(
      onInactive: () {
        if (state.enabled && !state.covered) state = state.copyWith(covered: true);
      },
      onHide: () {
        if (!_asking) _hiddenAt ??= clock();
      },
      onResume: _resumed,
    );
    ref.onDispose(() => _life?.dispose());
    final on = ref.read(bootPrefsProvider)[key] == true;
    // Cold start: locked until the owner shows up.
    return AppLockState(enabled: on, locked: on);
  }

  void _resumed() {
    final away = _hiddenAt;
    _hiddenAt = null;
    var next = state.copyWith(covered: false);
    if (state.enabled && shouldLock(hiddenAt: away, now: clock())) next = next.copyWith(locked: true);
    state = next;
  }

  Future<bool> _ask(String reason) async {
    if (_asking) return false;
    _asking = true;
    try {
      final l = ref.read(lockAuthenticatorProvider);
      if (!await l.isSupported()) return false;
      return await l.authenticate(reason);
    } finally {
      _asking = false;
      _hiddenAt = null;
    }
  }

  /// Turns the lock on after one successful check. False: the phone has no
  /// screen lock or the owner cancelled.
  Future<bool> enable(String reason) async {
    if (!await _ask(reason)) return false;
    await _save(true);
    state = state.copyWith(enabled: true, locked: false);
    return true;
  }

  Future<bool> disable(String reason) async {
    if (!await _ask(reason)) return false;
    await _forget();
    return true;
  }

  /// Shows the system prompt. A phone that lost its screen lock cannot ask
  /// anything, so the lock lets go instead of trapping the owner.
  Future<void> unlock(String reason) async {
    if (!state.locked) return;
    if (!await ref.read(lockAuthenticatorProvider).isSupported()) {
      await _forget();
      return;
    }
    if (await _ask(reason)) state = state.copyWith(locked: false, covered: false);
  }

  Future<void> _forget() async {
    await _save(false);
    state = const AppLockState();
  }

  Future<void> _save(bool on) => ref.read(prefsProvider).write(key, on);
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(AppLockController.new);

/// Covers the app while it is locked (and in the app switcher).
class AppLockGate extends ConsumerWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(authProvider.select((u) => u.value != null));
    final s = ref.watch(appLockProvider);
    final show = signedIn && s.enabled && (s.locked || s.covered);
    return Stack(
      children: [
        child,
        if (show) Positioned.fill(child: _LockScreen(locked: s.locked)),
      ],
    );
  }
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen({required this.locked});
  final bool locked;

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.locked) unawaited(_unlock());
  }

  @override
  void didUpdateWidget(_LockScreen old) {
    super.didUpdateWidget(old);
    if (widget.locked && !old.locked) unawaited(_unlock());
  }

  Future<void> _unlock() async {
    // Let the first frame of the cover land before the system sheet.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await ref.read(appLockProvider.notifier).unlock(context.l10n.lockReason);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l10n;
    // Sits above the Navigator, so it brings its own Material (text style,
    // ink) instead of inheriting one from a route.
    return Material(
      color: c.canvas,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
                child: GIcon(GIcons.lock, size: 32, color: c.primarySoftText),
              ),
              const SizedBox(height: 20),
              Text(l.lockTitle, style: context.t.title1, textAlign: TextAlign.center),
              if (widget.locked) ...[const SizedBox(height: 24), GButton(label: l.lockUnlock, onPressed: _unlock)],
            ],
          ),
        ),
      ),
    );
  }
}
