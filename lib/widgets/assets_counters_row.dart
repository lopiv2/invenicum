// widgets/asset_counters_row.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/asset_type_model.dart';
import '../models/inventory_item.dart';
import '../providers/inventory_item_provider.dart';

class AssetCountersRow extends StatelessWidget {
  final AssetType assetType;
  final int totalCountLocal;
  final String? selectedCountFieldId;
  final List<InventoryItem>? inventoryItems;

  const AssetCountersRow({
    super.key,
    required this.assetType,
    required this.totalCountLocal,
    this.selectedCountFieldId,
    this.inventoryItems,
  });

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider
    final itemProvider = context.watch<InventoryItemProvider>();

    // 🔑 CORRECCIÓN CRÍTICA: Lógica de selección de items
    // Si la pantalla nos pasa una lista vacía pero el provider ya tiene los items cargados,
    // usamos los del provider para evitar que los contadores parpadeen en 0 al refrescar.
    final bool isLocalEmpty = inventoryItems == null || inventoryItems!.isEmpty;
    final itemsToCount = (isLocalEmpty && itemProvider.inventoryItems.isNotEmpty)
        ? itemProvider.inventoryItems
        : (inventoryItems ?? []);

    final bool isLoading = itemProvider.isLoading;

    // --- LÓGICA DE CONTEO ---
    int possessionCount = _countField(itemsToCount, assetType.possessionFieldId);
    int desiredCount = _countField(itemsToCount, assetType.desiredFieldId);

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        // 1. TOTAL ÍTEMS
        Chip(
          avatar: isLoading && itemProvider.totalItems == 0
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.inventory, size: 18),
          label: Text('TOTAL ÍTEMS: ${itemProvider.totalItems}'),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),

        // 2. EN POSESIÓN
        if (assetType.possessionFieldId != null)
          _buildCounterChip(
            context,
            'EN POSESIÓN: $possessionCount',
            Icons.check_circle_outline,
            Colors.green,
          ),

        // 3. DESEADOS
        if (assetType.desiredFieldId != null)
          _buildCounterChip(
            context,
            'DESEADOS: $desiredCount',
            Icons.favorite_outline,
            Colors.pink,
          ),

        // 4. SUMATORIOS DINÁMICOS
        // 🔑 CORRECCIÓN: Iteramos sobre las definiciones del provider
        ...itemProvider.aggregationDefinitions.where((def) {
          final isSum = def['isSummable'];
          return isSum == true || isSum.toString() == 'true' || isSum == 1;
        }).map((def) {
          final fieldId = def['id'].toString();
          final fieldName = def['name'] as String? ?? 'Suma';
          final sumKey = 'sum_$fieldId';

          final dynamic rawValue = itemProvider.aggregationResults[sumKey];

          String sumDisplay = itemProvider.isLoading ? "..." : "0.00";
          if (rawValue != null) {
            double? parsed = double.tryParse(rawValue.toString());
            if (parsed != null) sumDisplay = parsed.toStringAsFixed(2);
          }

          return Chip(
            avatar: const Icon(Icons.calculate, size: 18),
            label: Text('SUMA $fieldName: $sumDisplay'),
            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          );
        }),

        // 5. INDICADOR DE CARGA DE CÁLCULOS
        if (isLoading && itemProvider.aggregationDefinitions.isEmpty)
          Chip(
            avatar: const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: const Text('Cargando cálculos...'),
            backgroundColor: Colors.grey.withOpacity(0.1),
          ),
      ],
    );
  }

  // --- MÉTODOS AUXILIARES ---

  Widget _buildCounterChip(BuildContext context, String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color.withOpacity(0.8)),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }

  int _countField(List<InventoryItem> items, String? fieldId) {
    if (fieldId == null || fieldId.isEmpty) return 0;
    return items.where((item) {
      final val = item.customFieldValues?[fieldId];
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      return false;
    }).length;
  }
}