import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:invenicum/models/user_preferences.dart';
import 'package:invenicum/services/preferences_service.dart';

class PreferencesProvider with ChangeNotifier {
  final PreferencesService _preferencesService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // El objeto de preferencias centralizado
  UserPreferences _prefs = UserPreferences.empty();
  UserPreferences get prefs => _prefs;

  // Helpers para facilitar el acceso desde la UI
  Locale get locale => Locale(_prefs.language);
  bool get aiEnabled => _prefs.aiEnabled;

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
      notifyListeners(); // Notificamos para que la app sepa que ya terminó de intentar cargar
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