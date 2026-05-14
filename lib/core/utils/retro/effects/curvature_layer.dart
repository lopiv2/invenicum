import 'package:flutter/material.dart';

class CurvatureLayer extends StatelessWidget {
  final double strength;
  final Widget child;

  const CurvatureLayer({
    super.key,
    required this.strength,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _VignettePainter(strength),
            ),
          ),
        ),
      ],
    );
  }
}

class _VignettePainter extends CustomPainter {
  final double strength;

  _VignettePainter(this.strength);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: strength),
        ],
        stops: const [0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_VignettePainter old) => old.strength != strength;
}
