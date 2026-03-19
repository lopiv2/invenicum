import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/screens/asset_types/local_widgets/condition_badge_widget.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/inventory_item.dart';
import '../../../data/models/asset_type_model.dart';
import '../../../data/models/location.dart';
import '../../../data/models/custom_field_definition.dart';
import '../../../providers/inventory_item_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../../widgets/ui/print_label_button_widget.dart';

class AssetPlutoTable extends StatefulWidget {
  final AssetType assetType;
  final int containerId;
  final int assetTypeId;
  final List<InventoryItem> items;
  final List<Location> availableLocations;

  const AssetPlutoTable({
    super.key,
    required this.assetType,
    required this.containerId,
    required this.assetTypeId,
    required this.items,
    required this.availableLocations,
  });

  @override
  State<AssetPlutoTable> createState() => _AssetPlutoTableState();
}

class _AssetPlutoTableState extends State<AssetPlutoTable> {
  PlutoGridStateManager? stateManager;
  late List<PlutoColumn> columns;
  late List<PlutoRow> rows;

  @override
  void initState() {
    super.initState();
    columns = _buildColumns();
    rows = _buildRows();
  }

  @override
  void didUpdateWidget(covariant AssetPlutoTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Comprobamos si la longitud ha cambiado o si los objetos son distintos
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.items != widget.items) {
      final newRows = _buildRows();
      setState(() {
        rows = newRows;
      });

      if (stateManager != null) {
        // Usamos refetch para una actualización limpia del estado interno de Pluto
        stateManager!.removeAllRows();
        stateManager!.appendRows(newRows);
      }
    }
  }

  // --- MÉTODOS DE ACCIÓN (Copiados de tu DataTable anterior) ---

  void _copyAsset(InventoryItem item) async {
    final itemCopy = item.copyWith(
      id: 0,
      name: "${item.name} (Copia)",
      resetImageIds: true,
    );
    try {
      await context.read<InventoryItemProvider>().cloneInventoryItem(itemCopy);
      ToastService.success('✅ Activo "${itemCopy.name}" copiado.');
    } catch (e) {
      ToastService.error('❌ Error al copiar: $e');
    }
  }

  void _deleteAsset(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Deseas eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<InventoryItemProvider>().deleteInventoryItem(
                item.id,
                widget.containerId,
                widget.assetTypeId,
              );
              if (stateManager != null) {
                final rowToRemove = stateManager!.rows.firstWhere(
                  (r) =>
                      (r.cells['item_object']!.value as InventoryItem).id ==
                      item.id,
                );
                stateManager!.removeRows([rowToRemove]);
              }
              ToastService.success('Elemento eliminado correctamente');
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- CONSTRUCCIÓN DE COLUMNAS ---

  List<PlutoColumn> _buildColumns() {
    List<PlutoColumn> baseColumns = [
      PlutoColumn(
        title: 'ID Obj',
        field: 'item_object',
        type: PlutoColumnType.text(),
        hide: true,
      ),
      PlutoColumn(
        title: 'Imagen',
        field: 'image',
        type: PlutoColumnType.text(),
        enableSorting: false,
        enableFilterMenuItem: false,
        width: 80,
        renderer: (rendererContext) {
          final String imageUrl = rendererContext.cell.value.toString();
          final String fullImageUrl = '${Environment.apiUrl}$imageUrl';

          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: fullImageUrl.isNotEmpty
                  ? Tooltip(
                      message: 'Ver imagen',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showImageDialog(context, fullImageUrl),
                          child: Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 20),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Nombre',
        field: 'name',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Stock actual',
        field: 'quantity',
        type: PlutoColumnType.number(),
        width: 100,
      ),
      PlutoColumn(
        title: 'Stock minimo',
        field: 'minStock',
        type: PlutoColumnType.number(),
        width: 100,
      ),
      PlutoColumn(
        title: 'Ubicación',
        field: 'location',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      PlutoColumn(
        title: 'Código de Barras',
        field: 'barcode',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      PlutoColumn(
        title: 'Precio de mercado',
        field: 'marketValue',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      PlutoColumn(
        title: 'Condición',
        field: 'condition',
        type: PlutoColumnType.text(),
        width: 150, // Ajusta el ancho para que quepa el badge
        renderer: (rendererContext) {
          // 1. Extraemos el objeto completo del activo de esta fila
          final item =
              rendererContext.row.cells['item_object']!.value as InventoryItem;

          // 3. Retornamos tu widget personalizado envolviéndolo en un Center o Padding si es necesario
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: ConditionBadgeWidget(condition: item.condition),
            ),
          );
        },
      ),
    ];

    // Columnas Dinámicas según el AssetType
    final customColumns = (widget.assetType.fieldDefinitions).map((field) {
      return PlutoColumn(
        title: field.name,
        field: field.id.toString(),
        type: field.type == CustomFieldType.number
            ? PlutoColumnType.number()
            : PlutoColumnType.text(),
        width: 150,
        renderer: field.type == CustomFieldType.boolean
            ? (rendererContext) {
                // Aseguramos que el valor sea bool
                final bool isChecked = rendererContext.cell.value == true;

                return Icon(
                  isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isChecked
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.5),
                );
              }
            : null,
      );
    }).toList();

    return [
      ...baseColumns,
      ...customColumns,
      PlutoColumn(
        title: 'Acciones',
        field: 'actions',
        type: PlutoColumnType.text(),
        enableSorting: false,
        enableFilterMenuItem: false,
        width: 200,
        renderer: (rendererContext) {
          final item =
              rendererContext.row.cells['item_object']!.value as InventoryItem;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                onPressed: () => context.go(
                  '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}/edit',
                  extra: item,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.orange),
                onPressed: () => _copyAsset(item),
              ),
              IconButton(
                icon: const Icon(Icons.print, size: 18, color: Colors.green),
                onPressed: () => PrintLabelButton.showPreview(context, item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _deleteAsset(item),
              ),
            ],
          );
        },
      ),
    ];
  }

  void _showImageDialog(BuildContext context, String fullImageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 0.1,
              maxScale: 4.0,
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No se pudo cargar la imagen.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text(
                      'Asegúrate de que la URL es correcta y el servidor está activo.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<PlutoRow> _buildRows() {
    return widget.items.map((item) {
      final Map<String, PlutoCell> cells = {
        'item_object': PlutoCell(value: item),
        'image': PlutoCell(
          value: (item.images.isNotEmpty) ? item.images[0].url : '',
        ),
        'name': PlutoCell(value: item.name),
        'quantity': PlutoCell(value: item.quantity),
        'minStock': PlutoCell(value: item.minStock),
        'location': PlutoCell(value: item.location?.name ?? ''),
        'barcode': PlutoCell(value: item.barcode ?? ''),
        'marketValue': PlutoCell(value: item.marketValue.toString()),
        'condition': PlutoCell(value: item.condition),
        'actions': PlutoCell(value: ''), // Necesario para el renderer
      };

      // --- CORRECCIÓN AQUÍ ---
      for (var field in widget.assetType.fieldDefinitions) {
        final fieldKey = field.id.toString();

        // Intentamos obtener el valor.
        // Si tu mapa usa ints como llaves: item.customFieldValues?[field.id]
        // Si tu mapa usa strings (JSON): item.customFieldValues?[fieldKey]
        final dynamic rawValue =
            item.customFieldValues?[field.id] ??
            item.customFieldValues?[fieldKey];

        cells[fieldKey] = PlutoCell(
          value: _parseCustomFieldValue(rawValue, field.type),
        );
      }

      return PlutoRow(cells: cells);
    }).toList();
  }

  // Función auxiliar para formatear según el tipo
  dynamic _parseCustomFieldValue(dynamic value, CustomFieldType type) {
    if (type == CustomFieldType.boolean) {
      if (value == null) return false;
      if (value is bool) return value;

      // Convertimos Strings como "si", "true", "1" a booleano true
      final String strValue = value.toString().toLowerCase().trim();
      return strValue == 'si' || strValue == 'true' || strValue == '1';
    }

    if (type == CustomFieldType.number) {
      if (value == null) return 0;
      return num.tryParse(value.toString()) ?? 0;
    }

    // Para texto y otros
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<InventoryItemProvider>();

    return PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (event) {
        stateManager = event.stateManager;
        // Mostrar filtros por defecto si quieres que se parezca a tu buscador
        stateManager?.setShowColumnFilter(true);
      },
      onRowDoubleTap: (event) {
        final item = event.row.cells['item_object']!.value as InventoryItem;
        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}',
        );
      },
      // --- VINCULACIÓN CON EL PROVIDER ---
      onSorted: (event) {
        if (event.column.field == 'actions' ||
            event.column.field == 'item_object')
          return;

        // Sincronizar el ordenamiento de Pluto con tu Provider
        //bool ascending = event.order.isAscending;
        /*itemProvider.sortInventoryItems(
          dataKey: event.column.field,
          ascending: ascending,
        );*/
      },
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBorderColor: Colors.transparent,
          columnTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.none, // Permitir scroll horizontal
        ),
      ),
      // --- PAGINACIÓN ---
      createFooter: (stateManager) {
        return PlutoPagination(
          stateManager,
          pageSizeToMove: itemProvider.itemsPerPage,
        );
      },
    );
  }
}
