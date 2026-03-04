// widgets/asset_counters_row.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/asset_type_model.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/models/custom_field_definition.dart';
import '../../../providers/inventory_item_provider.dart';
import '../../../widgets/ui/price_display_widget.dart';

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
    
    // Lógica para evitar el parpadeo de datos al cargar
    final bool isLocalEmpty = inventoryItems == null || inventoryItems!.isEmpty;
    final itemsToCount = (isLocalEmpty && itemProvider.inventoryItems.isNotEmpty)
        ? itemProvider.inventoryItems
        : (inventoryItems ?? []);

    final bool isLoading = itemProvider.isLoading;

    // Conteos rápidos
    int possessionCount = _countField(itemsToCount, assetType.possessionFieldId);
    int desiredCount = _countField(itemsToCount, assetType.desiredFieldId);

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 1. TOTAL ÍTEMS
        _buildCustomHeightChip(
          context,
          label: 'TOTAL ÍTEMS: ${itemProvider.totalItems}',
          icon: Icons.inventory,
          color: Theme.of(context).colorScheme.primary,
          isLoading: isLoading && itemProvider.totalItems == 0,
        ),

        // 2. EN POSESIÓN
        if (assetType.possessionFieldId != null)
          _buildCustomHeightChip(
            context,
            label: 'EN POSESIÓN: $possessionCount',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),

        // 3. DESEADOS
        if (assetType.desiredFieldId != null)
          _buildCustomHeightChip(
            context,
            label: 'DESEADOS: $desiredCount',
            icon: Icons.favorite_outline,
            color: Colors.pink,
          ),

        // 4. SUMATORIOS DINÁMICOS
        ...itemProvider.aggregationDefinitions.where((def) {
          final isSum = def['isSummable'];
          return isSum == true || isSum.toString() == 'true' || isSum == 1;
        }).map((def) {
          final fieldId = def['id'].toString();
          final fieldName = def['name'] as String? ?? 'Suma';
          final fieldType = def['type'];
          final sumKey = 'sum_$fieldId';
          final dynamic rawValue = itemProvider.aggregationResults[sumKey];

          return _buildAggregationChip(context, fieldName, fieldType, rawValue, isLoading);
        }),

        // 5. INDICADOR DE CARGA
        if (isLoading)
          _buildCustomHeightChip(
            context,
            label: 'Cargando cálculos...',
            icon: Icons.refresh,
            color: Colors.grey,
            isLoading: true,
          ),
      ],
    );
  }

  /// Constructor de Chips con altura aumentada para los sumatorios dinámicos
  Widget _buildAggregationChip(BuildContext context, String name, dynamic type, dynamic value, bool loading) {
    final bool isPrice = type == 'price' || type == CustomFieldType.price.name;

    return Chip(
      elevation: 2,
      shadowColor: Colors.black26,
      avatar: Icon(
        isPrice ? Icons.monetization_on : Icons.calculate,
        size: 20,
        color: Theme.of(context).colorScheme.secondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 🔑 Más alto
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      label: Container(
        constraints: const BoxConstraints(minHeight: 25),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$name: ', style: const TextStyle(fontWeight: FontWeight.w500)),
            if (loading)
              const Text("...")
            else if (isPrice)
              PriceDisplayWidget(value: value, fontSize: 14, color: Colors.black,) // 🔑 Reutilización
            else
              Text(
                (double.tryParse(value?.toString() ?? '0') ?? 0.0).toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  /// Constructor base para Chips con altura aumentada (Total, Posesión, etc.)
  Widget _buildCustomHeightChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return Chip(
      elevation: 2,
      shadowColor: Colors.black26,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 🔑 Más alto
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      backgroundColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      avatar: isLoading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 20, color: color.withOpacity(0.8)),
      label: Container(
        constraints: const BoxConstraints(minHeight: 25),
        child: Text(
          label,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
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