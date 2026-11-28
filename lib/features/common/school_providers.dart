import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/grading.dart';
import '../../core/json.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import 'models.dart';

/// School flags of the mobile app (B9): a disabled flag hides the feature.
class MobileFlags {
  const MobileFlags({
    this.streaksEnabled = false,
    this.weeklyDigestEnabled = false,
    this.checkinMissingAlert = false,
    this.liveActivityEnabled = false,
  });
  final bool streaksEnabled;

  /// W6 «Мой учебный день» (backend B6).
  final bool liveActivityEnabled;
  final bool weeklyDigestEnabled;
  final bool checkinMissingAlert;

  factory MobileFlags.fromJson(Json j) => MobileFlags(
    streaksEnabled: j.flag('streaks_enabled'),
    weeklyDigestEnabled: j.flag('weekly_digest_enabled'),
    checkinMissingAlert: j.flag('checkin_missing_alert'),
    liveActivityEnabled: j.flag('live_activity_enabled'),
  );
}

/// The active school: grading config, check-in flag, terms.
class School {
  const School({
    required this.id,
    required this.name,
    required this.grading,
    this.checkinEnabled = false,
    this.mobile = const MobileFlags(),
    this.lat,
    this.lon,
  });
  final String id;
  final String name;
  final Grading grading;
  final bool checkinEnabled;

  /// Mobile mechanics the school switched on (`mobile` of `/schools/{id}/`).
  final MobileFlags mobile;

  /// School location (for «Вы у школы / Далеко» in the camera).
  final double? lat;
  final double? lon;

  factory School.fromJson(Json j) => School(
    id: j.str('id'),
    name: j.str('name'),
    grading: Grading.fromSchool(j),
    checkinEnabled: j.flag('checkin_enabled'),
    mobile: MobileFlags.fromJson((j['mobile'] as Json?) ?? const {}),
    lat: j.number('latitude')?.toDouble(),
    lon: j.number('longitude')?.toDouble(),
  );
}

final schoolProvider = StreamProvider<School?>((ref) {
  final id = ref.watch(schoolIdProvider);
  if (id == null) return Stream.value(null);
  return cachedGet(ref, '/schools/$id/', parse: (d) => School.fromJson(d as Json));
});

final mobileFlagsProvider = Provider<MobileFlags>(
  (ref) => ref.watch(schoolProvider.select((s) => s.value?.mobile)) ?? const MobileFlags(),
);

/// Grading scale of the active school; the KZ preset while loading.
final gradingProvider = Provider<Grading>(
  (ref) => ref.watch(schoolProvider.select((s) => s.value?.grading)) ?? Grading.fallback,
);

/// Whether the school's formula is known (quarter marks are hidden otherwise).
final gradingLoadedProvider = Provider<bool>((ref) => ref.watch(schoolProvider.select((s) => s.value != null)));

/// Quarters of the current academic year, in order.
final termsProvider = StreamProvider<List<Term>>((ref) {
  ref.watch(schoolIdProvider);
  return cachedGet(
    ref,
    '/schools/academic-terms/',
    query: const {'page_size': 50},
    parse: (d) {
      final raw = resultsOf(d);
      final all = raw.map(Term.fromJson).toList();
      // Keep the year of the current term (several years may be listed).
      final current = raw.where((t) => t.flag('is_current')).firstOrNull;
      final year = current?.str('academic_year');
      final terms = year == null
          ? all
          : [
              for (final t in raw)
                if (t.str('academic_year') == year) Term.fromJson(t),
            ];
      return terms..sort((a, b) => a.number.compareTo(b.number));
    },
  );
});

/// The current quarter: flagged by the school, else the one containing today,
/// else the last started one.
Term? currentTermOf(List<Term> terms, DateTime now) {
  if (terms.isEmpty) return null;
  final today = isoDate(now);
  return terms.where((t) => t.isCurrent).firstOrNull ??
      terms.where((t) => t.contains(today)).firstOrNull ??
      terms.where((t) => t.start.compareTo(today) <= 0).lastOrNull ??
      terms.first;
}
