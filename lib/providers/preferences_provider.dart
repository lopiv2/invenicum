import 'package:flutter/material.dart';
import 'package:invenicum/services/preferences_service.dart';

class PreferencesProvider with ChangeNotifier {
  final PreferencesService _preferencesService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _languageCode = 'en';
  String get languageCode => _languageCode;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  PreferencesProvider(this._preferencesService);

  /// Carga las preferencias del usuario desde el backend
  Future<void> loadPreferences() async {
    try {
      final prefs = await _preferencesService.getPreferences();
      _languageCode = prefs['language'] as String? ?? 'en';
      _locale = Locale(_languageCode);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando preferencias: $e');
      _isInitialized = true;
    }
  }

  /// Actualiza el idioma localmente y en el backend
  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    _locale = Locale(languageCode);
    notifyListeners();

    try {
      await _preferencesService.updateLanguage(languageCode);
    } catch (e) {
      debugPrint('Error actualizando idioma: $e');
      rethrow;
    }
  }
}
