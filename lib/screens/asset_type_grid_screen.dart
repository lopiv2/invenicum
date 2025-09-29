// lib/screens/asset_type_grid_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // NECESARIO para la navegación
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/widgets/asset_type_card.dart';
import 'package:provider/provider.dart';
import '../providers/container_provider.dart';
import '../models/container_node.dart';

class AssetTypeGridScreen extends StatelessWidget {
  final String containerId;

  const AssetTypeGridScreen({super.key, required this.containerId});

  // Método de acción para redirigir a la pantalla de creación
  void _goToCreateAssetType(BuildContext context) {
    // La ruta debe ser algo como: /container/123/asset-types/new
    context.go('/container/$containerId/asset-types/new');
  }

  void _goToAssetList(BuildContext context, AssetType assetType) {
    context.go('/container/$containerId/asset-types/${assetType.id}/assets');
  }

  @override
  Widget build(BuildContext context) {
    final containerProvider = context.watch<ContainerProvider>();
    final containerIdInt = int.tryParse(containerId);

    if (containerIdInt == null) {
      return const Center(child: Text('Error: ID de contenedor inválido.'));
    }

    final ContainerNode? container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == containerIdInt, orElse: () => null);

    if (container == null) {
      if (containerProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text('Contenedor con ID $containerId no encontrado.'),
      );
    }

    final assetTypes = container.assetTypes;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título dinámico
              Text(
                'Tipos de Activo en "${container.name}"',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // >>> BOTÓN DE CREAR NUEVO TIPO DE ACTIVO <<<
              ElevatedButton.icon(
                onPressed: () => _goToCreateAssetType(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Crear Nuevo Tipo'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (assetTypes.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Aún no hay Tipos de Activo definidos en este contenedor.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            // GridView para mostrar los tipos de activo
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: assetTypes.length,
                itemBuilder: (context, index) {
                  final assetType = assetTypes[index];
                  return AssetTypeCard(
                    containerId: containerId,
                    assetType: assetType,
                    assetCount: 0,
                    onTap: () => _goToAssetList(context, assetType),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
