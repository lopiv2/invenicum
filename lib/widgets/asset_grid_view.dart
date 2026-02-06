// widgets/asset_grid_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/environment.dart'; // 💡 NECESARIO para construir la URL de la imagen
import '../../models/asset_type_model.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_item_provider.dart';
import '../../services/toast_service.dart';

// 🔑 CAMBIO: Convertimos a StatefulWidget para manejar el estado del slider
class AssetGridView extends StatefulWidget {
  final AssetType assetType;
  final List<InventoryItem> items;
  final int containerId;
  final int assetTypeId;

  const AssetGridView({
    super.key,
    required this.assetType,
    required this.items,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  State<AssetGridView> createState() => _AssetGridViewState();
}

class _AssetGridViewState extends State<AssetGridView> {
  // 🔑 ESTADO: Número de columnas deseado, inicializado en 4
  int _columnsCount = 4;
  final int minColumns = 3;
  final int maxColumns = 10;

  void _viewAssetDetails(BuildContext context, InventoryItem item) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}',
    );
  }

  // --- FUNCIONES DE ACCIÓN (Ahora usan widget. para acceder a las propiedades) ---

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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Deseas eliminar el activo "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<InventoryItemProvider>().deleteInventoryItem(
                item.id,
                widget.containerId,
                widget.assetTypeId,
              );
              ToastService.success('Activo "${item.name}" eliminado.');
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Función de utilidad para construir la URL completa de la imagen
  String _getFullImageUrl(InventoryItem item) {
    final String? imageUrl = item.images.isNotEmpty
        ? item.images.first.url
        : null;
    return imageUrl != null ? '${Environment.apiUrl}$imageUrl' : '';
  }

  // Lógica del GridView (separada para mayor claridad)
  Widget _buildGridView(BuildContext context, double maxCrossAxisExtent) {
    const double fixedCardHeight = 170.0;
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      // 🔑 Usamos el ancho calculado.
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        // El childAspectRatio puede necesitar un pequeño ajuste si el ancho se reduce mucho
        mainAxisExtent: fixedCardHeight,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final fullImageUrl = _getFullImageUrl(item);
        final hasImage = fullImageUrl.isNotEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _viewAssetDetails(context, item),
          child: Card(
            elevation: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. CONTENEDOR DE IMAGEN (Miniatura)
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                      color: Colors.grey.shade100,
                    ),
                    child: hasImage
                        ? Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.inventory,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),

                // 2. CONTENIDO DEL TEXTO Y ACCIONES
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila de Título y Acciones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botones de acción
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: 'Editar',
                                  onPressed: () => _editAsset(context, item),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Eliminar',
                                  onPressed: () => _deleteAsset(context, item),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Descripción
                        Text(
                          item.description ?? 'Sin descripción',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                        const Divider(height: 12),

                        // Mostrar los dos primeros campos personalizados clave
                        ...widget.assetType.fieldDefinitions.take(2).map((def) {
                          final value =
                              item.customFieldValues?[def.id.toString()] ?? '—';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Text(
                                  '${def.name}: ',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Flexible(
                                  child: Text(
                                    value.toString(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<InventoryItemProvider>();

    if (widget.items.isEmpty) {
      return Center(
        child: Text(
          (itemProvider.filters.isEmpty &&
                  itemProvider.globalSearchTerm == null)
              ? 'No hay activos creados aún.'
              : 'Ningún activo coincide con los criterios de búsqueda/filtro.',
        ),
      );
    }

    // 🔑 La CLAVE: Usamos Column para el Slider + Grid, pero el Grid
    // debe estar en un Expanded para evitar el overflow.
    return Column(
      children: [
        // --- SLIDER DE CONTROL ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.grid_view, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                'Columnas: $_columnsCount',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _columnsCount.toDouble(),
                  min: minColumns.toDouble(),
                  max: maxColumns.toDouble(),
                  divisions: maxColumns - minColumns,
                  label: '$_columnsCount columnas',
                  onChanged: (double newValue) {
                    setState(() {
                      _columnsCount = newValue.round();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // --- GRID VIEW DENTRO DE EXPANDED ---
        // 🔑 Envuelve el LayoutBuilder (que contiene el GridView) en Expanded.
        LayoutBuilder(
          builder: (context, constraints) {
            // Cálculo del ancho máximo necesario para forzar 'N' columnas
            final calculatedExtent = constraints.maxWidth / _columnsCount;

            // La propiedad 'primary: true' en GridView.builder es importante
            // para que maneje su propio scroll.
            return _buildGridView(context, calculatedExtent);
          },
        ),
      ],
    );
  }
}
