import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/screens/asset_search_bar.dart';
import 'package:invenicum/widgets/assets_counters_row.dart';
import 'package:provider/provider.dart';

import '../models/container_node.dart';
import '../models/asset_type_model.dart';
import '../models/location.dart'; // 🔑 Importado
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';

// Importar los nuevos widgets
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
  // --- ESTADO Y CONTROLADORES ---
  final TextEditingController _searchController = TextEditingController();
  bool _isListView = true;
  late InventoryItemProvider _itemProvider;

  // Filtros de agregación (Campos custom)
  String? _selectedCountFieldId;
  String? _selectedCountValue;

  // 🔑 NUEVO ESTADO: Filtro por Ubicación
  int? _selectedLocationId;


  @override
  void initState() {
    super.initState();
    _itemProvider = context.read<InventoryItemProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      _itemProvider.loadInventoryItems(
        containerId: int.tryParse(widget.containerId) ?? 0,
        assetTypeId: int.tryParse(widget.assetTypeId) ?? 0,
        aggregationFilters: {},
        forceReload: true,
        goToPageOne: true,
      );

      _searchController.addListener(_onSearchChanged);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _itemProvider.clearViewItems();
    super.dispose();
  }

  // --- MÉTODOS DE LÓGICA Y NAVEGACIÓN (applyFiltersAndLoad se mantiene igual) ---

  void _applyFiltersAndLoad({
    bool forceReload = false,
    bool goToPageOne = true,
  }) {
    if (!mounted) return;

    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) return;

    // Solo recargamos si se pasa un nuevo término de búsqueda global
    // o si se fuerza la recarga. La agregación local se maneja en 'build'.
    _itemProvider.loadInventoryItems(
      containerId: cIdInt,
      assetTypeId: atIdInt,
      aggregationFilters: {},
      forceReload: forceReload,
      goToPageOne: goToPageOne,
    );

    // Forzamos la reconstrucción para que el widget tome los nuevos filtros locales.
    setState(() {});
  }

  void _goBack(BuildContext context) {
    context.go('/container/${widget.containerId}/asset-types');
  }

  void _onSearchChanged() {
    if (!mounted) return;
    _itemProvider.setGlobalSearchTerm(_searchController.text);
    _itemProvider.goToPage(1);
  }

  void _goToCreateAsset(BuildContext context) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/new',
    );
  }

  void _onImportCSV(BuildContext context) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/import-csv',
    );
  }

  // 🔑 MODIFICADO: Lógica de Filtrado Local (Incluye Ubicación)
  List<dynamic> _getFilteredItems(List<dynamic> allItems) {
    // 1. Filtrar por Ubicación (Campo Común)
    Iterable<dynamic> filteredByLocation = allItems.where((item) {
      if (_selectedLocationId == null) {
        return true; // No hay filtro de ubicación aplicado
      }
      // Coincide si el locationId del ítem es igual al seleccionado
      return (item as InventoryItem).locationId == _selectedLocationId;
    });

    // 2. Aplicar el Filtro de Conteo/Agregación (Campos Custom)
    if (_selectedCountFieldId == null || _selectedCountValue == null) {
      return filteredByLocation.toList(); // Solo filtro de ubicación aplicado
    }

    final fieldId = _selectedCountFieldId!;
    final filterValue = _selectedCountValue!.toLowerCase().trim();

    return filteredByLocation.where((item) {
      final customValues =
          (item as InventoryItem).customFieldValues ??
          {};
      final itemValueRaw = customValues[fieldId];

      if (itemValueRaw == null) {
        return filterValue.isEmpty;
      }

      // MANEJO EXPLICITO DE BOOLEANOS
      if (itemValueRaw is bool) {
        final bool filterBool = (filterValue == 'true');
        if (filterValue == 'true' || filterValue == 'false') {
          return itemValueRaw == filterBool;
        }
        return false;
      }

      // Para String, int, double: convertir a string para comparación normalizada
      final itemValueString = itemValueRaw.toString().toLowerCase().trim();
      return itemValueString == filterValue;
    }).toList();
  }

  // --- DIÁLOGO DE FILTRO DE CONTEO (Se mantiene sin cambios) ---

  void _showCountFilterDialog(BuildContext context, AssetType assetType) {
    final List<Map<String, dynamic>> availableDefs = assetType.fieldDefinitions
        .map(
          (def) => {
            'id': def.id.toString(),
            'name': def.name,
            'type': def.type,
          },
        )
        .toList();

    String? tempSelectedFieldId = _selectedCountFieldId;
    TextEditingController tempValueController = TextEditingController(
      text: _selectedCountValue,
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Contar ítems por valor específico'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Campo a Contar',
                    ),
                    initialValue: tempSelectedFieldId,
                    items: availableDefs.map((def) {
                      final id = def['id'];
                      final name = def['name'] as String;
                      return DropdownMenuItem<String>(
                        value: id.toString(),
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setStateDialog(() {
                        tempSelectedFieldId = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: tempValueController,
                    decoration: const InputDecoration(
                      labelText: 'Valor Específico a Contar',
                      hintText: 'Ej: Dañado, Rojo, 50',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      // Limpiar el estado del filtro
                      _selectedCountFieldId = null;
                      _selectedCountValue = null;
                    });
                    _applyFiltersAndLoad();
                    context.pop();
                  },
                  child: const Text('Limpiar Contador'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Aplicar el nuevo estado del filtro
                      _selectedCountFieldId = tempSelectedFieldId;
                      _selectedCountValue = tempValueController.text.trim();
                    });
                    _applyFiltersAndLoad();
                    context.pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- WIDGET BUILD REFACTORIZADO (Añadiendo el selector de Ubicación) ---

  @override
  Widget build(BuildContext context) {
    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();

    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) {
      return const Center(
        child: Text('Error: IDs de contenedor o tipo de activo inválidos.'),
      );
    }

    final ContainerNode? container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

    final AssetType? assetType = container?.assetTypes
        .cast<AssetType?>()
        .firstWhere((at) => at?.id == atIdInt, orElse: () => null);

    if (container == null || assetType == null) {
      return const Center(
        child: Text('Contenedor o Tipo de Activo no encontrado.'),
      );
    }
    final List<Location> availableLocations = container.locations;

    // 1. Obtener los ítems base (ya filtrados por búsqueda global y paginados)
    final inventoryItems = itemProvider.inventoryItems;

    // 2. Aplicar el filtro de agregación y ubicación LOCALMENTE a los ítems visibles
    final viewItems = _getFilteredItems(inventoryItems);

    // 3. Obtener el Conteo Local
    final totalCountLocal = viewItems.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Activos en "${assetType.name}"'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
          tooltip: 'Volver a Tipos de Activo',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Título, Botones de Añadir y Filtro ---
            AssetListHeader(
              assetType: assetType,
              onGoToCreateAsset: () => _goToCreateAsset(context),
              onImportCSV: () => _onImportCSV(context),
              onShowCountFilterDialog: () =>
                  _showCountFilterDialog(context, assetType),
              selectedCountFieldId: _selectedCountFieldId,
            ),
            const SizedBox(height: 20),

  

            // --- CONTADORES DINÁMICOS Y SUMATORIOS ---
            AssetCountersRow(
              assetType: assetType,
              totalCountLocal: totalCountLocal,
              selectedCountFieldId: _selectedCountFieldId,
              // Si la Suma local se implementa, iría aquí: localAggregations: localAggregations,
            ),
            const SizedBox(height: 20),

            // --- BARRA DE BÚSQUEDA Y CONTROL DE VISTA ---
            AssetSearchBar(
              searchController: _searchController,
              isListView: _isListView,
              onToggleView: () {
                setState(() {
                  _isListView = !_isListView;
                });
              },
            ),
            const SizedBox(height: 10),

            // --- CONTENIDO PRINCIPAL ---
            if (itemProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: Card(
                  elevation: 1,
                  child: _isListView
                      ? AssetDataTable(
                          assetType: assetType,
                          containerId: cIdInt,
                          assetTypeId: atIdInt,
                          inventoryItems: viewItems as List<InventoryItem>,
                          availableLocations: availableLocations,
                        )
                      : AssetGridView(
                          assetType: assetType,
                          items: viewItems as List<InventoryItem>,
                          containerId: cIdInt,
                          assetTypeId: atIdInt,
                          //availableLocations: availableLocations,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
