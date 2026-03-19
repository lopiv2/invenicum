import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/screens/asset_types/local_widgets/condition_badge_widget.dart';
import 'package:invenicum/screens/asset_types/local_widgets/custom_footer_pagination.dart';
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
  final TextEditingController? searchController;

  const AssetPlutoTable({
    super.key,
    required this.assetType,
    required this.containerId,
    required this.assetTypeId,
    required this.items,
    required this.availableLocations,
    this.searchController,
  });

  @override
  State<AssetPlutoTable> createState() => _AssetPlutoTableState();
}

class _AssetPlutoTableState extends State<AssetPlutoTable> {
  PlutoGridStateManager? stateManager;
  late List<PlutoColumn> columns;
  late List<PlutoRow> _initialRows;
  bool _goToLastPage = false;

  @override
  void initState() {
    super.initState();
    columns = _buildColumns();
    // Las filas se inyectan en onLoaded, después de que el pageSize
    // ya está configurado por createFooter, evitando el RangeError.
    _initialRows = [];
    widget.searchController?.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController?.removeListener(_onSearchChanged);
    super.dispose();
  }

  /// Aplica una búsqueda global en todas las columnas visibles de PlutoGrid.
  /// PlutoGrid no expone un método nativo de búsqueda global, así que
  /// filtramos directamente sobre refRows usando el término de búsqueda.
  void _onSearchChanged() {
    if (stateManager == null) return;
    final term = widget.searchController?.text.trim().toLowerCase() ?? '';

    if (term.isEmpty) {
      // Restauramos todas las filas originales
      stateManager!.refRows.setFilter(null);
    } else {
      stateManager!.refRows.setFilter((row) {
        // Buscamos el término en cualquier celda de la fila
        return row.cells.entries.any((entry) {
          // Excluimos columnas ocultas o de control interno
          if (entry.key == 'item_object' || entry.key == 'actions') {
            return false;
          }
          final cellValue = entry.value.value;
          if (cellValue == null) return false;
          return cellValue.toString().toLowerCase().contains(term);
        });
      });
    }
    stateManager!.notifyListeners();
  }

  @override
  void didUpdateWidget(covariant AssetPlutoTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    final itemsChanged =
        oldWidget.items.length != widget.items.length ||
        !_areItemListsEqual(oldWidget.items, widget.items);

    if (itemsChanged && stateManager != null) {
      // Diferimos al siguiente frame para que PlutoGrid termine su layout
      // actual antes de modificar las filas, evitando el RangeError en
      // FilteredList cuando el pageSize es menor que el total anterior.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || stateManager == null) return;
        stateManager!.setShowLoading(true, level: PlutoGridLoadingLevel.rows);
        final newRows = _buildRows(widget.items);
        stateManager!.removeAllRows();
        stateManager!.appendRows(newRows);
        if (_goToLastPage) {
          stateManager!.setPage(stateManager!.totalPage);
          _goToLastPage = false;
        } else {
          stateManager!.setPage(1);
        }
        stateManager!.setShowLoading(false);
      });
    }
  }

  bool _areItemListsEqual(List<InventoryItem> a, List<InventoryItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].updatedAt != b[i].updatedAt) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // ACCIONES
  // ---------------------------------------------------------------------------

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
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Deseas eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<InventoryItemProvider>().deleteInventoryItem(
                item.id,
                widget.containerId,
                widget.assetTypeId,
              );
              ToastService.success('Elemento eliminado correctamente');
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COLUMNAS
  // ---------------------------------------------------------------------------

  List<PlutoColumn> _buildColumns() {
    final List<PlutoColumn> baseColumns = [
      PlutoColumn(
        title: 'ID Obj',
        field: 'item_object',
        type: PlutoColumnType.text(),
        hide: true,
        enableSorting: false,
        enableFilterMenuItem: false,
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
              child: imageUrl.isNotEmpty
                  ? Tooltip(
                      message: 'Ver imagen',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showImageDialog(context, fullImageUrl),
                          child: Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
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
        title: 'Stock mínimo',
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
        width: 150,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          final item =
              rendererContext.row.cells['item_object']!.value as InventoryItem;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: ConditionBadgeWidget(condition: item.condition),
            ),
          );
        },
      ),
    ];

    final customColumns = widget.assetType.fieldDefinitions.map((field) {
      return PlutoColumn(
        title: field.name,
        field: field.id.toString(),
        type: field.type == CustomFieldType.number
            ? PlutoColumnType.number()
            : PlutoColumnType.text(),
        width: 150,
        renderer: field.type == CustomFieldType.boolean
            ? (rendererContext) {
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
                  '/container/${widget.containerId}/asset-types/'
                  '${widget.assetTypeId}/assets/${item.id}/edit',
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

  // ---------------------------------------------------------------------------
  // FILAS
  // ---------------------------------------------------------------------------

  List<PlutoRow> _buildRows(List<InventoryItem> items) {
    return items.map((item) {
      final Map<String, PlutoCell> cells = {
        'item_object': PlutoCell(value: item),
        'image': PlutoCell(
          value: item.images.isNotEmpty ? item.images[0].url : '',
        ),
        'name': PlutoCell(value: item.name),
        'quantity': PlutoCell(value: item.quantity),
        'minStock': PlutoCell(value: item.minStock),
        'location': PlutoCell(value: item.location?.name ?? ''),
        'barcode': PlutoCell(value: item.barcode ?? ''),
        'marketValue': PlutoCell(value: item.marketValue.toString()),
        'condition': PlutoCell(value: item.condition),
        'actions': PlutoCell(value: ''),
      };

      for (var field in widget.assetType.fieldDefinitions) {
        final fieldKey = field.id.toString();
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

  dynamic _parseCustomFieldValue(dynamic value, CustomFieldType type) {
    if (type == CustomFieldType.boolean) {
      if (value == null) return false;
      if (value is bool) return value;
      final str = value.toString().toLowerCase().trim();
      return str == 'si' || str == 'true' || str == '1';
    }
    if (type == CustomFieldType.number) {
      if (value == null) return 0;
      return num.tryParse(value.toString()) ?? 0;
    }
    return value?.toString() ?? '';
  }

  // ---------------------------------------------------------------------------
  // DIÁLOGO IMAGEN
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: columns,
      rows: _initialRows,
      onLoaded: (event) {
        stateManager = event.stateManager;
        stateManager?.setShowColumnFilter(true);
        // Insertamos las filas aquí: createFooter ya aplicó setPageSize(10)
        // antes de este callback, así que PlutoGrid pagina correctamente.
        final rows = _buildRows(widget.items);
        stateManager?.appendRows(rows);
      },
      onRowDoubleTap: (event) {
        final item = event.row.cells['item_object']!.value as InventoryItem;
        context.go(
          '/container/${widget.containerId}/asset-types/'
          '${widget.assetTypeId}/assets/${item.id}',
        );
      },
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBorderColor: Colors.transparent,
          columnTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.none,
        ),
      ),
      createFooter: (stateManager) {
        // setPageSize aquí garantiza que se aplica antes del primer render del footer,
        // que es el momento en que PlutoGrid inicializa su paginación interna.
        stateManager.setPageSize(10, notify: false);
        return PlutoPaginationFooter(stateManager: stateManager);
      },
    );
  }
}
