import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
      // 1. Ajustamos el path al que definimos en Express
      const path = '/ai/extract';

      final response = await _dio.post(
        path,
        data: {
          'url': url,
          'fields': fields,
        },
      );

      // 2. Verificamos el éxito de la operación
      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Como Gemini 3 nos devuelve { mainProduct: {...}, others: [...] }
        // Extraemos el producto principal para facilitar el autocompletado del formulario
        if (data is Map && data.containsKey('mainProduct')) {
          return Map<String, dynamic>.from(data['mainProduct']);
        }
        
        // Si por alguna razón la IA devolvió el objeto directo
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception(response.data['message'] ?? 'Error desconocido en la IA');
      }
    } on DioException catch (e) {
      // 3. Manejo de error 429 (Límite de cuota)
      if (e.response?.statusCode == 429) {
        throw Exception('La IA está saturada. Espera 60 segundos.');
      }
      
      final errorMessage = e.response?.data['message'] ?? 'Error de conexión con el servidor';
      debugPrint('DioException en AIService: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error inesperado en AIService: $e');
      throw Exception('No se pudo procesar la "Magia IA"');
    }
  }
}