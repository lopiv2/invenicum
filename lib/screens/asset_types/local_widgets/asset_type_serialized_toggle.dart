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
                  'Un tipo seriado gestiona cada unidad como un registro independiente. No implica necesariamente que exista un número de serie real de fábrica.\n\n'
                  'Un tipo no seriado permite agrupar cantidades en un mismo registro. En contenedores de colección, los campos de posesión y deseados solo se pueden configurar sobre tipos no seriados.',
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
              ? 'Cada unidad se gestiona como un registro independiente.'
              : 'Permite agrupar cantidades en un mismo registro.',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
