import 'package:dio/dio.dart';
import 'api_service.dart';

class IntegrationService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  IntegrationService(this._apiService);

  Future<Map<String, dynamic>> testIntegration(String type, Map<String, dynamic> config) async {
  try {
    final response = await _dio.post('/integrations/test', data: {
      'type': type,
      'config': config,
    });
    return response.data;
  } on DioException catch (e) {
    return {
      'success': false,
      'message': e.response?.data['message'] ?? 'Error de conexión'
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
}
