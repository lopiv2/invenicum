import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/custom_theme_model.dart';
import 'api_service.dart';

class ThemeService {
  final ApiService _apiService;

  // Access to Dio for making requests
  Dio get _dio => _apiService.dio;

  ThemeService(this._apiService);

  /// Updates (or creates) the user's current theme preference.
  /// This saves the color and brightness in the User or Preferences table.
  Future<bool> updateUserTheme({
    required String hexColor,
    required String brightness,
  }) async {
    try {
      final response = await _dio.put(
        '/preferences/theme',
        data: {'themeColor': hexColor, 'themeBrightness': brightness},
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

  /// Saves a new theme into the user's "Saved Themes" list.
  Future<void> createCustomTheme(CustomTheme theme) async {
    final String hexColor =
        '#${theme.primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    try {
      final response = await _dio.post(
        '/preferences/custom-themes',
        data: {
          "name": theme.name,
          "primaryColor": hexColor, // 👈 We send the formatted String
          "brightness": theme.brightness == Brightness.dark ? 'dark' : 'light',
        },
      );
      return response.data;
    } catch (e) {
      debugPrint("Service error: $e");
      rethrow;
    }
  }

  Future<List<CustomTheme>> getCustomThemes() async {
    try {
      final response = await _dio.get('/preferences/custom-themes');

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
      debugPrint('Error fetching custom themes: $e');
      return [];
    }
  }

  /// Elimina un tema personalizado.
  /// Deletes a custom theme.
  /// 🛑 Protection logic against deleting default themes is validated here by ID.
  Future<void> deleteCustomTheme(String themeId) async {
    // Protection: Do not call the API if the ID is one of the predefined themes
    if (themeId == 'brand' ||
        themeId == 'emerald' ||
        themeId == 'sunset' ||
        themeId == 'dark_mode') {
      throw Exception(
        'Cannot delete system default themes.',
      );
    }

    try {
      final response = await _dio.delete('/preferences/custom-themes/$themeId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error deleting theme from database.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
