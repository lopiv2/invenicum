import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class HeroTextBlock extends StatelessWidget {
  const HeroTextBlock({required this.summary});

  final Widget summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.integrationsHeroHeadline,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.integrationsHeroSubheadline,
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
