// lib/services/inventory_item_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/models/inventory_item.dart';
// 🔑 Importamos la clase que contiene la lista de ítems Y los totales
import 'package:invenicum/models/inventory_item_response.dart';
import 'api_service.dart';
import 'dart:typed_data';
import 'dart:convert';

// Definimos un TypeDef para hacer la firma más legible
typedef FileData = List<Map<String, dynamic>>;

class InventoryItemService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  InventoryItemService(this._apiService);

  // --- 1. READ (Lectura) ---
  // 🔑 CAMBIO CLAVE: Ahora devuelve InventoryResponse (que contiene items y totales)
  Future<InventoryResponse> fetchInventoryItems({
    required int containerId,
    required int assetTypeId,
    Map<String, String>? aggregationFilters,
  }) async {
    try {
      String path = '/containers/$containerId/asset-types/$assetTypeId/items';

      final Map<String, dynamic> queryParameters = {};

      if (aggregationFilters != null && aggregationFilters.isNotEmpty) {
        final aggString = aggregationFilters.entries
            .map((e) => '${e.key}:${e.value}')
            .join(',');
        queryParameters['aggFilters'] = aggString;
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      // 🔑 Verificar y extraer correctamente
      if (response.data == null) {
        return InventoryResponse(
          items: [],
          aggregationDefinitions: [],
          aggregationResults: {},
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final dataField = responseData['data'] as Map<String, dynamic>?;

      if (dataField == null) {
        return InventoryResponse(
          items: [],
          aggregationDefinitions: [],
          aggregationResults: {},
        );
      }

      // Ahora pasamos el contenido correcto a fromJson
      return InventoryResponse.fromJson(dataField);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al obtener ítems: $e');
    }
  }

  // NUEVO MÉTODO DE CLONACIÓN
  Future<InventoryItem> cloneInventoryItem(InventoryItem item) async {
    // Asegúrate de que tu cliente HTTP (ej. Dio, http) usa la ruta correcta
    final containerId = item.containerId;
    final assetTypeId = item.assetTypeId;

    // 🎯 RUTA CLAVE: Llama al nuevo endpoint sin Multer
    final url = '/containers/$containerId/asset-types/$assetTypeId/items/clone';

    // Realiza la petición POST con el body JSON
    final response = await _dio.post(
      url,
      data: item
          .toJson(), // Envía el objeto InventoryItem (con images: [{id: 0, url: '...'}])
    );

    return InventoryItem.fromJson(response.data);
  }

  // ----------------------------------------------------------------------
  // --- 2. CREATE (Creación) ---
  // ----------------------------------------------------------------------
  Future<InventoryItem> createInventoryItem(
    InventoryItem item, {
    FileData filesData = const [],
  }) async {
    try {
      // 1. Construir FormData manualmente para manejar null correctamente
      final formData = FormData();
      
      formData.fields.add(MapEntry('name', item.name));
      formData.fields.add(MapEntry('description', item.description ?? ''));
      formData.fields.add(MapEntry('containerId', item.containerId.toString()));
      formData.fields.add(MapEntry('assetTypeId', item.assetTypeId.toString()));
      
      // 🔑 Manejar locationId correctamente: solo agregarlo si no es null
      if (item.locationId != null) {
        formData.fields.add(MapEntry('locationId', item.locationId.toString()));
      }
      
      formData.fields.add(MapEntry('customFieldValues', jsonEncode(item.customFieldValues)));

      // 2. Añadir los archivos a FormData
      for (var file in filesData) {
        final bytes = file['bytes'] as Uint8List;
        final name = file['name'] as String;

        final multipartFile = MultipartFile.fromBytes(bytes, filename: name);

        // El backend (Multer) espera 'images'
        formData.files.add(MapEntry('images', multipartFile));
      }

      // 3. Enviar la petición POST con FormData
      final response = await _dio.post('/items', data: formData);

      if (response.statusCode == 201) {
        // El backend devuelve una estructura anidada: { data: { data: InventoryItemJson } }
        final responseData = response.data;
        
        // Manejar la posible anidación
        dynamic itemData = responseData;
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }
        
        return InventoryItem.fromJson(itemData as Map<String, dynamic>);
      } else {
        throw Exception(
          'Error al crear activo: Código ${response.statusCode} - ${response.data['message'] ?? response.statusMessage}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al crear activo: $e');
    }
  }

  // ----------------------------------------------------------------------------------
  // 🚀 --- 3. UPDATE (Actualización) ---
  // ----------------------------------------------------------------------------------
  Future<InventoryItem> updateInventoryItem(
    InventoryItem item, {
    FileData filesToUpload = const [], // Nuevos archivos a subir
    List<int> imageIdsToDelete = const [], // IDs de imágenes a eliminar
  }) async {
    try {
      // 1. Construir FormData manualmente para manejar null correctamente
      final formData = FormData();
      
      formData.fields.add(MapEntry('name', item.name));
      formData.fields.add(MapEntry('description', item.description ?? ''));
      formData.fields.add(MapEntry('containerId', item.containerId.toString()));
      formData.fields.add(MapEntry('assetTypeId', item.assetTypeId.toString()));
      
      // 🔑 Manejar locationId correctamente: solo agregarlo si no es null
      if (item.locationId != null) {
        formData.fields.add(MapEntry('locationId', item.locationId.toString()));
      }
      
      formData.fields.add(MapEntry('customFieldValues', jsonEncode(item.customFieldValues)));
      formData.fields.add(MapEntry('imageIdsToDelete', jsonEncode(imageIdsToDelete)));

      // 2. Añadir los archivos NUEVOS a FormData
      for (var file in filesToUpload) {
        final bytes = file['bytes'] as Uint8List;
        final name = file['name'] as String;

        final multipartFile = MultipartFile.fromBytes(bytes, filename: name);

        formData.files.add(MapEntry('images', multipartFile));
      }

      // 3. Enviar la petición PATCH con FormData
      // El backend debe devolver el InventoryItem actualizado directamente.
      final response = await _dio.patch('/items/${item.id}', data: formData);

      if (response.statusCode == 200) {
        // Manejar la posible estructura anidada
        dynamic itemData = response.data;
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }
        
        return InventoryItem.fromJson(itemData as Map<String, dynamic>);
      } else {
        throw Exception(
          'Error al actualizar activo: Código ${response.statusCode} - ${response.data['message'] ?? response.statusMessage}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al actualizar activo: $e');
    }
  }

  // --- 4. DELETE (Borrado) ---
  Future<void> deleteInventoryItem(int itemId) async {
    try {
      final response = await _dio.delete('/items/$itemId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error al eliminar activo: Código ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al eliminar activo: $e');
    }
  }

  // ----------------------------------------------------------------------
  // 📦 --- 5. CREATE BATCH (Importación Masiva) ---
  // ----------------------------------------------------------------------

  /// Envía una lista de datos de activos mapeados a un endpoint de procesamiento por lotes.
  ///
  /// Utiliza una petición POST simple (JSON body) ya que no hay archivos adjuntos.
  Future<void> createBatchInventoryItems({
    required int containerId,
    required int assetTypeId,
    // La lista de Map<String, dynamic> representa los ítems listos para subir.
    required List<Map<String, dynamic>> itemsData,
  }) async {
    // 1. Endpoint específico para la importación masiva.
    // Es común usar un sub-recurso como '/batch' o '/import'
    final url = '/containers/$containerId/asset-types/$assetTypeId/items/batch';

    // 2. Preparar el cuerpo de la petición
    // El backend espera un objeto que contenga el array de ítems.
    final Map<String, dynamic> requestBody = {
      // 🔑 Aquí enviamos el array de activos
      'items': itemsData,
    };

    try {
      // 3. Enviar la petición POST. El método post de Dio
      // automáticamente serializa 'requestBody' a JSON.
      final response = await _dio.post(url, data: requestBody);

      // 4. Verificar el código de respuesta
      // Un POST exitoso que crea recursos a menudo devuelve 201 Created o 200 OK.
      if (response.statusCode != 201 && response.statusCode != 200) {
        // Si la API devuelve un error de validación o un 4xx/5xx, lanzamos.
        throw Exception(
          'Error al importar activos por lotes: Código ${response.statusCode} - ${response.data['message'] ?? response.statusMessage}',
        );
      }

      // Si la respuesta es exitosa (200/201), retornamos implícitamente void.
    } on DioException {
      // Captura errores específicos de red/API manejados por Dio.
      rethrow;
    } catch (e) {
      // Captura cualquier otro error (ej: JSON parsing).
      throw Exception('Error inesperado durante la importación por lotes: $e');
    }
  }
}
