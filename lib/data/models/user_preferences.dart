import 'package:invenicum/data/models/notifications_preferences_model.dart';
import 'package:invenicum/core/utils/constants.dart';

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
  final bool useSystemTheme;
  final bool isDarkMode;
  final bool autoResetFieldsOnSaveAndContinue;
  final bool cloneBusterEnabled;
  final String font;

  // ── Tema ────────────────────────────────────────────────────────────────────
  final String? themeColor;      // e.g. '#55FFFF'
  final String? themeBrightness; // 'light' | 'dark'
  final String? paletteId;       // 'cga' | 'ega' | 'scumm_crt' | null

  UserPreferences({
    this.id,
    this.language = 'en',
    this.currency = AppCurrencies.defaultCurrency,
    this.showAssetTypeLogo = true,
    this.aiEnabled = true,
    this.aiProvider,
    this.aiModel,
    this.userId,
    this.updatedAt,
    this.exchangeRates,
    this.useSystemTheme = true,
    this.isDarkMode = false,
    this.autoResetFieldsOnSaveAndContinue = true,
    this.cloneBusterEnabled = false,
    this.font = 'Default',
    NotificationSettings? notifications,
    this.themeColor,
    this.themeBrightness,
    this.paletteId,
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
      currency: json['currency'] as String? ?? AppCurrencies.defaultCurrency,
      showAssetTypeLogo: json['showAssetTypeLogo'] ?? json['show_asset_type_logo'] ?? true,
      aiEnabled: (json['aiEnabled'] ?? json['ai_enabled'] ?? true) as bool,
      aiProvider: (json['aiProvider'] ?? json['ai_provider']) as String?,
      aiModel: (json['aiModel'] ?? json['ai_model']) as String?,
      userId: json['userId'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      exchangeRates: parsedRates,
      useSystemTheme: json['useSystemTheme'] as bool? ?? true,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      autoResetFieldsOnSaveAndContinue:
          json['autoResetFieldsOnSaveAndContinue'] as bool? ?? true,
      cloneBusterEnabled: json['enableCloneBusterOmatic'] ?? false,
      font: json['font'] ?? 'Default',
      notifications: json['notifications'] != null
          ? NotificationSettings.fromJson(json['notifications'])
          : NotificationSettings(),
      // ── Tema ────────────────────────────────────────────────────────────────
      themeColor: json['themeColor'] as String?,
      themeBrightness: json['themeBrightness'] as String?,
      paletteId: json['paletteId'] as String?,
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
      'autoResetFieldsOnSaveAndContinue': autoResetFieldsOnSaveAndContinue,
      'cloneBusterEnabled': cloneBusterEnabled,
      'font': font,
      'updatedAt': updatedAt?.toIso8601String(),
      'notifications': notifications.toJson(),
      'themeColor': themeColor,
      'themeBrightness': themeBrightness,
      'paletteId': paletteId,
    };
  }

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
    bool? autoResetFieldsOnSaveAndContinue,
    bool? cloneBusterEnabled,
    String? font,
    String? themeColor,
    String? themeBrightness,
    String? paletteId,
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
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoResetFieldsOnSaveAndContinue:
          autoResetFieldsOnSaveAndContinue ?? this.autoResetFieldsOnSaveAndContinue,
      cloneBusterEnabled: cloneBusterEnabled ?? this.cloneBusterEnabled,
      font: font ?? this.font,
      themeColor: themeColor ?? this.themeColor,
      themeBrightness: themeBrightness ?? this.themeBrightness,
      paletteId: paletteId ?? this.paletteId,
    );
  }

  factory UserPreferences.empty() {
    return UserPreferences(
      language: 'en',
      currency: AppCurrencies.defaultCurrency,
      showAssetTypeLogo: true,
      aiEnabled: true,
      useSystemTheme: true,
      isDarkMode: false,
      autoResetFieldsOnSaveAndContinue: true,
      cloneBusterEnabled: false,
      font: 'Default',
      exchangeRates: {},
      notifications: NotificationSettings(),
      themeColor: null,
      themeBrightness: null,
      paletteId: null,
    );
  }
}