import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/services/toast_service.dart';
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
    // Navegación para crear un nuevo activo
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/new',
    );
  }

  // --- NUEVAS FUNCIONES DE ACCIÓN ---

  void _editAsset(BuildContext context, InventoryItem item) {
    // Navegación para editar:
    // La ruta GoRouter debería ser algo como: /container/3/asset-types/1/assets/123/edit
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}/edit',
      extra: item, // Puedes pasar el objeto item como extra si es útil
    );
    // Mostrar un mensaje de prueba
    ToastService.info('Editando activo: ${item.name} (ID: ${item.id})');
  }

  void _deleteAsset(BuildContext context, InventoryItem item) {
    // 💡 Aquí se debería mostrar un cuadro de diálogo de confirmación
    // y luego llamar a itemProvider.deleteItem(item.id).

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar el activo "${item.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Llamar al servicio para eliminar
                final itemProvider = context.read<InventoryItemProvider>();
                final assetTypeIdInt = int.tryParse(widget.assetTypeId);

                if (assetTypeIdInt != null) {
                  // Ahora la llamada coincide con la firma del Provider (itemId, containerId, assetTypeId)
                  itemProvider.deleteInventoryItem(
                    item.id,
                    item.containerId,
                    assetTypeIdInt, // <-- ID DEL TIPO DE ACTIVO REQUERIDO POR EL PROVIDER
                  );
                  ToastService.success('Activo "${item.name}" eliminado.');
                } else {
                  // Manejo si el assetTypeId del widget no es un número
                  ToastService.error(
                    'Error: El ID del tipo de activo es inválido.',
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  // ------------------------------------

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

    if (containerProvider.isLoading && containerProvider.containers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final ContainerNode? container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

    if (container == null) {
      return Center(
        child: Text('Contenedor con ID ${widget.containerId} no encontrado.'),
      );
    }

    final AssetType? assetType = container.assetTypes
        .cast<AssetType?>()
        .firstWhere((at) => at?.id == atIdInt, orElse: () => null);

    if (assetType == null) {
      return Center(
        child: Text(
          'Tipo de Activo con ID ${widget.assetTypeId} no encontrado.',
        ),
      );
    }

    // 1. AÑADIR LA CABECERA DE ACCIONES
    final List<String> tableHeaders = [
      'Nombre',
      'Descripción',
      ...assetType.fieldDefinitions.map((f) => f.name),
      'Acciones', // <-- NUEVA CABECERA
    ];

    if (tableHeaders.isEmpty) {
      return const Center(
        child: Text('Error: No se pudieron cargar las definiciones de campo.'),
      );
    }

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
                            // Fila de Mensaje de Vacío (Rellena hasta la nueva columna)
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text('No hay activos creados aún.'),
                                ),
                                // Relleno para que coincida con el número de columnas (headers.length - 1)
                                ...List.generate(
                                  tableHeaders.length - 1,
                                  (_) => const DataCell(SizedBox.shrink()),
                                ),
                              ],
                            ),
                          ]
                        : inventoryItems.map((item) {
                            // Fila de Datos Real
                            final List<DataCell> cells = [
                              // 1. Datos Fijos (Nombre)
                              DataCell(Text(item.name)),
                              DataCell(Text(item.description ?? '—')),
                            ];

                            // 2. Datos Dinámicos (Valores de campos personalizados)
                            for (final fieldDef in assetType.fieldDefinitions) {
                              final fieldValue =
                                  item.customFieldValues[fieldDef.id
                                      .toString()] ??
                                  '—';
                              cells.add(DataCell(Text(fieldValue.toString())));
                            }

                            // 3. NUEVA CELDA DE ACCIONES
                            cells.add(
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      tooltip: 'Editar',
                                      onPressed: () =>
                                          _editAsset(context, item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: Colors.red[600],
                                      tooltip: 'Eliminar',
                                      onPressed: () =>
                                          _deleteAsset(context, item),
                                    ),
                                  ],
                                ),
                              ),
                            );

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
