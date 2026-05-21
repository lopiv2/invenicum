import 'package:flutter/material.dart';

class PhosphorGlowLayer extends StatelessWidget {
  final double radius;
  final Color? color;
  final Widget child;

  const PhosphorGlowLayer({
    super.key,
    required this.radius,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        (color ?? Colors.cyan).withValues(alpha: 0.15),
        BlendMode.srcATop,
      ),
      child: child,
    );
  }
}
