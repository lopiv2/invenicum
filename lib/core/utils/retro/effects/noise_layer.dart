import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class NoiseLayer extends StatefulWidget {
  final double opacity;
  final int density;
  final Widget child;

  const NoiseLayer({
    super.key,
    required this.opacity,
    this.density = 80,
    required this.child,
  });

  @override
  State<NoiseLayer> createState() => _NoiseLayerState();
}

class _NoiseLayerState extends State<NoiseLayer> {
  Timer? _timer;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _startNoise();
  }

  void _startNoise() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() => _frame++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
              child: CustomPaint(
                painter: _NoisePainter(
                  opacity: widget.opacity,
                  density: widget.density,
                  seed: _frame,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;
  final int density;
  final int seed;

  _NoisePainter({
    required this.opacity,
    required this.density,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity);

    for (var i = 0; i < density; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(x, y, 2.0, 1.0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => old.seed != seed;
}
