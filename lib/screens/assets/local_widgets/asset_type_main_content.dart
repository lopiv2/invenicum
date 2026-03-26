import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/screens/asset_types/asset_data_table_pluto.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_grid_view.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_cylinder_gallery.dart';

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
    this.searchController,
  }) : _isListView = isListView;

  final bool _isListView;
  final bool isCurrentRoute;
  final dynamic assetType;
  final int cIdInt;
  final int atIdInt;
  final List<InventoryItem> viewItems;
  final dynamic locations;
  final bool isGalleryMode;
  final TextEditingController? searchController;

  @override
  Widget build(BuildContext context) {
    if (!isCurrentRoute) {
      return const SizedBox.shrink();
    }
    if (isGalleryMode) {
      return AssetCylinderGallery(items: viewItems);
    }
    return RepaintBoundary(
      child: _isListView
          ? AssetPlutoTable(
              key: ValueKey('pluto_$atIdInt'),
              assetType: assetType!,
              containerId: cIdInt,
              assetTypeId: atIdInt,
              items: viewItems,
              availableLocations: locations ?? [],
              searchController: searchController,
            )
          : AssetGridView(
              assetType: assetType,
              items: viewItems,
              containerId: cIdInt,
              assetTypeId: atIdInt,
              searchController: searchController,
            ),
    );
  }
}