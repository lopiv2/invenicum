// lib/screens/asset_type_grid_screen.dart (como un widget privado en el mismo archivo)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/asset_type_model.dart';

class AssetTypeCard extends StatelessWidget {
  final String containerId;
  final AssetType assetType;
  final int assetCount;

  const AssetTypeCard({
    required this.containerId,
    required this.assetType,
    required this.assetCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 3. Lógica de Navegación al hacer clic
          // Navegar a: /container/:containerId/asset-types/:assetTypeId/assets
          context.go(
            '/container/$containerId/asset-types/${assetType.id}/assets',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nombre del Tipo de Activo
                  Flexible(
                    child: Text(
                      assetType.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.inventory_2_outlined, color: Colors.indigo),
                ],
              ),
              
              // Número de activos (Placeholder, necesitarás una API para el conteo real)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$assetCount Activos',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  // Muestra la categoría asociada (si existe)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}