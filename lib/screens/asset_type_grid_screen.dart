// lib/screens/asset_type_grid_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/widgets/asset_type_card.dart';
import '../providers/container_provider.dart';

class AssetTypeGridScreen extends StatefulWidget {
  final String containerId;
  const AssetTypeGridScreen({super.key, required this.containerId});

  @override
  State<AssetTypeGridScreen> createState() => _AssetTypeGridScreenState();
}

class _AssetTypeGridScreenState extends State<AssetTypeGridScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ CLAVE 1: Ejecutar la carga después del renderizado inicial una sola vez.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialAssetCounts();
      }
    });
  }

  Future<void> _loadInitialAssetCounts() async {
    final containerProvider = context.read<ContainerProvider>();
    final itemProvider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId);

    if (cIdInt == null) return;

    // 1. Forzar la carga de la lista maestra si está vacía
    if (containerProvider.containers.isEmpty) {
      await containerProvider.loadContainers();
    }

    if (!mounted) return;

    // 2. IMPORTANTE: Buscar el contenedor DESPUÉS de asegurar que la lista existe
    final container = containerProvider.containers
        .where((c) => c.id == cIdInt)
        .firstOrNull;

    if (container != null) {
      // 3. Cargar los items para cada tipo de activo
      // Usamos Future.wait para que las cargas sean paralelas
      await Future.wait(
        container.assetTypes.map(
          (assetType) => itemProvider.loadInventoryItems(
            containerId: cIdInt,
            assetTypeId: assetType.id,
          ),
        ),
      );
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
    final theme = Theme.of(context);
    // ✅ watch() aquí es correcto para reaccionar a cambios de datos,
    // siempre que no disparemos lógica de carga aquí dentro.
    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();

    final containerIdInt = int.tryParse(widget.containerId);
    if (containerIdInt == null) {
      return const Center(child: Text('Error: ID de contenedor inválido.'));
    }

    // Buscar el contenedor de forma segura
    final container = containerProvider.containers
        .where((c) => c.id == containerIdInt)
        .firstOrNull;

    if (container == null) {
      if (containerProvider.isLoading) {
        return Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        );
      }
      return Center(
        child: Text(
          'Contenedor con ID ${widget.containerId} no encontrado.',
          style: TextStyle(color: theme.colorScheme.error),
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
                  color: theme.colorScheme.onSurface,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _goToCreateAssetType(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Crear Nuevo Tipo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  foregroundColor: theme.colorScheme.onSurface,
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
                  mainAxisExtent: 160,
                ),
                itemCount: assetTypes.length,
                itemBuilder: (context, index) {
                  final assetType = assetTypes[index];
                  final assetCount = itemProvider.getItemCountForAssetType(
                    containerIdInt,
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
