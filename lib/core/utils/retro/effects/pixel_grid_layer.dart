import 'package:flutter/material.dart';

class PixelGridLayer extends StatelessWidget {
  final double gridSize;
  final double opacity;
  final Widget child;

  const PixelGridLayer({
    super.key,
    required this.gridSize,
    required this.opacity,
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
              painter: _PixelGridPainter(gridSize, opacity),
            ),
          ),
        ),
      ],
    );
  }
}

class _PixelGridPainter extends CustomPainter {
  final double gridSize;
  final double opacity;

  _PixelGridPainter(this.gridSize, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.5)
      ..strokeWidth = 0.5;

    var x = gridSize;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += gridSize;
    }

    var y = gridSize;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += gridSize;
    }

    final dotPaint = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.3);
    final dotRadius = 0.8;

    x = gridSize / 2;
    while (x < size.width) {
      y = gridSize / 2;
      while (y < size.height) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
        y += gridSize;
      }
      x += gridSize;
    }
  }

  @override
  bool shouldRepaint(_PixelGridPainter old) =>
      old.gridSize != gridSize || old.opacity != opacity;
}
