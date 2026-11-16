import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/api/api_client.dart';
import '../common/models.dart';
import '../learner/learner_providers.dart';

enum CheckInPhase { idle, sending, failed, done }

/// One «Я в школе» attempt: the photo is kept so «Повторить» does not need a
/// new shot while the window is open (S2).
class CheckInRun {
  const CheckInRun({
    this.phase = CheckInPhase.idle,
    this.progress = 0,
    this.code,
    this.distance,
    this.offline = false,
    this.photoPath,
    this.lat,
    this.lon,
    this.at,
  });

  final CheckInPhase phase;
  final double progress;

  /// Backend refusal code (`outside_area`, `consent_required`…).
  final String? code;
  final int? distance;
  final bool offline;
  final String? photoPath;
  final double? lat;
  final double? lon;

  /// Local time of the successful check-in.
  final DateTime? at;

  /// The shot can be sent again (network problem, not a refusal of the photo).
  bool get canResend => photoPath != null && (offline || code == null || code == 'outside_area');

  CheckInRun copy({
    CheckInPhase? phase,
    double? progress,
    String? code,
    int? distance,
    bool? offline,
    DateTime? at,
  }) => CheckInRun(
    phase: phase ?? this.phase,
    progress: progress ?? this.progress,
    code: code,
    distance: distance,
    offline: offline ?? false,
    photoPath: photoPath,
    lat: lat,
    lon: lon,
    at: at ?? this.at,
  );
}

class CheckInController extends Notifier<CheckInRun> {
  @override
  CheckInRun build() => const CheckInRun();

  void reset() => state = const CheckInRun();

  /// Sends the selfie (and location when the school has a geofence).
  Future<bool> submit({required String photoPath, double? lat, double? lon}) async {
    state = CheckInRun(phase: CheckInPhase.sending, photoPath: photoPath, lat: lat, lon: lon);
    return _send();
  }

  /// «Повторить» from the card: same photo, fresh location if needed.
  Future<bool> retry({bool geofence = false}) async {
    if (state.photoPath == null) return false;
    var (lat, lon) = (state.lat, state.lon);
    if (geofence) {
      final p = await locate();
      lat = p?.latitude ?? lat;
      lon = p?.longitude ?? lon;
    }
    state = CheckInRun(phase: CheckInPhase.sending, photoPath: state.photoPath, lat: lat, lon: lon);
    return _send();
  }

  Future<bool> _send() async {
    try {
      await postCheckIn(
        ref,
        photoPath: state.photoPath!,
        latitude: state.lat,
        longitude: state.lon,
        onProgress: (p) => state = state.copy(phase: CheckInPhase.sending, progress: p),
      );
      state = state.copy(phase: CheckInPhase.done, progress: 1, at: DateTime.now());
      ref.invalidate(learnerDayProvider);
      return true;
    } catch (e) {
      final err = checkInError(e);
      if (err.code == 'already_checked_in') {
        state = state.copy(phase: CheckInPhase.done, at: DateTime.now());
        ref.invalidate(learnerDayProvider);
        return true;
      }
      state = state.copy(phase: CheckInPhase.failed, code: err.code, distance: err.distance, offline: isOffline(e));
      return false;
    }
  }

  /// Current position, or null when location is off or denied.
  static Future<Position?> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)),
      );
    } catch (_) {
      return null;
    }
  }
}

final checkInProvider = NotifierProvider<CheckInController, CheckInRun>(CheckInController.new);

/// Where the check-in card stands (design-system §3.15).
enum CheckInCardState { hidden, opensLater, open, done, late, closed, noConsent }

CheckInCardState checkInCardState(CheckInStatus? s, DateTime now) {
  if (s == null || !s.enabled) return CheckInCardState.hidden;
  if (s.checkedIn) return s.late ? CheckInCardState.late : CheckInCardState.done;
  if (!s.consent) return CheckInCardState.noConsent;
  if (s.windowOpen) return CheckInCardState.open;
  final m = now.hour * 60 + now.minute;
  return m < minutesOf(s.windowStart) ? CheckInCardState.opensLater : CheckInCardState.closed;
}
