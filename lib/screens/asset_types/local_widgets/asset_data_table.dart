// widgets/asset_data_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/widgets/ui/print_label_button_widget.dart';
import 'package:provider/provider.dart';

import '../../../data/models/inventory_item.dart';
import '../../../data/models/asset_type_model.dart';
import '../../../../providers/inventory_item_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../../data/models/data_source_table.dart';

class AssetDataTable extends StatefulWidget {
  final AssetType assetType;
  final int containerId;
  final int assetTypeId;
  final List<InventoryItem> inventoryItems;
  final List<Location> availableLocations;

  const AssetDataTable({
    super.key,
    required this.assetType,
    required this.containerId,
    required this.assetTypeId,
    required this.inventoryItems,
    required this.availableLocations,
  });

  @override
  State<AssetDataTable> createState() => _AssetDataTableState();
}

class _AssetDataTableState extends State<AssetDataTable> {
  int? _sortColumnIndex = 1;
  bool _sortAscending = true;
  InventoryDataSource? _dataSource;
  List<InventoryItem> _lastUpdateItemList = [];
  late double _dynamicMinWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final itemProvider = context.read<InventoryItemProvider>();
    final preferencesProvider = context.read<PreferencesProvider>();

    // 🔑 Inicializar UNA VEZ
    _dataSource ??= InventoryDataSource(
      itemProvider: itemProvider,
      preferencesProvider: preferencesProvider,
      assetType: widget.assetType,
      items: widget.inventoryItems,
      context: context,
      deleteCallback: (item) => _deleteAsset(context, item),
      editCallback: (item) => _editAsset(context, item),
      copyCallback: (item) => _copyAsset(context, item),
      printLabelCallback: (item) => _printLabel(context, item),
      onRowTap: (item) => context.go(
        '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}',
      ),
      availableLocations: widget.availableLocations,
      containerId: widget.containerId,
    );

