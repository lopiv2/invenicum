import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_data_table.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_grid_view.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_cylinder_gallery.dart';

class AssetTypeMainContent extends StatelessWidget {
  const AssetTypeMainContent({
    super.key,
    required bool isListView,
    required this.isCurrentRoute,
    required this.assetType,
    required this.cIdInt,
    required this.atIdInt,
    required this.viewItems,
    required this.locations,
    required this.isGalleryMode,
  }) : _isListView = isListView;

  final bool _isListView;
  final bool isCurrentRoute;
  final dynamic assetType;
  final int cIdInt;
  final int atIdInt;
  final List<InventoryItem> viewItems;
  final dynamic locations;
  final bool isGalleryMode;

  @override
  Widget build(BuildContext context) {
    if (!isCurrentRoute) {
      return const SizedBox.shrink(); // Placeholder más ligero
    }
    if (isGalleryMode) {
      return AssetCylinderGallery(items: viewItems);
    }

    return RepaintBoundary(
      child: _isListView
          ? AssetDataTable(
              key: ValueKey('table_${atIdInt}'),
              assetType: assetType,
              containerId: cIdInt,
              assetTypeId: atIdInt,
              inventoryItems: viewItems,
              availableLocations: locations,
            )
          : AssetGridView(
              assetType: assetType,
              items: viewItems,
              containerId: cIdInt,
              assetTypeId: atIdInt,
            ),
    );
  }
}
