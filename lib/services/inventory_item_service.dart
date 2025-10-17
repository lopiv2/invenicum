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
    // 🎯 NUEVO: Aceptar filtros de agregación para el contador dinámico
    Map<String, String>? aggregationFilters,
  }) async {
    try {
      // 1. Construir el Path base de la URL
      String path = '/containers/$containerId/asset-types/$assetTypeId/items';

      // 2. Construir los parámetros de query (query string)
      final Map<String, dynamic> queryParameters = {};

      // 3. Añadir los filtros de agregación si existen
      if (aggregationFilters != null && aggregationFilters.isNotEmpty) {
        // 🔑 Serializar el mapa de filtros de agregación en un formato legible por el backend
        // Ejemplo: { '10': 'Dañado' } -> '10:Dañado'
        final aggString = aggregationFilters.entries
            .map((e) => '${e.key}:${e.value}')
            .join(',');

        // Enviamos todos los filtros de agregación bajo una sola clave 'aggFilters'
        queryParameters['aggFilters'] = aggString;
      }

      final response = await _dio.get(
        path, // Usamos la URL base
        queryParameters: queryParameters.isNotEmpty
            ? queryParameters
            : null, // Enviamos los parámetros
      );

      // 🎯 CORRECCIÓN CLAVE: Verificar si la respuesta es nula o vacía.
      if (response.data == null) {
        // Si la respuesta es nula, devolvemos una InventoryResponse vacía.
        return InventoryResponse(
          items: [],
          aggregationDefinitions: [],
          aggregationResults: {},
        );
      }

      // Ahora es seguro hacer el cast, ya que hemos verificado que no es null.
      return InventoryResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al obtener ítems: $e');
    }
  }

  // ----------------------------------------------------------------------
  // --- 2. CREATE (Creación) ---
  // ----------------------------------------------------------------------
  Future<InventoryItem> createInventoryItem(
    InventoryItem item, {
    FileData filesData = const [],
  }) async {
    try {
      // 1. Convertir los datos del activo a Map y codificar el JSON
      final itemMap = {
        'name': item.name,
        'description': item.description,
        'containerId': item.containerId.toString(),
        'assetTypeId': item.assetTypeId.toString(),
        'customFieldValues': jsonEncode(item.customFieldValues),
      };

      // 2. Construir FormData
      final formData = FormData.fromMap(itemMap);

      // 3. Añadir los archivos a FormData
      for (var file in filesData) {
        final bytes = file['bytes'] as Uint8List;
        final name = file['name'] as String;

        final multipartFile = MultipartFile.fromBytes(bytes, filename: name);

        // El backend (Multer) espera 'images'
        formData.files.add(MapEntry('images', multipartFile));
      }

      // 4. Enviar la petición POST con FormData
      final response = await _dio.post('/items', data: formData);

      if (response.statusCode == 201) {
        // Asumimos que el backend devuelve { "data": InventoryItemJson }
        return InventoryItem.fromJson(response.data['data']);
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
      // 1. Convertir los datos del activo a Map y codificar el JSON
      final itemMap = {
        // Campos fijos
        'name': item.name,
        'description': item.description,
        'containerId': item.containerId.toString(),
        'assetTypeId': item.assetTypeId.toString(),

        // Campos personalizados como JSON string
        'customFieldValues': jsonEncode(item.customFieldValues),

        // IDs de imágenes a eliminar (Array de IDs como JSON string)
        'imageIdsToDelete': jsonEncode(imageIdsToDelete),
      };

      // 2. Construir FormData
      final formData = FormData.fromMap(itemMap);

      // 3. Añadir los archivos NUEVOS a FormData
      for (var file in filesToUpload) {
        final bytes = file['bytes'] as Uint8List;
        final name = file['name'] as String;

        final multipartFile = MultipartFile.fromBytes(bytes, filename: name);

        formData.files.add(MapEntry('images', multipartFile));
      }

      // 4. Enviar la petición PATCH con FormData
      // El backend debe devolver el InventoryItem actualizado directamente.
      final response = await _dio.patch('/items/${item.id}', data: formData);

      if (response.statusCode == 200) {
        return InventoryItem.fromJson(response.data);
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
}