    if (!identical(widget.inventoryItems, _lastUpdateItemList)) {
      _dataSource?.updateItems(widget.inventoryItems);
      _lastUpdateItemList = widget.inventoryItems;
    }
  }

  @override
  void didUpdateWidget(AssetDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔑 Actualizar SIEMPRE que cambien los items (incluyendo orden)
    // Comparar no solo si son referencias diferentes, sino también si el orden cambió
    bool itemsChanged =
        oldWidget.inventoryItems.length != widget.inventoryItems.length;

    if (!itemsChanged &&
        oldWidget.inventoryItems.isNotEmpty &&
        widget.inventoryItems.isNotEmpty) {
      // Comparar orden comparando los primeros elementos
      for (int i = 0; i < oldWidget.inventoryItems.length && i < 5; i++) {
        if (oldWidget.inventoryItems[i].id != widget.inventoryItems[i].id) {
          itemsChanged = true;
          break;
        }
      }
    }

    if (itemsChanged || oldWidget.assetTypeId != widget.assetTypeId) {
      _dataSource?.updateItems(widget.inventoryItems);
    }
  }

  @override
  void initState() {
    super.initState();
    _dynamicMinWidth =
      950 + (widget.assetType.fieldDefinitions.length * 180);
    // 1. Usamos read porque en initState solo queremos el valor inicial sin suscribirnos
    final itemProvider = context.read<InventoryItemProvider>();

    // 2. Restaurar el estado de ordenamiento visual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSortKey = itemProvider.sortKey;
      int index = -1;

      if (currentSortKey == 'name') {
        index = 1;
      } else if (currentSortKey == 'quantity') {
        index = 2;
      } else if (currentSortKey == 'minStock') {
        index = 3;
      } else if (currentSortKey == 'location') {
        index = 4;
      } else if (currentSortKey == 'condition') {
        index = 5;
      } else if (currentSortKey == 'description') {
        index = 6;
      } else if (currentSortKey == 'barcode') {
        index = 7;
      } else if (currentSortKey == 'marketValue') {
        index = 8;
      } else {
        final customIndex = widget.assetType.fieldDefinitions.indexWhere(
          (def) => def.id.toString() == currentSortKey,
        );
        if (customIndex != -1) index = customIndex + 7;
      }

      if (index != -1 && mounted) {
        setState(() {
          _sortColumnIndex = index;
          _sortAscending = itemProvider.sortAscending;
        });
      }
    });
  }

  void _sortItems(
    BuildContext context,
    int columnIndex,
    String dataKey,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    final itemProvider = context.read<InventoryItemProvider>();
    itemProvider.sortInventoryItems(dataKey: dataKey, ascending: ascending);
    itemProvider.goToPage(1); // Reset a pág 1 al ordenar
  }

  void _printLabel(BuildContext context, InventoryItem item) {
    // 🚀 Llama directamente a la vista previa del widget reutilizable
    PrintLabelButton.showPreview(context, item);
  }

  void _copyAsset(BuildContext context, InventoryItem item) async {
    final InventoryItem itemCopy = item.copyWith(
      id: 0,
      name: "${item.name} (Copia)",
      resetImageIds: true,
    );

    final itemProvider = context.read<InventoryItemProvider>();
    try {
      await itemProvider.cloneInventoryItem(itemCopy);
      ToastService.success('✅ Activo "${itemCopy.name}" copiado exitosamente.');
    } catch (e) {
      ToastService.error('❌ Error al copiar el activo: $e');
    }
  }

  void _editAsset(BuildContext context, InventoryItem item) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}/edit',
      extra: item,
    );
    ToastService.info('Editando activo: ${item.name} (ID: ${item.id})');
  }

  void _deleteAsset(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<InventoryItemProvider>().deleteInventoryItem(
                item.id,
                widget.containerId,
                widget.assetTypeId,
              );
              ToastService.success('Activo eliminado.');
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    String headerText,
    String filterKey,
  ) {
    final itemProvider = context.read<InventoryItemProvider>();
    final controller = TextEditingController(
      text: itemProvider.filters[filterKey] ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Filtrar por $headerText'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Valor a buscar'),
          autofocus: true,
          onSubmitted: (val) {
            itemProvider.setFilter(filterKey, val);
            itemProvider.goToPage(1);
            Navigator.pop(dialogContext);
          },
        ),
        actions: [
          if (itemProvider.filters.containsKey(filterKey))
            TextButton(
              onPressed: () {
                itemProvider.setFilter(filterKey, null);
                itemProvider.goToPage(1);
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Borrar Filtro',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () {
              itemProvider.setFilter(filterKey, controller.text);
              itemProvider.goToPage(1);
              Navigator.pop(dialogContext);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  Widget _buildFilterHeader(
    BuildContext context,
    String headerText,
    String filterKey,
  ) {
    final itemProvider = context.watch<InventoryItemProvider>();
    final isActive = itemProvider.filters.containsKey(filterKey);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            headerText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Theme.of(context).colorScheme.primary : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () => _showFilterDialog(context, headerText, filterKey),
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              size: 16, // Reducido de 18 a 16
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_dataSource == null) return const SizedBox.shrink();

    // 1. Escuchamos cambios en el provider
    final itemProvider = context.watch<InventoryItemProvider>();

    // 💡 CÁLCULO DINÁMICO DEL ANCHO
    final screenWidth = MediaQuery.of(context).size.width;
    if (_dynamicMinWidth < screenWidth) _dynamicMinWidth = screenWidth;

    // 🚀 OPTIMIZACIÓN: No actualizamos en build(), ya se hace en didUpdateWidget()

    return PaginatedDataTable2(
      autoRowsToHeight: true,
      wrapInCard: false,
      minWidth: _dynamicMinWidth,
      columnSpacing: 12,
      horizontalMargin: 12,
      dataRowHeight: 60,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,

      // 3. 🔑 Sincronizar página visual con el estado del Provider
      initialFirstRowIndex:
          (itemProvider.currentPage - 1) * itemProvider.itemsPerPage,

      empty: Center(
        child: Text(
          (itemProvider.filters.isEmpty &&
                  itemProvider.globalSearchTerm == null)
              ? 'No hay activos creados aún.'
              : 'Ningún activo coincide con los criterios.',
        ),
      ),
      columns: [
        const DataColumn2(
          label: Center(child: Icon(Icons.photo_library_outlined, size: 20)),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Nombre', 'name'),
          size: ColumnSize.M,
          onSort: (idx, asc) => _sortItems(context, idx, 'name', asc),
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Stock actual', 'quantity'),
          size: ColumnSize.M,
          onSort: (idx, asc) => _sortItems(context, idx, 'quantity', asc),
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Stock minimo', 'minStock'),
          size: ColumnSize.M,
          onSort: (idx, asc) => _sortItems(context, idx, 'minStock', asc),
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Ubicación', 'location'),
          size: ColumnSize.M,
          onSort: (idx, asc) => _sortItems(context, idx, 'location', asc),
        ),
        DataColumn2(
          label: Text(
            'Condición',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          size: ColumnSize.M,
          onSort: (idx, asc) => _sortItems(context, idx, 'condition', asc),
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Descripción', 'description'),
          size: ColumnSize.L,
          onSort: (idx, asc) => _sortItems(context, idx, 'description', asc),
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Código de Barras', 'barcode'),
          size: ColumnSize.L,
          onSort: (idx, asc) => _sortItems(context, idx, 'barcode', asc),
        ),
        DataColumn2(
          label: _buildFilterHeader(
            context,
            'Precio de mercado',
            'marketValue',
          ),
          size: ColumnSize.L,
          onSort: (idx, asc) => _sortItems(context, idx, 'marketValue', asc),
        ),
        // Columnas dinámicas
        ...widget.assetType.fieldDefinitions.asMap().entries.map((entry) {
          final fieldDef = entry.value;
          final filterKey = fieldDef.id.toString();
          ColumnSize columnSize = ColumnSize.M;
          if (fieldDef.type == CustomFieldType.boolean ||
              fieldDef.type == CustomFieldType.number) {
            columnSize = ColumnSize.S; // Más estrecho para números o checks
          } else if (fieldDef.type == CustomFieldType.dropdown) {
            columnSize = ColumnSize.L; // Más ancho para desplegables
          }
          return DataColumn2(
            label: _buildFilterHeader(context, fieldDef.name, filterKey),
            size: columnSize,
            onSort: (idx, asc) => _sortItems(context, idx, filterKey, asc),
          );
        }),
        const DataColumn2(
          headingRowAlignment: MainAxisAlignment.center,
          label: Text(
            'Acciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          size: ColumnSize.M,
        ),
      ],
      rowsPerPage: itemProvider.itemsPerPage,
      onRowsPerPageChanged: (newValue) {
        if (newValue != null) itemProvider.setItemsPerPage(newValue);
      },
      onPageChanged: (pageIndex) {
        itemProvider.goToPage(pageIndex + 1);
      },
      source: _dataSource!,
    );
  }
}
