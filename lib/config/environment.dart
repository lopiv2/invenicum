class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.43:3000', // Default URL for development
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.0.0', // Fallback only in local development
  );

  static const String apiVersion = '/api/v1';

  static String get baseUrl {
    final normalizedApiUrl = apiUrl.endsWith('/')
        ? apiUrl.substring(0, apiUrl.length - 1)
        : apiUrl;

    if (normalizedApiUrl.endsWith(apiVersion)) {
      return normalizedApiUrl;
    }

    return '$normalizedApiUrl$apiVersion';
  }

  // Docs
  static const String docsUrl = 'https://invenicum.com/en/docs/intro';
  static const String stacDocsUrl = "https://docs.stac.dev/introduction";
  
  // Timeouts
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 45000; // 45 seconds

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  
  // Other configuration values
  static const String appName = 'Invenicum';
}