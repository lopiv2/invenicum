import 'package:flutter/material.dart';
import 'integration_section_data.dart';
import 'integration_tile.dart';

class IntegrationSection extends StatelessWidget {
  const IntegrationSection({
    required this.section,
    required this.isLinked,
    required this.onTap,
  });

  final IntegrationSectionData section;
  final bool Function(String id) isLinked;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: section.accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: section.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(section.icon, color: section.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 1180
                  ? 3
                  : width >= 760
                  ? 2
                  : 1;
              final aspectRatio = width >= 1180
                  ? 1.38
                  : width >= 760
                  ? 1.28
                  : 1.18;

              return GridView.builder(
                itemCount: section.integrations.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  final integration = section.integrations[index];
                  return IntegrationTile(
                    integration: integration,
                    accent: section.accent,
                    isLinked: isLinked(integration.id),
                    onTap: () => onTap(integration.id),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
