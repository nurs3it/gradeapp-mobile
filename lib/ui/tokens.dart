import 'package:flutter/material.dart';

/// GradeApp design tokens v3 («Четыре страницы»), 1:1 with the web's
/// `frontend/src/shared/styles/index.css`. Change values there first.
Color _h(double h, double s, double l, [double a = 1]) => HSLColor.fromAHSL(a, h, s / 100, l / 100).toColor();

@immutable
class GColors extends ThemeExtension<GColors> {
  const GColors({
    required this.brand,
    required this.background,
    required this.foreground,
    required this.card,
    required this.popover,
    required this.surfaceMuted,
    required this.surfaceSunken,
    required this.primary,
    required this.primarySoft,
    required this.primarySoftForeground,
    required this.primaryText,
    required this.muted,
    required this.mutedForeground,
    required this.subtleForeground,
    required this.border,
    required this.divider,
    required this.inputBorder,
    required this.destructive,
    required this.destructiveText,
    required this.success,
    required this.successText,
    required this.warning,
    required this.warningForeground,
    required this.warningText,
    required this.info,
    required this.infoText,
    required this.gradeGood,
    required this.overlay,
    required this.lessons,
  });

  final Color brand;
  final Color background;
  final Color foreground;
  final Color card;
  final Color popover;
  final Color surfaceMuted;
  final Color surfaceSunken;
  final Color primary;
  final Color primarySoft;
  final Color primarySoftForeground;
  final Color primaryText;
  final Color muted;
  final Color mutedForeground;
  final Color subtleForeground;
  final Color border;
  final Color divider;
  final Color inputBorder;
  final Color destructive;
  final Color destructiveText;
  final Color success;
  final Color successText;
  final Color warning;
  final Color warningForeground;
  final Color warningText;
  final Color info;
  final Color infoText;
  final Color gradeGood;
  final Color overlay;

  /// Subject colours of the schedule (`--lesson-1..8`): subjects only, not decor.
  final List<Color> lessons;

  static final light = GColors(
    brand: _h(216, 91, 44),
    background: _h(220, 20, 97),
    foreground: _h(220, 16, 10),
    card: Colors.white,
    popover: Colors.white,
    surfaceMuted: _h(220, 16, 95),
    surfaceSunken: _h(220, 18, 93),
    primary: _h(216, 91, 44),
    primarySoft: _h(216, 100, 96),
    primarySoftForeground: _h(216, 91, 38),
    primaryText: _h(216, 91, 44),
    muted: _h(220, 16, 95),
    mutedForeground: _h(220, 9, 43),
    subtleForeground: _h(220, 8, 55),
    border: _h(220, 14, 89),
    divider: _h(220, 14, 93),
    inputBorder: _h(220, 9, 56),
    destructive: _h(4, 74, 44),
    destructiveText: _h(4, 74, 44),
    success: _h(152, 72, 27),
    successText: _h(152, 72, 27),
    warning: _h(30, 92, 33),
    warningForeground: Colors.white,
    warningText: _h(30, 92, 33),
    info: _h(200, 90, 34),
    infoText: _h(200, 90, 34),
    gradeGood: _h(216, 91, 40),
    overlay: _h(220, 30, 8),
    lessons: [
      _h(216, 84, 48),
      _h(152, 60, 40),
      _h(32, 90, 46),
      _h(276, 55, 54),
      _h(336, 65, 50),
      _h(196, 80, 42),
      _h(48, 85, 40),
      _h(12, 80, 50),
    ],
  );

  static final dark = GColors(
    brand: _h(216, 91, 44),
    background: _h(220, 16, 9),
    foreground: _h(220, 15, 95),
    card: _h(220, 14, 13),
    popover: _h(220, 14, 17),
    surfaceMuted: _h(220, 12, 17),
    surfaceSunken: _h(220, 14, 11),
    primary: _h(216, 88, 50),
    primarySoft: _h(216, 60, 20),
    primarySoftForeground: _h(216, 95, 74),
    primaryText: _h(214, 95, 70),
    muted: _h(220, 12, 18),
    mutedForeground: _h(220, 10, 66),
    subtleForeground: _h(220, 8, 50),
    border: _h(220, 12, 21),
    divider: _h(220, 12, 18),
    inputBorder: _h(220, 10, 46),
    destructive: _h(4, 74, 44),
    destructiveText: _h(4, 85, 68),
    success: _h(152, 64, 30),
    successText: _h(152, 55, 52),
    warning: _h(38, 92, 56),
    warningForeground: _h(0, 0, 10),
    warningText: _h(38, 92, 60),
    info: _h(200, 90, 34),
    infoText: _h(200, 85, 62),
    gradeGood: _h(214, 95, 70),
    overlay: _h(220, 30, 4),
    lessons: [
      _h(216, 95, 62),
      _h(152, 55, 50),
      _h(32, 90, 58),
      _h(276, 60, 68),
      _h(336, 72, 64),
      _h(196, 80, 55),
      _h(48, 85, 55),
      _h(12, 80, 62),
    ],
  );

  /// Stable colour of a subject by name (same subject → same colour every day).
  Color subject(String name) => lessons[name.hashCode.abs() % lessons.length];

  @override
  GColors copyWith() => this;

  @override
  GColors lerp(GColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Radii (§6.4). Nested: inner = outer − padding.
abstract final class GRadius {
  static const chip = 6.0;
  static const control = 10.0;
  static const card = 14.0;
  static const overlay = 20.0;
}

/// Spacing scale (4-pt grid).
abstract final class GSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Page side gutter.
  static const page = 16.0;
}

/// Motion (§6.6): only opacity and transform are animated.
abstract final class GMotion {
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 280);
  static const easeOut = Cubic(0.2, 0, 0, 1);
  static const easeIos = Cubic(0.32, 0.72, 0, 1);
}

extension GThemeX on BuildContext {
  GColors get c => Theme.of(this).extension<GColors>()!;
  TextTheme get t => Theme.of(this).textTheme;
}
