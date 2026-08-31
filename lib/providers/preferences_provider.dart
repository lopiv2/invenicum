import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/core/utils/loading_animation.dart';
import 'package:invenicum/data/models/notifications_preferences_model.dart';
import 'package:invenicum/data/models/overlay_image_config_model.dart';
import 'package:invenicum/data/models/user_preferences.dart';
import 'package:invenicum/data/services/preferences_service.dart';

class PreferencesProvider with ChangeNotifier {
  final PreferencesService _preferencesService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool _useSystemTheme = false;
  bool get useSystemTheme => _useSystemTheme;
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  UserPreferences _prefs = UserPreferences.empty();
  UserPreferences get prefs => _prefs;

  Map<String, double>? get exchangeRates => _prefs.exchangeRates;

  // Updated helpers
  Locale get locale => Locale(_prefs.language);
  bool get aiEnabled => _prefs.aiEnabled;
  String? get aiProvider => _prefs.aiProvider;
  String? get aiModel => _prefs.aiModel;
  // 🔑 Now currency comes from saved preferences
  String get selectedCurrency => _prefs.currency;
  bool get showAssetTypeLogo => _prefs.showAssetTypeLogo;
  bool get autoResetFieldsOnSaveAndContinue =>
      _prefs.autoResetFieldsOnSaveAndContinue;
  bool get cloneBusterEnabled => _prefs.cloneBusterEnabled;
  String get selectedFontFamily => _prefs.font;
  LoadingAnimation get loadingAnimation => _prefs.loadingAnimation;
  List<OverlayImageConfig> get crossToonConfigs => _prefs.crossToonConfigs;

  PreferencesProvider(this._preferencesService);

  NotificationSettings get notificationSettings => _prefs.notifications;

  /// Changes whether to follow the operating system theme
  Future<void> setUseSystemTheme(bool value) async {
    // 1. Save full current state in case network fails
    final bool oldSystemValue = _useSystemTheme;
    final bool oldDarkValue = _isDarkMode;
    final UserPreferences oldPrefs = _prefs;

    // 2. Apply business rule locally optimistically
    _useSystemTheme = value;

    if (value == true) {
      // RULE: If auto is enabled, manual dark mode MUST be false (0)
      _isDarkMode = false;
    }

    // Sync the main UserPreferences object
    _prefs = _prefs.copyWith(
      useSystemTheme: _useSystemTheme,
      isDarkMode: _isDarkMode,
    );

    notifyListeners(); // UI updates instantly

    try {
      // 3. Persist in the backend
      await _preferencesService.updateVisualStatus(
        useSystemTheme: _useSystemTheme,
        isDarkMode: _isDarkMode,
      );
    } catch (e) {
      // 4. If error, revert everything to previous state
      _useSystemTheme = oldSystemValue;
      _isDarkMode = oldDarkValue;
      _prefs = oldPrefs;
      notifyListeners();
      debugPrint('Error persisting visual status: $e');
      rethrow;
    }
  }

  /// Manually switches between light and dark mode
  Future<void> setDarkMode(bool value) async {
    // Save state for rollback
    final bool oldSystemValue = _useSystemTheme;
    final bool oldDarkValue = _isDarkMode;
    final UserPreferences oldPrefs = _prefs;

    // --- REVERSE LOGIC ---
    _isDarkMode = value;

    // If user manually enables dark mode,
    // assume they no longer want to follow the system.
    if (value == true) {
      _useSystemTheme = false;
    }

    // Update the global object
    _prefs = _prefs.copyWith(
      isDarkMode: _isDarkMode,
      useSystemTheme: _useSystemTheme,
    );

    notifyListeners();

    try {
      await _preferencesService.updateVisualStatus(
        useSystemTheme: _useSystemTheme,
        isDarkMode: _isDarkMode,
      );
    } catch (e) {
      // Rollback
      _isDarkMode = oldDarkValue;
      _useSystemTheme = oldSystemValue;
      _prefs = oldPrefs;
      notifyListeners();
      debugPrint('Error persisting dark mode: $e');
      rethrow;
    }
  }

