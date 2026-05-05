import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/cga_constants.dart';

/// Paints a double-line IBM PC box-drawing border (╔═╗ / ╚═╝ style).
class CGADoubleBorderPainter extends CustomPainter {
  final Color color;

  const CGADoubleBorderPainter({this.color = CGA.brightCyan});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const o = 2.0; // outer rect offset
    const i = 5.0; // inner rect offset
    const cl = 6.0; // corner connector length

    // Outer rect
    canvas.drawRect(
        Rect.fromLTWH(o, o, size.width - o * 2, size.height - o * 2), paint);
    // Inner rect
    canvas.drawRect(
        Rect.fromLTWH(i, i, size.width - i * 2, size.height - i * 2), paint);

    // Corner connectors
    // Top-left
    canvas.drawLine(Offset(i, o), Offset(i + cl, o), paint);
    canvas.drawLine(Offset(o, i), Offset(o, i + cl), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - i - cl, o), Offset(size.width - i, o), paint);
    canvas.drawLine(Offset(size.width - o, i), Offset(size.width - o, i + cl), paint);
    // Bottom-left
    canvas.drawLine(Offset(i, size.height - o), Offset(i + cl, size.height - o), paint);
    canvas.drawLine(Offset(o, size.height - i - cl), Offset(o, size.height - i), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - i - cl, size.height - o), Offset(size.width - i, size.height - o), paint);
    canvas.drawLine(Offset(size.width - o, size.height - i - cl), Offset(size.width - o, size.height - i), paint);
  }

  @override
  bool shouldRepaint(CGADoubleBorderPainter old) => old.color != color;
}