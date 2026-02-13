import 'package:invenicum/models/user_theme_config_model.dart';

class UserData {
  final int id;
  final String email;
  final String name;
  final String? username;
  final String? githubHandle;
  final String? avatarUrl; // 🚩 AÑADIDO
  final UserThemeConfig? themeConfig;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.githubHandle,
    this.avatarUrl, // 🚩 AÑADIDO
    this.themeConfig,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      githubHandle: json['githubHandle']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(), // 🚩 AÑADIDO
      themeConfig: json['themeConfig'] != null
          ? UserThemeConfig.fromJson(json['themeConfig'])
          : null,
    );
  }

  // copyWith mejorado para permitir valores nulos explícitos si fuera necesario
  UserData copyWith({
    int? id,
    String? email,
    String? name,
    String? username,
    String? githubHandle,
    String? avatarUrl, // 🚩 AÑADIDO
    UserThemeConfig? themeConfig,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      githubHandle: githubHandle ?? this.githubHandle,
      avatarUrl: avatarUrl ?? this.avatarUrl, // 🚩 AÑADIDO
      themeConfig: themeConfig ?? this.themeConfig,
    );
  }
}