  Future<void> updatePreference(String key, dynamic value) async {
    // Optimistic update
    _prefs = _prefs.copyWith(
      showAssetTypeLogo: key == 'showAssetTypeLogo'
          ? value as bool
          : _prefs.showAssetTypeLogo,
    );
    notifyListeners();

    try {
      final updated = await _preferencesService.updatePreference(key, value);
      _prefs = updated;
      notifyListeners();
    } catch (e) {
      await loadPreferences(); // rollback
      rethrow;
    }
  }

  Future<void> loadPreferences() async {
    try {
      final json = await _preferencesService.getPreferences();
      _prefs = UserPreferences.fromJson(json);

      _useSystemTheme = _prefs.useSystemTheme;
      _isDarkMode = _prefs.isDarkMode;

      _isInitialized = true;
      notifyListeners(); // ← this triggers ProxyProvider2 in main.dart,
      //   which calls prev.initializeTheme() with the
      //   3 fields already in _prefs
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // In preferences_provider.dart

  // Drag and Drop logic — onReorderItem already adjusts newIndex
  void reorderChannels(int oldIndex, int newIndex) {

    // 1. Access the list inside the nested class
    final List<String> items = List.from(_prefs.notifications.channelOrder);
    final String item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // 2. Update using nested copyWith
    _prefs = _prefs.copyWith(
      notifications: _prefs.notifications.copyWith(channelOrder: items),
    );
    notifyListeners();

    // 3. Sync with backend (send full object or just the list)
    _preferencesService.updateNotificationSettings(_prefs.notifications);
  }

  // Switch logic
  Future<void> setNotificationAlert(String type, bool enabled) async {
    final previousPrefs = _prefs;
    NotificationSettings currentNotifs = _prefs.notifications;
    NotificationSettings updatedNotifs;

    // 🔑 Map UI types to the new model fields
    switch (type) {
      case 'stock':
        updatedNotifs = currentNotifs.copyWith(alertStockLow: enabled);
        break;
      case 'preorder':
        updatedNotifs = currentNotifs.copyWith(alertPreSales: enabled);
        break;
      case 'loan':
        updatedNotifs = currentNotifs.copyWith(alertLoanReminders: enabled);
        break;
      case 'overdue':
        updatedNotifs = currentNotifs.copyWith(alertOverdueLoans: enabled);
        break;
      case 'maintenance':
        updatedNotifs = currentNotifs.copyWith(alertMaintenance: enabled);
        break;
      case 'price':
        updatedNotifs = currentNotifs.copyWith(alertPriceChange: enabled);
        break;
      default:
        return;
    }

    // 3. Optimistic update of main state
    _prefs = _prefs.copyWith(notifications: updatedNotifs);
    notifyListeners();

    try {
      // 🚀 Persistence: send the object that now generates the correct
      // keys for the backend (alertPreSales, alertLoanReminders, etc.)
      await _preferencesService.updateNotificationSettings(updatedNotifs);
    } catch (e) {
      // Rollback
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error updating alerts: $e');
    }
  }

  /// Converts an amount from the user's local currency to the base currency (USD)
  double convertToBase(double amount) {
    final rates = _prefs.exchangeRates;

    // If the current currency is USD, the value is already the base.
    if (selectedCurrency == AppCurrencies.usd ||
        rates == null ||
        !rates.containsKey(selectedCurrency)) {
      return amount;
    }

    // If rates['EUR'] is 0.85 (means 1 USD = 0.85 EUR)
    // To convert 15€ to USD: 15 / 0.85 = 17.64 USD
    // If you got 17.66, it's because you did: 15 * 1.17 (the inverse rate)

    final double rate = rates[selectedCurrency] ?? 1.0;

    if (rate == 0) return amount;

    // 🔑 THE GOLDEN RULE:
    // To go from BASE -> LOCAL: Multiply (USD * rate)
    // To go from LOCAL -> BASE: Divide (LOCAL / rate)
    return amount / rate;
  }

  double convertPrice(double amount) {
    final rates = _prefs.exchangeRates;
    final target =
        _prefs.currency; // Currency chosen by the user (EUR, MXN, etc.)

    // If no rates or user already chose USD, return original amount
    if (rates == null || rates.isEmpty || target == AppCurrencies.usd) {
      return amount;
    }

    // Get the rate for the target currency (e.g., 0.92 for EUR)
    final double rate = rates[target] ?? 1.0;

    return amount * rate;
  }

  Future<void> setCurrency(String currencyCode) async {
    final previousPrefs = _prefs;

    // 1. Optimistic update (instant UI)
    _prefs = _prefs.copyWith(currency: currencyCode);
    notifyListeners();

    try {
      // 2. Persist in the backend (using your existing service)
      // Make sure to add 'updateCurrency' in your PreferencesService
      await _preferencesService.updateCurrency(currencyCode);
    } catch (e) {
      // 3. Rollback if network fails
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error actualizando moneda: $e');
      rethrow;
    }
  }

  /// Updates the language locally and in the backend
  Future<void> setLanguage(String languageCode) async {
    final previousPrefs = _prefs;

    // Optimistic update
    _prefs = _prefs.copyWith(language: languageCode);
    notifyListeners();

    try {
      await _preferencesService.updateLanguage(languageCode);
    } catch (e) {
      _prefs = previousPrefs; // Rollback if it fails
      notifyListeners();
      debugPrint('Error updating language: $e');
      rethrow;
    }
  }

  /// Updates the AI state (On/Off)
  Future<void> setAiEnabled(bool enabled) async {
    final previousPrefs = _prefs;

    // Optimistic update
    _prefs = _prefs.copyWith(aiEnabled: enabled);
    notifyListeners();

    try {
      await _preferencesService.updateAiStatus(enabled);
    } catch (e) {
      _prefs = previousPrefs; // Rollback if it fails
      notifyListeners();
      debugPrint('Error updating AI state: $e');
      rethrow;
    }
  }

  /// Updates the AI provider and active model
  Future<void> updateAiProvider(String provider, String model) async {
    final previousPrefs = _prefs;

    _prefs = _prefs.copyWith(aiProvider: provider, aiModel: model);
    notifyListeners();

    try {
      await _preferencesService.updateAiProvider(provider, model);
      final json = await _preferencesService.getPreferences();
      _prefs = UserPreferences.fromJson(json);
      notifyListeners();
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error updating AI provider: $e');
      rethrow;
    }
  }

  Future<void> setAutoResetFieldsOnSaveAndContinue(bool enabled) async {
    final previousPrefs = _prefs;

    _prefs = _prefs.copyWith(autoResetFieldsOnSaveAndContinue: enabled);
    notifyListeners();

    try {
      await _preferencesService.updatePreference(
        'autoResetFieldsOnSaveAndContinue',
        enabled,
      );
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error updating auto reset fields preference: $e');
      rethrow;
    }
  }

  Future<void> setCloneBusterEnabled(bool enabled) async {
    final previousPrefs = _prefs;

    _prefs = _prefs.copyWith(cloneBusterEnabled: enabled);
    notifyListeners();

    try {
      await _preferencesService.updatePreference(
        'enableCloneBusterOmatic',
        enabled,
      );
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error updating clone buster preference: $e');
      rethrow;
    }
  }

  Future<void> setFontFamily(String font) async {
    final previousPrefs = _prefs;

    _prefs = _prefs.copyWith(font: font);
    notifyListeners();

    try {
      await _preferencesService.updatePreference('font', font);
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error updating font family preference: $e');
      rethrow;
    }
  }

  Future<void> setLoadingAnimation(LoadingAnimation animation) async {
    final previousPrefs = _prefs;

    _prefs = _prefs.copyWith(loadingAnimation: animation);
    notifyListeners();

    try {
      await _preferencesService.updatePreference(
        'loadingAnimation',
        animation.value,
      );
      _prefs = _prefs.copyWith(loadingAnimation: animation);
      notifyListeners();
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error updating loading animation preference: $e');
      rethrow;
    }
  }

  Future<void> addCrossToonConfig({
    required Uint8List imageBytes,
    required String imageName,
    required OverlayImageConfig config,
  }) async {
    try {
      final saved = await _preferencesService.createCrossToon(
        imageBytes: imageBytes,
        imageName: imageName,
        config: config,
      );
      final updatedList = List<OverlayImageConfig>.from(_prefs.crossToonConfigs)
        ..add(saved);
      _prefs = _prefs.copyWith(crossToonConfigs: updatedList);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding cross-toon config: $e');
      rethrow;
    }
  }

  Future<void> updateCrossToonConfig({
    required int index,
    required OverlayImageConfig config,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final previousPrefs = _prefs;
    final existing = _prefs.crossToonConfigs[index];
    if (existing.id == null) return;
    try {
      final saved = await _preferencesService.updateCrossToon(
        id: existing.id!,
        imageBytes: imageBytes,
        imageName: imageName,
        config: config,
      );
      final updatedList = List<OverlayImageConfig>.from(
        _prefs.crossToonConfigs,
      );
      updatedList[index] = saved;
      _prefs = _prefs.copyWith(crossToonConfigs: updatedList);
      notifyListeners();
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error updating cross-toon config: $e');
    }
  }

  Future<void> removeCrossToonConfig(int index) async {
    final previousPrefs = _prefs;
    final config = _prefs.crossToonConfigs[index];
    final updatedList = List<OverlayImageConfig>.from(_prefs.crossToonConfigs)
      ..removeAt(index);
    _prefs = _prefs.copyWith(crossToonConfigs: updatedList);
    notifyListeners();
    try {
      if (config.id != null) {
        await _preferencesService.deleteCrossToon(config.id!);
      }
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error removing cross-toon config: $e');
    }
  }

  Future<void> toggleCrossToonEnabled(int index, bool enabled) async {
    final previousPrefs = _prefs;
    final config = _prefs.crossToonConfigs[index];
    final updated = config.copyWith(enabled: enabled);
    final updatedList = List<OverlayImageConfig>.from(_prefs.crossToonConfigs)
      ..[index] = updated;
    _prefs = _prefs.copyWith(crossToonConfigs: updatedList);
    notifyListeners();
    if (config.id == null) return;
    try {
      await _preferencesService.updateCrossToon(
        id: config.id!,
        config: updated,
      );
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error toggling cross-toon enabled: $e');
    }
  }

  String getSymbolForCurrency(String currencyCode) {
    return AppCurrencies.getSymbol(currencyCode);
  }

  bool usesTrailingCurrencySymbol(String currencyCode) {
    return AppCurrencies.usesTrailingSymbol(currencyCode);
  }

  int getDecimalDigitsForCurrency(String currencyCode) {
    return AppCurrencies.getDecimalDigits(currencyCode);
  }

  String formatPrice(double amount, {String? currencyCode}) {
    final targetCurrency = currencyCode ?? selectedCurrency;
    final symbol = getSymbolForCurrency(targetCurrency);
    final useTrailingSymbol = usesTrailingCurrencySymbol(targetCurrency);
    final decimalDigits = getDecimalDigitsForCurrency(targetCurrency);

    final formatter = NumberFormat.decimalPattern(locale.toLanguageTag())
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;

    final formattedAmount = formatter.format(amount);

    return useTrailingSymbol
        ? '$formattedAmount $symbol'
        : '$symbol$formattedAmount';
  }
}
