import 'package:flutter/material.dart';

class ScanlinesLayer extends StatelessWidget {
  final double opacity;
  final double spacing;
  final Widget child;

  const ScanlinesLayer({
    super.key,
    required this.opacity,
    required this.spacing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ScanlinesPainter(opacity, spacing)),
          ),
        ),
      ],
    );
  }
}

class _ScanlinesPainter extends CustomPainter {
  final double opacity;
  final double spacing;

  _ScanlinesPainter(this.opacity, this.spacing);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = 1.0;

    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter old) =>
      old.opacity != opacity || old.spacing != spacing;
}
