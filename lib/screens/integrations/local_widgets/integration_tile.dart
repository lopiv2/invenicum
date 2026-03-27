import 'package:flutter/material.dart';
import 'package:invenicum/data/models/integration_field_type.dart';
import 'status_chip.dart';
import 'integration_visual.dart';

class IntegrationTile extends StatelessWidget {
  const IntegrationTile({
    required this.integration,
    required this.accent,
    required this.isLinked,
    required this.onTap,
  });

  final IntegrationModel integration;
  final Color accent;
  final bool isLinked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, accent.withValues(alpha: 0.06)],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.20)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusChip(
                            label: isLinked ? 'Conectada' : 'Sin configurar',
                            background: isLinked
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFFEDD5),
                            foreground: isLinked
                                ? const Color(0xFF166534)
                                : const Color(0xFF9A3412),
                            icon: isLinked
                                ? Icons.check_circle_rounded
                                : Icons.tune_rounded,
                          ),
                          StatusChip(
                            label: integration.isDataSource
                                ? 'Fuente de datos'
                                : 'Conector',
                            background: accent.withValues(alpha: 0.12),
                            foreground: accent,
                            icon: integration.isDataSource
                                ? Icons.cloud_download_outlined
                                : Icons.settings_input_component_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IntegrationVisual(
                      icon: integration.icon,
                      image: integration.image,
                      accent: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  integration.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    integration.description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (integration.fields.isNotEmpty)
                      Text(
                        '${integration.fields.length} campos',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        'Sin credenciales locales',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLinked ? 'Editar' : 'Configurar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_outward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
