import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:invenicum/data/models/notifications_preferences_model.dart';
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

  // Helpers actualizados
  Locale get locale => Locale(_prefs.language);
  bool get aiEnabled => _prefs.aiEnabled;
  String? get aiProvider => _prefs.aiProvider;
  String? get aiModel => _prefs.aiModel;
  // 🔑 Ahora la moneda viene de las preferencias guardadas
  String get selectedCurrency => _prefs.currency;

  PreferencesProvider(this._preferencesService);

  NotificationSettings get notificationSettings => _prefs.notifications;

  /// Cambia si debemos seguir el tema del sistema operativo
  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    notifyListeners(); // Actualiza la UI inmediatamente

    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool(_keySystemTheme, value);
  }

  /// Cambia manualmente entre modo claro y oscuro
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool(_keyDarkMode, value);
  }

  /// Carga las preferencias completas y actualiza el estado
  Future<void> loadPreferences() async {
    try {
      final json = await _preferencesService.getPreferences();
      _prefs = UserPreferences.fromJson(json);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando preferencias: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // En preferences_provider.dart

  // Lógica para el Drag and Drop
  // Lógica para el Drag and Drop (Reordenar canales)
  void reorderChannels(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;

    // 1. Accedemos a la lista dentro de la clase anidada
    final List<String> items = List.from(_prefs.notifications.channelOrder);
    final String item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // 2. Actualizamos usando el copyWith anidado
    _prefs = _prefs.copyWith(
      notifications: _prefs.notifications.copyWith(channelOrder: items),
    );
    notifyListeners();

    // 3. Sincronizar con backend (enviamos el objeto completo o solo la lista)
    _preferencesService.updateNotificationSettings(_prefs.notifications);
  }

  // Lógica para los switches
  Future<void> setNotificationAlert(String type, bool enabled) async {
    final previousPrefs = _prefs;
    NotificationSettings currentNotifs = _prefs.notifications;
    NotificationSettings updatedNotifs;

    // 🔑 Mapeamos los tipos de la UI a los nuevos campos del modelo
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

    // 3. Actualización optimista del estado principal
    _prefs = _prefs.copyWith(notifications: updatedNotifs);
    notifyListeners();

    try {
      // 🚀 Persistencia: enviamos el objeto que ahora genera las llaves
      // correctas para el backend (alertPreSales, alertLoanReminders, etc.)
      await _preferencesService.updateNotificationSettings(updatedNotifs);
    } catch (e) {
      // Rollback
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error actualizando alertas: $e');
    }
  }

  /// Convierte un monto de la moneda local del usuario a la moneda base (USD)
  double convertToBase(double amount) {
    final rates = _prefs.exchangeRates;

    // Si la moneda actual es USD, el valor ya es la base.
    if (selectedCurrency == 'USD' ||
        rates == null ||
        !rates.containsKey(selectedCurrency)) {
      return amount;
    }

    // Si rates['EUR'] es 0.85 (significa 1 USD = 0.85 EUR)
    // Para pasar de 15€ a USD: 15 / 0.85 = 17.64 USD
    // Si el resultado te dio 17.66, es porque se hizo: 15 * 1.17 (la tasa inversa)

    final double rate = rates[selectedCurrency] ?? 1.0;

    if (rate == 0) return amount;

    // 🔑 LA REGLA DE ORO:
    // Para ir de BASE -> LOCAL: Multiplicar (USD * rate)
    // Para ir de LOCAL -> BASE: Dividir (LOCAL / rate)
    return amount / rate;
  }

  double convertPrice(double amount) {
    final rates = _prefs.exchangeRates;
    final target =
        _prefs.currency; // Moneda elegida por el usuario (EUR, MXN, etc.)

    // Si no hay tasas o el usuario ya eligió USD, devolvemos el monto original
    if (rates == null || rates.isEmpty || target == 'USD') {
      return amount;
    }

    // Obtenemos la tasa para la moneda destino (ej: 0.92 para EUR)
    final double rate = rates[target] ?? 1.0;

    return amount * rate;
  }

  Future<void> setCurrency(String currencyCode) async {
    final previousPrefs = _prefs;

    // 1. Actualización optimista (instantánea en la UI)
    _prefs = _prefs.copyWith(currency: currencyCode);
    notifyListeners();

    try {
      // 2. Persistencia en el backend (usando tu servicio existente)
      // Asegúrate de añadir 'updateCurrency' en tu PreferencesService
      await _preferencesService.updateCurrency(currencyCode);
    } catch (e) {
      // 3. Rollback si falla la red
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error actualizando moneda: $e');
      rethrow;
    }
  }

  /// Actualiza el idioma localmente y en el backend
  Future<void> setLanguage(String languageCode) async {
    final previousPrefs = _prefs;

    // Actualización optimista
    _prefs = _prefs.copyWith(language: languageCode);
    notifyListeners();

    try {
      await _preferencesService.updateLanguage(languageCode);
    } catch (e) {
      _prefs = previousPrefs; // Revertimos si falla
      notifyListeners();
      debugPrint('Error actualizando idioma: $e');
      rethrow;
    }
  }

  /// Actualiza el estado de la IA (On/Off)
  Future<void> setAiEnabled(bool enabled) async {
    final previousPrefs = _prefs;

    // Actualización optimista
    _prefs = _prefs.copyWith(aiEnabled: enabled);
    notifyListeners();

    try {
      await _preferencesService.updateAiStatus(enabled);
    } catch (e) {
      _prefs = previousPrefs; // Revertimos si falla
      notifyListeners();
      debugPrint('Error actualizando estado IA: $e');
      rethrow;
    }
  }

  /// Actualiza el proveedor de IA y el modelo activo
  Future<void> updateAiProvider(String provider, String model) async {
    final previousPrefs = _prefs;

    // Actualización optimista
    _prefs = _prefs.copyWith(aiProvider: provider, aiModel: model);
    notifyListeners();

    try {
      await _preferencesService.updateAiProvider(provider, model);
    } catch (e) {
      _prefs = previousPrefs;
      notifyListeners();
      debugPrint('Error actualizando proveedor de IA: $e');
      rethrow;
    }
  }

  String getSymbolForCurrency(String currencyCode) {
    switch (currencyCode) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'MXN':
      case 'USD':
      default:
        return '\$';
    }
  }
}
