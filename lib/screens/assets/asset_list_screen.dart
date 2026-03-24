import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_search_bar.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_type_main_content.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_cylinder_gallery.dart';
import 'package:invenicum/screens/asset_types/local_widgets/assets_counters_row.dart';
import 'package:invenicum/screens/assets/local_widgets/possession_progress_bar.dart';
import 'package:provider/provider.dart';

import '../../data/models/container_node.dart';
import '../../data/models/asset_type_model.dart';
import '../../providers/container_provider.dart';
import '../../providers/inventory_item_provider.dart';
import '../asset_types/local_widgets/asset_list_header.dart';

// ---------------------------------------------------------------------------
// Data class para el Selector
// ---------------------------------------------------------------------------

class _PageStateData {
  final List<InventoryItem> items;
  final bool loading;

  const _PageStateData({required this.items, required this.loading});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PageStateData) return false;
    if (loading != other.loading) return false;
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i].id != other.items[i].id ||
          items[i].updatedAt != other.items[i].updatedAt) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(loading, items.length);
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class AssetListScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;

  const AssetListScreen({
    super.key,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isListView = true;
  String? _selectedCountFieldId;
  String? _selectedCountValue;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId) ?? 0;
    final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

    if (provider.currentContainerId != cIdInt ||
        provider.currentAssetTypeId != atIdInt) {
      provider.updateContextIds(cIdInt, atIdInt);
      Future(() {
        provider.loadInventoryItems(containerId: cIdInt, assetTypeId: atIdInt);
      });
    }
  }

  void _refreshTable(BuildContext context) {
    final provider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId) ?? 0;
    final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

    provider.loadInventoryItems(
      containerId: cIdInt,
      assetTypeId: atIdInt,
      forceReload: true, // Esto obliga a ignorar el caché y pedir al server
    );
  }

  void _goBack(BuildContext context) {
    context.goNamed(
      RouteNames.assetTypes,
      pathParameters: {'containerId': widget.containerId},
    );
  }

  void _showCountFilterDialog(BuildContext context, AssetType assetType) {
    final l10n = AppLocalizations.of(context)!;
    String? tempFieldId = _selectedCountFieldId;
    final tempValueController = TextEditingController(
      text: _selectedCountValue,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.countItemsByValue),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: l10n.fieldToCount),
              value: tempFieldId,
              items: assetType.fieldDefinitions
                  .map(
                    (def) => DropdownMenuItem(
                      value: def.id.toString(),
                      child: Text(def.name),
                    ),
                  )
                  .toList(),
              onChanged: (val) => tempFieldId = val,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: tempValueController,
              decoration: InputDecoration(
                labelText: l10n.specificValueToCount,
                hintText: l10n.exampleFilterHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCountFieldId = null;
                _selectedCountValue = null;
              });
              context.pop();
            },
            child: Text(l10n.clearCounter),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCountFieldId = tempFieldId;
                _selectedCountValue = tempValueController.text.trim();
              });
              context.pop();
            },
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = AppLocalizations.of(context)!;
    final cIdInt = int.tryParse(widget.containerId) ?? 0;
    final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

    return Selector<InventoryItemProvider, _PageStateData>(
      selector: (_, prov) => _PageStateData(
        items: prov.allInventoryItems,
        loading: prov.isLoading,
      ),
      builder: (context, data, child) {
        final containerProvider = context.read<ContainerProvider>();

        final container = containerProvider.containers
            .cast<ContainerNode?>()
            .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

        final assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
          (at) => at?.id == atIdInt,
          orElse: () => null,
        );

        if (data.loading && data.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (container == null || assetType == null) {
          return Scaffold(body: Center(child: Text(l10n.invalidNavigationIds)));
        }

        // Items filtrados localmente para los widgets de estadísticas
        // (contadores, barra de posesión, galería). No afectan a PlutoGrid.
        final statsItems = _filterForStats(data.items);
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _goBack(context),
              tooltip: l10n.backToAssetTypes,
            ),
            actions: [
              if (!data.loading) // Opcional: ocultar si ya está cargando
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip:
                      l10n.refresh, // Puedes usar l10n.refresh si lo tienes
                  onPressed: () => _refreshTable(context),
                ),
              const SizedBox(width: 8),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                AssetListHeader(
                  assetType: assetType,
                  onGoToCreateAsset: () => context.goNamed(
                    RouteNames.assetCreate,
                    pathParameters: {
                      'containerId': widget.containerId,
                      'assetTypeId': widget.assetTypeId,
                    },
                  ),
                  onImportCSV: () => context.goNamed(
                    RouteNames.assetImport,
                    pathParameters: {
                      'containerId': widget.containerId,
                      'assetTypeId': widget.assetTypeId,
                    },
                  ),
                  onShowCountFilterDialog: () =>
                      _showCountFilterDialog(context, assetType),
                  selectedCountFieldId: _selectedCountFieldId,
                ),
                const SizedBox(height: 20),

                AssetCountersRow(
                  key: ValueKey(
                    'counters_${widget.assetTypeId}_${statsItems.length}',
                  ),
                  assetType: assetType,
                  totalCountLocal: statsItems.length,
                  selectedCountFieldId: _selectedCountFieldId,
                  inventoryItems: statsItems,
                ),
                const SizedBox(height: 10),

                if (assetType.possessionFieldId != null)
                  PossessionProgressBar(
                    assetType: assetType,
                    inventoryItems: statsItems,
                  ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AssetSearchBar(
                    searchController: _searchController,
                    isListView: _isListView,
                    onToggleView: () =>
                        setState(() => _isListView = !_isListView),
                    onToggleGallery: () => _openGallery(context, statsItems),
                  ),
                ),

                Expanded(
                  child: data.loading
                      ? const Center(child: CircularProgressIndicator())
                      : AssetTypeMainContent(
                          isListView: _isListView,
                          isCurrentRoute: isCurrentRoute,
                          assetType: assetType,
                          cIdInt: cIdInt,
                          atIdInt: atIdInt,
                          viewItems: data.items,
                          locations: container.locations,
                          isGalleryMode: false,
                          searchController: _searchController,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Filtra la lista solo para los widgets de estadísticas (contadores,
  /// barra de posesión). No tiene nada que ver con el filtrado de PlutoGrid.
  List<InventoryItem> _filterForStats(List<InventoryItem> items) {
    if (_selectedCountFieldId == null || _selectedCountValue == null) {
      return items;
    }
    return items.where((item) {
      final val = item.customFieldValues?[_selectedCountFieldId];
      return val?.toString().toLowerCase().trim() ==
          _selectedCountValue!.toLowerCase().trim();
    }).toList();
  }

  void _openGallery(BuildContext context, List<InventoryItem> items) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        child: Stack(
          children: [
            AssetCylinderGallery(items: items),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
