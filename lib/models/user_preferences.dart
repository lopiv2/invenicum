class UserPreferences {
  final int? id;
  final String language;
  final bool aiEnabled;
  final int? userId;
  final DateTime? updatedAt;

  UserPreferences({
    this.id,
    this.language = 'es',
    this.aiEnabled = true,
    this.userId,
    this.updatedAt,
  });

  // Factoría para convertir el JSON del backend al modelo de Dart
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] as int?,
      // Soportamos tanto el camelCase del DTO como el snake_case de la DB por seguridad
      language: json['language'] as String? ?? 'es',
      aiEnabled: (json['aiEnabled'] ?? json['ai_enabled'] ?? true) as bool,
      userId: json['userId'] as int?,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  // Convierte el modelo a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'aiEnabled': aiEnabled,
      'userId': userId,
    };
  }

  // Método específico para actualizaciones parciales (como el Switch de IA)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'language': language,
      'aiEnabled': aiEnabled,
    };
  }

  // Permite crear una copia modificando solo algunos campos (útil para el Provider)
  UserPreferences copyWith({
    int? id,
    String? language,
    bool? aiEnabled,
    int? userId,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      language: language ?? this.language,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Valores iniciales seguros
  factory UserPreferences.empty() {
    return UserPreferences(
      language: 'es',
      aiEnabled: true,
    );
  }
}