import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/common/pulse.dart';
import '../l10n/l10n.dart';
import '../ui/ui.dart';
import 'router.dart';
import 'settings.dart';

final _light = buildTheme(Brightness.light);
final _dark = buildTheme(Brightness.dark);

class GradeApp extends ConsumerStatefulWidget {
  const GradeApp({super.key});

  @override
  ConsumerState<GradeApp> createState() => _GradeAppState();
}

class _GradeAppState extends ConsumerState<GradeApp> {
  StreamSubscription<Object?>? _refused;

  @override
  void initState() {
    super.initState();
    final outbox = ref.read(outboxProvider);
    unawaited(outbox.flush());
    // A refused record is shown in the lesson and the queue; the haptic tells
    // the teacher right away (§2.7).
    _refused = outbox.rejectedEvents.stream.listen((_) => GHaptics.error());
  }

  @override
  void dispose() {
    unawaited(_refused?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    // Keeps badges and the connectivity probe alive while signed in.
    ref.watch(pulseProvider.select((_) => 0));
    return MaterialApp.router(
      title: 'GradeApp',
      debugShowCheckedModeBanner: false,
      theme: _light,
      darkTheme: _dark,
      themeMode: settings.themeMode,
      themeAnimationDuration: GMotion.base,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      // Dynamic Type: honour the system scale up to 1.35 (§2.2).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final scale = math.min(mq.textScaler.scale(1), GScale.max);
        return MediaQuery(data: mq.copyWith(textScaler: TextScaler.linear(scale)), child: child!);
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
