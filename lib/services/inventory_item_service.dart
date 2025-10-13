// lib/services/inventory_item_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/models/inventory_item.dart';
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
  Future<List<InventoryItem>> fetchInventoryItems({
    required int containerId,
    required int assetTypeId,
  }) async {
    try {
      final response = await _dio.get(
        '/containers/$containerId/asset-types/$assetTypeId/items',
      );

      final List<dynamic> itemsListJson = response.data['data'] as List<dynamic>; 
      
      return itemsListJson
          .map((json) => InventoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
      
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
        
        final multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: name,
        );
        
        // El backend (Multer) espera 'images'
        formData.files.add(
          MapEntry('images', multipartFile), 
        );
      }

      // 4. Enviar la petición POST con FormData
      final response = await _dio.post('/items', data: formData);

      if (response.statusCode == 201) {
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
  // 🚀 --- 3. UPDATE (Actualización) - GESTIÓN DE DATOS, SUBIDA Y ELIMINACIÓN ---
  // ----------------------------------------------------------------------------------
  /// Actualiza un InventoryItem, gestionando simultáneamente la subida de archivos
  /// nuevos y la eliminación de imágenes existentes.
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
          
          // Campos personalizados como JSON string (esto lo parseamos en el backend)
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
          
          final multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: name,
          );
          
          formData.files.add(
            MapEntry('images', multipartFile), 
          );
        }

        // 4. Enviar la petición PATCH con FormData
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