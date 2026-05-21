import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

const _matrixChars = 'アイウエオカキクケコサシスセソタチツテト'
    'ナニヌネノハヒフヘホマミムメモヤユヨラリルレロ'
    'ワヰヱヲン0123456789';

class MatrixRainLayer extends StatefulWidget {
  final double opacity;
  final int columnCount;
  final double speed;
  final double? fontSize;
  final int? refreshMs;
  final Widget child;

  const MatrixRainLayer({
    super.key,
    this.opacity = 0.5,
    this.columnCount = 80,
    this.speed = 1.0,
    this.fontSize,
    this.refreshMs,
    required this.child,
  });

  @override
  State<MatrixRainLayer> createState() => _MatrixRainLayerState();
}

class _MatrixRainLayerState extends State<MatrixRainLayer> {
  Timer? _timer;
  int _frame = 0;
  List<_MatrixDrop> _drops = [];
  int _actualColumns = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(milliseconds: widget.refreshMs ?? (80 / widget.speed).round()),
      (_) {
        if (!mounted) return;
        setState(() => _frame++);
      },
    );
  }

  int _resolveColumnCount(double width) {
    if (widget.fontSize != null) {
      return (width / (widget.fontSize! * 1.2)).floor().clamp(1, 200);
    }
    return widget.columnCount;
  }

  void _initDrops(int count) {
    final rng = math.Random();
    _drops = List.generate(count, (i) {
      return _MatrixDrop(
        column: i,
        y: rng.nextDouble(),
        speed: 0.02 + rng.nextDouble() * 0.04,
        length: 5 + rng.nextInt(15),
        seed: rng.nextInt(10000),
      );
    });
  }

  @override
  void didUpdateWidget(MatrixRainLayer old) {
    super.didUpdateWidget(old);
    if (old.speed != widget.speed || old.refreshMs != widget.refreshMs) {
      _timer?.cancel();
      _timer = Timer.periodic(
        Duration(milliseconds: widget.refreshMs ?? (80 / widget.speed).round()),
        (_) {
          if (!mounted) return;
          setState(() => _frame++);
        },
      );
    }
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cols = _resolveColumnCount(constraints.maxWidth);
                if (_drops.isEmpty || cols != _actualColumns) {
                  _actualColumns = cols;
                  _initDrops(cols);
                }
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: _MatrixRainPainter(
                      drops: _drops,
                      opacity: widget.opacity,
                      frame: _frame,
                      columnCount: cols,
                      fontSize: widget.fontSize,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MatrixDrop {
  final int column;
  double y;
  final double speed;
  final int length;
  final int seed;

  _MatrixDrop({
    required this.column,
    required this.y,
    required this.speed,
    required this.length,
    required this.seed,
  });
}

class _MatrixRainPainter extends CustomPainter {
  final List<_MatrixDrop> drops;
  final double opacity;
  final int frame;
  final int columnCount;
  final double? fontSize;

  _MatrixRainPainter({
    required this.drops,
    required this.opacity,
    required this.frame,
    required this.columnCount,
    this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fs = fontSize ?? size.width / columnCount * 0.85;
    final charSpacing = fs * 1.3;
    final colWidth = fontSize != null ? fs * 1.2 : size.width / columnCount;
    final rng = math.Random(frame);

    for (final drop in drops) {
      drop.y += drop.speed;
      if (drop.y > 1.0 + drop.length * charSpacing / size.height) {
        drop.y = -drop.length * charSpacing / size.height;
      }

      final x = fontSize != null
          ? drop.column * colWidth
          : drop.column * (size.width / columnCount);
      final baseY = drop.y * size.height;

      for (var i = 0; i < drop.length; i++) {
        final cy = baseY - i * charSpacing;
        if (cy < -charSpacing || cy > size.height + charSpacing) continue;

        final charIndex = rng.nextInt(_matrixChars.length);
        final c = _matrixChars[charIndex];

        final t = i / drop.length;
        final alpha = (opacity * (1.0 - t * 0.85)).clamp(0.0, 1.0);

        final color = switch (i) {
          0 => Colors.white.withValues(alpha: alpha),
          1 || 2 => const Color(0xFF00FF41).withValues(alpha: alpha),
          _ => const Color(0xFF00AA22).withValues(alpha: alpha),
        };

        if (i == 0) {
          canvas.drawParagraph(
            _buildParagraph(c.toString(), const Color(0xFF00FF41).withValues(alpha: alpha * 0.2), fs * 2.4),
            Offset(x - fs * 0.65, cy - fs * 0.45),
          );
          canvas.drawParagraph(
            _buildParagraph(c.toString(), const Color(0xFF88FF88).withValues(alpha: alpha * 0.35), fs * 1.5),
            Offset(x - fs * 0.25, cy - fs * 0.2),
          );
        }

        canvas.drawParagraph(
          _buildParagraph(c.toString(), color, fs),
          Offset(x, cy),
        );
      }
    }
  }

  ui.Paragraph _buildParagraph(String text, Color color, double fontSize) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: fontSize,
        fontFamily: 'monospace',
      ),
    )..pushStyle(ui.TextStyle(color: color));
    builder.addText(text);
    return builder.build()..layout(const ui.ParagraphConstraints(width: 200));
  }

  @override
  bool shouldRepaint(_MatrixRainPainter old) => old.frame != frame;
}
