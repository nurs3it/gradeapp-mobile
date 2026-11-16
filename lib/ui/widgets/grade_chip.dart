import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens/colors.dart';
import '../tokens/layout.dart';
import 'chips.dart';

/// Tone of a mark by the school's rules (computed by `Grading.tone`).
enum GradeTone { excellent, good, fair, poor }

extension GradeToneColors on GradeTone {
  (Color bg, Color fg) soft(GColors c) => switch (this) {
    GradeTone.excellent => (c.okSoft, c.ok),
    GradeTone.good => (c.primarySoft, c.primarySoftText),
    GradeTone.fair => (c.warnSoft, c.warn),
    GradeTone.poor => (c.badSoft, c.bad),
  };

  Color solid() => switch (this) {
    GradeTone.excellent => GColors.okFill,
    GradeTone.good => GColors.brand,
    GradeTone.fair => GColors.warnFill,
    GradeTone.poor => GColors.badFill,
  };
}

enum GGradeSize { s, m, l }

/// Grade chip (§3.9). [text] is what is shown («9», «18/25», «—»); [tone]
/// null = neutral (`surface2`), used for scores and «no data».
class GGradeChip extends StatelessWidget {
  const GGradeChip({
    super.key,
    required this.text,
    this.tone,
    this.size = GGradeSize.s,
    this.isNew = false,
    this.solid = false,
    this.semanticLabel,
  });

  final String text;
  final GradeTone? tone;
  final GGradeSize size;
  final bool isNew;

  /// Just placed: solid tone with white figures.
  final bool solid;
  final String? semanticLabel;

  double get height => switch (size) {
    GGradeSize.s => 34,
    GGradeSize.m => 44,
    GGradeSize.l => 56,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final (bg, fg) = tone == null
        ? (c.surface2, c.ink)
        : solid
        ? (tone!.solid(), GColors.onFill)
        : tone!.soft(c);
    final style = switch (size) {
      GGradeSize.s => t.gradeS,
      GGradeSize.m => t.gradeM,
      GGradeSize.l => t.gradeL,
    }.copyWith(color: fg, fontSize: text.length > 3 ? 15 : null);
    final chip = Container(
      height: height,
      constraints: BoxConstraints(minWidth: height),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(GRadius.grade(height))),
      // widthFactor 1: hug the figure (an aligned Container would stretch in a Wrap).
      child: Center(
        widthFactor: 1,
        child: Text(text, style: style, maxLines: 1, textScaler: TextScaler.noScaling),
      ),
    );
    return Semantics(
      label: semanticLabel ?? text,
      excludeSemantics: true,
      child: isNew
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                chip,
                const Positioned(top: -3, right: -3, child: GNewDot()),
              ],
            )
          : chip,
    );
  }
}
