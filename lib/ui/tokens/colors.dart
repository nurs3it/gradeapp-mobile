import 'package:flutter/material.dart';

/// One subject colour family (design-system §2.1, «Цвета предметов»).
@immutable
class GSubject {
  const GSubject({required this.fill, required this.tintLight, required this.tintDark, required this.markerDark});

  /// Hero fill in both themes; white text on it is ≥ 6:1.
  final Color fill;
  final Color tintLight;
  final Color tintDark;
  final Color markerDark;

  Color tint(Brightness b) => b == Brightness.dark ? tintDark : tintLight;
  Color marker(Brightness b) => b == Brightness.dark ? markerDark : fill;
}

/// Order matches the web `lesson-1…8`.
const gSubjects = <GSubject>[
  GSubject(
    fill: Color(0xFF4F46E5),
    tintLight: Color(0xFFEAE9FC),
    tintDark: Color(0xFF242558),
    markerDark: Color(0xFF9A94FF),
  ),
  GSubject(
    fill: Color(0xFF0B6F43),
    tintLight: Color(0xFFE2EEE8),
    tintDark: Color(0xFF11302B),
    markerDark: Color(0xFF5BD69A),
  ),
  GSubject(
    fill: Color(0xFFAE3A0B),
    tintLight: Color(0xFFF5E7E2),
    tintDark: Color(0xFF3E221B),
    markerDark: Color(0xFFFF8F5E),
  ),
  GSubject(
    fill: Color(0xFF6D35DB),
    tintLight: Color(0xFFEDE7FB),
    tintDark: Color(0xFF2C2055),
    markerDark: Color(0xFFB38CFF),
  ),
  GSubject(
    fill: Color(0xFFA61F84),
    tintLight: Color(0xFFF4E4F0),
    tintDark: Color(0xFF3C1A3D),
    markerDark: Color(0xFFF17ACF),
  ),
  GSubject(
    fill: Color(0xFF0A6476),
    tintLight: Color(0xFFE2ECEF),
    tintDark: Color(0xFF102D39),
    markerDark: Color(0xFF4FC6DB),
  ),
  GSubject(
    fill: Color(0xFF875500),
    tintLight: Color(0xFFF1EBE0),
    tintDark: Color(0xFF332918),
    markerDark: Color(0xFFF2B33D),
  ),
  GSubject(
    fill: Color(0xFFB41F48),
    tintLight: Color(0xFFF6E4E9),
    tintDark: Color(0xFF401A2C),
    markerDark: Color(0xFFFF7E9F),
  ),
];

/// Stable subject index: FNV-1a over the UTF-16 code units, so the same course
/// keeps its colour across launches (Dart's `String.hashCode` does not).
int subjectIndex(String key) {
  var h = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    h ^= unit;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h % gSubjects.length;
}

GSubject subjectOf(String key) => gSubjects[subjectIndex(key)];

/// Semantic colour roles of «Веер» (design-system §2.1). The only place hex
/// values live; screens read `context.c.*`.
@immutable
class GColors extends ThemeExtension<GColors> {
  const GColors({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.hairline,
    required this.tabbar,
    required this.scrim,
    required this.skeleton,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.primaryText,
    required this.primarySoft,
    required this.primarySoftText,
    required this.goldSoft,
    required this.goldText,
    required this.ok,
    required this.okSoft,
    required this.warn,
    required this.warnSoft,
    required this.bad,
    required this.badSoft,
    required this.shadowTint,
  });

  final Brightness brightness;
  final Color canvas;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color hairline;
  final Color tabbar;
  final Color scrim;
  final Color skeleton;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color primaryText;
  final Color primarySoft;
  final Color primarySoftText;
  final Color goldSoft;
  final Color goldText;
  final Color ok;
  final Color okSoft;
  final Color warn;
  final Color warnSoft;
  final Color bad;
  final Color badSoft;

  /// Base colour of light-theme shadows (`rgba(16,24,40,…)`).
  final Color shadowTint;

  // Constants in both themes.
  static const brand = Color(0xFF0A5BD8);
  static const brandPressed = Color(0xFF0849AE);
  static const brandGradTop = Color(0xFF3175DE);
  static const gold = Color(0xFFFFC226);
  static const onGold = Color(0xFF1F1600);
  static const onFill = Color(0xFFFFFFFF);
  static const okFill = Color(0xFF11834F);
  static const warnFill = Color(0xFFB25F00);
  static const badFill = Color(0xFFD02A30);

  /// Always-dark camera surface.
  static const camera = Color(0xFF000000);

  /// Text button on the inverted (ink) toast.
  static const toastAction = Color(0xFF7AABFF);

  /// Brand-book graphite for the mark on light paper.
  static const graphite = Color(0xFF101828);

  Color get primary => brand;
  bool get isDark => brightness == Brightness.dark;

