import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Type scale of «Веер» (design-system §2.2). Onest, tabular figures on every
/// style that carries numbers.
@immutable
class GType extends ThemeExtension<GType> {
  const GType._(this._ink);

  final Color _ink;

  static const family = 'Onest';
  static const _tnum = [FontFeature.tabularFigures()];

  TextStyle _s(double size, double line, FontWeight w, {double track = 0, bool tnum = false}) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: line / size,
    fontWeight: w,
    letterSpacing: track * size,
    color: _ink,
    fontFeatures: tnum ? _tnum : null,
    leadingDistribution: TextLeadingDistribution.even,
  );

  TextStyle get displayXl => _s(88, 80, FontWeight.w800, track: -0.045, tnum: true);
  TextStyle get display => _s(64, 58, FontWeight.w800, track: -0.045, tnum: true);
  TextStyle get titleXl => _s(48, 50, FontWeight.w800, track: -0.035, tnum: true);
  TextStyle get largeTitle => _s(34, 40, FontWeight.w800, track: -0.03);
  TextStyle get heroTitle => _s(30, 34, FontWeight.w800, track: -0.025);
  TextStyle get title1 => _s(28, 32, FontWeight.w800, track: -0.03);
  TextStyle get title2 => _s(20, 25, FontWeight.w700, track: -0.015);
  TextStyle get headline => _s(17, 22, FontWeight.w700, track: -0.005);
  TextStyle get bodyStrong => _s(16, 21, FontWeight.w600);
  TextStyle get body => _s(16, 22, FontWeight.w400);
  TextStyle get callout => _s(15, 20, FontWeight.w500, tnum: true);
  TextStyle get subhead => _s(14, 19, FontWeight.w600);
  TextStyle get footnote => _s(13, 17, FontWeight.w500, tnum: true);
  TextStyle get eyebrow => _s(12, 16, FontWeight.w700, track: 0.06, tnum: true);
  TextStyle get caption => _s(11, 13, FontWeight.w700, track: 0.01);
  TextStyle get key => _s(26, 30, FontWeight.w800, track: -0.02, tnum: true);
  TextStyle get gradeS => _s(17, 20, FontWeight.w800, tnum: true);
  TextStyle get gradeM => _s(20, 24, FontWeight.w800, tnum: true);
  TextStyle get gradeL => _s(26, 30, FontWeight.w800, tnum: true);

  /// Number + unit tiles: «3» 36/800 and «задания» 17/700.
  TextStyle get tileValue => _s(36, 38, FontWeight.w800, track: -0.03, tnum: true);
  TextStyle get tileUnit => _s(17, 20, FontWeight.w700);

  static const light = GType._(Color(0xFF0D1320));
  static const dark = GType._(Color(0xFFF2F5FA));

  @override
  GType copyWith() => this;

  @override
  GType lerp(GType? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Dynamic Type caps (§2.2): big display numbers stop at 1.15, everything else
/// at 1.35. Wrap a hero number in `CappedText` instead of using `Text`.
abstract final class GScale {
  static const display = 1.15;
  static const max = 1.35;
  static const tabLabel = 1.0;

  /// From this scale on, layouts switch to their «large text» variants.
  static const reflow = 1.24;

  static double of(BuildContext context) => MediaQuery.textScalerOf(context).scale(1);
  static bool large(BuildContext context) => of(context) >= reflow;
}

class CappedText extends StatelessWidget {
  const CappedText(
    this.text, {
    super.key,
    required this.style,
    this.cap = GScale.display,
    this.maxLines = 1,
    this.textAlign,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle style;
  final double cap;
  final int maxLines;
  final TextAlign? textAlign;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final s = math.min(GScale.of(context), cap);
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
      textScaler: TextScaler.linear(s),
    );
  }
}
