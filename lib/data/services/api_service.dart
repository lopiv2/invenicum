import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invenicum/data/models/user_data_model.dart';
import '../../config/environment.dart';
import '../models/login_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Dio dio = Dio();
  final _storage = const FlutterSecureStorage();

  // 🚀 MEMORIA SÍNCRONA: El secreto para ganar la carrera de milisegundos.
  String? _cachedToken;

  factory ApiService() => _instance;

  Function()? onUnauthorized;

  ApiService._internal() {
    dio.options.baseUrl = '${Environment.apiUrl}${Environment.apiVersion}';
    dio.options.connectTimeout = Duration(
      milliseconds: Environment.connectTimeout,
    );
    dio.options.receiveTimeout = Duration(
      milliseconds: Environment.receiveTimeout,
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 🚩 CAMBIO CRÍTICO: Eliminamos el 'await' de aquí.
          // Si el token no está en _cachedToken, no lo buscamos en el disco dentro del interceptor
          // porque el disco es demasiado lento para peticiones en ráfaga.

          if (_cachedToken != null) {
            options.headers['Authorization'] = 'Bearer $_cachedToken';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            _cachedToken = null;
            _storage.delete(key: Environment.authTokenKey);
            if (onUnauthorized != null) {
              onUnauthorized!();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // ----------------------------------------------------
  // MÉTODOS DE SEGURIDAD
  // ----------------------------------------------------

  /// Cambia la contraseña del usuario actual
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        '/auth/change-password', // Ajusta a tu ruta de Node.js/Backend
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      // Si el backend devuelve success: true o simplemente un 200 OK
      return response.data['success'] == true || response.statusCode == 200;
    } on DioException catch (e) {
      // Capturamos el error del backend (ej: "La contraseña actual no es correcta")
      final errorMessage =
          e.response?.data['message'] ??
          e.response?.data['error'] ??
          'Error al cambiar la contraseña';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error de conexión al cambiar contraseña');
    }
  }

  /// Solicita un correo de recuperación
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await dio.post(
        '/auth/forgot-password', // Ajusta a tu ruta
        data: {'email': email},
      );
      return response.data['success'] == true || response.statusCode == 200;
    } catch (e) {
      print("ApiService: Error en password reset request: $e");
      return false;
    }
  }

  // ----------------------------------------------------
  // MÉTODOS DE USUARIO
  // ----------------------------------------------------

  Future<UserData?> updateProfile({
    required String name,
    String? username,
    String? githubHandle,
  }) async {
    try {
      final response = await dio.put(
        '/users/profile', // Ajusta esta ruta según tu backend
        data: {
          'name': name,
          'username': username,
          'githubHandle': githubHandle,
        },
      );

      // Tu backend devuelve { message: "...", user: {...} }
      final responseData = response.data;

      if (responseData['user'] != null) {
        return UserData.fromJson(responseData['user']);
      }
      return null;
    } on DioException catch (e) {
      // Manejo de errores específico para saber si el username está duplicado
      final errorMessage =
          e.response?.data['error'] ?? 'Error al actualizar perfil';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // lib/services/api_service.dart

  Future<Map<String, dynamic>?> getGitHubConfig() async {
    try {
      // Recuerda que esta ruta en Node.js debe ser pública (sin verifyToken)
      // para que la app pueda consultarla antes de iniciar el flujo
      final response = await dio.get('/auth/github/config');
      return response.data;
    } catch (e) {
      print("ApiService: Error al pedir config de GitHub: $e");
      return null;
    }
  }

  // Método específico para desconectar GitHub
  Future<bool> disconnectGitHub() async {
    try {
      final response = await dio.post('/auth/github/disconnect');

      return response.data['success'] == true;
    } catch (e) {
      print("ApiService: Error al desconectar GitHub: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> completeGitHubOAuth(String code) async {
    try {
      // Enviamos el código al backend.
      // Es el backend quien tiene el CLIENT_SECRET y hará el intercambio real.
      final response = await dio.post(
        '/auth/github/complete',
        data: {'code': code},
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> validateGitHubWithBackend(String handle) async {
    try {
      final response = await dio.post(
        '/users/verify-github',
        data: {'handle': handle},
      );

      if (response.statusCode == 200) {
        // Retornamos la data que nos da nuestro server (avatarUrl, etc)
        return response.data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ----------------------------------------------------
  // MÉTODOS DE AUTENTICACIÓN
  // ----------------------------------------------------

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await dio.post(
        Environment.loginEndpoint,
        data: {'username': username, 'password': password},
      );

      // Normalización de la respuesta (por si viene envuelta en 'data')
      Map<String, dynamic> responseData = response.data;
      if (responseData['data'] is Map) {
        responseData = responseData['data'] as Map<String, dynamic>;
      }

      final loginResponse = LoginResponse.fromJson(responseData);

      if (loginResponse.success && loginResponse.token != null) {
        // 🔑 PRIMERO en memoria (instantáneo para las siguientes peticiones)
        _cachedToken = loginResponse.token;
        // 🔑 SEGUNDO en disco (asíncrono, no bloquea el flujo)
        _storage.write(key: Environment.authTokenKey, value: _cachedToken!);
      }
      return loginResponse;
    } on DioException catch (e) {
      return LoginResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Error de autenticación',
      );
    }
  }

  // 🚩 REEMPLAZO: Este método se llama UNA SOLA VEZ al arrancar la app (en main.dart)
  Future<void> initializeToken() async {
    _cachedToken = await _storage.read(key: Environment.authTokenKey);
  }

  // Getter síncrono para los Providers
  String? get currentToken => _cachedToken;

  Future<String?> getToken() async =>
      _cachedToken ?? await _storage.read(key: Environment.authTokenKey);

  Future<UserData?> getMe() async {
    try {
      final response = await dio.get('/auth/me');
      return UserData.fromJson(response.data['user'] ?? response.data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async =>
      _cachedToken != null ||
      (await _storage.read(key: Environment.authTokenKey)) != null;

  Future<void> logout() async {
    _cachedToken = null;
    await _storage.delete(key: Environment.authTokenKey);
  }
}
