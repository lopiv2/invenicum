import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/inventory_item.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';
import '../models/container_node.dart';
import '../models/asset_type_model.dart';

// Convertido a StatefulWidget para manejar la inicialización única
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
  
  @override
  void initState() {
    super.initState();
    
    // ** SOLUCIÓN AL BUCLE INFINITO **
    // La carga se programa una única vez en initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cIdInt = int.tryParse(widget.containerId);
      final atIdInt = int.tryParse(widget.assetTypeId);
      
      if (cIdInt != null && atIdInt != null) {
        // Usamos .read para llamar a la función sin disparar rebuilds
        context.read<InventoryItemProvider>().loadInventoryItems(
          containerId: cIdInt,
          assetTypeId: atIdInt,
        );
      }
    });
  }

  void _goToCreateAsset(BuildContext context) {
    // Usamos widget.containerId y widget.assetTypeId
    context.go('/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/new');
  }

  @override
  Widget build(BuildContext context) {
    // Observamos providers (Solo se reconstruye si hay notifyListeners)
    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();

    // Usamos las propiedades del widget con la palabra clave 'widget.'
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    // 1. Manejar IDs inválidos
    if (cIdInt == null || atIdInt == null) {
      return const Center(
        child: Text('Error: IDs de contenedor o tipo de activo inválidos.'),
      );
    }

    // 2. Manejar estado de Carga de Contenedores
    if (containerProvider.isLoading && containerProvider.containers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Buscar el Contenedor
    final ContainerNode? container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

    // 4. Manejar Contenedor no encontrado
    if (container == null) {
      return Center(
        child: Text('Contenedor con ID ${widget.containerId} no encontrado.'),
      );
    }

    // 5. Buscar el Tipo de Activo
    final AssetType? assetType = container.assetTypes
        .cast<AssetType?>()
        .firstWhere((at) => at?.id == atIdInt, orElse: () => null);

    // 6. Manejar Tipo de Activo no encontrado
    if (assetType == null) {
      return Center(
        child: Text('Tipo de Activo con ID ${widget.assetTypeId} no encontrado.'),
      );
    }

    // --- Obtener datos de Ítems e Inicializar Cabeceras ---
    final List<String> tableHeaders = [
      'Nombre',
      ...assetType.fieldDefinitions.map((f) => f.name),
    ];

    if (tableHeaders.isEmpty) {
      return const Center(
        child: Text('Error: No se pudieron cargar las definiciones de campo.'),
      );
    }

    // Obtener la lista de ítems del proveedor
    final List<InventoryItem> inventoryItems = itemProvider.getInventoryItems(
      cIdInt,
      atIdInt,
    );
    // --------------------------------------------------------

    // --- 8. Lógica de Renderizado ---
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

          // Indicador de Carga de Ítems
          if (itemProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            // DataTable o Mensaje de Vacío
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 1,
                  child: DataTable(
                    columns: tableHeaders
                        .map(
                          (header) => DataColumn(
                            label: Expanded(
                              child: Text(
                                header,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        )
                        .toList(),

                    // CREACIÓN DINÁMICA DE FILAS
                    rows: inventoryItems.isEmpty
                        ? [
                            // Fila de Mensaje de Vacío (si no hay ítems)
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text('No hay activos creados aún.'),
                                ),
                                // Relleno para que coincida con el número de columnas
                                ...List.generate(
                                  tableHeaders.length - 1,
                                  (_) => const DataCell(SizedBox.shrink()),
                                ),
                              ],
                            ),
                          ]
                        : inventoryItems.map((item) {
                            // Fila de Datos Real (si hay ítems)

                            // 1. Datos Fijos (Nombre)
                            final List<DataCell> cells = [
                              DataCell(Text(item.name)),
                            ];

                            // 2. Datos Dinámicos (Valores de campos personalizados)
                            for (final fieldDef in assetType.fieldDefinitions) {
                              // Usamos el ID de la definición como clave en customFieldValues
                              final fieldValue =
                                  item.customFieldValues[fieldDef.id.toString()] ?? '—';
                              cells.add(DataCell(Text(fieldValue.toString())));
                            }

                            return DataRow(cells: cells);
                          }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}