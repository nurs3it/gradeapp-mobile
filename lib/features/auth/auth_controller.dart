import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import 'user.dart';

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

  Future<void> login(String email, String password, {String? otp}) async {
    final body = await ref.read(apiClientProvider).login(email.trim(), password, otp: otp);
    final user = body['user'];
    if (user is Json) await ref.read(jsonCacheProvider).write(_meKey, user);
    state = AsyncData(user is Json ? AppUser.fromJson(user) : await _fetchMe());
  }

  Future<void> logout() async {
    await ref.read(apiClientProvider).logout();
    await _wipe();
  }

  /// Server revoked the session (refresh → 401).
  Future<void> sessionLost() => _wipe();

  Future<void> _wipe() async {
    await ref.read(jsonCacheProvider).clear();
    await ref.read(outboxProvider).clear();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

/// The mode the app is in; defaults to the user's first supported role.
class ActiveRole extends Notifier<AppRole?> {
  @override
  AppRole? build() {
    final roles = ref.watch(authProvider.select((u) => u.value?.appRoles));
    return (roles == null || roles.isEmpty) ? null : roles.first;
  }

  void set(AppRole role) => state = role;
}

final activeRoleProvider = NotifierProvider<ActiveRole, AppRole?>(ActiveRole.new);
