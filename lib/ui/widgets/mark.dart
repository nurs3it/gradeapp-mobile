import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/layout.dart';

/// «Четыре страницы» geometry from the brand book (viewBox 100): four pages
/// rotated around (31, 75), opacities 25 / 48 / 72 / 100 %.
const _pages = [
  (w: 50.0, a: -6.0, o: 0.25),
  (w: 54.0, a: -28.0, o: 0.48),
  (w: 58.0, a: -50.0, o: 0.72),
  (w: 62.0, a: -72.0, o: 1.0),
];

class MarkPainter extends CustomPainter {
  MarkPainter({required this.color, this.unfold = const [1, 1, 1, 1], this.alpha = const [1, 1, 1, 1]});

  final Color color;

  /// Per page 0 (folded onto the first page) … 1 (brand angle).
  final List<double> unfold;

  /// Per page multiplier of the brand opacity.
  final List<double> alpha;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    for (var i = 0; i < _pages.length; i++) {
      final p = _pages[i];
      final a = alpha[i].clamp(0.0, 1.0);
      if (a == 0) continue;
      final angle = _pages.first.a + (p.a - _pages.first.a) * unfold[i];
      canvas
        ..save()
        ..translate(31, 75)
        ..rotate(angle * math.pi / 180)
        ..translate(-31, -75)
        ..drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(24, 66.5, p.w, 16), const Radius.circular(8)),
          Paint()..color = color.withValues(alpha: p.o * a),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(MarkPainter old) => old.color != color || !_eq(old.unfold, unfold) || !_eq(old.alpha, alpha);

  static bool _eq(List<double> a, List<double> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The static mark.
class GMark extends StatelessWidget {
  const GMark({super.key, this.size = 44, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: MarkPainter(color: color ?? GColors.brand),
    ),
  );
}

/// «Страницы переворачиваются» loader (1.87 s cycle). Replaces every spinner.
class GLoader extends StatefulWidget {
  const GLoader({super.key, this.size = 32, this.color});
  final double size;
  final Color? color;

  @override
  State<GLoader> createState() => _GLoaderState();
}

class _GLoaderState extends State<GLoader> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1870))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? GColors.brand;
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final phase = _ctrl.value;
            // Each page flips in turn: folds, then opens back to its angle.
            final unfold = [
              for (var i = 0; i < 4; i++) 1 - math.pow(math.sin(((phase - i * 0.12) % 1.0) * math.pi), 6).toDouble(),
            ];
            return CustomPaint(
              size: Size.square(widget.size),
              painter: MarkPainter(color: color, unfold: unfold),
            );
          },
        ),
      ),
    );
  }
}

/// Fan progress (§3.22): four pages; earned ones get the brand steps, the rest
/// 10 %. Four earned pages = the mark. Used for quarters and the refresh pull.
class GFanProgress extends StatelessWidget {
  const GFanProgress({super.key, required this.earned, this.size = 24, this.color});

  /// 0…4, fractions allowed (pull-to-refresh).
  final double earned;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: MarkPainter(
        color: color ?? GColors.brand,
        alpha: [for (var i = 0; i < 4; i++) (earned - i).clamp(0.0, 1.0) * 0.9 + 0.1],
      ),
    ),
  );
}

/// Unfolding mark for the «Отмечено» screen: pages open one by one on the
/// `celebrate` spring, 70 ms apart. [onDone] fires as the last page lands.
class GMarkUnfold extends StatefulWidget {
  const GMarkUnfold({super.key, this.size = 132, this.color = GColors.onFill, this.onDone});
  final double size;
  final Color color;
  final VoidCallback? onDone;

  @override
  State<GMarkUnfold> createState() => _GMarkUnfoldState();
}

class _GMarkUnfoldState extends State<GMarkUnfold> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _step = 0.07;
  late final double _settle = SpringCurve.celebrate.settle;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ((_settle + 3 * _step) * 1000).round()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GMotion.reduce(context)) {
        _ctrl.value = 1;
        widget.onDone?.call();
        return;
      }
      _ctrl.forward().whenComplete(() => widget.onDone?.call());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final total = _settle + 3 * _step;
        final t = _ctrl.value * total;
        final unfold = <double>[];
        final alpha = <double>[];
        for (var i = 0; i < 4; i++) {
          final local = ((t - i * _step) / _settle).clamp(0.0, 1.0);
          unfold.add(i == 0 ? 1 : SpringCurve.celebrate.transform(local));
          alpha.add(local > 0 || i == 0 ? 1 : 0);
        }
        return CustomPaint(
          size: Size.square(widget.size),
          painter: MarkPainter(color: widget.color, unfold: unfold, alpha: alpha),
        );
      },
    ),
  );
}

/// Brand loader centred on the canvas (splash, first load).
class GSplash extends StatelessWidget {
  const GSplash({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GColors.brandGradTop, GColors.brand],
      ),
    ),
    child: Center(child: GMark(size: 88, color: GColors.onFill)),
  );
}
