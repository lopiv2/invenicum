import 'package:flutter/material.dart';

class IntegrationVisual extends StatelessWidget {
  const IntegrationVisual({
    super.key,
    this.icon,
    required this.image,
    required this.accent,
  });

  final Widget? icon;
  final Image? image;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visAccent = isDark
        ? HSLColor.fromColor(accent).lightness < 0.5
            ? HSLColor.fromColor(accent).withLightness(0.5).toColor()
            : accent
        : accent;

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: visAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: icon != null
          ? FittedBox(fit: BoxFit.contain, child: icon!)
          : (image != null
              ? image!
              : const SizedBox.shrink()),
    );
  }
}
