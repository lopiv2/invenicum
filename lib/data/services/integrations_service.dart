import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'api_service.dart';

class IntegrationService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  IntegrationService(this._apiService);

  Future<Map<String, dynamic>> testIntegration(
    String type,
    Map<String, dynamic> config,
  ) async {
    try {
      final response = await _dio.post(
        '/integrations/test',
        data: {'type': type, 'config': config},
      );
      return response.data;
    } on DioException catch (e) {
      print("Status Code: ${e.response?.statusCode}");
      print(
        "Data del Error: ${e.response?.data}",
      ); // <--- ESTO te dirá el error real del backend
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Error de conexión',
      };
    }
  }

  // Nuevo método para eliminar una integración
  Future<void> deleteIntegration(String type) async {
    await _dio.delete('/integrations/$type');
  }

  // Obtiene qué integraciones están activas (para los checks verdes)
  Future<Map<String, bool>> getIntegrationStatuses() async {
    final response = await _dio.get('/integrations/status');
    // Accedemos a response.data['data'] porque el backend envía { data: { ... } }
    final Map<String, dynamic> rawMap = response.data['data'];
    return rawMap.map((key, value) => MapEntry(key, value as bool));
  }

  // Obtiene la configuración guardada (para rellenar los campos del modal)
  Future<Map<String, dynamic>?> getIntegrationConfig(String type) async {
    try {
      final response = await _dio.get('/integrations/$type');
      return response.data['data']['config'];
    } catch (e) {
      // Si no existe, devolvemos null en lugar de explotar
      return null;
    }
  }

  // Guarda o actualiza una integración
  Future<void> saveIntegration(String type, Map<String, dynamic> config) async {
    try {
      await _dio.post('/integrations', data: {'type': type, 'config': config});
    } catch (e) {
      throw Exception('Error al guardar la integración $type: $e');
    }
  }

  /// Llama al endpoint de enriquecimiento con IA (Gemini + API Externa)
  /// Devuelve un mapa con [name, description, imageUrl, customFieldValues, etc.]
  Future<Map<String, dynamic>?> enrichItem({
    required String query,
    required String source,
    String locale = "es",
  }) async {
    try {
      // Llamada al endpoint: /api/integrations/enrich?query=...&source=...&locale=...
      final response = await _dio.get(
        '/integrations/enrich',
        queryParameters: {'query': query, 'source': source, 'locale': locale},
      );

      // Verificamos la estructura de tu backend { success: true, data: { ... } }
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      // Capturamos errores específicos (404 no encontrado, 412 sin API Key, etc.)
      final errorMessage =
          e.response?.data['error'] ?? 'Error al enriquecer el objeto';
      debugPrint("[ENRICH-SERVICE-ERROR]: $errorMessage");

      // Lanzamos la excepción para que el UI (ToastService) pueda mostrar el mensaje real
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("[ENRICH-SERVICE-FATAL]: $e");
      return null;
    }
  }

  Future<InventoryItem?> lookupBarcode(String barcode) async {
    try {
      final response = await _dio.get('/integrations/barcode/lookup/$barcode');

      if (response.data['data'] != null) {
        // Usamos tu factory blindado para convertir el JSON en objeto
        return InventoryItem.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      debugPrint("Error en lookup de barcode: ${e.response?.data}");
      return null;
    }
  }
}
