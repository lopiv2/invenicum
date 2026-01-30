// lib/models/user_theme_config.dart
import 'dart:ui';

import 'custom_theme_model.dart';

class UserThemeConfig {
  final int id;
  final int userId;
  final CustomTheme theme; // 👈 Tu modelo vive aquí dentro

  UserThemeConfig({
    required this.id,
    required this.userId,
    required this.theme,
  });

  factory UserThemeConfig.fromJson(Map<String, dynamic> json) {
    return UserThemeConfig(
      id: json['id'],
      userId: json['userId'],
      theme: CustomTheme(
        id: 'temp',
        name: 'Cargando...',
        primaryColor: Color(
          int.parse(json['themeColor'].replaceFirst('#', '0xFF')),
        ),
        brightness: json['themeBrightness'] == 'dark'
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }
}
