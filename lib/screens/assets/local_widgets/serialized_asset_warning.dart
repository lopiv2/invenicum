import 'package:flutter/material.dart';

/// Widget para mostrar la advertencia cuando el artículo es seriado,
/// junto con el campo de número de serie.
class SerializedAssetWarningWidget extends StatelessWidget {
  final TextEditingController? serialNumberController;

  const SerializedAssetWarningWidget({
    super.key,
    this.serialNumberController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Aviso informativo ──────────────────────────────────────────
        Container(
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Número de serie ───────────────────────────────────────────
        if (serialNumberController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: serialNumberController,
            decoration: InputDecoration(
              labelText: 'Número de serie',
              hintText: 'Ej: SN-2024-00123',
              prefixIcon: Icon(
                Icons.tag_rounded,
                color: colorScheme.secondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
        ],
      ],
    );
  }
}