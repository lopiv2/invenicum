import 'package:flutter/foundation.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'package:invenicum/data/services/asset_type_service.dart';
import 'package:invenicum/data/services/container_service.dart';
import 'package:invenicum/data/services/location_service.dart';
import 'package:flutter/material.dart';

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
  Future<void>? _loadContainersFuture;

  // 2. Getters públicos
  List<ContainerNode> get containers => _containers;
  bool get isLoading => _isLoading;

  // --- Lógica de Obtener Contenedores ---
  Future<void> loadContainers() async {
    // Si ya hay una carga en curso, esperamos a la misma Future en lugar de salir sin más.
    if (_isLoading) {
      if (_loadContainersFuture != null) {
        await _loadContainersFuture;
      }
      return;
    }

    _isLoading = true;
    // Notificamos inicio de carga
    notifyListeners();

    _loadContainersFuture = () async {
      try {
        final loadedContainers = await _containerService.getContainers();

        // Cargamos SIEMPRE ubicaciones y listas personalizadas desde sus endpoints dedicados,
        // igual que ya hacíamos con ubicaciones, para que los contadores del sidebar
        // reflejen siempre el estado real después de cualquier F5.
        final updatedContainers = await Future.wait(
          loadedContainers.map((apiContainer) async {
            final locations = await _locationService.getLocations(
              apiContainer.id,
            );
            final dataLists = await _containerService.getDataLists(
              apiContainer.id,
            );

            return apiContainer.copyWith(
              locations: locations,
              assetTypes: apiContainer.assetTypes,
              dataLists: dataLists,
            );
          }),
        );

        _containers = updatedContainers;
      } catch (e) {
        print('Error al cargar contenedores: $e');
      } finally {
        _isLoading = false;
        notifyListeners(); // 🔑 Notificamos que la carga terminó
      }
    }();

    await _loadContainersFuture;
  }

  // --- Lógica de Crear Contenedor (Mantenido igual) ---
  Future<ContainerNode?> createNewContainer(
    String name,
    String? description, {
    bool isCollection = false,
  }) async {
    try {
      final newContainer = await _containerService.createContainer(
        name,
        description,
        isCollection: isCollection,
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

  /// Actualiza los campos de colección (posesión y deseados) para un tipo de activo
  Future<void> updateAssetTypeCollectionFields({
    required int containerId,
    required int assetTypeId,
    String? possessionFieldId,
    String? desiredFieldId,
  }) async {
    // Función auxiliar para encontrar y actualizar un AssetType dentro del estado local
    void _updateLocalAssetType({required AssetType newAssetType}) {
      final containerIndex = _containers.indexWhere((c) => c.id == containerId);

      if (containerIndex != -1) {
        final container = _containers[containerIndex];
        final assetTypeIndex = container.assetTypes.indexWhere(
          (at) => at.id == assetTypeId,
        );

        if (assetTypeIndex != -1) {
          // 1. Crear la nueva lista de AssetTypes
          final updatedAssetTypes = List<AssetType>.from(container.assetTypes);
          updatedAssetTypes[assetTypeIndex] =
              newAssetType; // 🔑 Usar el AssetType nuevo (sea optimista o confirmado por API)

          // 2. Crear la nueva instancia de ContainerNode (Inmutabilidad)
          final updatedContainer = container.copyWith(
            assetTypes: updatedAssetTypes,
          );

          // 3. Crear la nueva lista principal de contenedores y reemplazar
          final newContainersList = List<ContainerNode>.from(_containers);
          newContainersList[containerIndex] = updatedContainer;
          _containers = newContainersList;

          // 4. Notificar a los listeners
          notifyListeners();
        }
      }
    }

    // --- INICIO DE LA LÓGICA PRINCIPAL ---
    late final AssetType oldAssetType;

    try {
      // 1. PASO OPTIMISTA: Actualizar el estado local inmediatamente
      print(
        '🔄 Actualizando estado local sin esperar al servidor (Optimista)...',
      );

      final container = _containers.firstWhere((c) => c.id == containerId);
      oldAssetType = container.assetTypes.firstWhere(
        (at) => at.id == assetTypeId,
      );

      // 🔑 Usamos copyWith para crear la nueva instancia (¡Adiós a la construcción manual!)
      final updatedAssetTypeOptimistic = oldAssetType.copyWith(
        possessionFieldId: possessionFieldId,
        desiredFieldId: desiredFieldId,
      );

      _updateLocalAssetType(newAssetType: updatedAssetTypeOptimistic);

      print('✅ Estado local optimista actualizado.');

      // 2. LLAMADA AL SERVIDOR: Intentar persistir en el servidor
      print('📡 Intentando persistir en el servidor...');
      final updatedAssetTypeFromApi = await _assetTypeService
          .updateAssetTypeCollectionFields(
            assetTypeId: assetTypeId,
            possessionFieldId: possessionFieldId,
            desiredFieldId: desiredFieldId,
          );

      // 3. PASO DE CONFIRMACIÓN: Actualizar con la respuesta del servidor (si es diferente o por seguridad)
      print('🔄 Actualizando con respuesta del servidor (Confirmación)...');
      _updateLocalAssetType(newAssetType: updatedAssetTypeFromApi);

      print('✅ Actualización de campos de colección finalizada con éxito.');
    } catch (e) {
      print('🚨 Error al actualizar campos de colección: $e');

      _updateLocalAssetType(newAssetType: oldAssetType);

      // ⚠️ OPCIONAL pero RECOMENDADO: Si falla el servidor, deberías revertir
      // el estado optimista a los valores ANTERIORES.
      // Para simplificar, asumiremos que el error será manejado por el ToastService en el widget.

      // Relanzar la excepción para que el widget pueda capturarla
      // y mostrar un mensaje de error (ej: con ToastService.error).
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
    bool isSerialized = true,
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
            isSerialized: isSerialized,
            removeExistingImage: removeExistingImage,
          );

      // 2. Actualizar el estado local
      final containerIndex = _containers.indexWhere((c) => c.id == containerId);

      if (containerIndex == -1) {
        throw Exception('Contenedor con ID $containerId no encontrado.');
      }

      final originalContainer = _containers[containerIndex];

      // Recuperamos el AssetType original para preservar los campos de colección
      // (possessionFieldId, desiredFieldId) que el endpoint de edición general
      // no gestiona y que el backend devuelve como null si no los recibe.
      final originalAssetType = originalContainer.assetTypes.firstWhere(
        (at) => at.id == assetTypeId,
        orElse: () => updatedAssetTypeFromApi,
      );

      final mergedAssetType = updatedAssetTypeFromApi.copyWith(
        possessionFieldId:
            updatedAssetTypeFromApi.possessionFieldId ??
            originalAssetType.possessionFieldId,
        desiredFieldId:
            updatedAssetTypeFromApi.desiredFieldId ??
            originalAssetType.desiredFieldId,
      );

      // a. Eliminar el AssetType antiguo y añadir el nuevo (con campos preservados)
      final assetTypesWithoutOld = originalContainer.assetTypes
          .where((type) => type.id != assetTypeId)
          .toList();
      final updatedAssetTypes = List<AssetType>.from(assetTypesWithoutOld)
        ..add(mergedAssetType);

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

  Future<List<Map<String, dynamic>>> searchAll(String query) async {
    if (query.isEmpty) return [];
    final String q = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    // --- 1. BÚSQUEDA LOCAL (Inmediata) ---
    // Buscamos en lo que ya tenemos en memoria
    for (var container in _containers) {
      // Buscar en nombres de contenedores
      if (container.name.toLowerCase().contains(q)) {
        results.add({
          'name': container.name,
          'subtitle': 'Contenedor',
          'icon': Icons.inventory_2_rounded,
          'route': '/container/${container.id}/asset-types',
        });
      }

      // Buscar en tipos de activos (categorías)
      for (var type in container.assetTypes) {
        if (type.name.toLowerCase().contains(q)) {
          results.add({
            'name': type.name,
            'subtitle': 'Categoría en ${container.name}',
            'icon': Icons.category_rounded,
            'route': '/container/${container.id}/asset-types/${type.id}/assets',
          });
        }
      }
    }

    // --- 2. BÚSQUEDA EN API (Profunda) ---
    // Solo disparamos la búsqueda pesada si la query tiene una longitud mínima
    if (q.length >= 3) {
      try {
        final apiItems = await _containerService.searchItemsGlobal(q);

        for (var item in apiItems) {
          // Mapeamos la respuesta de la API al fordadmato del desplegable
          results.add({
            'name': item['name'] ?? 'Sin nombre',
            'subtitle': 'Activo en ${item['container_name']}',
            'icon': Icons.precision_manufacturing_outlined,
            // Construimos la ruta dinámica según tu estructura de GoRouter
            'route':
                '/container/${item['container_id']}/asset-types/${item['asset_type_id']}/assets/${item['id']}',
          });
        }
      } catch (e) {
        print('Error en búsqueda híbrida: $e');
        // No lanzamos el error para que al menos se vean los resultados locales
      }
    }

    return results;
  }

  // 🎯 MÉTODO CORREGIDO: Añadiendo defaultLocationId
  Future<void> addNewAssetTypeToContainer({
    required int containerId,
    required String name,
    required List<CustomFieldDefinition> fieldDefinitions,
    Uint8List? imageBytes,
    String? imageName,
    bool isSerialized = true,
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
            isSerialized: isSerialized,
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

  List<CustomFieldDefinition> get allDefinitions {
    final List<CustomFieldDefinition> allDefs = [];
    final Set<int> seenIds = {}; // Para evitar duplicados si un ID se repite

    for (var container in _containers) {
      for (var assetType in container.assetTypes) {
        for (var def in assetType.fieldDefinitions) {
          if (def.id != null && !seenIds.contains(def.id)) {
            allDefs.add(def);
            seenIds.add(def.id!);
          }
        }
      }
    }
    return allDefs;
  }

  // --- Lógica de Listas Personalizadas (Mantenido igual) ---

  // 🚩 Cambia Future<void> por Future<ListData>
  Future<ListData> createDataList({
    required int containerId,
    required String name,
    required String description,
    required List<String> items,
  }) async {
    try {
      final index = _containers.indexWhere((c) => c.id == containerId);
      if (index == -1) throw Exception('Container not found');

      // 1. Llamada al servicio
      final newList = await _containerService.createDataList(
        containerId: containerId,
        name: name,
        description: description,
        items: items,
      );

      // 2. Actualización de estado con inmutabilidad estricta
      final container = _containers[index];

      // 🚩 CLAVE: Forzamos la creación de una nueva instancia de lista
      final List<ListData> updatedDataLists = List<ListData>.from(
        container.dataLists,
      )..add(newList);

      final updatedContainer = container.copyWith(
        dataLists: updatedDataLists,
        locations: List.from(
          container.locations,
        ), // También refrescamos locations por si acaso
      );

      // 3. Reemplazo de la lista principal
      final newContainersList = List<ContainerNode>.from(_containers);
      newContainersList[index] = updatedContainer;

      _containers = newContainersList;

      // 4. Notificar a la UI
      notifyListeners();

      return newList;
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

  /// Añade una ubicación al ContainerNode en memoria sin hacer petición de red.
  /// Usar tras crear una ubicación para actualizar el dropdown inmediatamente,
  /// evitando el frame intermedio donde value no tiene item correspondiente.
  void addLocationToContainer(int containerId, Location location) {
    final index = _containers.indexWhere((c) => c.id == containerId);
    if (index == -1) return;

    final container = _containers[index];
    // Evitar duplicados por si ya existe (ej: por una recarga paralela)
    if (container.locations.any((l) => l.id == location.id)) return;

    final updatedContainer = container.copyWith(
      locations: [...container.locations, location],
    );
    final newList = List<ContainerNode>.from(_containers);
    newList[index] = updatedContainer;
    _containers = newList;
    notifyListeners();
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
