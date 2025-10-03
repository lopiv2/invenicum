// widgets/asset_data_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/inventory_item.dart';
import '../../models/asset_type_model.dart';
import '../../providers/inventory_item_provider.dart';
import '../../services/toast_service.dart';

class AssetDataTable extends StatefulWidget {
  final AssetType assetType;
  final int containerId;
  final int assetTypeId;
  // Recibe la lista ya paginada desde AssetListScreen
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
  
  // ESTADO DE ORDENAMIENTO (para la UI de DataTabe2)
  int? _sortColumnIndex = 0; // Por defecto: Nombre (Index 0)
  bool _sortAscending = true;

  // Sincroniza el estado local con el Provider al inicializar
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = context.read<InventoryItemProvider>();
      // Asume que 'name' es la clave inicial de ordenamiento si no hay otra definida
      final currentSortKey = itemProvider.sortKey; 
      
      // Determina el índice de la columna de ordenamiento
      int index = -1;
      if (currentSortKey == 'name') {
        index = 0;
      } else if (currentSortKey == 'description') {
        index = 1;
      } else {
        // Busca el índice de la columna dinámica
        final customIndex = widget.assetType.fieldDefinitions.indexWhere(
          (def) => def.id.toString() == currentSortKey,
        );
        if (customIndex != -1) {
          index = customIndex + 2; // +2 por Nombre y Descripción
        }
      }

      if (index != -1) {
        setState(() {
          _sortColumnIndex = index;
          _sortAscending = itemProvider.sortAscending;
        });
      }
    });
  }


  // --- LÓGICA DE ORDENAMIENTO (Sorting) ---

  void _sortItems(
    BuildContext context,
    int columnIndex,
    String dataKey,
    bool ascending,
  ) {
    // 1. Actualizar el estado de la UI (para que DataTabe2 muestre la flecha)
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    // 2. Notificar al Provider para que reordene la lista interna y vuelva a la página 1
    final itemProvider = context.read<InventoryItemProvider>();
    itemProvider.sortInventoryItems(
      dataKey: dataKey,
      ascending: ascending,
    );
    itemProvider.goToPage(1);
  }
  
  // --- FUNCIONES DE ACCIÓN ---
  
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
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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

  // --- LÓGICA DE FILTROS POR COLUMNA ---

  void _showFilterDialog(
    BuildContext context,
    String headerText,
    String filterKey,
  ) {
    final itemProvider = context.read<InventoryItemProvider>();
    final localFilterController = TextEditingController(
      text: itemProvider.filters[filterKey] ?? '',
    );

    void applyFilter(String value) {
      itemProvider.setFilter(filterKey, value);
      itemProvider.goToPage(1); // Volver a la página 1 al aplicar filtro
      Navigator.of(context).pop();
      localFilterController.dispose();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Filtrar por $headerText'),
          content: TextField(
            controller: localFilterController,
            decoration: const InputDecoration(
              labelText: 'Escribe el valor a buscar',
            ),
            autofocus: true,
            onSubmitted: applyFilter,
          ),
          actions: [
            if (itemProvider.filters.containsKey(filterKey))
              TextButton(
                onPressed: () {
                  itemProvider.setFilter(filterKey, null);
                  itemProvider.goToPage(1); // Volver a la página 1 al borrar
                  Navigator.of(dialogContext).pop();
                  localFilterController.dispose();
                },
                child: const Text('Borrar Filtro', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => applyFilter(localFilterController.text),
              child: const Text('Aplicar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                localFilterController.dispose();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // WIDGET DE CABECERA DE FILTRO
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
    // Usamos la lista paginada que nos pasa el widget padre
    final inventoryItems = widget.inventoryItems; 

    return DataTable2(
      minWidth: 800,
      columnSpacing: 12,
      horizontalMargin: 12,
      dataRowHeight: 50,
      
      // PROPIEDADES DE ORDENAMIENTO
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,

      empty: Center(
        child: Text(
          (itemProvider.filters.isEmpty && itemProvider.globalSearchTerm == null)
              ? 'No hay activos creados aún.'
              : 'Ningún activo coincide con los criterios de búsqueda/filtro.',
        ),
      ),
      columns: [
        // Columna 0: Nombre
        DataColumn2(
          label: _buildFilterHeader(context, 'Nombre', 'name'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            _sortItems(context, 0, 'name', ascending);
          },
        ),
        // Columna 1: Descripción
        DataColumn2(
          label: _buildFilterHeader(
            context,
            'Descripción',
            'description',
          ),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            _sortItems(context, 1, 'description', ascending);
          },
        ),
        // Columnas Dinámicas de Campos Personalizados
        ...widget.assetType.fieldDefinitions.asMap().entries.map((entry) {
          final columnIndex = entry.key + 2; // +2 por Nombre y Descripción
          final fieldDef = entry.value;
          final filterKey = fieldDef.id.toString();

          return DataColumn2(
            label: _buildFilterHeader(
              context,
              fieldDef.name,
              filterKey,
            ),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              _sortItems(
                context,
                columnIndex,
                filterKey,
                ascending,
              );
            },
          );
        }).toList(),
        // Columna Acciones (Sin ordenamiento)
        const DataColumn2(
          label: Center(
            child: Text(
              'Acciones',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          size: ColumnSize.S,
        ),
      ],

      // CREACIÓN DINÁMICA DE FILAS
      rows: inventoryItems.map((item) {
        final List<DataCell> cells = [
          DataCell(Text(item.name)),
          DataCell(
            Text(
              item.description ?? '—',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ];

        // Añadir celdas de campos personalizados
        for (final fieldDef in widget.assetType.fieldDefinitions) {
          final fieldValue =
              item.customFieldValues[fieldDef.id.toString()] ?? '—';
          cells.add(DataCell(
            Text(
              fieldValue.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ));
        }

        // Añadir celda de acciones
        cells.add(
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: 'Editar',
                  onPressed: () => _editAsset(context, item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red[600],
                  tooltip: 'Eliminar',
                  onPressed: () => _deleteAsset(context, item),
                ),
              ],
            ),
          ),
        );

        return DataRow(cells: cells);
      }).toList(),
    );
  }
}