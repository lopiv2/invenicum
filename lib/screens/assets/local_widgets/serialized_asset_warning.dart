import 'package:flutter/material.dart';

/// Widget para mostrar la advertencia cuando el artículo es seriado
class SerializedAssetWarningWidget extends StatelessWidget {
  const SerializedAssetWarningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: colorScheme.secondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Este es un artículo seriado. La cantidad es fija a 1.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(
                      color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
