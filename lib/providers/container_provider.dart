import 'package:flutter/foundation.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/models/list_data.dart';
import 'package:invenicum/services/asset_type_service.dart';
import 'package:invenicum/services/container_service.dart';
import 'package:invenicum/services/location_service.dart';

class ContainerProvider with ChangeNotifier {
  final ContainerService _containerService;
  final AssetTypeService _assetTypeService;
  final LocationService _locationService;

  ContainerProvider(
    this._containerService,
    this._assetTypeService,
    this._locationService,
  );

  // 1. La variable de estado privada que almacena los datos
  List<ContainerNode> _containers = [];
  bool _isLoading = false;

  // 2. Getters públicos
  List<ContainerNode> get containers => _containers;
  bool get isLoading => _isLoading;

  // --- Lógica de Obtener Contenedores ---
  Future<void> loadContainers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedContainers = await _containerService.getContainers();

      // Si ya teníamos contenedores, preservamos el estado expandido/colapsado
      if (_containers.isNotEmpty) {
        for (var i = 0; i < loadedContainers.length; i++) {
          final newContainer = loadedContainers[i];
          final existingContainer = _containers.firstWhere(
            (c) => c.id == newContainer.id,
            orElse: () => newContainer,
          );

          // Preservar las listas, tipos de activos y UBICACIONES si el contenedor ya existía
          if (existingContainer != newContainer) {
            loadedContainers[i] = existingContainer.copyWith(
              // Mantenemos los datos cargados asíncronamente
              dataLists: existingContainer.dataLists,
              assetTypes: existingContainer.assetTypes,
              // 🎯 CORRECCIÓN: Usar la lista de locations completa
              locations: existingContainer.locations,
            );
          }
        }
      }

