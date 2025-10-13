import 'package:flutter/material.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';

class AssetTypeCard extends StatelessWidget {
  final String containerId;
  final AssetType assetType;
  final int assetCount;
  final VoidCallback? onTap;

  const AssetTypeCard({
    super.key,
    required this.containerId,
    required this.assetType,
    required this.assetCount,
    this.onTap,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${assetType.name} ha sido eliminado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar ${assetType.name}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Columna derecha: Iconos y botones
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 8),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
