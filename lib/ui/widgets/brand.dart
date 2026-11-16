import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// «Четыре страницы» mark. Geometry is fixed by the brand book
/// (handoff/CLAUDE.md) — same numbers as frontend/src/shared/ui/Logo.tsx.
class GradeAppMark extends StatelessWidget {
  const GradeAppMark({super.key, this.size = 44, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _MarkPainter(color ?? context.c.brand, 0));
}

/// Brand loader: pages of the fan flip in sequence (web BrandLoader, 1.87s).
class BrandLoader extends StatefulWidget {
  const BrandLoader({super.key, this.size = 56});
  final double size;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1870))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) =>
          CustomPaint(size: Size.square(widget.size), painter: _MarkPainter(context.c.brand, _ctrl.value)),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color, this.phase);
  final Color color;

  /// 0 = static mark; (0,1) = loader phase.
  final double phase;

  static const _pages = [
    (w: 50.0, a: -6.0, o: 0.25),
    (w: 54.0, a: -28.0, o: 0.48),
    (w: 58.0, a: -50.0, o: 0.72),
    (w: 62.0, a: -72.0, o: 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    for (var i = 0; i < _pages.length; i++) {
      final p = _pages[i];
      var opacity = p.o;
      if (phase > 0) {
        // Each page pulses once per cycle, offset by its index.
        final t = (phase - i * 0.15) % 1.0;
        opacity = p.o * (0.35 + 0.65 * (0.5 + 0.5 * math.cos(t * 2 * math.pi)));
      }
      canvas
        ..save()
        ..translate(31, 75)
        ..rotate(p.a * math.pi / 180)
        ..translate(-31, -75)
        ..drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(24, 66.5, p.w, 16), const Radius.circular(8)),
          Paint()..color = color.withValues(alpha: opacity),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.phase != phase || old.color != color;
}

/// Wordmark: «Grade» foreground + «App» brand.
class GradeAppWordmark extends StatelessWidget {
  const GradeAppWordmark({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        const TextSpan(text: 'Grade'),
        TextSpan(
          text: 'App',
          style: TextStyle(color: context.c.brand),
        ),
      ],
    ),
    style: TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02 * size,
      color: context.c.foreground,
    ),
  );
}
