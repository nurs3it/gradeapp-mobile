import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/settings.dart';
import 'core/api/api_client.dart';
import 'core/api/session_store.dart';
import 'core/offline/outbox.dart';
import 'core/providers.dart';
import 'core/storage/json_cache.dart';
import 'features/auth/auth_controller.dart';
import 'features/learner/learner_providers.dart';
import 'features/notifications/push.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (cache, prefs, outbox, _) = await (JsonCache.open(), JsonCache.open('prefs'), Outbox.open(), Push.init()).wait;
  final boot = {
    for (final k in [SettingsController.key, ActiveRole.key, SelectedChild.key]) k: await prefs.read(k),
  };
  final sessions = SessionStore();
  late final ProviderContainer container;
  final api = ApiClient(sessions, onSessionLost: () => container.read(authProvider.notifier).sessionLost());
  outbox.attach(api.dio);

  container = ProviderContainer(
    overrides: [
      sessionStoreProvider.overrideWithValue(sessions),
      jsonCacheProvider.overrideWithValue(cache),
      prefsProvider.overrideWithValue(prefs),
      bootPrefsProvider.overrideWithValue(boot),
      outboxProvider.overrideWithValue(outbox),
      apiClientProvider.overrideWithValue(api),
    ],
  );

  runApp(UncontrolledProviderScope(container: container, child: const GradeApp()));
}
