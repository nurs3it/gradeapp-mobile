import 'package:flutter/material.dart';

import '../../core/grading.dart';
import '../tokens.dart';

enum GTone { neutral, primary, success, warning, danger, info }

extension GToneColor on GTone {
  /// Text/icon colour of the tone; the fill is the same colour at 12%.
  Color fg(GColors c) => switch (this) {
    GTone.neutral => c.mutedForeground,
    GTone.primary => c.primaryText,
    GTone.success => c.successText,
    GTone.warning => c.warningText,
    GTone.danger => c.destructiveText,
    GTone.info => c.infoText,
  };
}

/// Small status pill: «Идёт», «Опоздал», «Не сдано».
class GPill extends StatelessWidget {
  const GPill(this.label, {super.key, this.tone = GTone.neutral, this.icon});
  final String label;
  final GTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = tone.fg(context.c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone == GTone.neutral ? context.c.surfaceMuted : fg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(
            label,
            style: context.t.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// A mark in its scale colour (excellent/good/fair/poor like the web journal).
class GGradeChip extends StatelessWidget {
  const GGradeChip({super.key, required this.value, required this.grading, this.maxValue, this.size = 36});
  final num value;
  final num? maxValue;
  final Grading grading;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final scored = maxValue != null && maxValue! > 0;
    final mark = scored ? grading.min + (value / maxValue!) * (grading.max - grading.min) : value;
    final fg = switch (grading.tone(mark)) {
      GradeTone.excellent => c.successText,
      GradeTone.good => c.gradeGood,
      GradeTone.fair => c.warningText,
      GradeTone.poor => c.destructiveText,
    };
    final label = scored ? '${_fmt(value)}/${_fmt(maxValue!)}' : _fmt(value);
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GRadius.control),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: scored ? 13 : size * 0.47, fontWeight: FontWeight.w700, color: fg, height: 1),
      ),
    );
  }

  static String _fmt(num v) => v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);
}

/// Unread counter dot on icons.
class GCountBadge extends StatelessWidget {
  const GCountBadge({super.key, required this.count, required this.child});
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    label: Text(count > 99 ? '99+' : '$count'),
    backgroundColor: context.c.destructive,
    child: child,
  );
}
