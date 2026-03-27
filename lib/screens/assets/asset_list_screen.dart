import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/core/utils/async_task_helper.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_search_bar.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_type_main_content.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_cylinder_gallery.dart';
import 'package:invenicum/screens/asset_types/local_widgets/assets_counters_row.dart';
import 'package:invenicum/screens/assets/local_widgets/possession_progress_bar.dart';
import 'package:invenicum/screens/assets/local_widgets/sync_result_row_widget.dart';
import 'package:provider/provider.dart';

import '../../data/models/container_node.dart';
import '../../data/models/asset_type_model.dart';
import '../../data/services/toast_service.dart';
import '../../providers/container_provider.dart';
import '../../providers/inventory_item_provider.dart';
import 'local_widgets/asset_list_header.dart';

// ---------------------------------------------------------------------------
// Data class para el Selector
// ---------------------------------------------------------------------------

class _PageStateData {
  final List<InventoryItem> items;
  final bool loading;
  final int fingerprint;

  const _PageStateData({
    required this.items,
    required this.loading,
    required this.fingerprint,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PageStateData) return false;
    return loading == other.loading && fingerprint == other.fingerprint;
  }

  @override
  int get hashCode => Object.hash(loading, fingerprint);
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
  bool _showRefreshDone = false;
  String? _selectedCountFieldId;
  String? _selectedCountValue;
  final TextEditingController _searchController = TextEditingController();

  int get _cIdInt => int.tryParse(widget.containerId) ?? 0;
  int get _atIdInt => int.tryParse(widget.assetTypeId) ?? 0;

