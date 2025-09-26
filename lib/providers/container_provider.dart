// providers/container_provider.dart

import 'package:flutter/foundation.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/services/container_service.dart';

class ContainerProvider with ChangeNotifier {
  // Renombramos la variable a _containerService para mayor claridad.
  final ContainerService _containerService;

  ContainerProvider(this._containerService); // Recibe el ContainerService

  // 1. La variable de estado privada que almacena los datos
  List<ContainerNode> _containers = [];
  bool _isLoading = false;

  // 2. Getters públicos
  List<ContainerNode> get containers => _containers;
  bool get isLoading => _isLoading;

  // --- Lógica de Obtener Contenedores ---
  Future<void> loadContainers() async {
  _isLoading = true;
  notifyListeners(); // 1. Muestra la carga

  try {
    final loadedContainers = await _containerService.getContainers();
    _containers = loadedContainers;
  } catch (e) {
    print('Error al cargar contenedores: $e');
  } finally {
    _isLoading = false;
    notifyListeners(); // 2. Oculta la carga y muestra la lista (ya sea nueva o la antigua si falló).
  }
}

  // --- Lógica de Crear Contenedor ---
  Future<ContainerNode?> createNewContainer(
    String name,
    String? description,
  ) async {
    try {
      final newContainer = await _containerService.createContainer(name, description);
      await loadContainers();

      return newContainer;
    } catch (e) {
      print('Error al crear contenedor: $e');
      // Es vital que si el try falla, el error se propague para que el Sidebar lo maneje.
      rethrow; 
    }
  }

  Future<void> addNewAssetTypeToContainer({
    required int containerId,
    required AssetType newAssetType,
  }) async {
    // 1. Encontrar el índice del contenedor
    final index = _containers.indexWhere((c) => c.id == containerId);

    if (index == -1) {
      print('Error: Contenedor con ID $containerId no encontrado para añadir AssetType.');
      return;
    }

    // 2. Obtener el contenedor original
    final originalContainer = _containers[index];
    
    // Clonar la lista de assetTypes y añadir el nuevo elemento
    final updatedAssetTypes = List<AssetType>.from(originalContainer.assetTypes)
      ..add(newAssetType);

    // 3. Crear una nueva instancia de ContainerNode (inmutabilidad)
    final updatedContainer = originalContainer.copyWith(
      assetTypes: updatedAssetTypes,
    );

    // 4. Reemplazar el contenedor antiguo con el nuevo
    _containers[index] = updatedContainer;

    // TODO: PRÓXIMO PASO: Aquí iría la llamada al API para guardar el cambio en la BBDD
    // Por ahora, solo actualizamos el estado local.
    // await _containerService.saveAssetType(containerId, newAssetType);
    
    // 5. Notificar a los listeners para que la Sidebar y el Grid se actualicen
    notifyListeners();
  }
  
}
