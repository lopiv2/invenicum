import 'package:invenicum/data/models/notifications_preferences_model.dart';

class UserPreferences {
  final int? id;
  final String language;
  final String currency;
  final bool showAssetTypeLogo;
  final bool aiEnabled;
  final String? aiProvider;
  final String? aiModel;
  final int? userId;
  final DateTime? updatedAt;
  final Map<String, double>? exchangeRates;
  final NotificationSettings notifications;

  // 🔔 NUEVOS CAMPOS
  final bool useSystemTheme;
  final bool isDarkMode;

  UserPreferences({
    this.id,
    this.language = 'en',
    this.currency = 'USD',
    this.showAssetTypeLogo = true,
    this.aiEnabled = true,
    this.aiProvider,
    this.aiModel,
    this.userId,
    this.updatedAt,
    this.exchangeRates,
    this.useSystemTheme = true, // Por defecto sigue al sistema
    this.isDarkMode = false,    // Solo aplica si useSystemTheme es false
    NotificationSettings? notifications,
  }) : notifications = notifications ?? NotificationSettings();

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    Map<String, double>? parsedRates;
    if (json['exchangeRates'] != null) {
      parsedRates = (json['exchangeRates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    return UserPreferences(
      id: json['id'] as int?,
      language: json['language'] as String? ?? 'en',
      currency: json['currency'] as String? ?? 'USD',
      showAssetTypeLogo: json['showAssetTypeLogo'] ?? json['show_asset_type_logo'] ?? true,
      aiEnabled: (json['aiEnabled'] ?? json['ai_enabled'] ?? true) as bool,
      aiProvider: (json['aiProvider'] ?? json['ai_provider']) as String?,
      aiModel: (json['aiModel'] ?? json['ai_model']) as String?,
      userId: json['userId'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      exchangeRates: parsedRates,
      
      // 🔔 MAPEO DE NUEVOS CAMPOS (Vienen del DTO de Node)
      useSystemTheme: json['useSystemTheme'] as bool? ?? true,
      isDarkMode: json['isDarkMode'] as bool? ?? false,

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
      'aiProvider': aiProvider,
      'aiModel': aiModel,
      'userId': userId,
      'useSystemTheme': useSystemTheme,
      'isDarkMode': isDarkMode,
      'showAssetTypeLogo': showAssetTypeLogo,
      'updatedAt': updatedAt?.toIso8601String(),
      'notifications': notifications.toJson(),
    };
  }

  /// Útil para el PATCH /visual-settings que creamos
  Map<String, dynamic> toVisualSettingsJson() {
    return {
      'useSystemTheme': useSystemTheme,
      'isDarkMode': isDarkMode,
    };
  }

  UserPreferences copyWith({
    int? id,
    String? language,
    String? currency,
    bool? showAssetTypeLogo,
    bool? aiEnabled,
    String? aiProvider,
    String? aiModel,
    Map<String, double>? exchangeRates,
    NotificationSettings? notifications,
    bool? useSystemTheme,
    bool? isDarkMode,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      showAssetTypeLogo: showAssetTypeLogo ?? this.showAssetTypeLogo,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      notifications: notifications ?? this.notifications,
      // 🔔 NUEVOS
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  factory UserPreferences.empty() {
    return UserPreferences(
      language: 'en',
      currency: 'USD',
      showAssetTypeLogo: true,
      aiEnabled: true,
      useSystemTheme: true,
      isDarkMode: false,
      exchangeRates: {},
      notifications: NotificationSettings(),
    );
  }
}