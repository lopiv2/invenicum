import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/asset_types/local_widgets/condition_badge_widget.dart';
import 'package:invenicum/screens/asset_types/local_widgets/custom_footer_pagination.dart';
import 'package:invenicum/widgets/ui/price_display_widget.dart';
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
    // columns se construye en didChangeDependencies porque _buildColumns()
    // llama a getLocalizedString(context) que necesita las localizaciones,
    // las cuales no están disponibles en initState.
    _initialRows = [];
    widget.searchController?.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reconstruimos las columnas aquí donde context ya tiene localizaciones.
    // Solo la primera vez — si ya hay un stateManager activo no tocamos las columnas
    // para no romper el grid mientras está renderizado.
    if (stateManager == null) {
      columns = _buildColumns();
    }
  }

  @override
  void dispose() {
    widget.searchController?.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (stateManager == null) return;
    final term = widget.searchController?.text.trim().toLowerCase() ?? '';

    if (term.isEmpty) {
      stateManager!.refRows.setFilter(null);
    } else {
      stateManager!.refRows.setFilter((row) {
        return row.cells.entries.any((entry) {
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
      final ai = a[i];
      final bi = b[i];
      if (ai.id != bi.id ||
          ai.updatedAt != bi.updatedAt ||
          ai.name != bi.name ||
          ai.description != bi.description ||
          ai.quantity != bi.quantity ||
          ai.minStock != bi.minStock ||
          ai.locationId != bi.locationId ||
          ai.marketValue != bi.marketValue ||
          ai.customFieldValues.toString() != bi.customFieldValues.toString()) {
        return false;
      }
    }
    return true;
  }

  Future<void> _reloadItems() async {
    try {
      await context.read<InventoryItemProvider>().loadInventoryItems(
        containerId: widget.containerId,
        assetTypeId: widget.assetTypeId,
        forceReload: true,
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ToastService.error(l10n.reloadListError);
    }
  }

  Future<void> _openAssetDetail(InventoryItem item) async {
    await context.pushNamed(
      RouteNames.assetDetail,
      pathParameters: {
        'containerId': widget.containerId.toString(),
        'assetTypeId': widget.assetTypeId.toString(),
        'assetId': item.id.toString(),
      },
    );
    if (!mounted) return;
    await _reloadItems();
  }

  Future<void> _openAssetEdit(InventoryItem item) async {
    await context.pushNamed(
      RouteNames.assetEdit,
      pathParameters: {
        'containerId': widget.containerId.toString(),
        'assetTypeId': widget.assetTypeId.toString(),
        'assetId': item.id.toString(),
      },
      extra: item,
    );
    if (!mounted) return;
    await _reloadItems();
  }

  void _copyAsset(InventoryItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final itemCopy = item.copyWith(
      id: 0,
      name: "${item.name} (${l10n.copyItemSuffix})",
      resetImageIds: true,
    );
    try {
      await context.read<InventoryItemProvider>().cloneInventoryItem(itemCopy);
      ToastService.success(l10n.itemCopiedSuccess(itemCopy.name));
    } catch (e) {
      ToastService.error(l10n.copyError);
    }
  }

  void _deleteAsset(InventoryItem item) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.deleteItemMessage(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<InventoryItemProvider>().deleteInventoryItem(
                item.id,
                widget.containerId,
                widget.assetTypeId,
              );
              ToastService.success(l10n.elementDeletedSuccess);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<PlutoColumn> _buildColumns() {
    // Obtenemos los labels localizados para el select de condición.
    // Los valores del select DEBEN coincidir exactamente con los que
    // guardamos en las celdas en _buildRows (condition.getLocalizedString).
    final l10n = AppLocalizations.of(context)!;
    final conditionLabels = ItemCondition.values
        .map((e) => e.getLocalizedString(context))
        .toList();

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
        title: l10n.imageColumnLabel,
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
                      message: l10n.viewImageTooltip,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showImageDialog(context, fullImageUrl),
                          child: Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
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
        title: l10n.assetName,
        field: 'name',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: l10n.currentStockLabel,
        field: 'quantity',
        type: PlutoColumnType.number(),
        width: 100,
      ),
      PlutoColumn(
        title: l10n.minimumStockLabel,
        field: 'minStock',
        type: PlutoColumnType.number(),
        width: 100,
      ),
      PlutoColumn(
        title: l10n.locationColumnLabel,
        field: 'location',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      if (widget.assetType.isSerialized)
        PlutoColumn(
          title: l10n.serialNumberColumnLabel,
          field: 'serialNumber',
          type: PlutoColumnType.text(),
          width: 100,
        ),
      PlutoColumn(
        title: l10n.barCode,
        field: 'barcode',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      PlutoColumn(
        title: l10n.marketPriceLabel,
        field: 'marketValue',
        type: PlutoColumnType.text(),
        width: 150,
        renderer: (rendererContext) {
          // Usamos item_object para tener el enum real y mostrar el badge.
          final item =
              rendererContext.row.cells['item_object']!.value as InventoryItem;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Tooltip(
                message: item.marketValue.toString(),
                child: PriceDisplayWidget(
                  value: item.marketValue,
                  fontSize: 14,
                  color: Colors
                      .black87, // Color más neutro para la tabla si se prefiere
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: l10n.conditionColumnLabel,
        field: 'condition',
        // select con los strings localizados — PlutoGrid muestra un dropdown
        // al filtrar con exactamente estas opciones.
        type: PlutoColumnType.select(conditionLabels),
        width: 150,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          // Usamos item_object para tener el enum real y mostrar el badge.
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
                      : Colors.grey.withValues(alpha: 0.5),
                );
              }
            : field.type == CustomFieldType.price
            ? (rendererContext) {
                final dynamic raw = rendererContext.cell.value;
                final double numVal =
                    double.tryParse(raw?.toString() ?? '') ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Tooltip(
                      message: numVal.toString(),
                      child: PriceDisplayWidget(
                        value: numVal,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }
            : null,
      );
    }).toList();

    return [
      ...baseColumns,
      ...customColumns,
      PlutoColumn(
        title: l10n.actionsColumnLabel,
        field: 'actions',
        type: PlutoColumnType.text(),
        enableSorting: false,
        enableFilterMenuItem: false,
        width: 180,
        renderer: (rendererContext) {
          final item =
              rendererContext.row.cells['item_object']!.value as InventoryItem;
          final isMobile = MediaQuery.sizeOf(context).width < 700;

          final actions = [
            _buildActionIconButton(
              icon: Icons.edit,
              color: Colors.blue,
              tooltip: l10n.edit,
              compact: isMobile,
              onPressed: () => _openAssetEdit(item),
            ),
            _buildActionIconButton(
              icon: Icons.copy,
              color: Colors.orange,
              tooltip: l10n.copyItemSuffix,
              compact: isMobile,
              onPressed: () => _copyAsset(item),
            ),
            _buildActionIconButton(
              icon: Icons.print,
              color: Colors.green,
              tooltip: l10n.printLabel,
              compact: isMobile,
              onPressed: () => PrintLabelButton.showPreview(context, item),
            ),
            _buildActionIconButton(
              icon: Icons.delete,
              color: Colors.red,
              tooltip: l10n.delete,
              compact: isMobile,
              onPressed: () => _deleteAsset(item),
            ),
          ];

          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: actions),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required bool compact,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: compact ? 16 : 18, color: color),
      tooltip: tooltip,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      padding: EdgeInsets.all(compact ? 2 : 8),
      constraints: BoxConstraints(
        minWidth: compact ? 30 : 40,
        minHeight: compact ? 30 : 40,
      ),
      onPressed: onPressed,
    );
  }

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
        'serialNumber': PlutoCell(value: item.serialNumber ?? ''),
        'barcode': PlutoCell(value: item.barcode ?? ''),
        'marketValue': PlutoCell(value: item.marketValue.toString()),
        // El valor de la celda DEBE ser el string localizado del select
        // para que PlutoGrid pueda filtrar correctamente con el dropdown.
        'condition': PlutoCell(
          value: item.condition.getLocalizedString(context),
        ),
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
                      AppLocalizations.of(context)!.imageLoadError,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      AppLocalizations.of(context)!.imageUrlHint,
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final scrollbarThickness = isMobile ? 14.0 : 12.0;
    final scrollbarThicknessWhileDragging = isMobile ? 16.0 : 14.0;
    final scheme = Theme.of(context).colorScheme;
    final scrollbarColor = scheme.primary.withValues(alpha: 0.95);
    final scrollbarTrackColor = scheme.outline.withValues(alpha: 0.5);

    return PlutoGrid(
      columns: columns,
      rows: _initialRows,
      onLoaded: (event) {
        stateManager = event.stateManager;
        stateManager?.setShowColumnFilter(true);
        final rows = _buildRows(widget.items);
        stateManager?.appendRows(rows);
      },
      onRowDoubleTap: (event) {
        final item = event.row.cells['item_object']!.value as InventoryItem;
        _openAssetDetail(item);
      },
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBorderColor: Colors.transparent,
          columnTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
          draggableScrollbar: true,
          onlyDraggingThumb: false,
          scrollbarThickness: scrollbarThickness,
          scrollbarThicknessWhileDragging: scrollbarThicknessWhileDragging,
          crossAxisMargin: isMobile ? 12 : 10,
          mainAxisMargin: 6,
          scrollBarColor: scrollbarColor,
          scrollBarTrackColor: scrollbarTrackColor,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.none,
        ),
      ),
      createFooter: (stateManager) {
        stateManager.setPageSize(10, notify: false);
        return PlutoPaginationFooter(stateManager: stateManager);
      },
    );
  }
}
