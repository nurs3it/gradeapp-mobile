import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens/colors.dart';
import '../tokens/layout.dart';
import 'pressable.dart';

/// The one loud sheet of a screen (§3.4) with the fan of the next sheets
/// under it (§2.5 «Веер»): 14 / 30 pt side insets, 10 / 19 pt below,
/// 72 % / 48 % opacity, coloured as the next subjects.
class GHeroSheet extends StatelessWidget {
  const GHeroSheet({
    super.key,
    required this.color,
    required this.child,
    this.fan = const [],
    this.onTap,
    this.semanticLabel,
    this.leaves = true,
    this.heroTag,
    this.border,
  });

  final Color color;
  final Widget child;

  /// Colours of the next one or two sheets (empty = no fan).
  final List<Color> fan;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Decorative white capsules in the top-right corner.
  final bool leaves;
  final Object? heroTag;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(GRadius.hero),
      side: border ?? BorderSide.none,
    );
    Widget sheet = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(color: color, shape: shape),
      child: Stack(
        children: [
          if (leaves) const Positioned(right: -70, top: -40, child: _Leaves()),
          Padding(padding: const EdgeInsets.all(GSpace.heroPad), child: child),
        ],
      ),
    );
    if (heroTag != null) {
      sheet = Hero(
        tag: heroTag!,
        child: Material(type: MaterialType.transparency, child: sheet),
      );
    }
    if (onTap != null) {
      sheet = GPressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        excludeChildSemantics: semanticLabel != null,
        child: sheet,
      );
    } else if (semanticLabel != null) {
      sheet = Semantics(label: semanticLabel, excludeSemantics: true, child: sheet);
    }
    final layers = fan.take(2).toList();
    if (layers.isEmpty) return sheet;
    const insets = [14.0, 30.0];
    const drops = [10.0, 19.0];
    const alphas = [0.72, 0.48];
    return Padding(
      padding: EdgeInsets.only(bottom: drops[layers.length - 1]),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = layers.length - 1; i >= 0; i--)
            Positioned(
              left: insets[i],
              right: insets[i],
              bottom: -drops[i],
              height: 80,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: layers[i].withValues(alpha: alphas[i]),
                    shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(GRadius.hero - 4)),
                  ),
                ),
              ),
            ),
          sheet,
        ],
      ),
    );
  }
}

class _Leaves extends StatelessWidget {
  const _Leaves();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: SizedBox(
      width: 260,
      height: 200,
      child: Stack(
        children: [
          for (final (angle, alpha) in const [(-28.0, 0.07), (-50.0, 0.05)])
            Positioned(
              left: 30,
              top: 70,
              child: Transform.rotate(
                angle: angle * math.pi / 180,
                child: Container(
                  width: 210,
                  height: 50,
                  decoration: ShapeDecoration(
                    color: GColors.onFill.withValues(alpha: alpha),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// White-on-fill progress bar inside a hero (8 pt; track 26 %).
class GHeroProgress extends StatelessWidget {
  const GHeroProgress({super.key, required this.value, this.color = GColors.onFill, this.height = 8});
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: height,
      decoration: ShapeDecoration(color: color.withValues(alpha: 0.26), shape: const StadiumBorder()),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        heightFactor: 1,
        child: DecoratedBox(
          decoration: ShapeDecoration(color: color, shape: const StadiumBorder()),
        ),
      ),
    ),
  );
}

/// Linear progress on a surface (4–8 pt), e.g. ФО/СОР/СОЧ bars, load bar.
class GBar extends StatelessWidget {
  const GBar({super.key, required this.value, required this.color, this.height = 5, this.track});
  final double value;
  final Color color;
  final double height;
  final Color? track;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: ShapeDecoration(color: track ?? context.c.surface2, shape: const StadiumBorder()),
    alignment: Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: value.clamp(0.0, 1.0),
      heightFactor: 1,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: color, shape: const StadiumBorder()),
      ),
    ),
  );
}
