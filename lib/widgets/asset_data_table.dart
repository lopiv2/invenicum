// widgets/asset_data_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:provider/provider.dart';

import '../../models/inventory_item.dart';
import '../../models/asset_type_model.dart';
import '../../providers/inventory_item_provider.dart';
import '../../services/toast_service.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = context.read<InventoryItemProvider>();
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

    void applyFilter(String value) {
      itemProvider.setFilter(filterKey, value);
      itemProvider.goToPage(1);
      context.pop();
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
                  itemProvider.goToPage(1);
                  Navigator.of(dialogContext).pop();
                  localFilterController.dispose();
                },
                child: const Text(
                  'Borrar Filtro',
                  style: TextStyle(color: Colors.red),
                ),
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

  // 💡 NUEVO MÉTODO: Muestra un diálogo con la imagen en grande
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
              // Permite hacer zoom y pan en la imagen
              clipBehavior: Clip
                  .none, // Importante para que no recorte el contenido al hacer pan
              minScale: 0.1,
              maxScale: 4.0,
              child: Image.network(
                fullImageUrl,
                fit: BoxFit
                    .contain, // La imagen se ajustará al espacio disponible
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

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<InventoryItemProvider>();
    final inventoryItems = widget.inventoryItems;

    return DataTable2(
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
            _sortItems(
              context,
              1,
              'name',
              ascending,
            ); // Índice de columna correcto
          },
        ),
        DataColumn2(
          label: _buildFilterHeader(context, 'Descripción', 'description'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            _sortItems(
              context,
              2,
              'description',
              ascending,
            ); // Índice de columna correcto
          },
        ),
        ...widget.assetType.fieldDefinitions.asMap().entries.map((entry) {
          final columnIndex = entry.key + 3;
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
          label: Center(
            child: Text(
              'Acciones',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          size: ColumnSize.S,
        ),
      ],

      rows: inventoryItems.map((item) {
        final String? imageUrl = item.images.isNotEmpty
            ? item.images.first.url
            : null;

        // 💡 CONSTRUCCIÓN CORRECTA DE LA URL
        final String fullImageUrl = imageUrl != null
            ? '${Environment.apiUrl}$imageUrl'
            : ''; // Si no hay imagen, string vacío

        print('Cargando imagen para item ID ${item.id}: $fullImageUrl');

        final List<DataCell> cells = [
          DataCell(
            Center(
              child: Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                // 💡 ENVOLVEMOS LA IMAGEN CON MÁS LÓGICA
                child: imageUrl != null
                    ? Tooltip(
                        message: 'Ver imagen',
                        child: MouseRegion(
                          // Para cambiar el cursor al pasar el ratón
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            // Para detectar el tap
                            onTap: () =>
                                _showImageDialog(context, fullImageUrl),
                            child: Image.network(
                              fullImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    size: 25,
                                    color: Colors.grey,
                                  ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 25,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),
          DataCell(Text(item.name)),
          DataCell(
            Text(
              item.description ?? '—',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ];

        for (final fieldDef in widget.assetType.fieldDefinitions) {
          final fieldValue =
              item.customFieldValues[fieldDef.id.toString()] ?? '—';
          cells.add(
            DataCell(
              Text(
                fieldValue.toString(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }

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
