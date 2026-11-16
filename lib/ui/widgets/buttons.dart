import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme.dart';
import '../tokens/colors.dart';
import 'mark.dart';
import 'pressable.dart';

enum GButtonVariant { primary, tinted, secondary, surface, onColor, plain, destructive }

enum GButtonSize { l, m, s }

/// Capsule button (§3.6). One primary per screen; loading swaps the label for
/// the brand loader and keeps the width.
class GButton extends StatelessWidget {
  const GButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GButtonVariant.primary,
    this.size = GButtonSize.m,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.color,
    this.foreground,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final GButtonVariant variant;
  final GButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  /// `onColor`: the colour of the sheet the button sits on (its text colour).
  final Color? color;

  /// Overrides the text colour (e.g. `plain` in ink2 for «Пропустить»).
  final Color? foreground;
  final String? semanticLabel;

  double get height => switch (size) {
    GButtonSize.l => 56,
    GButtonSize.m => 50,
    GButtonSize.s => 40,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final enabled = onPressed != null && !loading;
    var (bg, fg) = switch (variant) {
      GButtonVariant.primary => (GColors.brand, GColors.onFill),
      GButtonVariant.tinted => (c.primarySoft, c.primarySoftText),
      GButtonVariant.secondary => (c.surface2, c.ink),
      GButtonVariant.surface => (c.surface, c.ink),
      GButtonVariant.onColor => (GColors.onFill, color ?? GColors.brand),
      GButtonVariant.plain => (Colors.transparent, c.primaryText),
      GButtonVariant.destructive => (GColors.badFill, GColors.onFill),
    };
    if (foreground != null) fg = foreground!;
    if (onPressed == null && !loading && variant != GButtonVariant.plain) {
      bg = c.surface2;
      fg = c.ink3.withValues(alpha: 0.6);
    } else if (onPressed == null && variant == GButtonVariant.plain) {
      fg = c.ink3.withValues(alpha: 0.6);
    }
    final style = (size == GButtonSize.l ? t.headline : t.bodyStrong).copyWith(color: fg, fontSize: size == GButtonSize.s ? 15 : null);
    final iconSize = size == GButtonSize.s ? 18.0 : 20.0;
    final content = loading
        ? GLoader(size: 22, color: fg)
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[GIcon(icon!, size: iconSize, color: fg), const SizedBox(width: 8)],
              Flexible(
                child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ),
            ],
          );
    return GPressable(
      onTap: enabled ? onPressed : null,
      scale: 0.94,
      semanticLabel: semanticLabel ?? label,
      excludeChildSemantics: true,
      child: Container(
        constraints: BoxConstraints(minHeight: height, minWidth: height),
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: variant == GButtonVariant.plain ? 8 : (size == GButtonSize.s ? 16 : 22)),
        decoration: ShapeDecoration(
          color: bg,
          shape: const StadiumBorder(),
          shadows: variant == GButtonVariant.surface && !c.isDark
              ? [BoxShadow(color: c.shadowTint.withValues(alpha: 0.05), offset: const Offset(0, 1), blurRadius: 2)]
              : null,
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

/// Round 44 × 44 icon button (40 in a nested nav bar).
class GIconButton extends StatelessWidget {
  const GIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.size = 44,
    this.background,
    this.color,
    this.badge,
    this.fill = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final Color? background;
  final Color? color;
  final int? badge;
  final double fill;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GPressable(
      onTap: onPressed,
      scale: 0.94,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: SizedBox.square(
        dimension: size < 44 ? 44 : size,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: ShapeDecoration(color: background ?? c.surface, shape: const CircleBorder()),
                alignment: Alignment.center,
                child: GIcon(icon, size: 22, color: color ?? c.ink, fill: fill),
              ),
              if (badge != null && badge! > 0)
                Positioned(right: -4, top: -4, child: GCountBadge(count: badge!)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Red counter (tab bar, bell): `bad-fill`, 18 pt, outlined in canvas.
class GCountBadge extends StatelessWidget {
  const GCountBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: ShapeDecoration(
          color: GColors.badFill,
          shape: StadiumBorder(side: BorderSide(color: c.canvas, width: 2)),
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
          count > 99 ? '99+' : '$count',
            style: context.t.caption.copyWith(color: GColors.onFill, fontSize: 11, height: 1),
            textScaler: TextScaler.noScaling,
          ),
        ),
      ),
    );
  }
}
