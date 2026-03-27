import 'package:flutter/material.dart';

class OrbitBadge extends StatelessWidget {
  const OrbitBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
