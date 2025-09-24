class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000', // URL por defecto para desarrollo
  );

  static const String apiVersion = '/api/v1';
  
  // Timeouts
  static const int connectTimeout = 5000; // 5 segundos
  static const int receiveTimeout = 3000; // 3 segundos

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  
  // Otros valores de configuración
  static const String appName = 'Invenicum';
}