  int _itemsFingerprint(List<InventoryItem> items) {
    return Object.hashAll(
      items.map(
        (i) => Object.hash(
          i.id,
          i.updatedAt,
          i.name,
          i.description,
          i.quantity,
          i.minStock,
          i.locationId,
          i.marketValue,
          i.customFieldValues.toString(),
          i.images.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<InventoryItemProvider>();
    final cIdInt = _cIdInt;
    final atIdInt = _atIdInt;

    if (provider.currentContainerId != cIdInt ||
        provider.currentAssetTypeId != atIdInt) {
      provider.updateContextIds(cIdInt, atIdInt);
      Future(() {
        provider.loadInventoryItems(containerId: cIdInt, assetTypeId: atIdInt);
      });
      return;
    }

    if (provider.allInventoryItems.isEmpty && !provider.isLoading) {
      Future(() {
        provider.loadInventoryItems(containerId: cIdInt, assetTypeId: atIdInt);
      });
    }
  }

  Future<void> _refreshTable(BuildContext context) async {
    final provider = context.read<InventoryItemProvider>();
    try {
      debugPrint(
        '[AssetListScreen] refresh start cId=$_cIdInt atId=$_atIdInt at=${DateTime.now().toIso8601String()}',
      );
      await provider.loadInventoryItems(
        containerId: _cIdInt,
        assetTypeId: _atIdInt,
        forceReload: true, // Esto obliga a ignorar el caché y pedir al server
      );
      final items = provider.allInventoryItems;
      debugPrint(
        '[AssetListScreen] refresh done cId=$_cIdInt atId=$_atIdInt items=${items.length} firstUpdatedAt=${items.isNotEmpty ? items.first.updatedAt : 'n/a'}',
      );
      _showRefreshDoneAnimation();
    } catch (_) {
      if (!context.mounted) return;
      ToastService.error("No se pudo recargar la lista");
    }
  }

  void _showRefreshDoneAnimation() {
    if (!mounted) return;
    setState(() => _showRefreshDone = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _showRefreshDone = false);
    });
  }

  Future<void> _syncMarketPrices(BuildContext context) async {
    final provider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId) ?? 0;
    final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sincronizar precios'),
        content: const Text(
          'Se consultará la API para actualizar el valor de mercado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final summary = await runAsyncTask(
        context,
        () => provider.syncAssetTypeMarketValues(
          assetTypeId: atIdInt,
          containerId: cIdInt,
        ),
        loadingMessage: "Sincronizando precios de mercado...",
        errorMessage: "No se pudieron sincronizar los precios",
      );

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sincronización completada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SyncResultRow(
                icon: Icons.trending_up,
                color: Colors.green,
                label: 'Actualizados',
                value: summary['updated'] ?? 0,
              ),
              SyncResultRow(
                icon: Icons.remove_circle_outline,
                color: Colors.orange,
                label: 'Sin precio en API',
                value: summary['skipped'] ?? 0,
              ),
              SyncResultRow(
                icon: Icons.error_outline,
                color: Colors.red,
                label: 'Errores',
                value: summary['errors'] ?? 0,
              ),
              const Divider(),
              SyncResultRow(
                icon: Icons.inventory_2_outlined,
                color: Colors.grey,
                label: 'Total procesados',
                value: summary['total'] ?? 0,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (_) {}
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
    final cIdInt = _cIdInt;
    final atIdInt = _atIdInt;

    return Selector<InventoryItemProvider, _PageStateData>(
      selector: (_, prov) => _PageStateData(
        items: prov.allInventoryItems,
        loading: prov.isLoading,
        fingerprint: _itemsFingerprint(prov.allInventoryItems),
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
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _goBack(context),
              tooltip: l10n.backToAssetTypes,
            ),
            actions: [
              if (!data.loading)
                IconButton(
                  tooltip: l10n.refresh,
                  onPressed: () => _refreshTable(context),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: _showRefreshDone
                        ? const Icon(
                            Icons.check_circle_rounded,
                            key: ValueKey('refresh_done'),
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.refresh,
                            key: ValueKey('refresh_idle'),
                          ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),

          body: Stack(
            children: [
              Positioned(
                top: -120,
                right: -90,
                child: IgnorePointer(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.12),
                          colorScheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                left: -110,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.secondary.withValues(alpha: 0.10),
                          colorScheme.secondary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.72,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.30,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          AssetListHeader(
                            assetType: assetType,
                            onSyncPrices: () => _syncMarketPrices(context),
                            onGoToCreateAsset: () async {
                              await context.pushNamed(
                                RouteNames.assetCreate,
                                pathParameters: {
                                  'containerId': widget.containerId,
                                  'assetTypeId': widget.assetTypeId,
                                },
                              );
                              if (!context.mounted) return;
                              await _refreshTable(context);
                            },
                            onImportCSV: () async {
                              await context.pushNamed(
                                RouteNames.assetImport,
                                pathParameters: {
                                  'containerId': widget.containerId,
                                  'assetTypeId': widget.assetTypeId,
                                },
                              );
                              if (!context.mounted) return;
                              await _refreshTable(context);
                            },
                            onShowCountFilterDialog: () =>
                                _showCountFilterDialog(context, assetType),
                            selectedCountFieldId: _selectedCountFieldId,
                          ),
                          const SizedBox(height: 10),
                          AssetSearchBar(
                            searchController: _searchController,
                            isListView: _isListView,
                            onToggleView: () =>
                                setState(() => _isListView = !_isListView),
                            onToggleGallery: () =>
                                _openGallery(context, statsItems),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer.withValues(
                          alpha: 0.75,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.22,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          AssetCountersRow(
                            key: ValueKey(
                              'counters_${widget.assetTypeId}_${statsItems.length}',
                            ),
                            assetType: assetType,
                            totalCountLocal: statsItems.length,
                            selectedCountFieldId: _selectedCountFieldId,
                            inventoryItems: statsItems,
                          ),
                          if (assetType.possessionFieldId != null) ...[
                            const SizedBox(height: 6),
                            PossessionProgressBar(
                              assetType: assetType,
                              inventoryItems: statsItems,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: data.loading
                            ? const Center(child: CircularProgressIndicator())
                            : AssetTypeMainContent(
                                key: ValueKey('content_${data.items.hashCode}'),
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
                    ),
                  ],
                ),
              ),
            ],
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
