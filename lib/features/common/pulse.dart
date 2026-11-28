import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/json.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';

/// Badges from `GET /me/pulse/` (C4).
class Pulse {
  const Pulse({
    this.notificationsUnread = 0,
    this.inbox = 0,
    this.billingPayable = 0,
    this.chatUnread = 0,
    this.pollSeconds = 60,
  });
  final int notificationsUnread;

  /// Conversations with something unread.
  final int chatUnread;
  final int inbox;
  final int billingPayable;
  final int pollSeconds;

  factory Pulse.fromJson(Json j) => Pulse(
    notificationsUnread: (j.number('notifications_unread') ?? 0).toInt(),
    inbox: ((j['inbox'] as Json?)?.number('total') ?? 0).toInt(),
    billingPayable: ((j['billing'] as Json?)?.number('payable') ?? 0).toInt(),
    chatUnread: (j.number('chat_unread') ?? 0).toInt(),
    pollSeconds: (j.number('poll_seconds') ?? 60).toInt().clamp(30, 600),
  );
}

/// Polls the pulse while the app is on screen, no more often than the server
/// asks. Coming back online also pushes the teacher's outbox.
class PulseController extends Notifier<Pulse> {
  Timer? _timer;
  AppLifecycleListener? _life;

  @override
  Pulse build() {
    final signedIn = ref.watch(authProvider.select((u) => u.value != null));
    ref.watch(schoolIdProvider);
    void stop() {
      _timer?.cancel();
      _timer = null;
      _life?.dispose();
      _life = null;
    }

    stop();
    ref.onDispose(stop);
    if (!signedIn) return const Pulse();
    _life = AppLifecycleListener(
      onResume: () {
        unawaited(refresh());
        unawaited(ref.read(outboxProvider).flush());
      },
      onPause: () => _timer?.cancel(),
    );
    scheduleMicrotask(refresh);
    return const Pulse();
  }

  Future<void> refresh() async {
    _timer?.cancel();
    try {
      final res = await ref.read(dioProvider).get<Json>('/me/pulse/');
      final wasOffline = ref.read(netProvider).offline;
      ref.read(netProvider.notifier).online();
      if (wasOffline) unawaited(ref.read(outboxProvider).flush());
      state = Pulse.fromJson(res.data!);
    } catch (e) {
      if (isOffline(e)) ref.read(netProvider.notifier).offline();
    }
    _timer = Timer(Duration(seconds: state.pollSeconds), refresh);
  }

  /// After reading notifications: drop the badge at once.
  void seen() =>
      state = Pulse(
        inbox: state.inbox,
        billingPayable: state.billingPayable,
        chatUnread: state.chatUnread,
        pollSeconds: state.pollSeconds,
      );
}

final pulseProvider = NotifierProvider<PulseController, Pulse>(PulseController.new);
