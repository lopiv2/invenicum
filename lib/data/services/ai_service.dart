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

      final responseData = response.data;

      // Dio en Flutter Web a veces devuelve el body ya como Map,
      // otras veces como String — normalizamos aquí.
      final Map<String, dynamic> body;
      if (responseData is Map<String, dynamic>) {
        body = responseData;
      } else if (responseData is Map) {
        body = Map<String, dynamic>.from(responseData);
      } else {
        throw 'Respuesta inesperada del servidor: ${responseData.runtimeType}';
      }

      if (body['success'] != true) {
        throw body['error'] ?? body['message'] ?? 'Error desconocido en la IA';
      }

      final data = body['data'];

      if (data == null) {
        throw 'El servidor no devolvió datos extraídos. Comprueba que la URL es accesible.';
      }

      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);

      throw 'Formato de datos inválido: se recibió ${data.runtimeType} en lugar de un objeto JSON.';
    } on DioException catch (e) {
      String errorMessage = 'Error en el servicio de IA';

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage =
              (data['error'] ?? data['message'] ?? errorMessage).toString();
        }
      }

      throw errorMessage;
    } catch (e) {
      // Re-lanzamos strings (nuestros mensajes de error) directamente.
      if (e is String) rethrow;
      throw 'Error inesperado: $e';
    }
  }
}