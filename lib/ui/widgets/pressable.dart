import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../tokens/layout.dart';

/// Press feedback of «Веер»: no ripple, the element shrinks to [scale] in
/// 90 ms and springs back on release (`snap`). Transform only — cheap.
class GPressable extends StatefulWidget {
  const GPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.semanticLabel,
    this.button = true,
    this.selected,
    this.excludeChildSemantics = false,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 0.97 for surfaces, 0.94 for buttons and keys.
  final double scale;
  final String? semanticLabel;
  final bool button;
  final bool? selected;
  final bool excludeChildSemantics;
  final HitTestBehavior behavior;

  @override
  State<GPressable> createState() => _GPressableState();
}

class _GPressableState extends State<GPressable> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController.unbounded(vsync: this, value: 1);

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _down() {
    if (!_enabled || GMotion.reduce(context)) return;
    _ctrl.animateTo(widget.scale, duration: GMotion.instant, curve: GMotion.standard);
  }

  void _up() {
    if (GMotion.reduce(context)) return;
    _ctrl.animateWith(SpringSimulation(GMotion.snap, _ctrl.value, 1, _ctrl.velocity));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.button && _enabled,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeChildSemantics,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: GestureDetector(
        behavior: widget.behavior,
        excludeFromSemantics: true,
        onTapDown: (_) => _down(),
        onTapUp: (_) => _up(),
        onTapCancel: _up,
        onLongPressEnd: (_) => _up(),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: ScaleTransition(scale: _ctrl, child: widget.child),
      ),
    );
  }
}
