import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart';
import '../models/login_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Dio dio = Dio();
  final _storage = const FlutterSecureStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio.options.baseUrl = '${Environment.apiUrl}${Environment.apiVersion}';
    dio.options.connectTimeout = Duration(
      milliseconds: Environment.connectTimeout,
    );
    dio.options.receiveTimeout = Duration(
      milliseconds: Environment.receiveTimeout,
    );

    // Interceptor para agregar el token a las peticiones
    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: Environment.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
      // MODIFICACIÓN AQUÍ:
      LogInterceptor(
        requestBody: true,
        responseBody:
            false, // Desactivamos el body global para manejarlo manualmente si quieres
        error: true,
        logPrint: (object) {
          // Solo imprimimos si no parece ser una lista gigante de bytes
          final log = object.toString();
          if (log.length < 1000) print(log);
        },
      ),
    ]);
  }

  Future<LoginResponse> login(String username, String password) async {
    // 2. Imprime la URL para verificarla
    try {
      final response = await dio.post(
        Environment.loginEndpoint,
        data: {'username': username, 'password': password},
      );

      if (response.data is! Map<String, dynamic>) {
        return LoginResponse(
          success: false,
          message: 'Error en el formato de la respuesta del servidor',
        );
      }

      Map<String, dynamic> responseData = response.data;

      // Si hay un objeto data, usamos esos valores
      if (responseData['data'] is Map) {
        responseData = responseData['data'] as Map<String, dynamic>;
      }

      final loginResponse = LoginResponse.fromJson(responseData);

      if (loginResponse.success && loginResponse.token != null) {
        await _storage.write(
          key: Environment.authTokenKey,
          value: loginResponse.token!,
        );
        print('Token guardado: ${loginResponse.token}'); // Para depuración
      }

      return loginResponse;
    } on DioException catch (e) {
      String message;

      if (e.response != null) {
        // Si hay una respuesta del servidor, lee el mensaje de error directamente
        message =
            e.response!.data['message'] ?? 'Error en la respuesta del servidor';

        // Y retorna una respuesta de LoginResponse con el error
        return LoginResponse(success: false, message: message);
      } else {
        // Si no hay respuesta del servidor (timeout, conexión perdida, etc.)
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            message =
                'Tiempo de espera agotado. Por favor, verifica tu conexión.';
            break;
          case DioExceptionType.connectionError:
            message = 'Error de conexión. Verifica tu conexión a internet.';
            break;
          default:
            message = 'Error desconocido. Por favor, intenta de nuevo.';
        }
        return LoginResponse(success: false, message: message);
      }
    } catch (e) {
      // Para cualquier otro tipo de error inesperado
      return LoginResponse(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: Environment.authTokenKey);
    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: Environment.authTokenKey);
    dio.options.headers.remove('Authorization');
  }

  Future<UserData?> getMe() async {
    try {
      final response = await dio.get('/auth/me'); // Asumiendo que este es el endpoint
      if (response.data != null) {
        // La respuesta puede venir con una clave 'user'
        if (response.data['user'] != null) {
          return UserData.fromJson(response.data['user']);
        }
        return UserData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      // Si el token es inválido o ha expirado, la petición puede fallar.
      // En ese caso, simplemente devolvemos null.
      print('Error fetching user data: $e');
      return null;
    }
  }
}
