// providers/container_provider.dart

import 'package:flutter/foundation.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/services/asset_type_service.dart';
import 'package:invenicum/services/container_service.dart';

class ContainerProvider with ChangeNotifier {
  // Renombramos la variable a _containerService para mayor claridad.
  final ContainerService _containerService;
  final AssetTypeService _assetTypeService; 

  ContainerProvider(this._containerService, this._assetTypeService);

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

  Future<void> deleteContainer(int containerId) async {
        // Opción 1: Optimista (quitarlo antes de la API y luego revertir si falla)
        // Opción 2: Pesimista (quitarlo solo si la API tiene éxito)
        // Usaremos la opción 2 para mayor seguridad.
        
        try {
            // 1. Llamar al servicio de la API para eliminar en el backend
            await _containerService.deleteContainer(containerId);

            // 2. Actualizar el estado local (eliminar de la lista)
            // Usamos where para crear una nueva lista sin el contenedor eliminado
            _containers = _containers.where((c) => c.id != containerId).toList();
            
            // 3. Notificar a la UI
            notifyListeners();

        } catch (e) {
            print('Error al eliminar contenedor $containerId: $e');
            // Es vital relanzar el error para que el widget (ContainerTreeView)
            // pueda atraparlo y mostrar una notificación al usuario.
            rethrow;
        }
    }
  

  Future<void> addNewAssetTypeToContainer({
 required int containerId,
 required String name,
 required String? imageUrl,
 required List<CustomFieldDefinition> fieldDefinitions,
 }) async {
    try {
      // 1. Convertir la lista de modelos de Dart a la lista de JSON que espera la API
      final fieldDefinitionsJson = fieldDefinitions.map((def) => def.toJson()).toList();

      // 2. LLAMAR AL SERVICIO DE API para crear el AssetType en el backend
      final AssetType newAssetTypeFromApi = await _assetTypeService.createAssetType(
        containerId: containerId,
        name: name,
        imageUrl: imageUrl,
        fieldDefinitionsJson: fieldDefinitionsJson, // JSON para la API
      );
      
      // 3. Actualizar el estado local (igual que antes, pero con el objeto real de la API)
      final index = _containers.indexWhere((c) => c.id == containerId);

      if (index == -1) {
        // Esto puede ocurrir si el contenedor se eliminó o si loadContainers aún no ha terminado.
        throw Exception('Contenedor con ID $containerId no encontrado.');
      }

      final originalContainer = _containers[index];
      
      final updatedAssetTypes = List<AssetType>.from(originalContainer.assetTypes)
        ..add(newAssetTypeFromApi); // Usamos el objeto devuelto por la API

      final updatedContainer = originalContainer.copyWith(
        assetTypes: updatedAssetTypes,
      );

      _containers[index] = updatedContainer;

      // 4. Notificar a los listeners
      notifyListeners();

    } catch (e) {
      // Propagar el error de la API o cualquier otro error para que la pantalla lo muestre.
      rethrow;
    }
 }
  
}
