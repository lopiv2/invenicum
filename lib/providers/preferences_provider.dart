import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:invenicum/models/user_preferences.dart';
import 'package:invenicum/services/preferences_service.dart';

class PreferencesProvider with ChangeNotifier {
  final PreferencesService _preferencesService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  UserPreferences _prefs = UserPreferences.empty();
  UserPreferences get prefs => _prefs;

  // Helpers actualizados
  Locale get locale => Locale(_prefs.language);
  bool get aiEnabled => _prefs.aiEnabled;
  // 🔑 Ahora la moneda viene de las preferencias guardadas
  String get selectedCurrency => _prefs.currency;

  PreferencesProvider(this._preferencesService);

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
}
