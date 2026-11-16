import 'package:flutter/material.dart';

import '../tokens/layout.dart';
import '../tokens/type.dart';

/// Scoreboard text (§2.6 «Тик отсчёта»): every changed character slides up
/// 8 pt and fades while the new one comes from below, 240 ms. No keyed
/// switchers — one controller, the previous text kept in state — so rapid
/// changes can never produce duplicate keys.
class GRollingText extends StatefulWidget {
  const GRollingText(this.text, {super.key, required this.style, this.cap = GScale.display, this.semanticsLabel});
  final String text;
  final TextStyle style;
  final double cap;
  final String? semanticsLabel;

  @override
  State<GRollingText> createState() => _GRollingTextState();
}

class _GRollingTextState extends State<GRollingText> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: GMotion.base, value: 1);
  late String _from = widget.text;

  @override
  void didUpdateWidget(GRollingText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      // Mid-animation: start from what is on screen now.
      _from = _ctrl.value < 0.5 ? _from : old.text;
      if (GMotion.reduce(context)) {
        _ctrl.value = 1;
      } else {
        _ctrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = TextScaler.linear(GScale.of(context).clamp(1.0, widget.cap));
    final to = widget.text;
    final from = _from.padLeft(to.length).substring(_from.length > to.length ? _from.length - to.length : 0);
    return Semantics(
      label: widget.semanticsLabel ?? to,
      excludeSemantics: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = GMotion.standard.transform(_ctrl.value);
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                for (var i = 0; i < to.length; i++)
                  if (_ctrl.value >= 1 || from[i] == to[i])
                    Text(to[i], style: widget.style, textScaler: scaler)
                  else
                    ClipRect(
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: 0,
                            child: Text(to[i], style: widget.style, textScaler: scaler),
                          ),
                          Transform.translate(
                            offset: Offset(0, -8 * t),
                            child: Opacity(
                              opacity: 1 - t,
                              child: Text(from[i], style: widget.style, textScaler: scaler),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, 8 * (1 - t)),
                            child: Opacity(
                              opacity: t,
                              child: Text(to[i], style: widget.style, textScaler: scaler),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
