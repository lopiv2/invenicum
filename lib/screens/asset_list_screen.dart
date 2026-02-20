import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/screens/asset_search_bar.dart';
import 'package:invenicum/widgets/assets_counters_row.dart';
import 'package:invenicum/widgets/possession_progress_bar.dart';
import 'package:provider/provider.dart';

import '../models/container_node.dart';
import '../models/asset_type_model.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';

import '../widgets/asset_data_table.dart';
import '../widgets/asset_grid_view.dart';
import '../widgets/asset_list_header.dart';

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

class _AssetListScreenState extends State<AssetListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isListView = true;
  late InventoryItemProvider _itemProvider;
  String? _selectedCountFieldId;
  String? _selectedCountValue;
  int? _selectedLocationId;

  @override
  @override
  void initState() {
    super.initState();
    // Usamos read porque no queremos "escuchar" aquí, solo ejecutar una acción única
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = Provider.of<InventoryItemProvider>(
        context,
        listen: false,
      );
      final cIdInt = int.tryParse(widget.containerId) ?? 0;
      final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

      if (itemProvider.currentContainerId != cIdInt ||
          itemProvider.currentAssetTypeId != atIdInt) {
        itemProvider.updateContextIds(cIdInt, atIdInt);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final cIdInt = int.tryParse(widget.containerId) ?? 0;
    final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

    final itemProvider = Provider.of<InventoryItemProvider>(
      context,
      listen: false,
    );

    if (itemProvider.currentContainerId != cIdInt ||
        itemProvider.currentAssetTypeId != atIdInt) {
      // 🔑 LA SOLUCIÓN: Pospone la ejecución al siguiente micro-ciclo
      Future.microtask(() {
        itemProvider.updateContextIds(cIdInt, atIdInt);
        itemProvider.loadInventoryItems(
          containerId: cIdInt,
          assetTypeId: atIdInt,
        );
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

  List<dynamic> _getFilteredItems(List<dynamic> allItems) {
    // 1. Identificadores de la pantalla actual
    final currentAtId = int.tryParse(widget.assetTypeId);
    final currentCId = int.tryParse(widget.containerId);

    return allItems.where((item) {
      final asset = item as InventoryItem;

      // --- ESCUDO DE SEGURIDAD (Esto es lo nuevo) ---
      // Si el ítem es de otra categoría o contenedor, lo descartamos de inmediato.
      // Esto es lo que evita los "elementos de más".
      if (asset.assetTypeId != currentAtId || asset.containerId != currentCId) {
        return false;
      }

      // --- TU LÓGICA DE FILTROS (Se mantiene exactamente igual) ---

      // Filtro de Ubicación
      if (_selectedLocationId != null &&
          asset.locationId != _selectedLocationId) {
        return false;
      }

      // Filtro de Contadores (Diálogos)
      if (_selectedCountFieldId != null && _selectedCountValue != null) {
        final val = asset.customFieldValues?[_selectedCountFieldId];
        if (val?.toString().toLowerCase().trim() !=
            _selectedCountValue!.toLowerCase().trim()) {
          return false;
        }
      }

      // Filtro de Búsqueda Local (Barra de búsqueda)
      final query = _searchController.text.toLowerCase().trim();
      if (query.isNotEmpty) {
        final matchesName = asset.name.toLowerCase().contains(query);
        final matchesDesc =
            asset.description?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesDesc) return false;
      }

      return true; // Si pasa todas las pruebas, se muestra
    }).toList();
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
    final l10n = AppLocalizations.of(context)!;
    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();

    // 2. Detectar si esta es la pantalla activa
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    final cIdInt = int.tryParse(widget.containerId) ?? 0;
    final atIdInt = int.tryParse(widget.assetTypeId) ?? 0;

    if (itemProvider.isLoading && itemProvider.aggregationDefinitions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goBack(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (cIdInt == 0 || atIdInt == 0) {
      return Center(child: Text(l10n.invalidNavigationIds));
    }

    final container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);
    final assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
      (at) => at?.id == atIdInt,
      orElse: () => null,
    );

    if (container == null || assetType == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final viewItems = _getFilteredItems(
      itemProvider.inventoryItems,
    ).cast<InventoryItem>();

    return Scaffold(
      appBar: AppBar(
        //title: Text('${l10n.assetsIn} "${assetType.name}"'),
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
              key: ValueKey('counters_${widget.assetTypeId}'),
              assetType: assetType,
              totalCountLocal: viewItems.length,
              selectedCountFieldId: _selectedCountFieldId,
              inventoryItems: viewItems,
            ),
            const SizedBox(height: 10),
            if (assetType.possessionFieldId != null)
              PossessionProgressBar(
                assetType: assetType,
                inventoryItems: viewItems,
              ),
            const SizedBox(height: 20),
            AssetSearchBar(
              searchController: _searchController,
              isListView: _isListView,
              onToggleView: () => setState(() => _isListView = !_isListView),
            ),
            const SizedBox(height: 10),
            if (itemProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Card(
                  // 4. USAMOS UNA FUNCIÓN PARA ENCAPSULAR LA LÓGICA DE LA TABLA
                  child: _buildMainContent(
                    isCurrentRoute: isCurrentRoute,
                    assetType: assetType,
                    cIdInt: cIdInt,
                    atIdInt: atIdInt,
                    viewItems: viewItems,
                    locations: container.locations,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({
    required bool isCurrentRoute,
    required dynamic assetType,
    required int cIdInt,
    required int atIdInt,
    required List<InventoryItem> viewItems,
    required dynamic locations,
  }) {
    // Si no estamos en esta pantalla (estamos en Details), devolvemos un widget
    // que no cambie. Al ser 'const' o un widget simple, Flutter no bajará al DataTable2.
    if (!isCurrentRoute) {
      // Retornamos un placeholder o simplemente mantenemos el estado anterior
      // RepaintBoundary ayuda a que no se intente repintar la capa de la tabla.
      return const RepaintBoundary(
        child: SizedBox.expand(
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    if (_isListView) {
      return AssetDataTable(
        // Usamos una ValueKey para que Flutter identifique la tabla correctamente
        key: ValueKey('table_${atIdInt}'),
        assetType: assetType,
        containerId: cIdInt,
        assetTypeId: atIdInt,
        inventoryItems: viewItems,
        availableLocations: locations,
      );
    } else {
      return AssetGridView(
        assetType: assetType,
        items: viewItems,
        containerId: cIdInt,
        assetTypeId: atIdInt,
      );
    }
  }
}
