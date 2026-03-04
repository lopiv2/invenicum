import 'package:invenicum/data/models/user_theme_config_model.dart';

class UserData {
  final int id;
  final String email;
  final String name;
  final String? username;
  final String? githubHandle;
  final String? avatarUrl;
  final String? githubId;        
  final DateTime? githubLinkedAt; 
  final DateTime? createdAt;      
  final UserThemeConfig? themeConfig;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.githubHandle,
    this.avatarUrl,
    this.githubId,
    this.githubLinkedAt,
    this.createdAt,
    this.themeConfig,
  });

  /// 🛡️ Lógica del "Tick Verde" integrada en el modelo
  /// Retorna true si tiene handle y la vinculación tiene menos de 30 días
  bool get isGitHubValidated {
    if (githubHandle == null || githubLinkedAt == null) return false;
    final diferencia = DateTime.now().difference(githubLinkedAt!);
    return diferencia.inDays < 30;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      githubHandle: json['githubHandle']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      githubId: json['githubId']?.toString(), // Mapeo del ID de GitHub
      
      // Parseo de fechas ISO8601 que vienen del DTO
      githubLinkedAt: json['githubLinkedAt'] != null 
          ? DateTime.parse(json['githubLinkedAt'].toString()) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : null,

      themeConfig: json['themeConfig'] != null
          ? UserThemeConfig.fromJson(json['themeConfig'])
          : null,
    );
  }

  UserData copyWith({
    int? id,
    String? email,
    String? name,
    String? username,
    String? githubHandle,
    String? avatarUrl,
    String? githubId,
    DateTime? githubLinkedAt,
    DateTime? createdAt,
    UserThemeConfig? themeConfig,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      githubHandle: githubHandle ?? this.githubHandle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      githubId: githubId ?? this.githubId,
      githubLinkedAt: githubLinkedAt ?? this.githubLinkedAt,
      createdAt: createdAt ?? this.createdAt,
      themeConfig: themeConfig ?? this.themeConfig,
    );
  }
}