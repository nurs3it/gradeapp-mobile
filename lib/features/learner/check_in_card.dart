import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'learner_providers.dart';
import 'models.dart';

/// «Я в школе». Student: one big button → selfie (+ location when the school
/// has a geofence) → done. Parent: read-only status of the child.
class CheckInCard extends ConsumerStatefulWidget {
  const CheckInCard({super.key, required this.status, required this.actionable});
  final CheckInStatus status;
  final bool actionable;

  @override
  ConsumerState<CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends ConsumerState<CheckInCard> {
  bool _busy = false;

  Future<void> _checkIn() async {
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      Position? pos;
      if (widget.status.geofence) {
        pos = await _locate();
        if (pos == null) {
          if (mounted) showGToast(context, l.checkInLocationDenied, error: true);
          return;
        }
      }
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (photo == null) return;
      await checkIn(ref, photoPath: photo.path, latitude: pos?.latitude, longitude: pos?.longitude);
      unawaited(HapticFeedback.heavyImpact());
      if (mounted) showGToast(context, l.checkInSuccess);
    } on DioException catch (e) {
      if (mounted) showGToast(context, _reason(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Position?> _locate() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)),
    );
  }

  String _reason(DioException e) {
    final l = context.l10n;
    final body = e.response?.data;
    return switch (checkInErrorCode(e)) {
      'window_closed' => l.checkInClosed,
      'consent_required' => l.checkInNoConsent,
      'location_required' => l.checkInLocationDenied,
      'outside_area' => l.checkInOutside(body is Map ? (body['distance_m'] as num? ?? 0).round() : 0),
      'stale_photo' || 'photo_required' => l.checkInStale,
      'already_checked_in' => l.checkInAlready,
      _ => l.errorMessage,
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status;
    final l = context.l10n;
    final c = context.c;

    if (s.checkedIn) {
      final time = s.checkedAt == null ? '' : clock(s.checkedAt!);
      return _Frame(
        icon: Icons.verified_rounded,
        iconColor: s.late ? c.warningText : c.successText,
        title: widget.actionable ? l.checkInDone(time) : l.childCheckedIn(time),
        trailing: s.late ? GPill(l.checkInLate, tone: GTone.warning) : null,
      );
    }
    if (!widget.actionable) {
      return _Frame(
        icon: Icons.schedule_rounded,
        iconColor: c.mutedForeground,
        title: l.childNotCheckedIn,
        subtitle: l.checkInWindow(s.windowStart, s.windowEnd),
      );
    }
    if (!s.consent) {
      return _Frame(
        icon: Icons.lock_outline_rounded,
        iconColor: c.mutedForeground,
        title: l.checkInTitle,
        subtitle: l.checkInNoConsent,
      );
    }
    if (!s.windowOpen) {
      return _Frame(
        icon: Icons.schedule_rounded,
        iconColor: c.mutedForeground,
        title: l.checkInTitle,
        subtitle: l.checkInWindow(s.windowStart, s.windowEnd),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpace.page),
      child: Material(
        color: c.primary,
        borderRadius: BorderRadius.circular(GRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _busy ? null : _checkIn,
          child: Padding(
            padding: const EdgeInsets.all(GSpace.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(GRadius.control),
                  ),
                  child: _busy
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.photo_camera_front_rounded, color: Colors.white),
                ),
                const SizedBox(width: GSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _busy ? l.checkInSending : l.checkInTitle,
                        style: context.t.titleMedium!.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.checkInHint,
                        style: context.t.bodySmall!.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.icon, required this.iconColor, required this.title, this.subtitle, this.trailing});
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: GSpace.page),
    child: GCard(
      padding: EdgeInsets.zero,
      child: GRow(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(title, style: context.t.titleSmall!.copyWith(fontSize: 16)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: trailing,
      ),
    ),
  );
}
