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
  String? _validatedAvatarUrl;
  String? get validatedAvatarUrl => _validatedAvatarUrl;

  // 🚩 MEJORA: Comprobación más robusta de autenticación
  bool get isAuthenticated => _user != null && _token != null;

  // 🚩 NUEVO: Verificación de cuenta de GitHub vinculada
  bool get isGitHubLinked =>
      _user?.githubHandle != null && _user!.githubHandle!.isNotEmpty;

  AuthProvider() {
    _apiService.onUnauthorized = () {
      // Si la API detecta un 401, ejecutamos la limpieza local
      _handleSessionExpired();
    };
  }

  void _handleSessionExpired() {
    _user = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Consulta al backend el estado actual de la vinculación con GitHub
  Future<bool> checkGitHubStatus() async {
    try {
      final userData = await _apiService.getMe();
      if (userData != null) {
        _user = userData;
        notifyListeners();
        return isGitHubLinked;
      }
      return false;
    } catch (e) {
      debugPrint("Error verificando vinculación GitHub: $e");
      return false;
    }
  }

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

  /// Obtiene la configuración pública de GitHub (ClientId) desde el backend
  Future<Map<String, dynamic>> getGitHubConfig() async {
    try {
      final config = await _apiService.getGitHubConfig();
      if (config != null && config['success'] == true) {
        return {'clientId': config['clientId']};
      }
      return {};
    } catch (e) {
      debugPrint("Error obteniendo configuración de GitHub: $e");
      return {};
    }
  }

  Future<void> disconnectGitHubAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.disconnectGitHub();

      if (success) {
        // 🚩 ACTUALIZACIÓN LOCAL:
        // Usamos copyWith para limpiar los campos y que la UI reaccione (el tick verde desaparezca)
        if (_user != null) {
          _user = _user!.copyWith(
            githubHandle: "", // O null si tu copyWith lo permite
            avatarUrl: "", // Opcional: resetear el avatar
          );
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error en AuthProvider al desconectar GitHub: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> linkGitHubAccount(String code) async {
    _setLoading(true);

    try {
      final response = await _apiService.completeGitHubOAuth(code);

      if (response != null && response['success'] == true) {
        final githubData = response['data'];

        _user = _user?.copyWith(
          githubHandle: githubData['githubHandle'],
          avatarUrl: githubData['avatarUrl'],
          githubId: githubData['githubId']?.toString(),
          githubLinkedAt: DateTime.now(),
          username: githubData['username'],
        );

        _validatedAvatarUrl = githubData['avatarUrl'];

        _setLoading(false);
        notifyListeners(); // Esto redibuja el perfil con el tick verde
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint("Error linking GitHub: $e");
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // lib/providers/auth_provider.dart

  Future<Map<String, dynamic>?> checkGitHubIdentity(String handle) async {
    if (handle.isEmpty) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.validateGitHubWithBackend(handle);

      if (data != null) {
        _validatedAvatarUrl = data['avatarUrl'];

        _isLoading = false;
        notifyListeners();
        return data;
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
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

  /// Actualiza el perfil del usuario (Nombre, Username, GitHub)
  /// Actualiza el perfil del usuario y notifica a la app
  Future<void> updateProfile({
    required String name,
    String? username,
    String? githubHandle,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateProfile(
        name: name,
        username: username,
        githubHandle: githubHandle,
      );

      if (updatedUser != null) {
        _user = updatedUser; // Actualizamos el usuario local
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error en updateProfile: $e");
      rethrow; // Devolvemos el error a la pantalla (ProfileScreen) para mostrar el SnackBar
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
