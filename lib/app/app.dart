import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/auth/auth_controller.dart';
import '../features/learner/learner_providers.dart';
import '../features/common/pulse.dart';
import '../features/notifications/notifications.dart';
import '../features/notifications/push.dart';
import '../features/platform/lesson_live.dart';
import '../features/platform/local_notifications.dart';
import '../features/platform/platform_host.dart';
import '../features/platform/push_background.dart';
import '../features/platform/push_intent.dart';
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
  late final PlatformHost _host = PlatformHost(ref);
  late final AppLifecycleListener _life = AppLifecycleListener(onResume: _onResume);

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
    _listenPlatform();
  }

  /// Widgets, reminders and the lock-screen lesson follow the account.
  void _listenPlatform() {
    _life;
    _subs.add(LocalNotifications.taps.listen(_openLocal));
    unawaited(
      LocalNotifications.launchResponse().then((r) {
        if (r != null) _openLocal(r);
      }),
    );
    ref
      ..listenManual(authProvider.select((a) => a.value?.id), (prev, id) {
        if (id == null && prev != null) {
          unawaited(_host.onSignedOut());
        } else if (id != null) {
          unawaited(_host.refresh(force: true));
        }
      })
      ..listenManual(activeRoleProvider, (_, _) => unawaited(_host.refresh(force: true)))
      ..listenManual(learnerIdProvider, (_, _) => unawaited(_host.refresh(force: true)));
    unawaited(ref.read(authProvider.future).then((_) => _onResume()));
  }

  void _onResume() {
    unawaited(_host.refresh());
    unawaited(
      resolveL10n(ref.read(prefsProvider)).then((l) => LessonLive.sweep(l, ref.read(prefsProvider))),
    );
  }

  /// Tap or button on a notification this app drew itself (Android pushes,
  /// reminders, the lesson in progress).
  void _openLocal(NotificationResponse r) {
    unawaited(_openData(LocalNotifications.decode(r.payload), r.actionId));
  }

  Future<void> _openData(Map<String, dynamic> data, String? actionId) async {
    while (_nav == null) {
      await WidgetsBinding.instance.endOfFrame;
    }
    if (mounted) await openPush(_nav!, ref, data, actionId: actionId);
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

  Future<void> _open(RemoteMessage m) => _openData(m.data, m.actionIdentifier);

  /// In the app a push is a toast, not a system banner (C5: no duplicates).
  void _onForeground(RemoteMessage m) {
    final intent = intentFor(m.data);
    // Silent sync (W9): refresh quietly, show nothing.
    if (intent is SyncIntent) {
      unawaited(_host.onSync(intent));
      return;
    }
    unawaited(ref.read(pulseProvider.notifier).refresh());
    ref.invalidate(notificationsProvider);
    final ctx = _nav;
    final n = m.notification;
    // Data-only pushes (Android, with buttons when backgrounded) carry their
    // text in `data`.
    final title = n?.title ?? m.data['title'] as String?;
    final body = n?.body ?? m.data['body'] as String?;
    if (ctx == null || (title == null && body == null)) return;
    final text = [title, body].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    GToast.show(ctx, text, icon: GIcons.bell, actionLabel: ctx.l10n.notifOpen, onAction: () => unawaited(_open(m)));
  }

  /// Android channels carry the app language; re-created when it changes.
  void _syncChannels(BuildContext context) {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final locale = Localizations.localeOf(context);
    if (locale == _channelsLocale) return;
    _channelsLocale = locale;
    final l = context.l10n;
    // iOS action titles and the extra Android channels follow the language.
    unawaited(LocalNotifications.init(l, onBackgroundResponse: notificationActionInBackground));
    if (Platform.isAndroid) {
      unawaited(SystemBridge.createChannels(l));
      unawaited(LocalNotifications.ensureChannels(l));
    }
  }

  @override
  void dispose() {
    _life.dispose();
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
