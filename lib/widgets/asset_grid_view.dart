// widgets/asset_grid_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/asset_type_model.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_item_provider.dart';
import '../../services/toast_service.dart';

class AssetGridView extends StatelessWidget {
  final AssetType assetType;
  // Recibe la lista ya paginada desde AssetListScreen
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

  // --- FUNCIONES DE ACCIÓN ---

  void _editAsset(BuildContext context, InventoryItem item) {
    context.go(
      '/container/$containerId/asset-types/$assetTypeId/assets/${item.id}/edit',
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
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<InventoryItemProvider>().deleteInventoryItem(
                    item.id,
                    containerId,
                    assetTypeId,
                  );
              ToastService.success('Activo "${item.name}" eliminado.');
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<InventoryItemProvider>();

    if (items.isEmpty) {
        return Center(
            child: Text(
              (itemProvider.filters.isEmpty && itemProvider.globalSearchTerm == null)
                ? 'No hay activos creados aún.'
                : 'Ningún activo coincide con los criterios de búsqueda/filtro.',
            ),
        );
    }
    
    return GridView.builder(
      // Usamos PrimaryScrollController para evitar problemas de scroll anidados con Card
      primary: true, 
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Se ajusta a 4 columnas por defecto
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 2.5, // Más ancho que alto
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Editar',
                          onPressed: () => _editAsset(context, item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          tooltip: 'Eliminar',
                          onPressed: () => _deleteAsset(context, item),
                        ),
                      ],
                    ),
                  ],
                ),
                // Descripción
                Text(
                  item.description ?? 'Sin descripción',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const Divider(height: 12),
                
                // Mostrar algunos campos personalizados clave
                ...assetType.fieldDefinitions.take(2).map((def) {
                    final value = item.customFieldValues[def.id.toString()] ?? '—';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Text('${def.name}: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          Flexible(
                            child: Text(
                              value.toString(), 
                              style: Theme.of(context).textTheme.bodySmall, 
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ],
                      ),
                    );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}