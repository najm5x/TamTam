import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Lightweight animated sparkle overlay for the Home background only.
///
/// Purely decorative: it never reads game/domain state, never affects
/// layout size (wrap it in `Positioned.fill` where it's placed), and is
/// wrapped in [IgnorePointer] so it can never intercept taps meant for the
/// Home UI above it. Rebuilds are isolated to this widget's own ticker --
/// placing it does not cause the rest of Home to repaint every frame.
class HomeSparkleLayer extends StatefulWidget {
  const HomeSparkleLayer({super.key, this.sparkleCount = 28});

  final int sparkleCount;

  @override
  State<HomeSparkleLayer> createState() => _HomeSparkleLayerState();
}

class _HomeSparkleLayerState extends State<HomeSparkleLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<_Sparkle> _sparkles;
  double _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    final random = Random(7);
    _sparkles = List.generate(widget.sparkleCount, (_) => _Sparkle.random(random));
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsedSeconds = elapsed.inMicroseconds / 1e6;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _SparklePainter(sparkles: _sparkles, elapsedSeconds: _elapsedSeconds),
        ),
      ),
    );
  }
}

class _Sparkle {
  final double dx; // horizontal position, fraction of width (0..1)
  final double dy; // base vertical position, fraction of height (0..1)
  final double size; // base radius in logical px
  final double twinklePeriod; // seconds per twinkle cycle
  final double twinklePhase;
  final double driftAmplitude; // logical px
  final double driftPeriod; // seconds per drift cycle
  final double driftPhase;
  final double minOpacity;
  final double maxOpacity;

  const _Sparkle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.twinklePeriod,
    required this.twinklePhase,
    required this.driftAmplitude,
    required this.driftPeriod,
    required this.driftPhase,
    required this.minOpacity,
    required this.maxOpacity,
  });

  factory _Sparkle.random(Random r) {
    return _Sparkle(
      dx: r.nextDouble(),
      dy: r.nextDouble(),
      size: 1.5 + r.nextDouble() * 2.5,
      twinklePeriod: 1.8 + r.nextDouble() * 1.7,
      twinklePhase: r.nextDouble() * 2 * pi,
      driftAmplitude: 8.0 + r.nextDouble() * 12.0,
      driftPeriod: 7.0 + r.nextDouble() * 9.0,
      driftPhase: r.nextDouble() * 2 * pi,
      minOpacity: 0.15 + r.nextDouble() * 0.1,
      maxOpacity: 0.4 + r.nextDouble() * 0.15,
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.sparkles, required this.elapsedSeconds});

  final List<_Sparkle> sparkles;
  final double elapsedSeconds;

  static const Color _sparkleColor = Color(0xFFFFF3D6);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in sparkles) {
      final twinkle = (sin(elapsedSeconds / s.twinklePeriod * 2 * pi + s.twinklePhase) + 1) / 2;
      final opacity = s.minOpacity + (s.maxOpacity - s.minOpacity) * twinkle;
      final scale = 0.7 + 0.3 * twinkle;
      final drift = sin(elapsedSeconds / s.driftPeriod * 2 * pi + s.driftPhase) * s.driftAmplitude;

      final center = Offset(s.dx * size.width, s.dy * size.height + drift);
      paint.color = _sparkleColor.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(center, s.size * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds;
  }
}
