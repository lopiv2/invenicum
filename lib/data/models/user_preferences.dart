import 'package:invenicum/data/models/notifications_preferences_model.dart';

class UserPreferences {
  final int? id;
  final String language;
  final String currency;
  final bool aiEnabled;
  final int? userId;
  final DateTime? updatedAt;
  final Map<String, double>? exchangeRates;
  final NotificationSettings notifications;

  UserPreferences({
    this.id,
    this.language = 'es',
    this.currency = 'USD',
    this.aiEnabled = true,
    this.userId,
    this.updatedAt,
    this.exchangeRates,
    NotificationSettings? notifications,
  }) : this.notifications = notifications ?? NotificationSettings();

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    Map<String, double>? parsedRates;
    if (json['exchangeRates'] != null) {
      parsedRates = (json['exchangeRates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    return UserPreferences(
      id: json['id'] as int?,
      language: json['language'] as String? ?? 'es',
      currency: json['currency'] as String? ?? 'USD',
      aiEnabled: (json['aiEnabled'] ?? json['ai_enabled'] ?? true) as bool,
      userId: json['userId'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      exchangeRates: parsedRates,
      // 🚀 CLAVE: Pasamos el JSON completo. NotificationSettings.fromJson
      // ahora buscará 'alertStockLow', etc., directamente en la raíz.
      notifications: json['notifications'] != null
          ? NotificationSettings.fromJson(json['notifications'])
          : NotificationSettings(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'currency': currency,
      'aiEnabled': aiEnabled,
      'userId': userId,
      // 🚀 Aplanamos las notificaciones para que el Backend las reciba
      // como espera su DTO (UserPreferencesDTO.fromRequest).
      'notifications': notifications.toJson(),
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'language': language,
      'currency': currency,
      'aiEnabled': aiEnabled,
      // 🚀 Incluimos las alertas en cada actualización de preferencias.
      ...notifications.toJson(),
    };
  }

  UserPreferences copyWith({
    int? id,
    String? language,
    String? currency,
    bool? aiEnabled,
    Map<String, double>? exchangeRates,
    NotificationSettings? notifications,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      notifications: notifications ?? this.notifications,
    );
  }

  factory UserPreferences.empty() {
    return UserPreferences(
      language: 'es',
      currency: 'USD',
      aiEnabled: true,
      exchangeRates: {},
      notifications: NotificationSettings(),
    );
  }
}
