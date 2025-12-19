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
    final itemProvider = context.watch<InventoryItemProvider>();

    // Obtener los items a contar (parámetro o del itemProvider)
    final itemsToCount = inventoryItems ?? itemProvider.inventoryItems;

    // Lógica para obtener el nombre del campo dinámico
    final String dynamicFieldName = selectedCountFieldId != null
        ? assetType.fieldDefinitions
            .firstWhere((def) => def.id.toString() == selectedCountFieldId)
            .name
        : '';

    // 🎯 Contar items con possessionFieldId en true/1
    int possessionCount = 0;
    if (assetType.possessionFieldId != null && assetType.possessionFieldId!.isNotEmpty) {
      possessionCount = itemsToCount.where((item) {
        final customValues = item.customFieldValues ?? {};
        final fieldValue = customValues[assetType.possessionFieldId!];
        // Contar si el valor es true o 1
        if (fieldValue is bool) {
          return fieldValue == true;
        }
        if (fieldValue is int) {
          return fieldValue == 1;
        }
        if (fieldValue is String) {
          return fieldValue.toLowerCase() == 'true' || fieldValue == '1';
        }
        return false;
      }).length;
    }

    // 🎯 Contar items con desiredFieldId en true/1
    int desiredCount = 0;
    if (assetType.desiredFieldId != null && assetType.desiredFieldId!.isNotEmpty) {
      desiredCount = itemsToCount.where((item) {
        final customValues = item.customFieldValues ?? {};
        final fieldValue = customValues[assetType.desiredFieldId!];
        // Contar si el valor es true o 1
        if (fieldValue is bool) {
          return fieldValue == true;
        }
        if (fieldValue is int) {
          return fieldValue == 1;
        }
        if (fieldValue is String) {
          return fieldValue.toLowerCase() == 'true' || fieldValue == '1';
        }
        return false;
      }).length;
    }

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        // Contador Total de Ítems (Total del backend antes de filtros locales)
        Chip(
          avatar: const Icon(Icons.inventory, size: 18),
          label: Text('TOTAL ÍTEMS: ${itemProvider.totalItems}'),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        ),

        // 🎯 Contador de Posesión (si está configurado)
        if (assetType.possessionFieldId != null && assetType.possessionFieldId!.isNotEmpty)
          Chip(
            avatar: const Icon(Icons.check_circle_outline, size: 18),
            label: Text('EN POSESIÓN: $possessionCount'),
            backgroundColor: Colors.green.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          ),

        // 🎯 Contador de Deseados (si está configurado)
        if (assetType.desiredFieldId != null && assetType.desiredFieldId!.isNotEmpty)
          Chip(
            avatar: const Icon(Icons.favorite_outline, size: 18),
            label: Text('DESEADOS: $desiredCount'),
            backgroundColor: Colors.pink.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          ),

        // 🎯 Contador Dinámico (solo si está activo - para filtros manuales)
        if (selectedCountFieldId != null)
          Chip(
            avatar: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(
              'CONTADOR ${dynamicFieldName} = "$totalCountLocal"',
            ),
            backgroundColor:
                Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          ),

        // Sumatorios Agregados (basados en las definiciones isSummable)
        ...itemProvider.aggregationDefinitions.map((def) {
          final fieldId = def['id'].toString();
          final fieldName = def['name'] as String? ?? 'Campo Desconocido';
          final bool isSummable = def['isSummable'] == true;

          if (!isSummable) return const SizedBox.shrink();

          final sumKey = 'sum_$fieldId';
          // Se usa el resultado del backend, pero si quieres la suma LOCAL,
          // necesitas pasar localAggregations como parámetro.
          // Por ahora, usamos el resultado del backend (itemProvider.aggregationResults).
          final sumValue =
              itemProvider.aggregationResults[sumKey]?.toString() ?? '0.0';

          return Chip(
            avatar: const Icon(Icons.calculate, size: 18),
            label: Text('SUMA ${fieldName}: ${sumValue}'),
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          );
        }).toList(),
      ],
    );
  }
}