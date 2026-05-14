import 'package:flutter/material.dart';

class BloomLayer extends StatelessWidget {
  final double intensity;
  final double radius;
  final Color? color;
  final Widget child;

  const BloomLayer({
    super.key,
    required this.intensity,
    required this.radius,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRect(
              child: BackdropFilter(
                filter: ColorFilter.mode(
                  (color ?? Colors.white)
                      .withValues(alpha: intensity * 0.5),
                  BlendMode.srcOver,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
