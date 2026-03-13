import 'package:flutter/material.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'barcode_field_widget.dart';
import 'card_section_widget.dart';
import 'quantity_min_stock_fields.dart';
import 'section_header_widget.dart';
import 'serialized_asset_warning.dart';

/// Widget para la sección de inventario
class InventorySectionWidget extends StatelessWidget {
  final TextEditingController barcodeController;
  final TextEditingController quantityController;
  final TextEditingController minStockController;
  final AssetType? assetType;
  final Set<String> highlightedFields;
  final VoidCallback? onScanPressed;

  const InventorySectionWidget({
    super.key,
    required this.barcodeController,
    required this.quantityController,
    required this.minStockController,
    required this.assetType,
    this.highlightedFields = const {},
    this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CardSectionWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: 'Inventario',
            icon: Icons.warehouse_outlined,
          ),
          BarcodeFieldWidget(
            controller: barcodeController,
            highlighted: highlightedFields.contains('barcode'),
            onScanPressed: onScanPressed,
          ),
          const SizedBox(height: 16),
          if (assetType != null && !assetType!.isSerialized) ...[
            QuantityMinStockFieldsWidget(
              quantityController: quantityController,
              minStockController: minStockController,
            ),
          ] else if (assetType != null && assetType!.isSerialized) ...[
            const SerializedAssetWarningWidget(),
          ],
        ],
      ),
    );
  }
}
