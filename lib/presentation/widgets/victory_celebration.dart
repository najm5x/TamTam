import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Lightweight confetti/sparkle overlay for the Victory screen. Purely
/// decorative: wrapped in [IgnorePointer] so it never intercepts taps, never
/// affects layout (place it in a `Positioned.fill`), and disposes its own
/// ticker when the page is left.
class VictoryCelebration extends StatefulWidget {
  const VictoryCelebration({super.key, this.particleCount = 46});

  final int particleCount;

  @override
  State<VictoryCelebration> createState() => _VictoryCelebrationState();
}

class _VictoryCelebrationState extends State<VictoryCelebration>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<_Particle> _particles;
  double _elapsedSeconds = 0;

  static const List<Color> _palette = [
    Color(0xFFF6C453), // warm gold
    Color(0xFFFFF7E6), // ivory
    Color(0xFFE0483E), // red accent
    Color(0xFF3E7BFA), // blue accent
    Color(0xFF57C46B), // small amount of green
    Color(0xFFF2E14C), // small amount of yellow
  ];

  @override
  void initState() {
    super.initState();
    final random = Random(11);
    _particles = List.generate(widget.particleCount, (_) => _Particle.random(random, _palette));
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
          painter: _ConfettiPainter(particles: _particles, elapsedSeconds: _elapsedSeconds),
        ),
      ),
    );
  }
}

class _Particle {
  final double dx; // horizontal position, fraction of width (0..1)
  final double startDelay; // seconds before this particle starts falling
  final double fallPeriod; // seconds to fall the full height and loop
  final double size;
  final double swayAmplitude; // logical px
  final double swayPeriod;
  final double swayPhase;
  final double rotationSpeed; // radians per second
  final double rotationPhase;
  final Color color;
  final bool isSquare;

  const _Particle({
    required this.dx,
    required this.startDelay,
    required this.fallPeriod,
    required this.size,
    required this.swayAmplitude,
    required this.swayPeriod,
    required this.swayPhase,
    required this.rotationSpeed,
    required this.rotationPhase,
    required this.color,
    required this.isSquare,
  });

  factory _Particle.random(Random r, List<Color> palette) {
    return _Particle(
      dx: r.nextDouble(),
      startDelay: r.nextDouble() * 2.5,
      fallPeriod: 3.5 + r.nextDouble() * 2.5,
      size: 4.0 + r.nextDouble() * 5.0,
      swayAmplitude: 10.0 + r.nextDouble() * 18.0,
      swayPeriod: 1.6 + r.nextDouble() * 1.4,
      swayPhase: r.nextDouble() * 2 * pi,
      rotationSpeed: (r.nextBool() ? 1 : -1) * (0.8 + r.nextDouble() * 1.6),
      rotationPhase: r.nextDouble() * 2 * pi,
      color: palette[r.nextInt(palette.length)],
      isSquare: r.nextBool(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.elapsedSeconds});

  final List<_Particle> particles;
  final double elapsedSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final t = elapsedSeconds - p.startDelay;
      if (t < 0) {
        continue;
      }
      final cycle = (t % p.fallPeriod) / p.fallPeriod;
      final y = cycle * (size.height + 40.0) - 20.0;
      final sway = sin(elapsedSeconds / p.swayPeriod * 2 * pi + p.swayPhase) * p.swayAmplitude;
      final x = p.dx * size.width + sway;
      final rotation = elapsedSeconds * p.rotationSpeed + p.rotationPhase;
      final fadeIn = (cycle * 10.0).clamp(0.0, 1.0);
      final fadeOut = ((1.0 - cycle) * 6.0).clamp(0.0, 1.0);
      final opacity = (fadeIn < fadeOut ? fadeIn : fadeOut).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      paint.color = p.color.withValues(alpha: 0.75 * opacity);
      if (p.isSquare) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds;
  }
}
