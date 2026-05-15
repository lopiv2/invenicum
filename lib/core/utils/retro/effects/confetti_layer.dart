import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiLayer extends StatefulWidget {
  final double opacity;
  final int particleCount;
  final double speed;
  final List<Color> colors;
  final Widget child;

  const ConfettiLayer({
    super.key,
    this.opacity = 0.8,
    this.particleCount = 40,
    this.speed = 1.0,
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ],
    required this.child,
  });

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      widget.particleCount,
      (_) => _ConfettiParticle(widget.colors),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      opacity: widget.opacity,
                      speed: widget.speed,
                      time: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  late double x;
  late double y;
  late double rotation;
  late double rotationSpeed;
  late double width;
  late double height;
  late double drift;
  late double fallSpeed;
  late Color color;

  _ConfettiParticle(List<Color> palette) {
    final rng = math.Random();
    x = rng.nextDouble();
    y = rng.nextDouble();
    rotation = rng.nextDouble() * math.pi * 2;
    rotationSpeed = (rng.nextDouble() - 0.5) * 0.05;
    width = 3.0 + rng.nextDouble() * 6.0;
    height = 2.0 + rng.nextDouble() * 4.0;
    drift = (rng.nextDouble() - 0.5) * 0.015;
    fallSpeed = 0.004 + rng.nextDouble() * 0.008;
    color = palette[rng.nextInt(palette.length)];
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double opacity;
  final double speed;
  final double time;

  _ConfettiPainter({
    required this.particles,
    required this.opacity,
    required this.speed,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random();

    for (final p in particles) {
      p.y += p.fallSpeed * speed;
      p.x += p.drift * speed + math.sin(p.rotation + time * 2) * 0.002;
      p.rotation += p.rotationSpeed;

      if (p.y > 1.0) {
        p.y = -0.02;
        p.x = rng.nextDouble();
        p.rotation = rng.nextDouble() * math.pi * 2;
      }
      if (p.x > 1.0) p.x = 0.0;
      if (p.x < 0.0) p.x = 1.0;

      final cx = p.x * size.width;
      final cy = p.y * size.height;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(p.rotation);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity);
      canvas.drawRect(
        Rect.fromLTWH(-p.width / 2, -p.height / 2, p.width, p.height),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.time != time;
}
