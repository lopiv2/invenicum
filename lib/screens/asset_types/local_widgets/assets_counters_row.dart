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
    final items = inventoryItems ?? [];
    final bool isLoading = itemProvider.isLoading;

    final double totalMarketValue = _calculateTotalMarketValue(items);

    final int possessionCount = _countField(items, assetType.possessionFieldId);
    final int desiredCount = _countField(items, assetType.desiredFieldId);

    final chips = <Widget>[
      _buildMarketValueChip(
        context,
        totalMarketValue,
        isLoading && items.isEmpty,
      ),
      _buildCustomHeightChip(
        context,
        label: 'TOTAL: ${items.length}',
        icon: Icons.inventory,
        color: Theme.of(context).colorScheme.primary,
        isLoading: isLoading && items.isEmpty,
      ),
      if (assetType.possessionFieldId != null)
        _buildCustomHeightChip(
          context,
          label: 'POSESIÓN: $possessionCount',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
      if (assetType.desiredFieldId != null)
        _buildCustomHeightChip(
          context,
          label: 'DESEADOS: $desiredCount',
          icon: Icons.favorite_outline,
          color: Colors.pink,
        ),
      ...itemProvider.aggregationDefinitions
          .where((def) {
            final isSum = def['isSummable'];
            return isSum == true || isSum.toString() == 'true' || isSum == 1;
          })
          .map((def) {
            final fieldId = def['id'].toString();
            final fieldName = def['name'] as String? ?? 'Suma';
            final fieldType = def['type'];
            final sumKey = 'sum_$fieldId';
            final dynamic rawValue = itemProvider.aggregationResults[sumKey];

            return _buildAggregationChip(
              context,
              fieldName,
              fieldType,
              rawValue,
              isLoading,
            );
          }),
      if (isLoading)
        _buildCustomHeightChip(
          context,
          label: 'Calculando...',
          icon: Icons.refresh,
          color: Colors.grey,
          isLoading: true,
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }

  // Widget específico para el valor de mercado con el PriceDisplayWidget
  Widget _buildMarketValueChip(
    BuildContext context,
    double totalValue,
    bool isSyncing,
  ) {
    return Chip(
      elevation: 0,
      shadowColor: Colors.transparent,
      avatar: Icon(Icons.analytics, size: 16, color: Colors.blueGrey),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      label: Container(
        constraints: const BoxConstraints(minHeight: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'MERCADO: ',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            if (isSyncing)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey,
                ),
              )
            else
              PriceDisplayWidget(
                value: totalValue,
                fontSize: 12,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregationChip(
    BuildContext context,
    String name,
    dynamic type,
    dynamic value,
    bool loading,
  ) {
    final bool isPrice = type == 'price' || type == CustomFieldType.price.name;

    return Chip(
      elevation: 0,
      shadowColor: Colors.transparent,
      avatar: Icon(
        isPrice ? Icons.monetization_on : Icons.calculate,
        size: 16,
        color: Theme.of(context).colorScheme.secondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.secondary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      label: Container(
        constraints: const BoxConstraints(minHeight: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$name: ',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            if (loading)
              const Text('...')
            else if (isPrice)
              PriceDisplayWidget(
                value: value,
                fontSize: 12,
                color: Colors.black,
              )
            else
              Text(
                (double.tryParse(value?.toString() ?? '0') ?? 0.0)
                    .toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeightChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return Chip(
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      backgroundColor: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      avatar: isLoading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 16, color: color.withValues(alpha: 0.8)),
      label: Container(
        constraints: const BoxConstraints(minHeight: 18),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Función para sumar los precios de mercado
  double _calculateTotalMarketValue(List<InventoryItem> items) {
    return items.fold(0.0, (sum, item) {
      // Usamos el campo marketPrice del modelo InventoryItem
      return sum + (item.totalMarketValue);
    });
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
