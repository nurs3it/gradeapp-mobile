import 'package:flutter/material.dart';

import '../haptics.dart';
import '../icons.dart';
import '../theme.dart';
import '../tokens/layout.dart';
import '../tokens/type.dart';
import 'buttons.dart';
import 'pressable.dart';

class GTabItem {
  const GTabItem({required this.icon, required this.label, this.badge = 0, this.semanticLabel});
  final IconData icon;
  final String label;
  final int badge;

  /// «Оценки, 2 новых».
  final String? semanticLabel;
}

/// Floating capsule tab bar (§3.1): 64 pt, 16 from the sides, 22 from the
/// bottom; the `primary-soft` indicator rides the `smooth` spring. Labels hide
/// at text scale ≥ 1.3 (icons grow to 28).
class GTabBar extends StatelessWidget {
  const GTabBar({super.key, required this.items, required this.index, required this.onTap});
  final List<GTabItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final iconsOnly = GScale.of(context) >= 1.3;
    final reduce = GMotion.reduce(context);
    final n = items.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        GSpace.tabbarSide,
        0,
        GSpace.tabbarSide,
        GSpace.tabbarBottom + MediaQuery.paddingOf(context).bottom * 0.4,
      ),
      child: Container(
        height: GSpace.tabbarH,
        padding: const EdgeInsets.all(6),
        decoration: ShapeDecoration(color: c.tabbar, shape: const StadiumBorder(), shadows: GDepth.level2(c)),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(n == 1 ? 0 : -1 + 2 * index / (n - 1), 0),
              duration: reduce ? Duration.zero : SpringCurve.smooth.duration,
              curve: SpringCurve.smooth,
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: ShapeDecoration(color: c.primarySoft, shape: const StadiumBorder()),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: _Cell(
                      item: items[i],
                      active: i == index,
                      iconsOnly: iconsOnly,
                      onTap: () {
                        GHaptics.selection();
                        onTap(i);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.item, required this.active, required this.iconsOnly, required this.onTap});
  final GTabItem item;
  final bool active;
  final bool iconsOnly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = active ? c.primarySoftText : c.ink2;
    final icon = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Outline → filled cross-fade (two fixed layers, no keyed switcher).
        AnimatedOpacity(
          opacity: active ? 0 : 1,
          duration: GMotion.quick,
          child: GIcon(item.icon, size: iconsOnly ? 28 : 24, color: c.ink2),
        ),
        AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: GMotion.quick,
          child: GIcon(item.icon, size: iconsOnly ? 28 : 24, color: c.primarySoftText, fill: 1),
        ),
        if (item.badge > 0) Positioned(right: -10, top: -6, child: GCountBadge(count: item.badge)),
      ],
    );
    return Tooltip(
      message: iconsOnly ? item.label : '',
      triggerMode: iconsOnly ? TooltipTriggerMode.longPress : TooltipTriggerMode.manual,
      child: GPressable(
        onTap: onTap,
        scale: 0.94,
        selected: active,
        semanticLabel: item.semanticLabel ?? item.label,
        excludeChildSemantics: true,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (!iconsOnly) ...[
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.noScaling,
                  style: context.t.caption.copyWith(color: fg, fontWeight: active ? FontWeight.w700 : FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Capsule dock that replaces the tab bar on the lesson screen (§3.27).
class GDock extends StatelessWidget {
  const GDock({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, GSpace.tabbarBottom + MediaQuery.paddingOf(context).bottom * 0.4),
      child: Container(
        constraints: const BoxConstraints(minHeight: GSpace.tabbarH),
        padding: const EdgeInsets.all(7),
        decoration: ShapeDecoration(color: c.tabbar, shape: const StadiumBorder(), shadows: GDepth.level2(c)),
        child: Row(children: children),
      ),
    );
  }
}
