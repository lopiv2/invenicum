// providers/container_provider.dart

import 'package:flutter/foundation.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/models/list_data.dart';
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
      final newContainer = await _containerService.createContainer(
        name,
        description,
      );
      await loadContainers();

      return newContainer;
    } catch (e) {
      print('Error al crear contenedor: $e');
      // Es vital que si el try falla, el error se propague para que el Sidebar lo maneje.
      rethrow;
    }
  }

  Future<void> deleteContainer(int containerId) async {
    try {
      await _containerService.deleteContainer(containerId);
      _containers = _containers.where((c) => c.id != containerId).toList();
      notifyListeners();
    } catch (e) {
      print('Error al eliminar contenedor $containerId: $e');
      rethrow;
    }
  }

  Future<void> renameContainer(int containerId, String newName) async {
    try {
      final updatedContainerFromApi = await _containerService.updateContainer(
        containerId,
        newName,
      );

      // 2. Encontrar el índice del contenedor original en la lista local
      final index = _containers.indexWhere((c) => c.id == containerId);

      if (index == -1) {
        throw Exception(
          'Contenedor con ID $containerId no encontrado en el estado local.',
        );
      }

      final originalContainer = _containers[index];

      final updatedContainer = originalContainer.copyWith(
        name: updatedContainerFromApi.name,
      );

      // 4. Reemplazar el contenedor antiguo por el nuevo en la lista (inmutabilidad)
      _containers[index] = updatedContainer;

      // 5. Notificar a la UI
      notifyListeners();
    } catch (e) {
      print('Error al renombrar contenedor $containerId a "$newName": $e');
      rethrow;
    }
  }

  Future<void> deleteAssetType(int containerId, int assetTypeId) async {
    try {
      await _assetTypeService.deleteAssetType(assetTypeId);
      
      // Actualizar el estado local
      final containerIndex = _containers.indexWhere((c) => c.id == containerId);
      if (containerIndex != -1) {
        final container = _containers[containerIndex];
        final updatedAssetTypes = container.assetTypes
            .where((type) => type.id != assetTypeId)
            .toList();
        
        _containers[containerIndex] = container.copyWith(
          assetTypes: updatedAssetTypes,
        );
        
        notifyListeners();
      }
    } catch (e) {
      print('Error al eliminar el tipo de activo $assetTypeId: $e');
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
      final fieldDefinitionsJson = fieldDefinitions
          .map((def) => def.toJson())
          .toList();

      // 2. LLAMAR AL SERVICIO DE API para crear el AssetType en el backend
      final AssetType newAssetTypeFromApi = await _assetTypeService
          .createAssetType(
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

      final updatedAssetTypes = List<AssetType>.from(
        originalContainer.assetTypes,
      )..add(newAssetTypeFromApi); // Usamos el objeto devuelto por la API

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

  // Método para crear una nueva lista personalizada
  Future<void> createDataList({
    required int containerId,
    required String name,
    required String description,
    required List<String> items,
  }) async {
    try {
      final index = _containers.indexWhere((c) => c.id == containerId);
      if (index == -1) {
        throw Exception('Container not found');
      }

      // Crear la nueva lista a través del servicio
      final newList = await _containerService.createDataList(
        containerId: containerId,
        name: name,
        description: description,
        items: items,
      );
      
      // Actualizar el estado local
      final container = _containers[index];
      final updatedContainer = container.copyWith(
        dataLists: [...container.dataLists, newList],
      );
      _containers[index] = updatedContainer;

      // Notificar a los listeners
      notifyListeners();
    } catch (e) {
      print('Error al crear lista personalizada: $e');
      rethrow;
    }
  }

  // Método para actualizar una lista personalizada
  Future<void> updateDataList({
    required int dataListId,
    required String name,
    required String description,
    required List<String> items,
  }) async {
    try {
      // Actualizar a través del servicio
      final updatedList = await _containerService.updateDataList(
        dataListId: dataListId,
        name: name,
        description: description,
        items: items,
      );

      // Actualizar el estado local
      for (int i = 0; i < _containers.length; i++) {
        final listIndex = _containers[i].dataLists.indexWhere((l) => l.id == dataListId);
        if (listIndex != -1) {
          final updatedLists = List<ListData>.from(_containers[i].dataLists);
          updatedLists[listIndex] = updatedList;
          _containers[i] = _containers[i].copyWith(dataLists: updatedLists);
          notifyListeners();
          break;
        }
      }
    } catch (e) {
      print('Error al actualizar lista personalizada: $e');
      rethrow;
    }
  }

  // Método para eliminar una lista personalizada
  Future<void> deleteDataList(int dataListId) async {
    try {
      // Eliminar a través del servicio
      await _containerService.deleteDataList(dataListId);

      // Actualizar el estado local
      for (int i = 0; i < _containers.length; i++) {
        final hasDataList = _containers[i].dataLists.any((l) => l.id == dataListId);
        if (hasDataList) {
          final updatedLists = _containers[i].dataLists.where((l) => l.id != dataListId).toList();
          _containers[i] = _containers[i].copyWith(dataLists: updatedLists);
          notifyListeners();
          break;
        }
      }
    } catch (e) {
      print('Error al eliminar lista personalizada: $e');
      rethrow;
    }
  }

  // Método para cargar las listas de un contenedor específico
  Future<void> loadDataLists(int containerId) async {
    try {
      final lists = await _containerService.getDataLists(containerId);
      
      // Actualizar solo las listas del contenedor específico
      final containerIndex = _containers.indexWhere((c) => c.id == containerId);
      if (containerIndex != -1) {
        _containers[containerIndex] = _containers[containerIndex].copyWith(
          dataLists: lists,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error al cargar listas personalizadas: $e');
      rethrow;
    }
  }
}
