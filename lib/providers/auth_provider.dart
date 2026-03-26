import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:invenicum/data/services/toast_service.dart';
import '../data/models/user_data_model.dart';
import '../data/models/login_response.dart';
import '../data/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserData? _user;
  String? _token;
  bool _isLoading = true;

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

  /// [tokenAlreadyInitialized] — pasar true desde main.dart cuando ya se ha
  /// llamado a ApiService().initializeToken() antes del runApp.
  /// Evita la doble inicialización y los notifyListeners() intermedios
  /// que pueden disparar el redirect del router con estado inconsistente.
  AuthProvider({bool tokenAlreadyInitialized = false}) {
    _apiService.onUnauthorized = () {
      // 🚩 CLAVE: Solo actuar si todavía no hemos procesado la expiración
      if (isAuthenticated) {
        _handleSessionExpired(); // Esto pone _user y _token a null inmediatamente

        ToastService.error('Sesión expirada');
      }
    };
    _initialize(skipTokenInit: tokenAlreadyInitialized);
  }

  Future<void> _initialize({bool skipTokenInit = false}) async {
    // Si el token ya fue inicializado en main.dart antes del runApp,
    // nos saltamos initializeToken() y los notifyListeners() intermedios
    // que provocan evaluaciones del redirect con estado inconsistente.
    try {
      if (!skipTokenInit) {
        await _apiService.initializeToken();
      }

      if (_apiService.currentToken != null) {
        try {
          final userData = await _apiService.getMe().timeout(
            const Duration(seconds: 15),
            onTimeout: () => null,
          );

          if (userData != null) {
            _user = userData;
            _token = _apiService.currentToken;
          } else {
            // getMe() devolvió null sin excepción — error temporal.
            // Mantenemos token Y creamos un usuario mínimo desde el token
            // para que isAuthenticated = true y el router no redirija al login.
            debugPrint("⚠️ AuthProvider: getMe() sin datos, manteniendo sesión");
            _token = _apiService.currentToken;
            // Si no tenemos _user, usamos el último conocido o uno vacío
            // para que isAuthenticated no falle por _user == null.
            _user ??= UserData.empty();
          }
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            // 401 explícito → token inválido → logout
            debugPrint("⚠️ AuthProvider: token inválido (401) — cerrando sesión");
            await _apiService.logout();
          } else {
            // Error de red, 404, 5xx, timeout → no cerramos sesión.
            // Mantenemos token Y _user para que isAuthenticated siga siendo true.
            debugPrint("⚠️ AuthProvider: error de red (${e.response?.statusCode}) — manteniendo sesión");
            _token = _apiService.currentToken;
            _user ??= UserData.empty();
          }
        }
      }
    } catch (e) {
      debugPrint("❌ AuthProvider._initialize error: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Una sola notificación al terminar — limpia y predecible.
    }
  }

  void _handleSessionExpired() {
    _user = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Solicita un correo de recuperación de contraseña
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _apiService.requestPasswordReset(email);
    } catch (e) {
      debugPrint("Error solicitando reset: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia la contraseña del usuario autenticado
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Llamamos al servicio (asegúrate de que el nombre coincida con tu ApiService)
      final success = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      // 2. Si el servicio no lanzó excepción pero devolvió false
      if (!success) {
        throw Exception("No se pudo actualizar la contraseña.");
      }

      return true; // Todo salió bien
    } on Exception catch (e) {
      // 3. Capturamos el error específico (ej: "Contraseña actual incorrecta")
      debugPrint("Error en updatePassword: $e");
      rethrow; // Lanzamos para que el ToastService en la UI lo muestre
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    try {
      await _apiService.initializeToken();
      final savedToken = _apiService.currentToken;

      if (savedToken != null) {
        try {
          final userData = await _apiService.getMe().timeout(
            const Duration(seconds: 15),
            onTimeout: () => null,
          );

          if (userData != null) {
            _token = savedToken;
            _user = userData;
          } else {
            await _apiService.logout();
            _token = null;
            _user = null;
          }
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            debugPrint("⚠️ checkAuthStatus: 401 — token expirado, cerrando sesión");
            await _apiService.logout();
            _token = null;
            _user = null;
          } else {
            // Error de red o servidor → mantenemos sesión con usuario vacío
            debugPrint("⚠️ checkAuthStatus: error de red (${e.response?.statusCode}) — manteniendo sesión");
            _token = savedToken;
            _user ??= UserData.empty();
          }
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