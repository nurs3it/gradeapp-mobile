import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/providers.dart';
import 'package:gradeapp/core/storage/json_cache.dart';
import 'package:gradeapp/features/auth/auth_controller.dart';
import 'package:gradeapp/features/auth/user.dart';
import 'package:gradeapp/features/shell/app_lock.dart';

class _Device implements LockAuthenticator {
  _Device({this.supported = true, this.passes = true});
  bool supported;
  bool passes;
  int asked = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> authenticate(String reason) async {
    asked++;
    return passes;
  }
}

class _Auth extends AuthController {
  @override
  Future<AppUser?> build() async =>
      const AppUser(id: 'me', email: 'a@b.c', firstName: 'A', lastName: 'B', roles: ['student']);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('locks only after more than five minutes away', () {
    final t = DateTime(2026, 11, 17, 9);
    expect(shouldLock(hiddenAt: null, now: t), isFalse);
    expect(shouldLock(hiddenAt: t, now: t.add(const Duration(minutes: 5))), isFalse);
    expect(shouldLock(hiddenAt: t, now: t.add(const Duration(minutes: 5, seconds: 1))), isTrue);
  });

  group('AppLockController', () {
    Future<(ProviderContainer, _Device)> setup({bool enabled = false, _Device? device}) async {
      final dev = device ?? _Device();
      final dir = Directory.systemTemp.createTempSync('lock');
      addTearDown(() => dir.deleteSync(recursive: true));
      final c = ProviderContainer(
        overrides: [
          lockAuthenticatorProvider.overrideWithValue(dev),
          prefsProvider.overrideWithValue(JsonCache.inDirectory(dir)),
          bootPrefsProvider.overrideWithValue({AppLockController.key: enabled ? true : null}),
          authProvider.overrideWith(_Auth.new),
        ],
      );
      addTearDown(c.dispose);
      await c.read(authProvider.future);
      return (c, dev);
    }

    test('off by default, not locked', () async {
      final (c, _) = await setup();
      expect(c.read(appLockProvider).enabled, isFalse);
      expect(c.read(appLockProvider).locked, isFalse);
    });

    test('a saved lock starts locked and opens with the phone check', () async {
      final (c, dev) = await setup(enabled: true);
      expect(c.read(appLockProvider).locked, isTrue);
      dev.passes = false;
      await c.read(appLockProvider.notifier).unlock('r');
      expect(c.read(appLockProvider).locked, isTrue);
      dev.passes = true;
      await c.read(appLockProvider.notifier).unlock('r');
      expect(c.read(appLockProvider).locked, isFalse);
      expect(c.read(appLockProvider).enabled, isTrue);
    });

    test('turning on needs one successful check', () async {
      final (c, dev) = await setup(device: _Device(passes: false));
      expect(await c.read(appLockProvider.notifier).enable('r'), isFalse);
      expect(c.read(appLockProvider).enabled, isFalse);
      dev.passes = true;
      expect(await c.read(appLockProvider.notifier).enable('r'), isTrue);
      expect(c.read(appLockProvider).enabled, isTrue);
      expect(c.read(appLockProvider).locked, isFalse);
    });

    test('a phone without screen lock cannot be enabled, and releases an old lock', () async {
      final (c, dev) = await setup(enabled: true, device: _Device(supported: false));
      expect(await c.read(appLockProvider.notifier).enable('r'), isFalse);
      await c.read(appLockProvider.notifier).unlock('r');
      expect(c.read(appLockProvider).enabled, isFalse);
      expect(c.read(appLockProvider).locked, isFalse);
      expect(dev.asked, 0);
    });
  });
}
