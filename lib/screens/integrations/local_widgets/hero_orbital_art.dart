import 'package:flutter/material.dart';
import 'orbit_badge.dart';

class HeroOrbitalArt extends StatelessWidget {
  const HeroOrbitalArt({super.key});

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
          Positioned(
            top: MediaQuery.of(context).size.height / 60,
            child: OrbitBadge(icon: Icons.auto_awesome_rounded),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width / 11,
            child: OrbitBadge(icon: Icons.telegram),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 60,
            child: OrbitBadge(icon: Icons.qr_code_2_rounded),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 11,
            child: OrbitBadge(icon: Icons.bar_chart_rounded),
          ),
        ],
      ),
    );
  }
}
