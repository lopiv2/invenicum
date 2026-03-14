class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.43:3000', // URL por defecto para desarrollo
    //defaultValue: 'http://192.168.1.173:3000', // URL por defecto para desarrollo
  );

  static const String appVersion = '1.0.0'; // Versión por defecto

  static const String apiVersion = '/api/v1';

  static String get baseUrl => '$apiUrl$apiVersion';

  //Docs
  static const String docsUrl = 'https://docs.invenicum.com';
  static const String stacDocsUrl = "https://docs.stac.dev/introduction";
  
  // Timeouts
  static const int connectTimeout = 15000; // 15 segundos
  static const int receiveTimeout = 45000; // 45 segundos

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