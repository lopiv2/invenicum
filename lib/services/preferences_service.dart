import 'package:dio/dio.dart';
import 'package:invenicum/services/api_service.dart';

class PreferencesService {
  final ApiService _apiService;

  PreferencesService(this._apiService);

  Dio get _dio => _apiService.dio;

  /// Obtiene todas las preferencias del usuario desde el backend
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _dio.get('/preferences');
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza la preferencia de idioma en el backend
  Future<void> updateLanguage(String languageCode) async {
    try {
      await _dio.put(
        '/preferences/language',
        data: {
          'language': languageCode,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