  static const light = GColors(
    brightness: Brightness.light,
    canvas: Color(0xFFF2F4F8),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEAEEF4),
    surface3: Color(0xFFE1E6EE),
    hairline: Color(0xFFE3E7EE),
    tabbar: Color(0xF7FFFFFF),
    scrim: Color(0x520D1320),
    skeleton: Color(0xFFE6EAF0),
    ink: Color(0xFF0D1320),
    ink2: Color(0xFF4A5466),
    ink3: Color(0xFF5D6779),
    primaryText: Color(0xFF0A5BD8),
    primarySoft: Color(0xFFE6EFFD),
    primarySoftText: Color(0xFF0848B0),
    goldSoft: Color(0xFFFFF3D1),
    goldText: Color(0xFF8A5A00),
    ok: Color(0xFF0B7A47),
    okSoft: Color(0xFFE2F4EA),
    warn: Color(0xFF975400),
    warnSoft: Color(0xFFFDF0DA),
    bad: Color(0xFFC42127),
    badSoft: Color(0xFFFCE6E6),
    shadowTint: Color(0xFF101828),
  );

  static const dark = GColors(
    brightness: Brightness.dark,
    canvas: Color(0xFF090C12),
    surface: Color(0xFF131821),
    surface2: Color(0xFF1B212C),
    surface3: Color(0xFF252C39),
    hairline: Color(0xFF232A36),
    tabbar: Color(0xF71B212C),
    scrim: Color(0x8F000000),
    skeleton: Color(0xFF1E2430),
    ink: Color(0xFFF2F5FA),
    ink2: Color(0xFFA3ADBE),
    ink3: Color(0xFF8B96A8),
    primaryText: Color(0xFF7AABFF),
    primarySoft: Color(0xFF132545),
    primarySoftText: Color(0xFF9DC0FF),
    goldSoft: Color(0xFF2E250C),
    goldText: Color(0xFFFFD36B),
    ok: Color(0xFF4CCB88),
    okSoft: Color(0xFF10291D),
    warn: Color(0xFFFFB547),
    warnSoft: Color(0xFF2D2109),
    bad: Color(0xFFFF7B7B),
    badSoft: Color(0xFF371619),
    shadowTint: Color(0xFF000000),
  );

  /// Subject tint / marker for the current theme.
  Color subjectTint(String key) => subjectOf(key).tint(brightness);
  Color subjectMarker(String key) => subjectOf(key).marker(brightness);
  Color subjectFill(String key) => subjectOf(key).fill;

  /// One elevation step up (dark sheets): groups and chips inside a dark
  /// sheet would otherwise vanish into its `surface`.
  GColors raised() => !isDark
      ? this
      : GColors(
          brightness: brightness,
          canvas: canvas,
          surface: surface2,
          surface2: surface3,
          surface3: surface3,
          hairline: surface3,
          tabbar: tabbar,
          scrim: scrim,
          skeleton: skeleton,
          ink: ink,
          ink2: ink2,
          ink3: ink3,
          primaryText: primaryText,
          primarySoft: primarySoft,
          primarySoftText: primarySoftText,
          goldSoft: goldSoft,
          goldText: goldText,
          ok: ok,
          okSoft: okSoft,
          warn: warn,
          warnSoft: warnSoft,
          bad: bad,
          badSoft: badSoft,
          shadowTint: shadowTint,
        );

  @override
  GColors copyWith() => this;

  @override
  GColors lerp(GColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return GColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: l(canvas, other.canvas),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      hairline: l(hairline, other.hairline),
      tabbar: l(tabbar, other.tabbar),
      scrim: l(scrim, other.scrim),
      skeleton: l(skeleton, other.skeleton),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      primaryText: l(primaryText, other.primaryText),
      primarySoft: l(primarySoft, other.primarySoft),
      primarySoftText: l(primarySoftText, other.primarySoftText),
      goldSoft: l(goldSoft, other.goldSoft),
      goldText: l(goldText, other.goldText),
      ok: l(ok, other.ok),
      okSoft: l(okSoft, other.okSoft),
      warn: l(warn, other.warn),
      warnSoft: l(warnSoft, other.warnSoft),
      bad: l(bad, other.bad),
      badSoft: l(badSoft, other.badSoft),
      shadowTint: l(shadowTint, other.shadowTint),
    );
  }
}

/// Status tones used by pills, state rows and the parent verdict.
enum GTone { ok, warn, bad, info, neutral }

extension GToneColors on GTone {
  Color fg(GColors c) => switch (this) {
    GTone.ok => c.ok,
    GTone.warn => c.warn,
    GTone.bad => c.bad,
    GTone.info => c.primarySoftText,
    GTone.neutral => c.ink2,
  };

  Color soft(GColors c) => switch (this) {
    GTone.ok => c.okSoft,
    GTone.warn => c.warnSoft,
    GTone.bad => c.badSoft,
    GTone.info => c.primarySoft,
    GTone.neutral => c.surface2,
  };

  Color fill(GColors c) => switch (this) {
    GTone.ok => GColors.okFill,
    GTone.warn => GColors.warnFill,
    GTone.bad => GColors.badFill,
    GTone.info => GColors.brand,
    GTone.neutral => c.ink3,
  };
}
