import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/auth/auth_controller.dart';
import '../features/common/pulse.dart';
import '../features/notifications/notifications.dart';
import '../features/notifications/push.dart';
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
  final _subs = <StreamSubscription<Object?>>[];
  Locale? _channelsLocale;

  @override
  void initState() {
    super.initState();
    final outbox = ref.read(outboxProvider);
    unawaited(outbox.flush());
    // A refused record is shown in the lesson and the queue; the haptic tells
    // the teacher right away (§2.7).
    _subs.add(outbox.rejectedEvents.stream.listen((_) => GHaptics.error()));
    // The app icon badge follows the unread count of the bell.
    ref.listenManual(pulseProvider.select((p) => p.notificationsUnread), (_, n) => unawaited(SystemBridge.setBadge(n)));
    if (Push.enabled) _listenPush();
  }

  void _listenPush() {
    _subs
      ..add(FirebaseMessaging.onMessage.listen(_onForeground))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen(_open));
    unawaited(
      FirebaseMessaging.instance.getInitialMessage().then((m) {
        if (m != null) unawaited(_open(m));
      }),
    );
    unawaited(
      ref.read(authProvider.future).then((u) {
        if (u != null) unawaited(ref.read(pushProvider).register());
      }),
    );
  }

  BuildContext? get _nav => ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;

  Future<void> _open(RemoteMessage m) async {
    while (_nav == null) {
      await WidgetsBinding.instance.endOfFrame;
    }
    if (mounted) await openPush(_nav!, ref, m);
  }

  /// In the app a push is a toast, not a system banner (C5: no duplicates).
  void _onForeground(RemoteMessage m) {
    unawaited(ref.read(pulseProvider.notifier).refresh());
    ref.invalidate(notificationsProvider);
    final ctx = _nav;
    final n = m.notification;
    if (ctx == null || n == null) return;
    final text = [n.title, n.body].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    GToast.show(ctx, text, icon: GIcons.bell, actionLabel: ctx.l10n.notifOpen, onAction: () => unawaited(_open(m)));
  }

  /// Android channels carry the app language; re-created when it changes.
  void _syncChannels(BuildContext context) {
    if (!Platform.isAndroid) return;
    final locale = Localizations.localeOf(context);
    if (locale == _channelsLocale) return;
    _channelsLocale = locale;
    unawaited(SystemBridge.createChannels(context.l10n));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
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
        _syncChannels(context);
        final mq = MediaQuery.of(context);
        final scale = math.min(mq.textScaler.scale(1), GScale.max);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
