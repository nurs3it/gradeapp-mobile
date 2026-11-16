import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// Card: white surface, hairline border, 14pt radius (`--radius-card`).
class GCard extends StatelessWidget {
  const GCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GSpace.lg),
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final radius = BorderRadius.circular(GRadius.card);
    return Material(
      color: color ?? c.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor ?? c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                onTap!();
              },
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}

/// Section title row above a group of cards ("Сегодня", "Последние оценки").
class GSectionHeader extends StatelessWidget {
  const GSectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GSpace.page, GSpace.xl, GSpace.sm, GSpace.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.t.titleMedium)),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(textStyle: context.t.titleSmall),
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

/// iOS-style list row inside a card: leading, title/subtitle, trailing.
class GRow extends StatelessWidget {
  const GRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: dense ? 48 : 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GSpace.lg, vertical: GSpace.sm + 2),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: GSpace.md)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(
                    style: context.t.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: title,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: DefaultTextStyle.merge(
                        style: context.t.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        child: subtitle!,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: GSpace.sm), trailing!],
          ],
        ),
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// Rows separated by inset dividers, wrapped in one card.
class GGroup extends StatelessWidget {
  const GGroup({super.key, required this.children, this.inset = 16});
  final List<Widget> children;
  final double inset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpace.page),
      child: GCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[if (i > 0) Divider(indent: inset), children[i]],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with the overlay radius and drag handle.
Future<T?> showGSheet<T>(BuildContext context, WidgetBuilder builder) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (ctx) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
    child: builder(ctx),
  ),
);

void showGToast(BuildContext context, String message, {bool error = false}) {
  final c = context.c;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? c.destructive : null,
        duration: const Duration(seconds: 3),
      ),
    );
}
