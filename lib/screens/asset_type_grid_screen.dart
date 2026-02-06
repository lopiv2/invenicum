// lib/screens/asset_type_grid_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/widgets/asset_type_card.dart';
import '../providers/container_provider.dart';
import '../models/container_node.dart';

class AssetTypeGridScreen extends StatefulWidget {
  final String containerId;
  const AssetTypeGridScreen({super.key, required this.containerId});
  @override
  State<AssetTypeGridScreen> createState() => _AssetTypeGridScreenState();
}

class _AssetTypeGridScreenState extends State<AssetTypeGridScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      // 🎯 CAMBIO CLAVE: Usamos Future.microtask para iniciar la carga asíncrona
      // Esto se ejecuta inmediatamente después de que las dependencias cambian y el contexto está listo.
      Future.microtask(() => _loadInitialAssetCounts());
      _isInit = true;
    }
  }

  Future<void> _loadInitialAssetCounts() async {
  final containerProvider = context.read<ContainerProvider>();
  final itemProvider = context.read<InventoryItemProvider>();
  final cIdInt = int.tryParse(widget.containerId);

  if (cIdInt == null) return;

  // 1. Forzar la carga si no hay contenedores
  if (containerProvider.containers.isEmpty) {
    await containerProvider.loadContainers();
  }

  if (!mounted) return;

  // 2. Buscar el contenedor después de asegurar la carga
  final container = containerProvider.containers
      .where((c) => c.id == cIdInt)
      .firstOrNull;

  // 3. Cargar los contadores
  if (container != null) {
    for (var assetType in container.assetTypes) {
      // Importante: No esperes (await) aquí para que carguen en paralelo,
      // pero asegúrate de que el provider sepa gestionar llamadas múltiples.
      itemProvider.loadInventoryItems(
        containerId: cIdInt,
        assetTypeId: assetType.id,
      );
    }
  }
}

  void _goToCreateAssetType(BuildContext context) {
    context.go('/container/${widget.containerId}/asset-types/new');
  }

  void _goToAssetList(BuildContext context, AssetType assetType) {
    context.go(
      '/container/${widget.containerId}/asset-types/${assetType.id}/assets',
    );
  }

  void _goToEditAssetType(BuildContext context, AssetType assetType) {
    context.go(
      '/container/${widget.containerId}/asset-types/${assetType.id}/edit',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🎨 Tu tema personalizado
    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();

    final containerIdInt = int.tryParse(widget.containerId);

    if (containerIdInt == null) {
      return const Center(child: Text('Error: ID de contenedor inválido.'));
    }

    // Buscar el contenedor
    final ContainerNode? container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == containerIdInt, orElse: () => null);

    if (container == null) {
      // 🎯 Mostrar indicador de carga si los contenedores aún no están listos
      if (containerProvider.isLoading) {
        return Center(
          child: CircularProgressIndicator(
            color:
                theme.primaryColor, // 👈 Usa tu color (Esmeralda, Cereza, etc.)
          ),
        );
      }
      return Center(
        child: Text(
          'Contenedor con ID ${widget.containerId} no encontrado.',
          style: TextStyle(
            color: theme.colorScheme.error,
          ), // Texto en color de error del tema
        ),
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
              Text(
                'Tipos de Activo en "${container.name}"',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme
                      .colorScheme
                      .onSurface, // Se adapta a fondo claro/oscuro
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _goToCreateAssetType(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Crear Nuevo Tipo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainer, // 👈 Color del tema
                  foregroundColor: theme
                      .colorScheme
                      .onSurface, // Texto legible sobre el color
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (assetTypes.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Aún no hay Tipos de Activo definidos en este contenedor.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 160, // Altura fija para las tarjetas
                ),
                itemCount: assetTypes.length,
                itemBuilder: (context, index) {
                  final assetType = assetTypes[index];

                  final assetCount = itemProvider.getItemCountForAssetType(
                    containerIdInt, // O widget.containerId
                    assetType.id,
                  );

                  return AssetTypeCard(
                    containerId: widget.containerId,
                    assetType: assetType,
                    assetCount: assetCount,
                    onTap: () => _goToAssetList(context, assetType),
                    onEdit: () => _goToEditAssetType(context, assetType),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
