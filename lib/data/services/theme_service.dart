import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/custom_theme_model.dart';
import 'api_service.dart';

/// Theme persistence service.
///
/// The backend only knows about [hexColor] and [brightness].
/// The [paletteId] / retro concept is purely a client-side concern:
/// it is derived from the theme [id] when needed and never stored
/// as a separate field in the database.
class ThemeService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  ThemeService(this._apiService);

  // ─── System theme IDs (cannot be deleted) ──────────────────────────────────
  static const Set<String> _systemIds = {
    'brand',
    'emerald', 'sunset', 'ocean', 'lavender', 'forest',
    'cherry',  'indigo', 'amber', 'sakura',   'slate',
    'cyberpunk', 'nordic', 'dark_mode',
    'retro_cga', 'retro_ega',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE ACTIVE THEME
  // ─────────────────────────────────────────────────────────────────────────

  /// Persists the user's active theme choice.
  /// Only [hexColor] and [brightness] are sent — no palette/retro fields.
  Future<bool> updateUserTheme({
    required String hexColor,
    required String brightness,
  }) async {
    try {
      final response = await _dio.put(
        '/preferences/theme',
        data: {
          'themeColor': hexColor,
          'themeBrightness': brightness,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Dio error updating theme: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error updating theme: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CUSTOM THEMES
  // ─────────────────────────────────────────────────────────────────────────

  /// Saves a new theme to the user's library.
  /// Again, only color + brightness — no palette field.
  Future<void> createCustomTheme(CustomTheme theme) async {
    try {
      await _dio.post(
        '/preferences/custom-themes',
        data: {
          'name': theme.name,
          'primaryColor': theme.hexColor,
          'brightness': theme.brightnessStr,
        },
      );
    } catch (e) {
      debugPrint('ThemeService.createCustomTheme error: $e');
      rethrow;
    }
  }

  /// Retrieves all custom themes stored by the user.
  Future<List<CustomTheme>> getCustomThemes() async {
    try {
      final response = await _dio.get('/preferences/custom-themes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) {
          return CustomTheme(
            id: json['id'].toString(),
            name: json['name'] as String,
            primaryColor: Color(
              int.parse(
                (json['primaryColor'] as String).replaceFirst('#', '0xFF'),
              ),
            ),
            brightness: json['brightness'] == 'dark'
                ? Brightness.dark
                : Brightness.light,
            // paletteId is never stored in the DB — user-created themes
            // are always plain Material themes.
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('ThemeService.getCustomThemes error: $e');
      return [];
    }
  }

  /// Deletes a custom theme by ID.
  /// Throws if [themeId] belongs to a system-defined theme.
  Future<void> deleteCustomTheme(String themeId) async {
    if (_systemIds.contains(themeId)) {
      throw Exception('Cannot delete system default themes.');
    }

    try {
      final response =
          await _dio.delete('/preferences/custom-themes/$themeId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error deleting theme from database.');
      }
    } catch (e) {
      rethrow;
    }
  }
}