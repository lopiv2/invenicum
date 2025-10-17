// widgets/asset_data_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/inventory_item.dart';
import '../../models/asset_type_model.dart';
import '../../providers/inventory_item_provider.dart';
import '../../services/toast_service.dart';
import '../../models/data_source_table.dart'; // Asegúrate de que esta ruta sea correcta

class AssetDataTable extends StatefulWidget {
  final AssetType assetType;
  final int containerId;
  final int assetTypeId;
  final List<InventoryItem> inventoryItems;

  const AssetDataTable({
    super.key,
    required this.assetType,
    required this.containerId,
    required this.assetTypeId,
    required this.inventoryItems,
  });

  @override
  State<AssetDataTable> createState() => _AssetDataTableState();
}

class _AssetDataTableState extends State<AssetDataTable> {
  int? _sortColumnIndex = 1;
  bool _sortAscending = true;
  late InventoryDataSource _dataSource;
  late VoidCallback _providerListener;

  @override
  void initState() {
    super.initState();

    final itemProvider = context.read<InventoryItemProvider>();

    // 1. Inicializar el DataSource y el Listener
    // ------------------------------------------------------------------
    _dataSource = InventoryDataSource(
      itemProvider: itemProvider,
      assetType: widget.assetType,
      items: widget.inventoryItems,
      context: context,
      deleteCallback: (item) => _deleteAsset(context, item),
      editCallback: (item) => _editAsset(context, item),
    );

    _providerListener = () {
      // Usar el getter público 'inventoryItems' del provider
      _dataSource.updateItems(itemProvider.inventoryItems);
    };

    itemProvider.addListener(_providerListener);
    // ------------------------------------------------------------------

    // 2. Restaurar el estado de ordenamiento
    // ------------------------------------------------------------------
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSortKey = itemProvider.sortKey;

      int index = -1;
      if (currentSortKey == 'name') {
        index = 1;
      } else if (currentSortKey == 'description') {
        index = 2;
      } else {
        final customIndex = widget.assetType.fieldDefinitions.indexWhere(
          (def) => def.id.toString() == currentSortKey,
        );
        if (customIndex != -1) {
          index = customIndex + 3;
        }
      }

      if (index != -1) {
        setState(() {
          _sortColumnIndex = index;
          _sortAscending = itemProvider.sortAscending;
        });
      }
    });
    // ------------------------------------------------------------------
  }

  @override
  void dispose() {
    //context.read<InventoryItemProvider>().removeListener(_providerListener);
    super.dispose();
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
    itemProvider.goToPage(1);
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar el activo "${item.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final itemProvider = context.read<InventoryItemProvider>();

                itemProvider.deleteInventoryItem(
                  item.id,
                  widget.containerId,
                  widget.assetTypeId,
                );
                ToastService.success('Activo "${item.name}" eliminado.');
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(
    BuildContext context,
    String headerText,
    String filterKey,
  ) {
    final itemProvider = context.read<InventoryItemProvider>();
    final localFilterController = TextEditingController(
      text: itemProvider.filters[filterKey] ?? '',
    );

    // 🚨 Usamos showDialog().then(...) para asegurar la disposición del controller
    showDialog(
      context: context,
      builder: (dialogContext) {
        // 👈 Usamos dialogContext para cerrar el diálogo

        // Función para aplicar filtro, navegando a página 1, y cerrando el diálogo
        void applyFilterAndClose(String value) {
          itemProvider.setFilter(filterKey, value);
          itemProvider.goToPage(1);
          // Usamos el contexto del diálogo para cerrarlo
          Navigator.of(dialogContext).pop();
        }

        return AlertDialog(
          title: Text('Filtrar por $headerText'),
          content: TextField(
            controller: localFilterController,
            decoration: const InputDecoration(
              labelText: 'Escribe el valor a buscar',
            ),
            autofocus: true,
            onSubmitted: applyFilterAndClose,
          ),
          actions: [
            // Botón Borrar Filtro
            if (itemProvider.filters.containsKey(filterKey))
              TextButton(
                onPressed: () {
                  itemProvider.setFilter(filterKey, null);
                  itemProvider.goToPage(1);
                  Navigator.of(
                    dialogContext,
                  ).pop(); // 👈 Uso explícito de dialogContext
                },
                child: const Text(
                  'Borrar Filtro',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            // Botón Aplicar
            TextButton(
              onPressed: () => applyFilterAndClose(localFilterController.text),
              child: const Text('Aplicar'),
            ),
            // Botón Cancelar
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(), // 👈 Uso explícito de dialogContext
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    ).then((_) {
      // La disposición del controller sigue siendo correcta aquí
      localFilterController.dispose();
    });
  }

  Widget _buildFilterHeader(
    BuildContext context,
    String headerText,
    String filterKey,
  ) {
    final itemProvider = context.watch<InventoryItemProvider>();
    final isActive = itemProvider.filters.containsKey(filterKey);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
        IconButton(
          icon: Icon(
            isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
            size: 20,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
          ),
          tooltip: isActive ? 'Filtro activo' : 'Filtrar columna',
          onPressed: () => _showFilterDialog(context, headerText, filterKey),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<InventoryItemProvider>();

    final dataSource = _dataSource;

    // 1. Definición del DataTable2
    final dataTable = PaginatedDataTable2(
      minWidth: 900,
      columnSpacing: 12,
      horizontalMargin: 12,
      dataRowHeight: 60,
    
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
    
      empty: Center(
        child: Text(
          (itemProvider.filters.isEmpty &&
                  itemProvider.globalSearchTerm == null)
              ? 'No hay activos creados aún.'
              : 'Ningún activo coincide con los criterios de búsqueda/filtro.',
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
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            _sortItems(context, 1, 'name', ascending);
          },
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Descripción', 'description'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            _sortItems(context, 2, 'description', ascending);
          },
        ),
        ...widget.assetType.fieldDefinitions.asMap().entries.map((entry) {
          final fieldDef = entry.value;
          final filterKey = fieldDef.id.toString();
    
          return DataColumn2(
            label: _buildFilterHeader(context, fieldDef.name, filterKey),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              _sortItems(context, columnIndex, filterKey, ascending);
            },
          );
        }).toList(),
        const DataColumn2(
          label: Text(
            'Acciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          size: ColumnSize.S,
        ),
      ],
    
      // Configuración de paginación que interactúa con el Provider
      rowsPerPage: itemProvider.itemsPerPage,
      onRowsPerPageChanged: (int? newValue) {
        if (newValue != null) {
          itemProvider.setItemsPerPage(newValue);
        }
      },
      // El total de filas se obtiene del provider
      //rowCount: totalItems,
    
      // Control de página basado en el provider
      //pageToDisplay: itemProvider.currentPage - 1,
      onPageChanged: (int pageIndex) {
        // DataTable2 usa un índice base 0, tu provider usa base 1.
        itemProvider.goToPage(pageIndex + 1);
      },
    
      source: dataSource,
    );

    // 3. Devolvemos la tabla
    // Se elimina el Column envolvente, ya que la tabla debe ocupar el Expanded del padre.
    return dataTable;
  }
}
