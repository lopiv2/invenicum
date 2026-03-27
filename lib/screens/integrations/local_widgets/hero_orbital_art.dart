import 'package:flutter/material.dart';
import 'orbit_badge.dart';

class HeroOrbitalArt extends StatelessWidget {
  const HeroOrbitalArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
          ),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 56),
          ),
          const Positioned(
            top: 22,
            child: OrbitBadge(icon: Icons.auto_awesome_rounded),
          ),
          const Positioned(right: 18, child: OrbitBadge(icon: Icons.telegram)),
          const Positioned(
            bottom: 20,
            child: OrbitBadge(icon: Icons.qr_code_2_rounded),
          ),
          const Positioned(
            left: 16,
            child: OrbitBadge(icon: Icons.bar_chart_rounded),
          ),
        ],
      ),
    );
  }
}