      _containers = loadedContainers;
    } catch (e) {
      print('Error al cargar contenedores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Lógica de Crear Contenedor (Mantenido igual) ---
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

      final index = _containers.indexWhere((c) => c.id == containerId);

      if (index == -1) {
        throw Exception(
          'Contenedor con ID $containerId no encontrado en el estado local.',
        );
      }

      final originalContainer = _containers[index];

      // 🎯 CORRECCIÓN: Ya no pasamos locationsCount
      final updatedContainer = originalContainer.copyWith(
        name: updatedContainerFromApi.name,
        locations:
            originalContainer.locations, // Mantener las ubicaciones existentes
      );

      final newContainersList = List<ContainerNode>.from(_containers);
      newContainersList[index] = updatedContainer;
      _containers = newContainersList;

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

        // 🎯 CORRECCIÓN: Ya no pasamos locationsCount
        final updatedContainer = container.copyWith(
          assetTypes: updatedAssetTypes,
          locations: container.locations,
        );

        // 🚨 Inmutabilidad: Reemplazar el contenedor en una NUEVA lista
        final newContainersList = List<ContainerNode>.from(_containers);
        newContainersList[containerIndex] = updatedContainer;
        _containers = newContainersList;

        notifyListeners();
      }
    } catch (e) {
      print('Error al eliminar el tipo de activo $assetTypeId: $e');
      rethrow;
    }
  }

  Future<void> updateAssetType({
    required int containerId,
    required int assetTypeId,
    required String name,
    required List<CustomFieldDefinition> fieldDefinitions,
    Uint8List? imageBytes,
    String? imageName,
    required bool removeExistingImage,
  }) async {
    try {
      // 1. ... (Lógica de API)
      final fieldDefinitionsJson = fieldDefinitions
          .map((def) => def.toJson())
          .toList();

      final AssetType updatedAssetTypeFromApi = await _assetTypeService
          .updateAssetType(
            assetTypeId: assetTypeId,
            name: name,
            fieldDefinitionsJson: fieldDefinitionsJson,
            imageBytes: imageBytes,
            imageName: imageName,
            removeExistingImage: removeExistingImage,
          );

      // 2. Actualizar el estado local
      final containerIndex = _containers.indexWhere((c) => c.id == containerId);

      if (containerIndex == -1) {
        throw Exception('Contenedor con ID $containerId no encontrado.');
      }

      final originalContainer = _containers[containerIndex];

      // a. Eliminar el AssetType antiguo y añadir el nuevo
      final assetTypesWithoutOld = originalContainer.assetTypes
          .where((type) => type.id != assetTypeId)
          .toList();
      final updatedAssetTypes = List<AssetType>.from(assetTypesWithoutOld)
        ..add(updatedAssetTypeFromApi);

      // b. Crear un nuevo ContainerNode con la lista de AssetTypes actualizada
      // 🎯 CORRECCIÓN: Ya no pasamos locationsCount
      final updatedContainer = originalContainer.copyWith(
        assetTypes: updatedAssetTypes,
        locations: originalContainer.locations,
      );

      // 🚨 Inmutabilidad: Reemplazar el contenedor en una NUEVA lista
      final newContainersList = List<ContainerNode>.from(_containers);
      newContainersList[containerIndex] = updatedContainer;
      _containers = newContainersList;

      // 3. Notificar a los listeners
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // 🎯 MÉTODO CORREGIDO: Añadiendo defaultLocationId
  Future<void> addNewAssetTypeToContainer({
    required int containerId,
    required String name,
    required List<CustomFieldDefinition> fieldDefinitions,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      // 1. Lógica de API
      final fieldDefinitionsJson = fieldDefinitions
          .map((def) => def.toJson())
          .toList();
      final AssetType newAssetTypeFromApi = await _assetTypeService
          .createAssetType(
            containerId: containerId,
            name: name,
            fieldDefinitionsJson: fieldDefinitionsJson,
            imageBytes: imageBytes,
            imageName: imageName,
            // 🎯 CORRECCIÓN: Pasar la ID de la ubicación al servicio
          );

      // 2. Actualizar el estado local
      final index = _containers.indexWhere((c) => c.id == containerId);
      if (index == -1) {
        throw Exception('Contenedor con ID $containerId no encontrado.');
      }

      final originalContainer = _containers[index];
      final updatedAssetTypes = List<AssetType>.from(
        originalContainer.assetTypes,
      )..add(newAssetTypeFromApi);

      // 🎯 CORRECCIÓN: Ya no pasamos locationsCount
      final updatedContainer = originalContainer.copyWith(
        assetTypes: updatedAssetTypes,
        locations: originalContainer.locations,
      );

      // 🚨 Inmutabilidad: Reemplazar el contenedor en una NUEVA lista
      final newContainersList = List<ContainerNode>.from(_containers);
      newContainersList[index] = updatedContainer;
      _containers = newContainersList;

      // 3. Notificar a los listeners
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // --- Lógica de Listas Personalizadas (Mantenido igual) ---

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

      final newList = await _containerService.createDataList(
        containerId: containerId,
        name: name,
        description: description,
        items: items,
      );

      final container = _containers[index];
      // 🎯 CORRECCIÓN: Ya no pasamos locationsCount
      final updatedContainer = container.copyWith(
        dataLists: [...container.dataLists, newList],
        locations: container.locations,
      );

      final newContainersList = List<ContainerNode>.from(_containers);
      newContainersList[index] = updatedContainer;
      _containers = newContainersList;

      notifyListeners();
    } catch (e) {
      print('Error al crear lista personalizada: $e');
      rethrow;
    }
  }

  Future<void> updateDataList({
    required int dataListId,
    required String name,
    required String description,
    required List<String> items,
  }) async {
    try {
      final updatedList = await _containerService.updateDataList(
        dataListId: dataListId,
        name: name,
        description: description,
        items: items,
      );

      for (int i = 0; i < _containers.length; i++) {
        final listIndex = _containers[i].dataLists.indexWhere(
          (l) => l.id == dataListId,
        );
        if (listIndex != -1) {
          final container = _containers[i];
          final updatedLists = List<ListData>.from(container.dataLists);
          updatedLists[listIndex] = updatedList;

          // 🎯 CORRECCIÓN: Ya no pasamos locationsCount
          final updatedContainer = container.copyWith(
            dataLists: updatedLists,
            locations: container.locations,
          );

          final newContainersList = List<ContainerNode>.from(_containers);
          newContainersList[i] = updatedContainer;
          _containers = newContainersList;

          notifyListeners();
          break;
        }
      }
    } catch (e) {
      print('Error al actualizar lista personalizada: $e');
      rethrow;
    }
  }

  Future<void> deleteDataList(int dataListId) async {
    try {
      await _containerService.deleteDataList(dataListId);

      for (int i = 0; i < _containers.length; i++) {
        final hasDataList = _containers[i].dataLists.any(
          (l) => l.id == dataListId,
        );
        if (hasDataList) {
          final container = _containers[i];
          final updatedLists = container.dataLists
              .where((l) => l.id != dataListId)
              .toList();

          // 🎯 CORRECCIÓN: Ya no pasamos locationsCount
          final updatedContainer = container.copyWith(
            dataLists: updatedLists,
            locations: container.locations,
          );

          final newContainersList = List<ContainerNode>.from(_containers);
          newContainersList[i] = updatedContainer;
          _containers = newContainersList;

          notifyListeners();
          break;
        }
      }
    } catch (e) {
      print('Error al eliminar lista personalizada: $e');
      rethrow;
    }
  }

  // 🎯 MÉTODO CORREGIDO: Ahora carga la lista de ubicaciones completa
  Future<void> loadDataLists(int containerId) async {
    try {
      // 1. Cargar Listas Personalizadas
      final lists = await _containerService.getDataLists(containerId);

      // 2. 🔑 Cargar la lista de ubicaciones completa
      final locations = await _locationService.getLocations(containerId);

      // 3. Actualizar el contenedor específico
      final containerIndex = _containers.indexWhere((c) => c.id == containerId);
      if (containerIndex != -1) {
        final containerToUpdate = _containers[containerIndex];

        // 3a. Crear un NUEVO ContainerNode con los datos actualizados
        final updatedContainer = containerToUpdate.copyWith(
          dataLists: lists,
          // 🎯 CORRECCIÓN: Usar la lista de ubicaciones
          locations: locations,
        );

        // 3b. 🔑 LA CLAVE: Crea una NUEVA lista y la reasigna
        final newContainersList = List<ContainerNode>.from(_containers);
        newContainersList[containerIndex] = updatedContainer;
        _containers = newContainersList;

        notifyListeners();
      }
    } catch (e) {
      print('Error al cargar listas y ubicaciones: $e');
      rethrow;
    }
  }

  // Método para obtener una lista específica por su ID (Mantenido igual)
  Future<ListData> getDataList(int dataListId) async {
    try {
      return await _containerService.getDataList(dataListId);
    } catch (e) {
      print('Error al obtener la lista personalizada: $e');
      rethrow;
    }
  }
}
