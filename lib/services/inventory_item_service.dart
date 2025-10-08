// lib/services/inventory_item_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'api_service.dart';
import 'dart:typed_data'; 
import 'dart:convert'; // 💡 Necesario para jsonEncode

// Definimos un TypeDef para hacer la firma más legible
typedef FileData = List<Map<String, dynamic>>; 

class InventoryItemService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  InventoryItemService(this._apiService);

  // --- 1. READ (Lectura) ---
  // ... (Esta función se mantiene igual, asumiendo que el backend devuelve la lista)
  Future<List<InventoryItem>> fetchInventoryItems({
    required int containerId,
    required int assetTypeId,
  }) async {
    try {
      final response = await _dio.get(
        '/containers/$containerId/items',
        queryParameters: {'assetTypeId': assetTypeId},
      );

      // 💡 El backend ahora devuelve { success: true, data: [...] }
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
  // --- 2. CREATE (Creación) - CORRECCIÓN CLAVE EN EL NOMBRE DEL CAMPO ---
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
        'containerId': item.containerId.toString(), // 💡 ENVIAR COMO STRING
        'assetTypeId': item.assetTypeId.toString(), // 💡 ENVIAR COMO STRING
        // 💡 CONVERTIMOS EL OBJETO CUSTOM FIELDS A JSON STRING
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
        
        // 🛑 CORRECCIÓN CLAVE: El backend (Multer) espera 'images', no 'images[]'.
        // Multer.array('images') ya maneja el array implícitamente.
        formData.files.add(
          MapEntry('images', multipartFile), 
        );
      }

      // 4. Enviar la petición POST con FormData
      final response = await _dio.post('/items', data: formData);

      if (response.statusCode == 201) {
        // 💡 El backend devuelve un objeto con la clave 'data'
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
  // --- 3. UPDATE (Actualización) - MANTENEMOS LA GESTIÓN DE URLs EXISTENTES ---
  // ----------------------------------------------------------------------------------
  Future<InventoryItem> updateInventoryItem(InventoryItem item) async {
    try {
      // Usamos los URLs existentes y convertimos los campos JSON a string
      final data = item.toJson();
      data['imageUrls'] = item.images.map((img) => img.url).toList(); 
      data['customFieldValues'] = jsonEncode(item.customFieldValues);
      
      final response = await _dio.put('/items/${item.id}', data: data);

      if (response.statusCode == 200) {
        // 💡 El backend devuelve un objeto con la clave 'data'
        return InventoryItem.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Error al actualizar activo: Código ${response.statusCode}',
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
    // ... (Se mantiene igual)
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