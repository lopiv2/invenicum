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
    // Usamos .read()
    final containerProvider = context.read<ContainerProvider>();
    final itemProvider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId);

    if (cIdInt == null) return;

    // 1. CARGAR CONTENEDORES SI ES NECESARIO (AWAIT)
    // Es posible que necesitemos esperar a que la lista de contenedores se llene.
    // Si la lista está vacía Y el proveedor NO está ya cargando...
    if (containerProvider.containers.isEmpty && !containerProvider.isLoading) {
      try {
        // 🛑 Esperamos la carga de los contenedores
        await containerProvider.loadContainers();
        // En este punto, loadContainers DEBE haber llamado a notifyListeners()
        // lo que causaría una reconstrucción. Pero como estamos usando .read(),
        // la reconstrucción no se detiene aquí.
      } catch (e) {
        // Manejar error de carga
        return;
      }
      if (!mounted) return;
    }

    // 2. BUSCAR el contenedor después de la carga
    // Volvemos a leer el provider para obtener el estado MÁS RECIENTE.
    // Como el build() se ejecuta de nuevo después de la carga, la búsqueda es segura.
    final ContainerNode? container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

    // 3. Iniciar la carga de ítems para cada AssetType
    if (!mounted) return;
    if (container != null) {
      for (var assetType in container.assetTypes) {
        // Llama a la carga de ítems, que llamará a notifyListeners()
        // en el InventoryItemProvider cuando termine.
        itemProvider.loadInventoryItems(
          containerId: cIdInt,
          assetTypeId: assetType.id,
        );
      }
    }
  }

  // ... (El resto del código _AssetTypeGridScreenState se mantiene igual) ...
  // incluyendo los métodos _goToCreateAssetType, _goToAssetList y el método build

  void _goToCreateAssetType(BuildContext context) {
    context.go('/container/${widget.containerId}/asset-types/new');
  }

  void _goToAssetList(BuildContext context, AssetType assetType) {
    context.go(
      '/container/${widget.containerId}/asset-types/${assetType.id}/assets',
    );
  }

  @override
  Widget build(BuildContext context) {
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
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text('Contenedor con ID ${widget.containerId} no encontrado.'),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
