import 'package:flutter/material.dart';

class DitheringLayer extends StatelessWidget {
  final double strength;
  final double patternSize;
  final Widget child;

  const DitheringLayer({
    super.key,
    required this.strength,
    this.patternSize = 4.0,
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
              painter: _DitheringPainter(strength, patternSize),
            ),
          ),
        ),
      ],
    );
  }
}

class _DitheringPainter extends CustomPainter {
  final double strength;
  final double patternSize;

  static const _bayer4 = [
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5],
  ];

  _DitheringPainter(this.strength, this.patternSize);

  @override
  void paint(Canvas canvas, Size size) {
    final cols = (size.width / patternSize).ceil();
    final rows = (size.height / patternSize).ceil();

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final bayerValue = _bayer4[r % 4][c % 4] / 16.0;
        final cellOpacity = bayerValue * strength;

        if (cellOpacity > 0.01) {
          final paint = Paint()
            ..color = Colors.black.withValues(alpha: cellOpacity);
          canvas.drawRect(
            Rect.fromLTWH(
              c * patternSize,
              r * patternSize,
              patternSize,
              patternSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DitheringPainter old) =>
      old.strength != strength || old.patternSize != patternSize;
}
