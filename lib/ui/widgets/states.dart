import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme.dart';
import '../tokens/colors.dart';
import '../tokens/layout.dart';
import 'buttons.dart';
import 'mark.dart';

/// Skeleton (§3.16): shapes of the future content, one opacity pulse for the
/// whole block (no shimmer). Shown only when there is no cache.
class GSkeleton extends StatefulWidget {
  const GSkeleton({super.key, this.hero = true, this.rows = 3});
  final bool hero;
  final int rows;

  @override
  State<GSkeleton> createState() => _GSkeletonState();
}

class _GSkeletonState extends State<GSkeleton> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: c.skeleton, borderRadius: BorderRadius.circular(h / 2)),
    );
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.6).animate(_ctrl),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GSpace.gutter(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.hero) ...[
                  Container(
                    height: 180,
                    decoration: ShapeDecoration(color: c.skeleton, shape: GRadius.surface(GRadius.hero)),
                  ),
                  const SizedBox(height: 24),
                ],
                Container(
                  decoration: ShapeDecoration(color: c.surface, shape: GRadius.surface(GRadius.card)),
                  child: Column(
                    children: [
                      for (var i = 0; i < widget.rows; i++)
                        SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                bar(40, 12),
                                const SizedBox(width: 12),
                                bar(5, 30),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [bar(140, 12), const SizedBox(height: 8), bar(90, 10)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state (§3.16): mark in a 64 plate, status title, what will come here,
/// optional tinted action.
class GEmpty extends StatelessWidget {
  const GEmpty({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.onAction,
    this.error = false,
    this.icon,
  });

  final String title;
  final String? message;
  final String? action;
  final VoidCallback? onAction;
  final bool error;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: GSpace.gutter(context) + 12, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: ShapeDecoration(color: error ? c.badSoft : c.primarySoft, shape: GRadius.surface(22)),
            alignment: Alignment.center,
            child: icon != null
                ? GIcon(icon!, size: 28, color: error ? c.bad : c.primarySoftText)
                : GMark(size: 44, color: error ? c.bad : GColors.brand),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(title, style: context.t.headline, textAlign: TextAlign.center),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              style: context.t.body.copyWith(color: c.ink2),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            GButton(label: action!, onPressed: onAction, variant: GButtonVariant.tinted, size: GButtonSize.s),
          ],
        ],
      ),
    );
  }
}

/// State row (§3.16): the place for anything that needs an action, instead of
/// a toast. First sentence bold.
class GStateRow extends StatelessWidget {
  const GStateRow({
    super.key,
    required this.title,
    this.message,
    this.tone = GTone.neutral,
    this.icon,
    this.action,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? message;
  final GTone tone;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = tone == GTone.neutral ? c.ink : tone.fg(c);
    final iconData =
        icon ??
        switch (tone) {
          GTone.bad => GIcons.error,
          GTone.warn => GIcons.info,
          GTone.ok => GIcons.ok,
          _ => GIcons.info,
        };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: padding ?? const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: ShapeDecoration(color: tone.soft(c), shape: GRadius.surface(20)),
        child: Row(
          children: [
            GIcon(iconData, size: 20, color: fg, fill: 1),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (message != null)
                      TextSpan(
                        text: ' $message',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                style: context.t.subhead.copyWith(color: tone == GTone.neutral ? c.ink : fg),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 8),
              GButton(label: action!, onPressed: onAction, size: GButtonSize.s, variant: GButtonVariant.surface),
            ],
          ],
        ),
      ),
    );
  }
}
