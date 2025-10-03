// lib/services/inventory_item_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'api_service.dart'; // Tu servicio base de Dio

class InventoryItemService {
  final ApiService _apiService;
  // Usamos un getter para acceder a la instancia de Dio
  Dio get _dio => _apiService.dio;

  InventoryItemService(this._apiService);

  // --- 1. READ (Lectura) ---
  /// Obtiene la lista de ítems de inventario para un tipo de activo específico.
  Future<List<InventoryItem>> fetchInventoryItems({
    required int containerId,
    required int assetTypeId,
  }) async {
    try {
      final response = await _dio.get(
        '/containers/$containerId/items',
        queryParameters: {'assetTypeId': assetTypeId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> itemsListJson = response.data as List<dynamic>;

        return itemsListJson
            .map((json) => InventoryItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener ítems: Código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al obtener ítems: $e');
    }
  }

  // ------------------------------------
  // --- 2. CREATE (Creación) (CORREGIDO) ---
  // ------------------------------------
  /// Crea un nuevo ítem de inventario, incluyendo opcionalmente URLs de imágenes.
  ///
  /// Ruta esperada en el backend: POST /items
  Future<InventoryItem> createInventoryItem(
    InventoryItem item, {
    // ACEPTA LAS NUEVAS URLS DE IMAGEN
    List<String> imageUrls = const [], 
  }) async {
    try {
      // Usamos toMap() para serializar el objeto InventoryItem sin el ID (que es nuevo)
      final data = {
        'name': item.name,
        'description': item.description,
        'containerId': item.containerId,
        'assetTypeId': item.assetTypeId,
        'customFieldValues': item.customFieldValues,
        // AÑADIMOS LAS URLS DE IMAGEN PARA QUE EL BACKEND LAS PROCESE
        'imageUrls': imageUrls, 
      };

      final response = await _dio.post('/items', data: data);

      if (response.statusCode == 201) {
        // 201 Created
        // El backend debe devolver el objeto completo, incluyendo el nuevo ID y las imágenes.
        return InventoryItem.fromJson(response.data);
      } else {
        // Mejor manejo de errores para incluir detalles del backend si están disponibles
        throw Exception(
          'Error al crear activo: Código ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al crear activo: $e');
    }
  }

  // -------------------------------------
  // --- 3. UPDATE (Actualización) (MODIFICADO) ---
  // -------------------------------------
  /// Actualiza un ítem de inventario existente, incluyendo la gestión de imágenes.
  ///
  /// Ruta esperada en el backend: PUT/PATCH /items/:id
  Future<InventoryItem> updateInventoryItem(InventoryItem item) async {
    try {
      // Preparamos las URLs existentes para enviarlas de vuelta
      final currentImageUrls = item.images.map((img) => img.url).toList();
      
      // Usamos PUT/PATCH para enviar el objeto completo para la actualización.
      final data = {
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'containerId': item.containerId,
        'assetTypeId': item.assetTypeId,
        'customFieldValues': item.customFieldValues,
        
        // Asumimos que el backend recibirá la lista COMPLETA de URLs y 
        // gestionará las adiciones/eliminaciones.
        'imageUrls': currentImageUrls, 
      };

      final response = await _dio.put('/items/${item.id}', data: data);

      if (response.statusCode == 200) {
        // 200 OK
        // El backend debe devolver el objeto actualizado.
        return InventoryItem.fromJson(response.data);
      } else {
        throw Exception(
          'Error al actualizar activo: Código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al actualizar activo: $e');
    }
  }

  // --- 4. DELETE (Borrado) ---
  /// Borra un ítem de inventario por ID.
  ///
  /// Ruta esperada en el backend: DELETE /items/:id
  Future<void> deleteInventoryItem(int itemId) async {
    try {
      final response = await _dio.delete('/items/$itemId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        // 204 No Content (típico para DELETE) o 200 OK
        throw Exception(
          'Error al eliminar activo: Código ${response.statusCode}',
        );
      }
      // Si la respuesta es exitosa (204/200), simplemente retornamos.
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado al eliminar activo: $e');
    }
  }
}