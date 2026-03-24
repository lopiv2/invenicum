import 'package:flutter/material.dart';

/// Widget para el toggle de artículo seriado/no seriado
class AssetTypeSerializedToggle extends StatelessWidget {
  final bool isSerialized;
  final ValueChanged<bool> onChanged;

  const AssetTypeSerializedToggle({
    super.key,
    required this.isSerialized,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.secondaryHeaderColor,
      child: CheckboxListTile(
        value: isSerialized,
        onChanged: (value) {
          onChanged(value ?? true);
        },
        title: Row(
          children: [
            const Text('¿Es un artículo seriado?'),
            const SizedBox(width: 8),
            Tooltip(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              showDuration: const Duration(seconds: 5),
              triggerMode: TooltipTriggerMode.longPress,
              message:
                  'Los artículos seriados tienen cantidad fija de 1 (ej: número de serie).\n\n'
                  'Los no seriados pueden tener cantidades variables (ej: consumibles), '
                  'y añaden campos de "Cantidad" y "Stock Mínimo" en la creación de elementos.',
              child: Icon(
                Icons.help_outline,
                size: 18,
                color: theme.primaryColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        subtitle: Text(
          isSerialized
              ? 'Cantidad fija (1 unidad).'
              : 'Cantidad variable y control de stock.',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
