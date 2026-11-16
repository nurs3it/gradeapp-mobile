import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/grading.dart';
import '../../core/json.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';

/// Grading scale + attendance codes of the active school. Falls back to the
/// 5-point default while loading or if the school endpoint is not readable.
final gradingProvider = StreamProvider<Grading>((ref) {
  final school = ref.watch(authProvider.select((u) => u.value?.linkedSchool));
  if (school == null) return Stream.value(Grading.fallback);
  return cachedGet(ref, '/schools/$school/', parse: (d) => Grading.fromSchool(d as Json));
});

final gradingOrDefaultProvider = Provider<Grading>((ref) => ref.watch(gradingProvider).value ?? Grading.fallback);
