import 'package:flutter/material.dart';

class IntegrationVisual extends StatelessWidget {
  const IntegrationVisual({
    required this.icon,
    required this.image,
    required this.accent,
  });

  final Widget icon;
  final Image? image;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: FittedBox(fit: BoxFit.contain, child: icon),
    );
  }
}
