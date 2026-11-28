import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../learner/learner_providers.dart';
import 'check_in_state.dart';

/// «Я в школе» on the student's «Сегодня» (§3.15). Loud (brand) only while
/// the window is open and the student has not checked in.
class CheckInCard extends ConsumerWidget {
  const CheckInCard({super.key, required this.status, required this.state, this.dayOver = false});
  final CheckInStatus status;
  final CheckInCardState state;

  /// Every lesson has ended: «В школе с …» is no longer true.
  final bool dayOver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.t;
    final run = ref.watch(checkInProvider);
    switch (state) {
      case CheckInCardState.hidden:
        return const SizedBox.shrink();
      case CheckInCardState.done || CheckInCardState.late:
        final late = state == CheckInCardState.late;
        final at = status.checkedAt ?? run.at;
        final time = at == null ? '' : Fmt.clock(at);
        return _Pill(
          icon: late ? GIcons.clock : GIcons.check,
          tone: late ? GTone.warn : GTone.ok,
          title: late ? l.checkInLateAt(time) : (dayOver ? l.checkInMarkedAt(time) : l.checkInDoneAt(time)),
          subtitle: dayOver ? l.wgChildDayOver : (late ? null : l.checkInOnTime),
        );
      case CheckInCardState.opensLater:
        return _Quiet(icon: GIcons.lock, title: l.checkInOpensAt(status.windowStart));
      case CheckInCardState.closed:
        return _Quiet(icon: GIcons.clock, title: l.checkInClosed(status.windowEnd), message: l.checkInClosedHint);
      case CheckInCardState.noConsent:
        return _Quiet(
          icon: GIcons.lock,
          tone: GTone.warn,
          title: l.checkInNoConsent,
          message: l.checkInAskParentHint,
          action: l.p7Ask,
          onAction: () => unawaited(_askParent(context, ref)),
        );
      case CheckInCardState.open:
        final sending = run.phase == CheckInPhase.sending;
        final failed = run.phase == CheckInPhase.failed;
        return GHeroSheet(
          color: GColors.brand,
          onTap: sending ? null : () => context.push('/checkin'),
          semanticLabel: '${l.checkInTitle}. ${l.checkInBy(status.windowEnd)}. ${l.checkInSubtitle}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.checkInBy(status.windowEnd).toUpperCase(),
                          style: t.eyebrow.copyWith(color: GColors.onFill.withValues(alpha: 0.88)),
                        ),
                        const SizedBox(height: 6),
                        Text(l.checkInTitle, style: t.title1.copyWith(color: GColors.onFill)),
                        const SizedBox(height: 4),
                        Text(
                          sending ? l.checkInSendingPct((run.progress * 100).round()) : l.checkInSubtitle,
                          style: t.callout.copyWith(color: GColors.onFill.withValues(alpha: 0.88)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(color: GColors.onFill, shape: BoxShape.circle),
                    child: sending
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              value: run.progress,
                              strokeWidth: 4,
                              color: GColors.brand,
                              backgroundColor: GColors.brand.withValues(alpha: 0.15),
                            ),
                          )
                        : const GIcon(GIcons.checkIn, size: 30, color: GColors.brand),
                  ),
                ],
              ),
              if (failed) ...[const SizedBox(height: 14), _ErrorRow(run: run, status: status)],
            ],
          ),
        );
    }
  }
}

class _ErrorRow extends ConsumerWidget {
  const _ErrorRow({required this.run, required this.status});
  final CheckInRun run;
  final CheckInStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final ctrl = ref.read(checkInProvider.notifier);
    Future<void> retry() async {
      final ok = await ctrl.retry(geofence: status.geofence);
      if (ok) {
        GHaptics.success();
      } else {
        GHaptics.error();
      }
    }

    final (String title, String? action, VoidCallback? onAction) = switch (run.code) {
      'outside_area' => (l.checkInOutside(run.distance ?? 0), l.retry, retry),
      'location_required' => (
        l.checkInNeedLocation,
        l.openSettings,
        () => unawaited(Geolocator.openLocationSettings()),
      ),
      'stale_photo' || 'photo_required' => (l.checkInStale, l.checkInOpenCamera, () => context.push('/checkin')),
      'window_closed' => (l.checkInWindowClosed, null, null),
      'consent_required' => (l.checkInNoConsent, null, null),
      _ when run.offline => (l.checkInOffline, l.retry, retry),
      _ => (l.checkInFailed, l.retry, run.canResend ? retry : () => context.push('/checkin')),
    };
    return GStateRow(title: title, tone: GTone.bad, action: action, onAction: onAction);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.tone, required this.title, this.subtitle});
  final IconData icon;
  final GTone tone;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      label: [title, ?subtitle].join('. '),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: ShapeDecoration(color: c.surface, shape: const StadiumBorder(), shadows: GDepth.level1(c)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: tone.soft(c), shape: BoxShape.circle),
              child: GIcon(icon, size: 22, color: tone.fg(c), fill: 1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: context.t.bodyStrong, maxLines: 2),
                  if (subtitle != null) Text(subtitle!, style: context.t.footnote.copyWith(color: c.ink2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet({required this.icon, required this.title, this.message, this.tone, this.action, this.onAction});
  final IconData icon;
  final String title;
  final String? message;
  final GTone? tone;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GCard(
      color: tone?.soft(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GIcon(icon, size: 22, color: tone?.fg(c) ?? c.ink2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: context.t.bodyStrong.copyWith(color: tone?.fg(c))),
              ),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!, style: context.t.footnote.copyWith(color: c.ink2)),
          ],
          if (action != null) ...[
            const SizedBox(height: 10),
            GButton(label: action!, size: GButtonSize.s, variant: GButtonVariant.tinted, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// P7: «Попросить родителя» — one request a day; the parent gets a push.
Future<void> _askParent(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final id = ref.read(myStudentIdProvider);
  if (id == null) return;
  String message;
  var icon = GIcons.ok;
  try {
    await ref.read(dioProvider).post<Object?>('/students/$id/photo-consent/request/');
    GHaptics.success();
    message = l.p7Sent;
  } on DioException catch (e) {
    GHaptics.error();
    icon = GIcons.error;
    switch (e.response?.statusCode) {
      case 429:
        message = l.p7TooSoon;
      case 409:
        message = l.p7AlreadyGranted;
        ref.invalidate(learnerDayProvider);
      default:
        message = l.errorGeneric;
    }
  }
  if (context.mounted) GToast.show(context, message, icon: icon);
}
