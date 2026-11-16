import 'package:flutter/material.dart';

import '../haptics.dart';
import '../icons.dart';
import '../theme.dart';
import '../tokens/colors.dart';
import '../tokens/layout.dart';
import 'pressable.dart';

/// Filter chip (§3.8): 36 pt capsule; selected = inverted (ink / canvas).
/// A count is set bold in front of the word («**2** не отмечено»).
class GChip extends StatelessWidget {
  const GChip({
    super.key,
    required this.label,
    this.count,
    this.selected = false,
    this.onTap,
    this.tone,
    this.dot,
    this.icon,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback? onTap;

  /// `warn` when the count means a debt.
  final GTone? tone;

  /// Subject colour dot before the label.
  final Color? dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final (bg, fg) = selected
        ? (c.ink, c.canvas)
        : tone != null
        ? (tone!.soft(c), tone!.fg(c))
        : (c.surface, c.ink);
    return GPressable(
      onTap: onTap == null
          ? null
          : () {
              GHaptics.selection();
              onTap!();
            },
      selected: selected,
      semanticLabel: count == null ? label : '$count $label',
      excludeChildSemantics: true,
      child: SizedBox(
        height: 44,
        child: Center(
          widthFactor: 1,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: ShapeDecoration(
              color: bg,
              shape: const StadiumBorder(),
              shadows: selected || tone != null ? null : GDepth.level1(c),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dot != null) ...[
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                ],
                if (icon != null) ...[GIcon(icon!, size: 16, color: fg), const SizedBox(width: 6)],
                if (count != null) ...[
                  Text('$count', style: t.subhead.copyWith(color: fg, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 5),
                ],
                Text(label, style: t.subhead.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Suggestion chip: `primary-soft` + icon. Tap applies the value.
class GSuggestChip extends StatelessWidget {
  const GSuggestChip({super.key, required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GPressable(
      onTap: onTap,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: ShapeDecoration(color: c.primarySoft, shape: const StadiumBorder()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[GIcon(icon!, size: 16, color: c.primarySoftText), const SizedBox(width: 6)],
            Flexible(
              child: Text(
                label,
                style: context.t.subhead.copyWith(color: c.primarySoftText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status pill (§3.8): 28 pt, soft tone, filled icon + word. Never colour alone.
class GStatusPill extends StatelessWidget {
  const GStatusPill({super.key, required this.label, required this.tone, this.icon});
  final String label;
  final GTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = tone.fg(c);
    return Container(
      height: 28,
      padding: EdgeInsets.only(left: icon == null ? 10 : 7, right: 10),
      decoration: ShapeDecoration(color: tone.soft(c), shape: const StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[GIcon(icon!, size: 16, color: fg, fill: 1), const SizedBox(width: 4)],
          Text(label, style: context.t.footnote.copyWith(color: fg, fontWeight: FontWeight.w700), maxLines: 1),
        ],
      ),
    );
  }
}

/// Work-type badge ФО / СОР / СОЧ (r-badge 7).
class GTypeBadge extends StatelessWidget {
  const GTypeBadge({super.key, required this.label, required this.kind});
  final String label;

  /// formative / sor / soch / other.
  final String kind;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg) = switch (kind) {
      'sor' => (c.warnSoft, c.warn),
      'soch' => (gSubjects[3].tint(c.brightness), gSubjects[3].marker(c.brightness)),
      'formative' => (c.primarySoft, c.primarySoftText),
      _ => (c.surface2, c.ink2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(GRadius.badge)),
      child: Text(label, style: context.t.caption.copyWith(color: fg), maxLines: 1),
    );
  }
}

/// Golden «new» dot (10 pt, outlined in the surface colour).
class GNewDot extends StatelessWidget {
  const GNewDot({super.key, this.size = 10});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: GColors.gold,
      shape: BoxShape.circle,
      border: Border.all(color: context.c.surface, width: 2),
    ),
  );
}
