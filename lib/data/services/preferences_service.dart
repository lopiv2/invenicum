import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:invenicum/data/models/notifications_preferences_model.dart';
import 'package:invenicum/data/models/overlay_image_config_model.dart';
import 'package:invenicum/data/models/user_preferences.dart';
import 'package:invenicum/data/services/api_service.dart';

class PreferencesService {
  final ApiService _apiService;

  PreferencesService(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<UserPreferences> updatePreference(String key, dynamic value) async {
    try {
      final response = await _dio.patch('/preferences', data: {key: value});
      if (response.statusCode == 200) {
        final data = response.data;
        final json = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        return UserPreferences.fromJson(json);
      }
      throw Exception('Error updating preference: ${response.statusCode}');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? e.response?.data['message'])
          : e.message;
      throw Exception('Connection error: $msg');
    }
  }

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
      await _dio.put(
        '/preferences/notifications',
        data: {'notifications': settings.toJson()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza el estado del modo oscuro y sistema (Configuración de comportamiento)
  Future<void> updateVisualStatus({
    required bool useSystemTheme,
    required bool isDarkMode,
  }) async {
    try {
      // Usamos PATCH al endpoint raíz o un sub-recurso de comportamiento
      await _dio.patch(
        '/preferences/visual-settings',
        data: {'useSystemTheme': useSystemTheme, 'isDarkMode': isDarkMode},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza el proveedor de IA activo y el modelo seleccionado
  Future<void> updateAiProvider(String provider, String model) async {
    try {
      await _dio.patch(
        '/preferences/ai-provider',
        data: {'aiProvider': provider, 'aiModel': model},
      );
    } catch (e) {
      rethrow;
    }
  }

  // ── CrossToons ────────────────────────────────────────────────────────────

  /// Creates a new cross-toon config with an uploaded image.
  Future<OverlayImageConfig> createCrossToon({
    required Uint8List imageBytes,
    required String imageName,
    required OverlayImageConfig config,
  }) async {
    try {
      final formData = FormData.fromMap({
        'speed': config.speed.inSeconds,
        'direction': config.direction.name,
        'frequency': config.frequency.inSeconds,
        'zone': config.zone.name,
        'imageSize': config.imageSize,
        'turnMode': config.turnMode.name,
        'turnMinDelay': config.turnMinDelay,
        'turnMaxDelay': config.turnMaxDelay,
        'maxTurns': config.maxTurns,
        'animationFps': config.animationFps,
        'enabled': config.enabled,
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: imageName,
          contentType: DioMediaType('image', imageName.split('.').last),
        ),
      });

      final response = await _dio.post('/preferences/cross-toons', data: formData);
      final json = response.data is Map<String, dynamic> && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return OverlayImageConfig.fromJson(json);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? e.response?.data['message'])
          : e.message;
      throw Exception('Error creating cross-toon: $msg');
    }
  }

  /// Updates an existing cross-toon config (with optional new image).
  Future<OverlayImageConfig> updateCrossToon({
    required int id,
    Uint8List? imageBytes,
    String? imageName,
    required OverlayImageConfig config,
  }) async {
    try {
      final formData = FormData.fromMap({
        'speed': config.speed.inSeconds,
        'direction': config.direction.name,
        'frequency': config.frequency.inSeconds,
        'zone': config.zone.name,
        'imageSize': config.imageSize,
        'turnMode': config.turnMode.name,
        'turnMinDelay': config.turnMinDelay,
        'turnMaxDelay': config.turnMaxDelay,
        'maxTurns': config.maxTurns,
        'animationFps': config.animationFps,
        'enabled': config.enabled,
        if (imageBytes != null && imageName != null)
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName,
            contentType: DioMediaType('image', imageName.split('.').last),
          ),
      });

      final response = await _dio.patch('/preferences/cross-toons/$id', data: formData);
      final json = response.data is Map<String, dynamic> && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return OverlayImageConfig.fromJson(json);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? e.response?.data['message'])
          : e.message;
      throw Exception('Error updating cross-toon: $msg');
    }
  }

  /// Deletes a cross-toon config from the server.
  Future<void> deleteCrossToon(int id) async {
    try {
      await _dio.delete('/preferences/cross-toons/$id');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? e.response?.data['message'])
          : e.message;
      throw Exception('Error deleting cross-toon: $msg');
    }
  }
}
