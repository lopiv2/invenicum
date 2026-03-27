import 'package:flutter/material.dart';

class HeroTextBlock extends StatelessWidget {
  const HeroTextBlock({required this.summary});

  final Widget summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conecta servicios, APIs y herramientas desde una única vista clara.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Agrupamos las integraciones por propósito para que la configuración sea más rápida, más visual y más fácil de mantener también en móvil.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        summary,
      ],
    );
  }
}
