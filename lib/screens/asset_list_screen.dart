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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cIdInt = int.tryParse(widget.containerId);
      final atIdInt = int.tryParse(widget.assetTypeId);
      final itemProvider = context.read<InventoryItemProvider>();

      if (cIdInt != null && atIdInt != null) {
        // Inicializa la carga de datos.
        // El Provider ahora almacena cIdInt y atIdInt y notifica la actualización.
        // Se asume que el Provider ya tiene un ordenamiento y paginación por defecto.
        itemProvider.loadInventoryItems(
          containerId: cIdInt,
          assetTypeId: atIdInt,
          forceReload: true, // Forzar la carga inicial si es necesario
        );
      }
      
      // Suscribirse a los cambios del controlador para actualizar el Provider
      _searchController.addListener(_onSearchChanged);
    });
  }

  // Nuevo método para manejar la búsqueda de forma síncrona con el Provider
  void _onSearchChanged() {
    final itemProvider = context.read<InventoryItemProvider>();
    itemProvider.setGlobalSearchTerm(_searchController.text);
    itemProvider.goToPage(1); // Siempre volver a la página 1 al buscar o filtrar
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- NAVEGACIÓN ---

  void _goToCreateAsset(BuildContext context) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/new',
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
    
    // 🚨 CORRECCIÓN 2: Usamos el getter totalItems. Ya no se pasan IDs.
    final totalFilteredItems = itemProvider.totalItems;


    return Padding(
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
              ElevatedButton.icon(
                onPressed: () => _goToCreateAsset(context),
                icon: const Icon(Icons.add),
                label: const Text('Añadir Activo'),
              ),
            ],
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                tooltip: _isListView ? 'Mostrar como Grid' : 'Mostrar como Lista',
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
    );
  }
}