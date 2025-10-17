import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/container_node.dart';
import '../models/asset_type_model.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';
import '../widgets/asset_data_table.dart';
import '../widgets/asset_grid_view.dart';

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
  // Estado para la barra de búsqueda global
  final TextEditingController _searchController = TextEditingController();

  // Estado para el control de la vista (true = Lista/DataTable, false = Grid/Cards)
  bool _isListView = true;

  late InventoryItemProvider _itemProvider;

  String? _selectedCountFieldId; // ID del campo custom seleccionado (ej: '10')
  String? _selectedCountValue;

  @override
  void initState() {
    super.initState();
    _itemProvider = context.read<InventoryItemProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFiltersAndLoad(
        forceReload: true,
      ); // 🔑 Llama a la nueva lógica de carga inicial

      _searchController.addListener(_onSearchChanged);
    });
  }

  void _applyFiltersAndLoad({
    bool forceReload = false,
    bool goToPageOne = true,
  }) {
    if (!mounted) return;

    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) return;

    // Construir el mapa de filtros de agregación para el backend
    final Map<String, String> aggFilters = {};
    if (_selectedCountFieldId != null &&
        _selectedCountValue != null &&
        _selectedCountValue!.isNotEmpty) {
      aggFilters[_selectedCountFieldId!] = _selectedCountValue!;
    }

    _itemProvider.loadInventoryItems(
      containerId: cIdInt,
      assetTypeId: atIdInt,
      aggregationFilters: aggFilters, // Pasar el filtro dinámico
      forceReload: forceReload,
      goToPageOne: goToPageOne,
    );
  }

  void _goBack(BuildContext context) {
    // 🔑 CAMBIO CLAVE: Usamos context.go() para NAVEGAR
    // directamente a la ruta padre, forzando su reconstrucción
    // y reseteando el widget tree asociado.
    context.go('/container/${widget.containerId}/asset-types');
  }

  // Nuevo método para manejar la búsqueda de forma síncrona con el Provider
  void _onSearchChanged() {
    // 🔑 CORRECCIÓN: Verificar si el widget está montado antes de usar context.
    if (!mounted) return;

    _itemProvider.setGlobalSearchTerm(_searchController.text);
    _itemProvider.goToPage(1);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _itemProvider.clearViewItems();
    super.dispose();
  }

  // --- NAVEGACIÓN ---

  void _goToCreateAsset(BuildContext context) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/new',
    );
  }

  void _showCountFilterDialog(BuildContext context, AssetType assetType) {
    // Usamos las definiciones del AssetType local para el Dropdown
    final List<Map<String, dynamic>> availableDefs = assetType.fieldDefinitions
        .map(
          (def) => {
            'id': def.id.toString(),
            'name': def.name,
            'type': def.type,
          },
        )
        .toList();

    // Estados temporales para el diálogo
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
                      // 🔑 CORRECCIÓN CLAVE: Castear o convertir el ID a String
                      return DropdownMenuItem<String>(
                        value: id.toString(), // Asegurar que el valor es String
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
                    _applyFiltersAndLoad(); // Recargar sin filtro de conteo
                    Navigator.of(context).pop();
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
                    _applyFiltersAndLoad(); // Recargar con el nuevo filtro
                    Navigator.of(context).pop();
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

    // 🚨 CORRECCIÓN 1: Usamos el getter inventoryItems. Ya no se pasan IDs.
    final inventoryItems = itemProvider.inventoryItems;

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
            // Título y Botón de Añadir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Listado de Activos: "${assetType.name}"',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // 🎯 BOTÓN PARA ABRIR EL FILTRO DE CONTEO
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showCountFilterDialog(context, assetType),
                      icon: const Icon(Icons.pin_drop),
                      label: Text(
                        _selectedCountFieldId == null
                            ? 'Contador Dinámico'
                            : 'Filtro Activo',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedCountFieldId != null
                            ? Theme.of(context).colorScheme.tertiary
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    // Contador Total de Ítems (siempre visible)
                    Chip(
                      avatar: const Icon(Icons.inventory, size: 18),
                      label: Text(
                        'TOTAL ÍTEMS: ${itemProvider.totalItems}',
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                    ),

                    // 🎯 Contador Dinámico (solo si está activo)
                    if (_selectedCountFieldId != null)
                      Chip(
                        avatar: const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                        ),
                        label: Text(
                          'COUNT "${assetType.fieldDefinitions.firstWhere((def) => def.id.toString() == _selectedCountFieldId).name}": ${itemProvider.aggregationResults['count_${_selectedCountFieldId}']?.toString() ?? '0'}',
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.tertiary.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                      ),

                    // Sumatorios (basados en las definiciones isSummable del backend)
                    ...itemProvider.aggregationDefinitions.map((def) {
                      return const SizedBox.shrink(); // No mostrar nada si no es sumable
                    }).toList(),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _goToCreateAsset(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Activo'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ///Contadores de agregaciones
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: itemProvider.aggregationDefinitions.map((def) {
                final fieldId = def['id'].toString();
                final fieldName = def['name'] as String? ?? 'Campo Desconocido';

                final bool isCountable = def['isCountable'] == true;
                final bool isSummable = def['isSummable'] == true;

                final List<Widget> aggregationWidgets = [];

                // 1. Mostrar Sumatorio (isSummable)
                if (isSummable) {
                  final sumKey = 'sum_$fieldId';
                  // Obtener el valor de la suma. Usamos 0.0 por defecto para evitar errores si no hay valor.
                  final sumValue =
                      itemProvider.aggregationResults[sumKey]?.toString() ??
                      '0.0';

                  aggregationWidgets.add(
                    Chip(
                      avatar: const Icon(Icons.calculate, size: 18),
                      // Etiqueta para la Suma Total
                      label: Text('SUMA ${fieldName}: ${sumValue}'),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                    ),
                  );
                }

                // 2. Mostrar Contador (isCountable)
                if (isCountable) {
                  final countKey = 'count_$fieldId';
                  // Obtener el valor del conteo. Usamos 0 por defecto.
                  final countValue =
                      itemProvider.aggregationResults[countKey]?.toString() ??
                      '0';

                  aggregationWidgets.add(
                    Chip(
                      avatar: const Icon(Icons.pin, size: 18),
                      // Etiqueta para el Conteo
                      label: Text('COUNT ${fieldName}: ${countValue}'),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                    ),
                  );
                }

                // Devuelve todos los chips generados para este campo custom
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: aggregationWidgets,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // BARRA DE BÚSQUEDA Y CONTROL DE VISTA
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Búsqueda Global',
                        hintText: 'Buscar en todas las columnas...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  // La lógica del Provider se maneja en el Listener
                                  // Aquí solo forzamos la limpieza del campo
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                      ),
                      // Se elimina onChanged, ya que usamos el listener del controller
                    ),
                  ),
                ),
                // Botón de alternar vista
                IconButton(
                  icon: Icon(
                    _isListView ? Icons.grid_view : Icons.list,
                    size: 30,
                  ),
                  tooltip: _isListView
                      ? 'Mostrar como Grid'
                      : 'Mostrar como Lista',
                  onPressed: () {
                    setState(() {
                      _isListView = !_isListView;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- CONTENIDO PRINCIPAL: Carga o Tabla/Grid ---
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
                          inventoryItems: inventoryItems, // Lista paginada
                        )
                      : AssetGridView(
                          assetType: assetType,
                          items: inventoryItems, // Lista paginada
                          containerId: cIdInt,
                          assetTypeId: atIdInt,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
