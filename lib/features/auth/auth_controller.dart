import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../notifications/push.dart';
import 'user.dart';
import '../../core/analytics.dart';

/// Signed-in user, or null. Boot uses the cached profile so the app opens
/// offline; the fresh profile replaces it once the network answers.
class AuthController extends AsyncNotifier<AppUser?> {
  static const _meKey = 'me';

  @override
  Future<AppUser?> build() async {
    final session = await ref.read(sessionStoreProvider).load();
    if (session == null) return null;
    final cached = await ref.read(jsonCacheProvider).read(_meKey);
    final fresh = _fetchMe();
    if (cached is Json) {
      fresh.then((u) => state = AsyncData(u)).ignore();
      return AppUser.fromJson(cached);
    }
    return fresh;
  }

  Future<AppUser> _fetchMe() async {
    final res = await ref.read(dioProvider).get<Json>('/users/me/');
    await ref.read(jsonCacheProvider).write(_meKey, res.data);
    return AppUser.fromJson(res.data!);
  }

  Future<void> refreshMe() async => state = AsyncData(await _fetchMe());

  Future<void> login(String email, String password, {String? otp}) async {
    final body = await ref.read(apiClientProvider).login(email.trim(), password, otp: otp);
    await _signedIn(body);
  }

  /// One-time school code; returns the login to show («Ваш логин»).
  Future<String> redeemCode(String code, {required String newPassword, String? otp}) async {
    final body = await ref.read(apiClientProvider).redeemAccessCode(code, newPassword: newPassword, otp: otp);
    final login = body.str('login');
    await _signedIn(body, publish: false);
    return login;
  }

  /// Publishes a user signed in by [redeemCode] after the «Ваш логин» step.
  Future<void> finishCodeSignIn() async {
    final cached = await ref.read(jsonCacheProvider).read(_meKey);
    state = AsyncData(cached is Json ? AppUser.fromJson(cached) : await _fetchMe());
  }

  Future<void> _signedIn(Json body, {bool publish = true}) async {
    final user = body['user'];
    if (user is Json) await ref.read(jsonCacheProvider).write(_meKey, user);
    if (publish) state = AsyncData(user is Json ? AppUser.fromJson(user) : await _fetchMe());
    unawaited(ref.read(pushProvider).register());
    ref.read(analyticsProvider).track(AnalyticsEvents.login);
  }

  /// C11: another school. Data of the previous one must not linger.
  Future<void> switchSchool(String schoolId) async {
    await ref.read(dioProvider).patch<void>('/users/me/', data: {'linked_school': schoolId});
    await ref.read(jsonCacheProvider).clear();
    state = AsyncData(await _fetchMe());
  }

  Future<void> logout() async {
    await ref.read(pushProvider).unregister();
    await ref.read(apiClientProvider).logout();
    await _wipe();
  }

  /// Server revoked the session (refresh → 401): the token dies locally so
  /// this phone stops getting the account's pushes.
  Future<void> sessionLost() async {
    await ref.read(pushProvider).unregister(withServer: false);
    await _wipe();
  }

  Future<void> _wipe() async {
    await ref.read(jsonCacheProvider).clear();
    await ref.read(outboxProvider).clear();
    await ref.read(prefsProvider).write(ActiveRole.key, null);
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

/// The mode the app is in. Remembered between launches (P2-minimum); falls
/// back to the user's first supported role.
class ActiveRole extends Notifier<AppRole?> {
  static const key = 'active_role';
  AppRole? _saved;

  @override
  AppRole? build() {
    _saved ??= AppRole.values.asNameMap()[ref.read(bootPrefsProvider)[key]];
    final roles = ref.watch(authProvider.select((u) => u.value?.appRoles));
    if (roles == null || roles.isEmpty) return null;
    return roles.contains(_saved) ? _saved : roles.first;
  }

  void set(AppRole role) {
    _saved = role;
    state = role;
    unawaited(ref.read(prefsProvider).write(key, role.name));
  }
}

final activeRoleProvider = NotifierProvider<ActiveRole, AppRole?>(ActiveRole.new);

/// The school the user works in (for grading, terms, check-in flags).
final schoolIdProvider = Provider<String?>((ref) => ref.watch(authProvider.select((u) => u.value?.linkedSchool)));

/// Permission check that rebuilds only when the answer changes.
final canProvider = Provider.family<bool, String>(
  (ref, permission) => ref.watch(authProvider.select((u) => u.value?.can(permission) ?? false)),
);
