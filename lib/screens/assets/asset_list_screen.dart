import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class _PageStateData {
  final List<InventoryItem> items;
  final bool loading;
  final int totalItems;

  const _PageStateData({
    required this.items,
    required this.loading,
    required this.totalItems,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PageStateData) return false;

    if (loading != other.loading || totalItems != other.totalItems) {
      return false;
    }

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
  int get hashCode => Object.hash(loading, totalItems, items.length);
}

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

  final TextEditingController _searchController = TextEditingController();
  bool _isListView = true;
  bool _isGalleryMode = false;
  late InventoryItemProvider _itemProvider;
  String? _selectedCountFieldId;
  String? _selectedCountValue;
  int? _selectedLocationId;

  // 🚀 CACHÉ DE ITEMS FILTRADOS
  List<InventoryItem> _cachedFilteredItems = [];
  String? _lastSearchTerm;
  String? _lastCountFieldId;
  String? _lastCountValue;
  int? _lastLocationId;
  int? _lastItemsHash;
  String? _lastFiltersHash;
  String? _lastGlobalSearchHash;
  int? _lastSortKeyHash;

  @override
  void initState() {
    super.initState();
    // Usamos read porque no queremos "escuchar" aquí, solo ejecutar una acción única
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemProvider = Provider.of<InventoryItemProvider>(
        context,
        listen: false,
      );
      final cIdInt = int.tryParse(widget.containerId) ?? 0;
      final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

      if (_itemProvider.currentContainerId != cIdInt ||
          _itemProvider.currentAssetTypeId != atIdInt) {
        _itemProvider.updateContextIds(cIdInt, atIdInt);
      }

      // 🚀 LISTENER OPTIMIZADO: Se registra solo una vez en initState
      _searchController.addListener(_onSearchChanged);
    });
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    //_itemProvider.clearViewItems();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    _itemProvider.setGlobalSearchTerm(_searchController.text);
    _itemProvider.goToPage(1);
  }

  void _goBack(BuildContext context) {
    context.go('/container/${widget.containerId}/asset-types');
  }

  // 🚀 MÉTODO OPTIMIZADO CON CACHÉ
  List<InventoryItem> _getFilteredItems(
    List<InventoryItem> allItems,
    InventoryItemProvider itemProvider,
  ) {
    // 🔑 Calcular hash de los items incluyendo CONTENIDO (no solo IDs)
    // Esto detecta cambios cuando editas campos y también cuando hay valores vacíos
    int itemsHash = itemProvider.totalItems ^ allItems.length;

    for (final item in allItems) {
      itemsHash = ((itemsHash * 31) ^ item.id.hashCode);
      itemsHash = ((itemsHash * 31) ^ (item.updatedAt?.hashCode ?? 0));
    }

    final searchTerm = _searchController.text.toLowerCase().trim();

    // También incluir el sortKey del provider para detectar cambios de ordenamiento
    final sortKeyHash =
        '${itemProvider.sortKey}_${itemProvider.sortAscending}'.hashCode;

    // Crear hash de los filtros del provider
    final filtersHash = itemProvider.filters.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    final globalSearchHash = itemProvider.globalSearchTerm ?? '';

    // 🔑 CACHÉ: Solo recalcular si algo cambió
    if (_lastItemsHash == itemsHash &&
        _lastSearchTerm == searchTerm &&
        _lastCountFieldId == _selectedCountFieldId &&
        _lastCountValue == _selectedCountValue &&
        _lastLocationId == _selectedLocationId &&
        _lastFiltersHash == filtersHash &&
        _lastGlobalSearchHash == globalSearchHash &&
        _lastSortKeyHash == sortKeyHash) {
      return _cachedFilteredItems;
    }

    // 1. Identificadores de la pantalla actual
    final currentAtId = int.tryParse(widget.assetTypeId);
    final currentCId = int.tryParse(widget.containerId);

    _cachedFilteredItems = allItems.where((item) {
      final asset = item;

      // --- ESCUDO DE SEGURIDAD ---
      if (asset.assetTypeId != currentAtId || asset.containerId != currentCId) {
        return false;
      }

      // --- FILTROS DEL PROVIDER (COLUMNAS) ---
      if (itemProvider.filters.isNotEmpty) {
        bool passesAllFilters = itemProvider.filters.entries.every((e) {
          final filterValue = e.value.toLowerCase();

          // Manejo de Cantidad (Stock)
          if (e.key == 'quantity') {
            return _compareNumeric(asset.quantity, filterValue);
          }
          // Manejo de Stock Mínimo
          if (e.key == 'minStock') {
            return _compareNumeric(asset.minStock, filterValue);
          }
          if (e.key == 'name') {
            return asset.name.toLowerCase().contains(filterValue);
          }
          if (e.key == 'description') {
            return (asset.description ?? '').toLowerCase().contains(
              filterValue,
            );
          }
          if (e.key == 'location') {
            return (asset.location?.name ?? '').toLowerCase().contains(
              filterValue,
            );
          }
          if (e.key == 'barcode') {
            return (asset.barcode ?? '').toLowerCase().contains(filterValue);
          }
          if (e.key == 'marketValue') {
            return _compareNumeric(asset.marketValue, filterValue);
          }
          // Campos personalizados
          return (asset.customFieldValues?[e.key]?.toString() ?? '')
              .toLowerCase()
              .contains(filterValue);
        });
        if (!passesAllFilters) return false;
      }

      // --- BÚSQUEDA GLOBAL DEL PROVIDER ---
      if (itemProvider.globalSearchTerm != null) {
        final term = itemProvider.globalSearchTerm!.toLowerCase();
        bool matches =
            asset.name.toLowerCase().contains(term) ||
            (asset.description ?? '').toLowerCase().contains(term) ||
            (asset.location?.name ?? '').toLowerCase().contains(term);
        if (!matches) {
          matches =
              asset.customFieldValues?.values.any(
                (v) => v.toString().toLowerCase().contains(term),
              ) ??
              false;
        }
        if (!matches) return false;
      }

      // --- TU LÓGICA LOCAL DE FILTROS ---

      // Filtro de Ubicación
      if (_selectedLocationId != null &&
          asset.locationId != _selectedLocationId) {
        return false;
      }

      // Filtro de Contadores
      if (_selectedCountFieldId != null && _selectedCountValue != null) {
        final val = asset.customFieldValues?[_selectedCountFieldId];
        if (val?.toString().toLowerCase().trim() !=
            _selectedCountValue!.toLowerCase().trim()) {
          return false;
        }
      }

      // Filtro de Búsqueda Local (barra de búsqueda de Asset List)
      if (searchTerm.isNotEmpty) {
        final matchesName = asset.name.toLowerCase().contains(searchTerm);
        final matchesDesc =
            asset.description?.toLowerCase().contains(searchTerm) ?? false;
        if (!matchesName && !matchesDesc) return false;
      }

      return true;
    }).toList();

    // 🔑 Actualizar caché
    _lastItemsHash = itemsHash;
    _lastSearchTerm = searchTerm;
    _lastCountFieldId = _selectedCountFieldId;
    _lastCountValue = _selectedCountValue;
    _lastLocationId = _selectedLocationId;
    _lastFiltersHash = filtersHash;
    _lastGlobalSearchHash = globalSearchHash;
    _lastSortKeyHash = sortKeyHash;

    return _cachedFilteredItems;
  }

  // 🔑 Función auxiliar para comparar valores numéricos
  bool _compareNumeric(num value, String filterStr) {
    final str = filterStr.trim();
    if (str.isEmpty) return false;

    try {
      // 1. Soportar rangos: "10-20"
      // Verificamos que contenga '-' pero que no sea un número negativo (ej. "-5")
      if (str.contains('-') && !str.startsWith('-')) {
        final parts = str.split('-');
        if (parts.length == 2) {
          final n1 = num.tryParse(parts[0].trim());
          final n2 = num.tryParse(parts[1].trim());
          if (n1 != null && n2 != null) {
            return value >= n1 && value <= n2;
          }
        }
      }
      if (str.startsWith('=')) {
        final n = num.tryParse(str.substring(1).trim());
        return n != null && value == n;
      }

      // 2. Soportar comparadores: ">=", "<=", ">", "<"
      if (str.startsWith('>=')) {
        final n = num.tryParse(str.substring(2).trim());
        return n != null && value >= n;
      }
      if (str.startsWith('<=')) {
        final n = num.tryParse(str.substring(2).trim());
        return n != null && value <= n;
      }
      if (str.startsWith('>')) {
        final n = num.tryParse(str.substring(1).trim());
        return n != null && value > n;
      }
      if (str.startsWith('<')) {
        final n = num.tryParse(str.substring(1).trim());
        return n != null && value < n;
      }

      // 3. Valor exacto
      final n = num.tryParse(str);
      return n != null && value == n;
    } catch (e) {
      return false;
    }
  }

  void _showCountFilterDialog(BuildContext context, AssetType assetType) {
    final l10n = AppLocalizations.of(context)!;
    String? tempFieldId = _selectedCountFieldId;
    TextEditingController tempValueController = TextEditingController(
      text: _selectedCountValue,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Mantiene el estado vivo

    final l10n = AppLocalizations.of(context)!;
    final cIdInt = int.tryParse(widget.containerId) ?? 0;
    final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

    // 🚀 Selector OPTIMIZADO: Solo escucha items y loading
    return Selector<InventoryItemProvider, _PageStateData>(
      selector: (_, prov) => _PageStateData(
        items: prov.inventoryItems,
        loading: prov.isLoading,
        totalItems: prov.totalItems,
      ),
      builder: (context, data, child) {
        // Obtenemos los providers con 'read' para evitar que el movimiento del sidebar los dispare
        final containerProvider = context.read<ContainerProvider>();

        final container = containerProvider.containers
            .cast<ContainerNode?>()
            .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

        final assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
          (at) => at?.id == atIdInt,
          orElse: () => null,
        );

        // Pantallas de error/carga inicial
        if (data.loading && data.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (container == null || assetType == null) {
          return Scaffold(body: Center(child: Text(l10n.invalidNavigationIds)));
        }

        // 🚀 Usar CACHÉ: Items filtrados solo se recalculan si cambió algo
        final viewItems = _getFilteredItems(
          data.items,
          context.read<InventoryItemProvider>(),
        ).cast<InventoryItem>();
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _goBack(context),
              tooltip: l10n.backToAssetTypes,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- ELEMENTOS RESTAURADOS ---
                AssetListHeader(
                  assetType: assetType,
                  onGoToCreateAsset: () => context.go(
                    '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/new',
                  ),
                  onImportCSV: () => context.go(
                    '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/import-csv',
                  ),
                  onShowCountFilterDialog: () =>
                      _showCountFilterDialog(context, assetType),
                  selectedCountFieldId: _selectedCountFieldId,
                ),
                const SizedBox(height: 20),

                AssetCountersRow(
                  // 🚩 ValueKey para forzar recalc cuando los items filtrados cambien
                  key: ValueKey(
                    'counters_${widget.assetTypeId}_${viewItems.length}',
                  ),
                  assetType: assetType,
                  totalCountLocal: viewItems.length,
                  selectedCountFieldId: _selectedCountFieldId,
                  inventoryItems: viewItems,
                ),
                const SizedBox(height: 10),

                // Barra de posesión (Solo si el campo existe)
                if (assetType.possessionFieldId != null)
                  PossessionProgressBar(
                    assetType: assetType,
                    inventoryItems: viewItems,
                  ),

                const SizedBox(height: 20),

                AssetSearchBar(
                  searchController: _searchController,
                  isListView: _isListView,
                  onToggleView: () =>
                      setState(() => _isListView = !_isListView),
                  onToggleGallery: () => _openGallery(context, viewItems),
                ),

                const SizedBox(height: 10),

                // --- ÁREA DE LA TABLA CON PROTECCIÓN DE RE-PINTADO ---
                Expanded(
                  child: data.loading
                      ? const Center(child: CircularProgressIndicator())
                      : AssetTypeMainContent(
                          isListView: _isListView,
                          isCurrentRoute: isCurrentRoute,
                          assetType: assetType,
                          cIdInt: cIdInt,
                          atIdInt: atIdInt,
                          viewItems: viewItems,
                          locations: container.locations,
                          isGalleryMode: _isGalleryMode,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openGallery(BuildContext context, List<InventoryItem> items) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black.withOpacity(0.9),
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
