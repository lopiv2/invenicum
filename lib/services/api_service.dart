import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invenicum/models/user_data_model.dart';
import '../config/environment.dart';
import '../models/login_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Dio dio = Dio();
  final _storage = const FlutterSecureStorage();
  
  // 🚀 MEMORIA SÍNCRONA: El secreto para ganar la carrera de milisegundos.
  String? _cachedToken;

  factory ApiService() => _instance;

  ApiService._internal() {
    dio.options.baseUrl = '${Environment.apiUrl}${Environment.apiVersion}';
    dio.options.connectTimeout = Duration(milliseconds: Environment.connectTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: Environment.receiveTimeout);

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
          }
          return handler.next(e);
        },
      ),
    );
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
        message: e.response?.data['message'] ?? 'Error de autenticación'
      );
    }
  }

  // 🚩 REEMPLAZO: Este método se llama UNA SOLA VEZ al arrancar la app (en main.dart)
  Future<void> initializeToken() async {
    _cachedToken = await _storage.read(key: Environment.authTokenKey);
  }

  // Getter síncrono para los Providers
  String? get currentToken => _cachedToken;

  Future<String?> getToken() async => _cachedToken ?? await _storage.read(key: Environment.authTokenKey);

  Future<UserData?> getMe() async {
    try {
      final response = await dio.get('/auth/me');
      return UserData.fromJson(response.data['user'] ?? response.data);
    } catch (_) { return null; }
  }

  Future<bool> isAuthenticated() async => _cachedToken != null || (await _storage.read(key: Environment.authTokenKey)) != null;

  Future<void> logout() async {
    _cachedToken = null;
    await _storage.delete(key: Environment.authTokenKey);
  }
}