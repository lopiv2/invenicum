// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:invenicum/models/user_data_model.dart';
import '../models/login_response.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserData? _user;
  bool _isLoading = true;

  UserData? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Intentar cargar sesión persistente al iniciar la app
  Future<void> checkAuthStatus() async {
    try {
      final hasToken = await _apiService.isAuthenticated();
      if (hasToken) {
        final user = await _apiService.getMe();
        _user = user; // Si es null, el login se activará
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners(); // El router re-evalúa aquí y te deja entrar
    }
  }

  Future<LoginResponse> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      if (response.success && response.user != null) {
        _user = response.user;
        notifyListeners(); // Notificar inmediatamente después de establecer el usuario
      }

      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
  }
}
