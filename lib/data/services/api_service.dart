import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/user_data_model.dart';
import 'package:invenicum/data/services/veni_chatbot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/environment.dart';
import '../models/login_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Dio dio = Dio();

  // 🚀 MEMORIA SÍNCRONA: El secreto para ganar la carrera de milisegundos.
  String? _cachedToken;

  factory ApiService() => _instance;

  Function()? onUnauthorized;

  ApiService._internal() {
    dio.options.baseUrl = Environment.baseUrl;
    dio.options.connectTimeout = Duration(
      milliseconds: Environment.connectTimeout,
    );
    dio.options.receiveTimeout = Duration(
      milliseconds: Environment.receiveTimeout,
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_cachedToken != null) {
            options.headers['Authorization'] = 'Bearer $_cachedToken';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final dynamic rawData = e.response?.data;
            final String message = rawData is Map<String, dynamic>
                ? (rawData['message']?.toString() ?? '')
                : '';

            final bool hadAuthHeader =
                e.requestOptions.headers['Authorization'] != null;

            // Solo cerramos sesión si el 401 viene de una validación JWT real.
            final bool isJwtUnauthorized =
                message == 'Invalid or expired token' ||
                message == 'Token no proporcionado';

            if (hadAuthHeader && isJwtUnauthorized) {
              _cachedToken = null;
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(Environment.authTokenKey);
              if (onUnauthorized != null) {
                onUnauthorized!();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // ----------------------------------------------------
  // 🆕 PRIMER USO / SETUP
  // ----------------------------------------------------

  /// Consulta al backend si la app necesita configuración inicial.
  /// Devuelve [true] si es el primer arranque (tabla users vacía o no existe),
  /// [false] si ya hay al menos un usuario registrado.
  /// En caso de error de red se devuelve [false] para no bloquear el arranque.
  Future<bool> checkFirstRun() async {
    try {
      final response = await dio.get('/auth/first-run');
      // Se espera: { "firstRun": true } o { "firstRun": false }
      return response.data['firstRun'] == true;
    } on DioException catch (e) {
      // 404 → endpoint no implementado aún → no bloqueamos
      // 5xx → error del servidor → no bloqueamos
      print('ApiService: checkFirstRun error ${e.response?.statusCode}: $e');
      return false;
    } catch (e) {
      print('ApiService: checkFirstRun unexpected error: $e');
      return false;
    }
  }

  /// Crea el primer usuario administrador de la plataforma.
  /// Solo debe poder llamarse cuando [checkFirstRun()] devuelve [true].
  /// Lanza [Exception] con el mensaje del backend si falla.
  Future<void> createFirstAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await dio.post(
        '/auth/setup',
        data: {'name': name, 'email': email, 'password': password},
      );
      // El backend simplemente devuelve 201. No necesitamos el cuerpo.
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.response?.data['error'] ??
          'Error al crear el administrador';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
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
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      return response.data['success'] == true || response.statusCode == 200;
    } on DioException catch (e) {
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
        '/auth/forgot-password',
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
        '/users/profile',
        data: {
          'name': name,
          'username': username,
          'githubHandle': githubHandle,
        },
      );
      final responseData = response.data;
      if (responseData['user'] != null) {
        return UserData.fromJson(responseData['user']);
      }
      return null;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['error'] ?? 'Error al actualizar perfil';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<Map<String, dynamic>?> getGitHubConfig() async {
    try {
      final response = await dio.get('/auth/github/config');
      return response.data;
    } catch (e) {
      print("ApiService: Error al pedir config de GitHub: $e");
      return null;
    }
  }

  Future<bool> disconnectGitHub() async {
    try {
      final response = await dio.post('/auth/github/disconnect');
      return response.data['success'] == true;
    } catch (e) {
      print("ApiService: Error al desconectar GitHub: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> completeGitHubOAuth(
    String code, {
    String? redirectUri,
  }) async {
    try {
      final Map<String, dynamic> payload = {'code': code};
      if (redirectUri != null && redirectUri.isNotEmpty) {
        payload['redirectUri'] = redirectUri;
      }

      final response = await dio.post(
        '/auth/github/complete',
        data: payload,
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
        return response.data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Consulta al backend por el estado de versión de la app.
  ///
  /// Endpoint esperado en backend:
  /// GET /app/version/check?currentVersion=x.y.z
  /// Respuesta esperada (ejemplo):
  /// {
  ///   "latestVersion": "1.2.0",
  ///   "hasUpdate": true,
  ///   "releasesUrl": "https://github.com/lopiv2/invenicum/releases"
  /// }
  Future<Map<String, dynamic>> checkAppVersion({
    required String currentVersion,
  }) async {
    try {
      final response = await dio.get(
        '/app/version/check',
        queryParameters: {'currentVersion': currentVersion},
      );

      final dynamic raw = response.data;
      if (raw is Map<String, dynamic>) {
        if (raw['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(raw['data']);
        }
        return Map<String, dynamic>.from(raw);
      }

      throw Exception('Invalid version check response');
    } on DioException catch (e) {
      final message =
          e.response?.data?['message']?.toString() ??
          e.response?.data?['error']?.toString() ??
          'Error checking app version';
      throw Exception(message);
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

      Map<String, dynamic> responseData = response.data;
      if (responseData['data'] is Map) {
        responseData = responseData['data'] as Map<String, dynamic>;
      }

      final loginResponse = LoginResponse.fromJson(responseData);

      if (loginResponse.success && loginResponse.token != null) {
        _cachedToken = loginResponse.token;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Environment.authTokenKey, _cachedToken!);
      }
      return loginResponse;
    } on DioException catch (e) {
      return LoginResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Error de autenticación',
      );
    }
  }

  /// Se llama UNA SOLA VEZ al arrancar la app (en main.dart)
  Future<void> initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(Environment.authTokenKey);
  }

  String? get currentToken => _cachedToken;

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Environment.authTokenKey);
  }

  Future<UserData?> getMe() async {
    try {
      final response = await dio.get('/auth/me');
      return UserData.fromJson(response.data['user'] ?? response.data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      // Propagamos para que AuthProvider distinga 401 (token inválido)
      // de errores de red/timeout (mantener sesión)
      rethrow;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    if (_cachedToken != null) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Environment.authTokenKey) != null;
  }

  Future<void> logout() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Environment.authTokenKey);
    ChatService veniChatbotService = ChatService(this);
    veniChatbotService.clearHistory();
  }
}
