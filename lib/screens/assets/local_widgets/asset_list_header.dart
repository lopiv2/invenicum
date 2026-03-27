// widgets/asset_list_header.dart

import 'package:flutter/material.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/asset_type_model.dart';

class AssetListHeader extends StatelessWidget {
  final AssetType assetType;
  final VoidCallback onGoToCreateAsset;
  final VoidCallback onShowCountFilterDialog;
  final VoidCallback onImportCSV;
  final VoidCallback onSyncPrices;
  final String? selectedCountFieldId;

  const AssetListHeader({
    super.key,
    required this.assetType,
    required this.onGoToCreateAsset,
    required this.onShowCountFilterDialog,
    required this.onImportCSV,
    required this.onSyncPrices,
    this.selectedCountFieldId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 760;
    final theme = Theme.of(context);
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          assetType.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 22 : 24,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Gestiona, busca y sincroniza tus activos desde un solo panel.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final actionsBlock = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _buildActionButton(
          context,
          onPressed: onShowCountFilterDialog,
          icon: Icons.pin_drop,
          label: selectedCountFieldId == null ? 'Filtro' : 'Filtro activo',
          color: selectedCountFieldId != null
              ? theme.colorScheme.inversePrimary
              : theme.colorScheme.surfaceVariant,
          isMobile: isMobile,
        ),
        _buildActionButton(
          context,
          onPressed: onImportCSV,
          icon: Icons.file_upload,
          label: 'Importar',
          color: theme.colorScheme.surfaceVariant,
          isMobile: isMobile,
        ),
        Selector<InventoryItemProvider, (bool, int)>(
          selector: (_, prov) {
            final count = prov.allInventoryItems
                .where(
                  (item) =>
                      item.barcode != null && item.barcode!.trim().isNotEmpty,
                )
                .length;
            return (prov.isSyncingPrices, count);
          },
          builder: (context, data, child) {
            final isSyncing = data.$1;
            final barcodeCount = data.$2;

            return Badge(
              label: Text('$barcodeCount'),
              isLabelVisible: barcodeCount > 0 && !isSyncing,
              backgroundColor: theme.colorScheme.error,
              child: _buildActionButton(
                context,
                onPressed: isSyncing ? () {} : onSyncPrices,
                icon: Icons.sync_alt_rounded,
                label: isSyncing ? 'Sync...' : 'Sincronizar',
                color: theme.colorScheme.surfaceVariant,
                isMobile: isMobile,
                isLoading: isSyncing,
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          onPressed: onGoToCreateAsset,
          icon: Icons.add,
          label: 'Nuevo activo',
          color: theme.colorScheme.primary,
          textColor: theme.colorScheme.onPrimary,
          isMobile: isMobile,
          isPrimary: true,
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titleBlock, const SizedBox(height: 12), actionsBlock],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        Flexible(child: actionsBlock),
      ],
    );
  }

  // Helper para crear botones consistentes y responsivos
  Widget _buildActionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
    required bool isMobile,
    bool isPrimary = false,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: textColor),
      label: Text(label, style: TextStyle(color: textColor, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: isPrimary ? 2 : 0,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 10 : 11,
        ),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
