import 'package:dio/dio.dart';
import 'api_service.dart';

class AIService {
  final ApiService _apiService;

  Dio get _dio => _apiService.dio;

  AIService(this._apiService);

  /// Envía una URL al backend para que la IA extraiga los datos.
  Future<Map<String, dynamic>> extractDataFromUrl({
    required String url,
    required List<String> fields,
  }) async {
    try {
      const path = '/ai/extract';

      final response = await _dio.post(
        path,
        data: {'url': url, 'fields': fields},
      );

      // 1. Verificamos el éxito de la operación
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        throw 'Formato de datos inválido';
      } else {
        // 🚩 Si success es false, buscamos 'error' o 'message'
        throw response.data['error'] ??
            response.data['message'] ??
            'Error desconocido en la IA';
      }
    } on DioException catch (e) {
      // 🛡️ Extraemos el mensaje enviado por el backend en errores HTTP (400, 401, 500, etc.)
      String errorMessage = "Error en el servicio de IA";

      if (e.response?.data != null) {
        final data = e.response!.data;
        // Tu backend usa 'error' en el catch del router
        errorMessage = data['error'] ?? data['message'] ?? errorMessage;
      }

      throw errorMessage;
    } catch (e) {
      throw "Error inesperado: $e";
    }
  }
}
