import 'package:flutter/material.dart';
import '../models/user_data_model.dart';
import '../models/login_response.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserData? _user;
  String? _token;
  bool _isLoading = false;

  // Getters
  UserData? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  
  // 🚩 MEJORA: Comprobación más robusta de autenticación
  bool get isAuthenticated => _user != null && _token != null;

  /// Verifica si hay una sesión guardada al abrir la app
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    // Importante: No notificamos aquí para evitar parpadeos innecesarios en el splash
    
    try {
      // 1. Cargamos el token del storage a la memoria del ApiService inmediatamente
      await _apiService.initializeToken();
      
      final savedToken = _apiService.currentToken;
      
      if (savedToken != null) {
        // 2. Si hay token, intentamos recuperar el perfil del usuario
        final userData = await _apiService.getMe();
        
        if (userData != null) {
          _token = savedToken;
          _user = userData;
        } else {
          // Token expirado o inválido: limpieza total
          await _apiService.logout();
          _token = null;
          _user = null;
        }
      }
    } catch (e) {
      debugPrint("Error verificando estado de auth: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Proceso de inicio de sesión
  Future<LoginResponse> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      if (response.success && response.token != null) {
        // 🚩 EL PUNTO CLAVE:
        // El ApiService ya guardó el token en su memoria interna (_cachedToken)
        // dentro de su propio método login(). 
        
        _token = response.token;
        _user = response.user;

        // Aquí no necesitamos esperar, el token ya es accesible síncronamente
        // para cualquier petición que lancen los ProxyProviders en main.dart
      }
      return response;
    } catch (e) {
      return LoginResponse(success: false, message: "Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  /// Cierre de sesión completo
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
      _user = null;
      _token = null;
    } catch (e) {
      debugPrint("Error durante el logout: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método para actualizar datos del usuario sin re-loguear
  void updateUser(UserData newUser) {
    _user = newUser;
    notifyListeners();
  }
}