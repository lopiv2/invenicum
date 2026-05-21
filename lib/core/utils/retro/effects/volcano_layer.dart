import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class VolcanoLayer extends StatefulWidget {
  final double opacity;
  final int particleCount;
  final double speed;
  final double power;
  final Widget child;

  const VolcanoLayer({
    super.key,
    this.opacity = 0.7,
    this.particleCount = 50,
    this.speed = 1.0,
    this.power = 8.0,
    required this.child,
  });

  @override
  State<VolcanoLayer> createState() => _VolcanoLayerState();
}

class _VolcanoLayerState extends State<VolcanoLayer> {
  Timer? _timer;
  int _frame = 0;
  late List<_LavaParticle> _particles;
  double _width = 0;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _timer = Timer.periodic(
      Duration(milliseconds: (40 / widget.speed).round()),
      (_) {
        if (!mounted) return;
        setState(() => _frame++);
      },
    );
  }

  void _initParticles() {
    final rng = math.Random(42);
    _particles = List.generate(widget.particleCount, (_) {
      return _LavaParticle._random(rng, 0, 0, widget.power);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        _height = constraints.maxHeight;
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _VolcanoPainter(
                      particles: _particles,
                      opacity: widget.opacity,
                      frame: _frame,
                      speed: widget.speed,
                      power: widget.power,
                      width: _width,
                      height: _height,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LavaParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double radius;
  late double life;
  late Color color;

  _LavaParticle._random(math.Random rng, double width, double height, double maxPower) {
    x = width / 2 + (rng.nextDouble() - 0.5) * 40;
    y = height;
    final angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * 1.2;
    final p = maxPower * 0.5 + rng.nextDouble() * (maxPower * 0.5);
    vx = math.cos(angle) * p;
    vy = math.sin(angle) * p;
    radius = 1.5 + rng.nextDouble() * 3;
    life = 0.0;
    color = _randomLavaColor(rng);
  }
}

const _lavaPalette = [Color(0xFFFF0000), Color(0xFFFFAA00), Color(0xFFFFCC00)];

Color _randomLavaColor(math.Random rng) {
  return _lavaPalette[rng.nextInt(_lavaPalette.length)];
}

Color _lavaFade(Color base, double life) {
  final t = life.clamp(0.0, 1.0);
  final darken = Color.lerp(base, const Color(0xFF331100), t * 0.7)!;
  final alpha = (1.0 - t * 0.85).clamp(0.0, 1.0);
  return darken.withValues(alpha: alpha);
}

class _VolcanoPainter extends CustomPainter {
  final List<_LavaParticle> particles;
  final double opacity;
  final int frame;
  final double speed;
  final double power;
  final double width;
  final double height;

  _VolcanoPainter({
    required this.particles,
    required this.opacity,
    required this.frame,
    required this.speed,
    required this.power,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(frame);

    for (final p in particles) {
      final gravity = p.vy > 0 ? 0.35 : 0.15;
      p.x += p.vx * speed * 2;
      p.vy += gravity * speed * 2;
      p.y += p.vy * speed * 2;
      p.life += 0.008 * speed;

      if (p.life > 1.0 || p.y > height + 20) {
        final angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * 1.2;
        final pwr = power * 0.5 + rng.nextDouble() * (power * 0.5);
        p.x = width / 2 + (rng.nextDouble() - 0.5) * 40;
        p.y = height;
        p.vx = math.cos(angle) * pwr;
        p.vy = math.sin(angle) * pwr;
        p.radius = 1.5 + rng.nextDouble() * 3;
        p.life = 0.0;
        p.color = _randomLavaColor(rng);
      }

      if (p.x < 0 || p.x > width) {
        p.vx *= -0.5;
        p.x = p.x.clamp(0, width);
      }

      final faded = _lavaFade(p.color, p.life);
      final alpha = faded.a * opacity;

      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * (1.0 - p.life * 0.5),
        Paint()..color = faded.withValues(alpha: alpha),
      );

      if (p.life < 0.3) {
        canvas.drawCircle(
          Offset(p.x, p.y),
          p.radius * 2.5,
          Paint()
            ..color = p.color.withValues(alpha: alpha * 0.25),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_VolcanoPainter old) => old.frame != frame;
}
