import 'package:flutter/material.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/config/environment.dart';

class AssetTypeCard extends StatelessWidget {
  final String containerId;
  final AssetType assetType;
  final int assetCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const AssetTypeCard({
    super.key,
    required this.containerId,
    required this.assetType,
    required this.assetCount,
    this.onTap,
    this.onEdit,
  });

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Text(
                '¿Estás seguro de que deseas eliminar el tipo de activo "${assetType.name}" y todos sus elementos asociados? Esta acción no se puede deshacer.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _handleDelete(BuildContext context) async {
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (confirmed) {
      try {
        await context.read<ContainerProvider>().deleteAssetType(
          int.parse(containerId),
          assetType.id,
        );
        if (context.mounted) {
          ToastService.success(
            'Tipo de Activo "${assetType.name}" eliminado con éxito.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          ToastService.error('Error al eliminar ${assetType.name}: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = assetType.images.isNotEmpty
        ? assetType.images.first.url
        : null;
    final fullImageUrl = imageUrl != null
        ? '${Environment.apiUrl}$imageUrl'
        : '';
    final hasImage = fullImageUrl.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            // Contenedor de imagen
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.07,
                height: MediaQuery.of(context).size.height * 0.15,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Columna izquierda: Título y contador
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            assetType.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$assetCount Activos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Columna derecha: Iconos y botones
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔑 BOTÓN DE EDITAR
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blueGrey,
                          ),
                          onPressed: onEdit, // Usar el nuevo callback
                          tooltip: 'Editar tipo de activo',
                        ),

                        // BOTÓN DE ELIMINAR
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _handleDelete(context),
                          tooltip: 'Eliminar tipo de activo',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
