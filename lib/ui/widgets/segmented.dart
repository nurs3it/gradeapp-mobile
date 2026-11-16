import 'package:flutter/material.dart';

import '../haptics.dart';
import '../icons.dart';
import '../theme.dart';
import '../tokens/layout.dart';
import 'pressable.dart';

/// Segmented control (§3.7): `surface2` track 44, thumb `surface` slides on
/// the `smooth` spring. Segments are text or icons.
class GSegmented<T> extends StatelessWidget {
  const GSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
    this.labels,
    this.icons,
    this.semanticLabels,
    this.height = 44,
  });

  final List<T> values;
  final T selected;
  final ValueChanged<T> onChanged;
  final List<String>? labels;
  final List<IconData>? icons;
  final List<String>? semanticLabels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final index = values.indexOf(selected).clamp(0, values.length - 1);
    final reduce = GMotion.reduce(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(color: c.surface2, shape: const StadiumBorder()),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth / values.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: reduce ? Duration.zero : SpringCurve.smooth.duration,
                curve: SpringCurve.smooth,
                left: w * index,
                top: 0,
                bottom: 0,
                width: w,
                child: DecoratedBox(
                  decoration: ShapeDecoration(color: c.surface, shape: const StadiumBorder(), shadows: GDepth.thumb(c)),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: GPressable(
                        scale: 1,
                        selected: i == index,
                        semanticLabel: semanticLabels?[i] ?? labels?[i],
                        excludeChildSemantics: true,
                        onTap: () {
                          if (i == index) return;
                          GHaptics.selection();
                          onChanged(values[i]);
                        },
                        child: Center(
                          child: icons != null
                              ? GIcon(icons![i], size: 20, color: i == index ? c.ink : c.ink2, fill: i == index ? 1 : 0)
                              : Text(
                                  labels![i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.t.subhead.copyWith(fontSize: 15, color: i == index ? c.ink : c.ink2),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
