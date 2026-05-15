import 'dart:math' as math;
import 'package:flutter/material.dart';

class SnowLayer extends StatefulWidget {
  final double opacity;
  final int flakeCount;
  final double speed;
  final Widget child;

  const SnowLayer({
    super.key,
    this.opacity = 0.6,
    this.flakeCount = 60,
    this.speed = 1.0,
    required this.child,
  });

  @override
  State<SnowLayer> createState() => _SnowLayerState();
}

class _SnowLayerState extends State<SnowLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Snowflake> _flakes;

  @override
  void initState() {
    super.initState();
    _flakes = List.generate(widget.flakeCount, (_) => _Snowflake());
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
                    painter: _SnowPainter(
                      flakes: _flakes,
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

class _Snowflake {
  double x;
  double y;
  double radius;
  double drift;
  double fallSpeed;

  _Snowflake()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        radius = 1.0 + math.Random().nextDouble() * 2.5,
        drift = (math.Random().nextDouble() - 0.5) * 0.01,
        fallSpeed = 0.003 + math.Random().nextDouble() * 0.007;
}

class _SnowPainter extends CustomPainter {
  final List<_Snowflake> flakes;
  final double opacity;
  final double speed;
  final double time;

  _SnowPainter({
    required this.flakes,
    required this.opacity,
    required this.speed,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity);

    for (final flake in flakes) {
      flake.y += flake.fallSpeed * speed;
      flake.x += flake.drift * speed;

      if (flake.y > 1.0) {
        flake.y = -0.02;
        flake.x = math.Random().nextDouble();
      }
      if (flake.x > 1.0) flake.x = 0.0;
      if (flake.x < 0.0) flake.x = 1.0;

      canvas.drawCircle(
        Offset(flake.x * size.width, flake.y * size.height),
        flake.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SnowPainter old) => old.time != time;
}
