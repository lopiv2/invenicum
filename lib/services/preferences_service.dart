import 'package:dio/dio.dart';
import 'package:invenicum/models/notifications_preferences_model.dart';
import 'package:invenicum/services/api_service.dart';

class PreferencesService {
  final ApiService _apiService;

  PreferencesService(this._apiService);

  Dio get _dio => _apiService.dio;

  /// Obtiene todas las preferencias del usuario desde el backend
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _dio.get('/preferences');
      // Retornamos el mapa 'data' que el DTO en Flutter se encargará de parsear
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza específicamente el estado de la IA
  /// Usamos PATCH para indicar una actualización parcial del recurso
  Future<Map<String, dynamic>> updateAiStatus(bool isEnabled) async {
    try {
      final response = await _dio.patch(
        '/preferences/ai-status',
        data: {'aiEnabled': isEnabled},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCurrency(String currencyCode) async {
    await _dio.put('/preferences/currency', data: {'currency': currencyCode});
  }

  /// Actualiza la preferencia de idioma en el backend
  Future<void> updateLanguage(String languageCode) async {
    try {
      await _dio.put('/preferences/language', data: {'language': languageCode});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      await _dio.patch(
        '/preferences/notifications',
        data: settings
            .toJson(), // Enviamos { channelOrder: [...], alertStockLow: true, ... }
      );
    } catch (e) {
      rethrow;
    }
  }
}
