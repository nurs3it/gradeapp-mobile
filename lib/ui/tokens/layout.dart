import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'colors.dart';

/// Spacing (design-system §2.3), 4-pt grid.
abstract final class GSpace {
  static const x2 = 2.0;
  static const x4 = 4.0;
  static const x6 = 6.0;
  static const x8 = 8.0;
  static const x12 = 12.0;
  static const x16 = 16.0;
  static const x20 = 20.0;
  static const x24 = 24.0;
  static const x28 = 28.0;
  static const x32 = 32.0;
  static const x40 = 40.0;
  static const x56 = 56.0;

  static const sectionTop = 26.0;
  static const sectionGap = 10.0;
  static const stackGap = 12.0;
  static const cardPad = 16.0;
  static const heroPad = 20.0;
  static const rowMin = 60.0;
  static const rowCompact = 52.0;
  static const touch = 44.0;
  static const tabbarH = 64.0;
  static const tabbarBottom = 22.0;
  static const tabbarSide = 16.0;

  /// Scroll bottom padding under the floating capsule.
  static const contentBottom = tabbarH + tabbarBottom + 16;

  /// Screen gutter: 20, or 16 on narrow phones (< 380).
  static double gutter(BuildContext context) => MediaQuery.sizeOf(context).width < 380 ? 16 : 20;
}

/// Radii (§2.4). Surfaces ≥ 22 use a continuous (superellipse) corner.
abstract final class GRadius {
  static const badge = 7.0;
  static const key = 20.0;
  static const field = 16.0;
  static const card = 26.0;
  static const hero = 32.0;
  static const sheet = 38.0;

  static double grade(double height) => height * 0.34;

  static ShapeBorder surface(double r) => RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(r));
}

/// Depth (§2.5): one cheap shadow at most, none in the dark theme.
abstract final class GDepth {
  static List<BoxShadow> level1(GColors c) => c.isDark
      ? const []
      : [BoxShadow(color: c.shadowTint.withValues(alpha: 0.05), offset: const Offset(0, 1), blurRadius: 2)];

  static List<BoxShadow> level2(GColors c) => c.isDark
      ? [
          BoxShadow(
            color: c.shadowTint.withValues(alpha: 0.6),
            offset: const Offset(0, 12),
            blurRadius: 32,
            spreadRadius: -6,
          ),
        ]
      : [
          BoxShadow(
            color: c.shadowTint.withValues(alpha: 0.18),
            offset: const Offset(0, 12),
            blurRadius: 32,
            spreadRadius: -8,
          ),
          BoxShadow(color: c.shadowTint.withValues(alpha: 0.06), offset: const Offset(0, 2), blurRadius: 6),
        ];

  static List<BoxShadow> sheet(GColors c) => c.isDark
      ? const []
      : [BoxShadow(color: c.shadowTint.withValues(alpha: 0.16), offset: const Offset(0, -10), blurRadius: 40)];

  /// Segmented thumb.
  static List<BoxShadow> thumb(GColors c) => c.isDark
      ? const []
      : [BoxShadow(color: c.shadowTint.withValues(alpha: 0.12), offset: const Offset(0, 1), blurRadius: 3)];
}

/// Motion (§2.6): durations, curves, springs.
abstract final class GMotion {
  static const instant = Duration(milliseconds: 90);
  static const quick = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 240);
  static const reduced = Duration(milliseconds: 200);

  static const standard = Cubic(0.32, 0.72, 0, 1);
  static const emphasized = Cubic(0.05, 0.7, 0.1, 1);
  static const exit = Cubic(0.3, 0, 0.8, 0.15);

  static const snap = SpringDescription(mass: 1, stiffness: 632, damping: 43.2);
  static const smooth = SpringDescription(mass: 1, stiffness: 273, damping: 29.8);
  static const sheet = SpringDescription(mass: 1, stiffness: 224, damping: 29.9);
  static const bouncy = SpringDescription(mass: 1, stiffness: 195, damping: 19);
  static const celebrate = SpringDescription(mass: 1, stiffness: 110, damping: 12.6);

  /// «Уменьшить движение»: springs and scales become a 200 ms cross-fade.
  static bool reduce(BuildContext context) => MediaQuery.disableAnimationsOf(context);
}

/// A spring as a [Curve] for implicit animations (`AnimatedSlide` & co).
class SpringCurve extends Curve {
  SpringCurve(this.spring) : _sim = SpringSimulation(spring, 0, 1, 0), settle = _settle(spring);
  final SpringDescription spring;
  final SpringSimulation _sim;

  /// Seconds until the spring is visually at rest.
  final double settle;

  static double _settle(SpringDescription spring) {
    final sim = SpringSimulation(spring, 0, 1, 0, tolerance: const Tolerance(distance: 0.002, velocity: 0.02));
    var s = 0.0;
    while (!sim.isDone(s) && s < 2) {
      s += 0.01;
    }
    return s;
  }

  // Normalised so the spring settles at t = 1.
  @override
  double transformInternal(double t) => t >= 1 ? 1 : _sim.x(t * settle);

  /// Matching duration for an implicit animation.
  Duration get duration => Duration(milliseconds: (settle * 1000).round());

  static final snap = SpringCurve(GMotion.snap);
  static final smooth = SpringCurve(GMotion.smooth);
  static final sheet = SpringCurve(GMotion.sheet);
  static final bouncy = SpringCurve(GMotion.bouncy);
  static final celebrate = SpringCurve(GMotion.celebrate);
}
