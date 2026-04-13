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

  // 🚀 SYNCHRONOUS CACHE: The secret to win the milliseconds race.
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

              // Only log out if the 401 comes from a real JWT validation.
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

  /// Checks with the backend whether the app requires initial setup.
  /// Returns [true] if this is the first run (users table empty or missing),
  /// [false] if there's at least one registered user.
  /// On network errors returns [false] so startup is not blocked.
  Future<bool> checkFirstRun() async {
    try {
      final response = await dio.get('/auth/first-run');
      // Expected: { "firstRun": true } or { "firstRun": false }
      return response.data['firstRun'] == true;
    } on DioException catch (e) {
      // 404 → endpoint not implemented yet → don't block
      // 5xx → server error → don't block
      debugPrint('ApiService: checkFirstRun error ${e.response?.statusCode}: $e');
      return false;
    } catch (e) {
      debugPrint('ApiService: checkFirstRun unexpected error: $e');
      return false;
    }
  }

  /// Creates the first administrator user for the platform.
  /// Should only be called when [checkFirstRun()] returns [true].
  /// Throws [Exception] with the backend message on failure.
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
      // The backend simply returns 201. We don't need the body.
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.response?.data['error'] ??
          'Error creating administrator';
      throw Exception(message);
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // ----------------------------------------------------
  // SECURITY METHODS
  // ----------------------------------------------------

  /// Change the current user's password
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
          'Error changing password';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Connection error while changing password');
    }
  }

  /// Requests a password recovery email
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.data['success'] == true || response.statusCode == 200;
    } catch (e) {
      debugPrint("ApiService: Error in password reset request: $e");
      return false;
    }
  }

  // ----------------------------------------------------
  // USER METHODS
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
          e.response?.data['error'] ?? 'Error updating profile';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>?> getGitHubConfig() async {
    try {
      final response = await dio.get('/auth/github/config');
      return response.data;
    } catch (e) {
      debugPrint("ApiService: Error requesting GitHub config: $e");
      return null;
    }
  }

  Future<bool> disconnectGitHub() async {
    try {
      final response = await dio.post('/auth/github/disconnect');
      return response.data['success'] == true;
    } catch (e) {
      debugPrint("ApiService: Error disconnecting GitHub: $e");
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

  /// Checks the app version status with the backend.
  ///
  /// Expected backend endpoint:
  /// GET /app/version/check?currentVersion=x.y.z
  /// Example response:
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
  // AUTHENTICATION METHODS
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
        message: e.response?.data['message'] ?? 'Authentication error',
      );
    }
  }

  /// Called ONCE at app startup (in main.dart)
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
      // Re-throw so AuthProvider can distinguish 401 (invalid token)
      // from network/timeout errors (keep session)
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
