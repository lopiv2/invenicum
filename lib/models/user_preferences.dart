class UserPreferences {
  final int? id;
  final String language;
  final String currency; // 🔑 Cambiado a String no-nulo con valor por defecto
  final bool aiEnabled;
  final int? userId;
  final DateTime? updatedAt;

  UserPreferences({
    this.id,
    this.language = 'es',
    this.currency = 'EUR', // 🔑 Por defecto siempre EUR
    this.aiEnabled = true,
    this.userId,
    this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] as int?,
      language: json['language'] as String? ?? 'es',
      // 🔑 Mapeamos la moneda desde el JSON
      currency: json['currency'] as String? ?? 'EUR', 
      aiEnabled: (json['aiEnabled'] ?? json['ai_enabled'] ?? true) as bool,
      userId: json['userId'] as int?,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'currency': currency, // 🔑 Añadido
      'aiEnabled': aiEnabled,
      'userId': userId,
    };
  }

  // Útil para tu PreferencesService.updateCurrency
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'language': language,
      'currency': currency, // 🔑 Añadido
      'aiEnabled': aiEnabled,
    };
  }

  UserPreferences copyWith({
    int? id,
    String? language,
    String? currency, // 🔑 Añadido
    bool? aiEnabled,
    int? userId,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      language: language ?? this.language,
      currency: currency ?? this.currency, // 🔑 Añadido
      aiEnabled: aiEnabled ?? this.aiEnabled,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserPreferences.empty() {
    return UserPreferences(
      language: 'es',
      currency: 'EUR',
      aiEnabled: true,
    );
  }
}