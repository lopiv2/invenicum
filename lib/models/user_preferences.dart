class UserPreferences {
  final int? id;
  final String language;
  final String currency; // 🔑 Cambiado a String no-nulo con valor por defecto
  final bool aiEnabled;
  final int? userId;
  final DateTime? updatedAt;
  final Map<String, double>? exchangeRates;

  UserPreferences({
    this.id,
    this.language = 'es',
    this.currency = 'EUR',
    this.aiEnabled = true,
    this.userId,
    this.updatedAt,
    this.exchangeRates, // Nuevo
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    // Procesamos los rates asegurándonos de convertirlos a double
    Map<String, double>? parsedRates;
    if (json['exchangeRates'] != null) {
      parsedRates = (json['exchangeRates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    return UserPreferences(
      id: json['id'] as int?,
      language: json['language'] as String? ?? 'es',
      currency: json['currency'] as String? ?? 'EUR',
      aiEnabled: (json['aiEnabled'] ?? json['ai_enabled'] ?? true) as bool,
      userId: json['userId'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      exchangeRates: parsedRates, // Asignamos los rates
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
    String? currency,
    bool? aiEnabled,
    int? userId,
    DateTime? updatedAt,
    Map<String, double>? exchangeRates, // Añadido al copyWith
  }) {
    return UserPreferences(
      id: id ?? this.id,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      exchangeRates: exchangeRates ?? this.exchangeRates,
    );
  }

  factory UserPreferences.empty() {
    return UserPreferences(
      language: 'es',
      currency: 'EUR',
      aiEnabled: true,
      exchangeRates: {},
    );
  }
}
