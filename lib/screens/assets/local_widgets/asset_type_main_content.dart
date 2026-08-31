import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/screens/asset_types/asset_data_table_trina.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_grid_view.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_cylinder_gallery.dart';

class AssetTypeMainContent extends StatefulWidget {
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
  State<AssetTypeMainContent> createState() => _AssetTypeMainContentState();
}

class _AssetTypeMainContentState extends State<AssetTypeMainContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.isGalleryMode) {
      return AssetCylinderGallery(items: widget.viewItems);
    }

    return RepaintBoundary(
      child: widget._isListView
          ? AssetPlutoTable(
              key: ValueKey('pluto_${widget.atIdInt}'),
              assetType: widget.assetType!,
              containerId: widget.cIdInt,
              assetTypeId: widget.atIdInt,
              items: widget.viewItems,
              availableLocations: widget.locations ?? [],
              searchController: widget.searchController,
            )
          : AssetGridView(
              assetType: widget.assetType,
              items: widget.viewItems,
              containerId: widget.cIdInt,
              assetTypeId: widget.atIdInt,
              searchController: widget.searchController,
            ),
    );
  }
}
