// lib/services/inventory_item_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'api_service.dart'; // Tu servicio base de Dio

class InventoryItemService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  InventoryItemService(this._apiService);

  /// Obtiene la lista de ítems de inventario para un tipo de activo específico.
  /// 
  /// Ruta esperada en el backend: GET /containers/:containerId/items?assetTypeId=:assetTypeId
  Future<List<InventoryItem>> getInventoryItems({
    required int containerId,
    required int assetTypeId,
  }) async {
    try {
      // Usamos la ruta GET /containers/:containerId/items
      // y pasamos el assetTypeId como query parameter para filtrar en el backend.
      final response = await _dio.get(
        '/containers/$containerId/items',
        queryParameters: {'assetTypeId': assetTypeId},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        // Asumimos que la lista de ítems está anidada en 'data' en la respuesta.
        final List<dynamic> itemsListJson = responseData['data'] as List<dynamic>;

        // Mapear la lista JSON a una lista de modelos InventoryItem
        return itemsListJson
            .map((json) => InventoryItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener ítems: Código ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      // Re-lanza el error de conexión o API.
      rethrow; 
    } catch (e) {
      throw Exception('Error inesperado al obtener ítems: $e');
    }
  }
}