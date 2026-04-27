// lib/screens/asset_type_grid_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_badge.dart';
import 'package:provider/provider.dart';

import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_card.dart';
import '../../providers/container_provider.dart';

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
    context.goNamed(
      RouteNames.assetTypeCreate,
      pathParameters: {'containerId': widget.containerId},
    );
  }

  void _goToAssetList(BuildContext context, AssetType assetType) {
    context.goNamed(
      RouteNames.assetList,
      pathParameters: {
        'containerId': widget.containerId,
        'assetTypeId': assetType.id.toString(),
      },
    );
  }

  void _goToEditAssetType(BuildContext context, AssetType assetType) {
    context.goNamed(
      RouteNames.assetTypeEdit,
      pathParameters: {
        'containerId': widget.containerId,
        'assetTypeId': assetType.id.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // ✅ watch() aquí es correcto para reaccionar a cambios de datos,
    // siempre que no disparemos lógica de carga aquí dentro.
    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();

    final containerIdInt = int.tryParse(widget.containerId);
    if (containerIdInt == null) {
      return Center(child: Text(l10n.invalidContainerIdError));
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
          l10n.containerNotFoundError(widget.containerId),
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }

    final assetTypes = container.assetTypes;

    return Padding(
      padding: EdgeInsets.all(screenWidth > 600 ? 24.0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header responsive
          if (screenWidth > 600)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      Text(
                        l10n.assetTypesInContainer(container.name),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      AssetTypeBadge(isCollection: container.isCollection,),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _goToCreateAssetType(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(l10n.createNewTypeButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      l10n.assetTypesInContainer(container.name),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    AssetTypeBadge(isCollection: container.isCollection,),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _goToCreateAssetType(context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.createNewTypeButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          // COLOR LEGENDS
          const SizedBox(height: 20),
          if (assetTypes.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l10n.noAssetTypesMessage,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenWidth > 900
                      ? 420
                      : (screenWidth > 600 ? 320 : 220),
                  crossAxisSpacing: screenWidth > 600 ? 20 : 12,
                  mainAxisSpacing: screenWidth > 600 ? 20 : 12,
                  mainAxisExtent: screenWidth > 600 ? 165 : 130,
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
                    isCollection: containerProvider.containers
                        .firstWhere((c) => c.id == containerIdInt)
                        .isCollection,
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
