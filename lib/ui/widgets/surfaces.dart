import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme.dart';
import '../tokens/layout.dart';
import '../tokens/type.dart';
import 'pressable.dart';

/// Sheet of paper (§3.3): `surface`, continuous 26 corners, level-1 shadow,
/// no border. Tappable cards shrink to 0.97.
class GCard extends StatelessWidget {
  const GCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GSpace.cardPad),
    this.onTap,
    this.color,
    this.radius = GRadius.card,
    this.border,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  /// Only for the alarm outline of a child card (§1.5 rule 6).
  final BorderSide? border;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final box = Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: color ?? c.surface,
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius), side: border ?? BorderSide.none),
        shadows: GDepth.level1(c),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GPressable(onTap: onTap, semanticLabel: semanticLabel, child: box);
  }
}

/// Group of rows inside one sheet; hairlines start at the text.
class GGroup extends StatelessWidget {
  const GGroup({super.key, required this.children, this.inset = 16});
  final List<Widget> children;

  /// Hairline left inset (aligns with the row text).
  final double inset;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(color: c.surface, shape: GRadius.surface(GRadius.card), shadows: GDepth.level1(c)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Padding(padding: EdgeInsetsDirectional.only(start: inset), child: Container(height: 1, color: c.hairline)),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Section title `title-2` with an optional action on the right («Неделя ›»).
class GSectionHeader extends StatelessWidget {
  const GSectionHeader(this.title, {super.key, this.action, this.onAction, this.trailing, this.color});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.fromLTRB(GSpace.gutter(context), GSpace.sectionTop, GSpace.gutter(context), GSpace.sectionGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: context.t.title2.copyWith(color: color))),
          ),
          ?trailing,
          if (action != null)
            GPressable(
              onTap: onAction,
              semanticLabel: action,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32),
                child: Center(child: Text(action!, style: context.t.callout.copyWith(color: c.primaryText, fontWeight: FontWeight.w600))),
              ),
            ),
        ],
      ),
    );
  }
}

/// List row (§3.5): leading → subject marker → title / subtitle → trailing.
/// Pressed rows tint to `surface2` instead of scaling.
class GRow extends StatefulWidget {
  const GRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.marker,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.minHeight = GSpace.rowMin,
    this.background,
    this.chevron = false,
    this.semanticLabel,
    this.padding,
    this.titleStyle,
    this.subtitleMaxLines = 1,
    this.titleMaxLines = 1,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;

  /// Subject colour: draws the 5 × 30 pill after the leading slot.
  final Color? marker;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double minHeight;
  final Color? background;
  final bool chevron;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final int subtitleMaxLines;
  final int titleMaxLines;

  @override
  State<GRow> createState() => _GRowState();
}

class _GRowState extends State<GRow> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && (widget.onTap != null || widget.onLongPress != null)) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final row = AnimatedContainer(
      duration: GMotion.instant,
      color: _down ? c.surface2 : (widget.background ?? Colors.transparent),
      constraints: BoxConstraints(minHeight: widget.minHeight),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 12)],
          if (widget.marker != null) ...[
            Container(
              width: 5,
              height: 30,
              decoration: ShapeDecoration(color: widget.marker, shape: const StadiumBorder()),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: widget.titleStyle ?? t.bodyStrong,
                  maxLines: widget.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  child: widget.title,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: t.footnote.copyWith(color: c.ink2),
                    maxLines: widget.subtitleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[const SizedBox(width: 10), widget.trailing!],
          if (widget.chevron) ...[const SizedBox(width: 4), GIcon(GIcons.chevron, size: 22, color: c.ink3)],
        ],
      ),
    );
    if (widget.onTap == null && widget.onLongPress == null) {
      return widget.semanticLabel == null ? row : Semantics(label: widget.semanticLabel, excludeSemantics: true, child: row);
    }
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onLongPressEnd: (_) => _set(false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: row,
      ),
    );
  }
}

/// Half-width tile (§3.3): label with icon on top, big number + unit below.
class GTile extends StatelessWidget {
  const GTile({
    super.key,
    required this.label,
    this.icon,
    this.value,
    this.unit,
    this.caption,
    this.child,
    this.onTap,
    this.semanticLabel,
  });

  final String label;
  final IconData? icon;
  final String? value;
  final String? unit;
  final String? caption;

  /// Custom body instead of value/unit (e.g. grade chips).
  final Widget? child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    return GCard(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 122 - 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[GIcon(icon!, size: 20, color: c.ink2), const SizedBox(width: 6)],
                Expanded(child: Text(label, style: t.subhead.copyWith(color: c.ink2), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 10),
            if (child != null)
              child!
            else if (value != null)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: value, style: t.tileValue),
                    if (unit != null) TextSpan(text: ' $unit', style: t.tileUnit),
                  ],
                ),
                textScaler: TextScaler.linear(GScale.of(context).clamp(1.0, GScale.display)),
                maxLines: 2,
              ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              Text(caption!, style: t.subhead.copyWith(color: c.ink2), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }
}

/// Two tiles per row; one per row at large text (§2.2 reflow).
class GTileRow extends StatelessWidget {
  const GTileRow({super.key, required this.tiles});
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) return const SizedBox.shrink();
    if (tiles.length == 1 || GScale.large(context)) {
      return Column(children: [for (final t in tiles) Padding(padding: const EdgeInsets.only(bottom: GSpace.stackGap), child: t)]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tiles[0]),
          const SizedBox(width: GSpace.stackGap),
          Expanded(child: tiles[1]),
        ],
      ),
    );
  }
}

/// Section title `title-2` with an action, inside an already padded list.
class GSectionTitle extends StatelessWidget {
  const GSectionTitle({super.key, required this.title, this.action, this.onAction, this.trailing});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: GSpace.sectionTop, bottom: GSpace.sectionGap),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Semantics(header: true, child: Text(title, style: context.t.title2))),
        ?trailing,
        if (action != null)
          GPressable(
            onTap: onAction,
            semanticLabel: action,
            excludeChildSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              child: Center(
                child: Text(
                  action!,
                  style: context.t.callout.copyWith(color: context.c.primaryText, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
