import 'dart:ui';

import 'package:dio/dio.dart';
import '../models/custom_theme_model.dart';
import 'api_service.dart';

class ThemeService {
  final ApiService _apiService;

  // Acceso a Dio para realizar las peticiones
  Dio get _dio => _apiService.dio;

  ThemeService(this._apiService);

  /// Obtiene las preferencias de tema del usuario desde la DB.
  Future<Map<String, dynamic>?> getUserThemePreferences() async {
    try {
      final response = await _dio.get('/users/preferences/theme');

      if (response.statusCode == 200) {
        // Retorna el objeto con themeColor y themeBrightness
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error al obtener preferencias de tema: $e');
      return null;
    }
  }

  /// Actualiza (o crea) la preferencia de tema actual del usuario.
  /// Esto guarda el color y brillo en la tabla User o Preferences.
  Future<bool> updateUserTheme({
    required String hexColor,
    required String brightness,
  }) async {
    try {
      final response = await _dio.put(
        '/users/preferences/theme',
        data: {'themeColor': hexColor, 'themeBrightness': brightness},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error de Dio al actualizar tema: ${e.message}');
      return false;
    } catch (e) {
      print('Error inesperado al actualizar tema: $e');
      return false;
    }
  }

  /// Guarda un nuevo tema en la lista de "Temas Guardados" del usuario.
  Future<void> createCustomTheme(CustomTheme theme) async {
    final String hexColor =
        '#${theme.primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    try {
      final response = await _dio.post(
        '/users/custom-themes',
        data: {
          "name": theme.name,
          "primaryColor": hexColor, // 👈 Mandamos el String formateado
          "brightness": theme.brightness == Brightness.dark ? 'dark' : 'light',
        },
      );
      return response.data;
    } catch (e) {
      print("Error en el servicio: $e");
      rethrow;
    }
  }

  Future<List<CustomTheme>> getCustomThemes() async {
    try {
      final response = await _dio.get('/users/custom-themes');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data
            .map(
              (json) => CustomTheme(
                id: json['id'].toString(),
                name: json['name'],
                primaryColor: Color(
                  int.parse(json['primaryColor'].replaceFirst('#', '0xFF')),
                ),
                brightness: json['brightness'] == 'dark'
                    ? Brightness.dark
                    : Brightness.light,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener temas personalizados: $e');
      return [];
    }
  }

  /// Elimina un tema personalizado.
  /// 🛑 La lógica de protección contra temas por defecto se valida aquí por ID.
  Future<void> deleteCustomTheme(String themeId) async {
    // Protección: No permitimos llamar a la API si el ID es de los predefinidos
    if (themeId == 'brand' ||
        themeId == 'emerald' ||
        themeId == 'sunset' ||
        themeId == 'dark_mode') {
      throw Exception(
        'No se pueden eliminar los temas por defecto del sistema.',
      );
    }

    try {
      final response = await _dio.delete('/users/custom-themes/$themeId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar el tema de la base de datos.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
