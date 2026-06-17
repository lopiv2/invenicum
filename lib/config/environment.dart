import 'package:flutter/services.dart';

class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.43:3000',
  );

  static String _appVersion = '';
  static bool _initialized = false;

  /// Returns the app version.
  ///
  /// Priority:
  /// 1. `--dart-define=APP_VERSION=...` (CI / production)
  /// 2. `version:` field from `pubspec.yaml` (development)
  /// 3. `'0.0.0'` as last resort.
  static String get appVersion {
    if (_appVersion.isNotEmpty) return _appVersion;
    const fromEnv = String.fromEnvironment('APP_VERSION');
    if (fromEnv.isNotEmpty) return fromEnv;
    return '0.0.0';
  }

  /// Must be called once early in `main()` before any widget reads [appVersion].
  ///
  /// Loads `pubspec.yaml` from assets and parses its `version:` field as
  /// a fallback when `--dart-define=APP_VERSION` was not provided.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const fromEnv = String.fromEnvironment('APP_VERSION');
    if (fromEnv.isNotEmpty) {
      _appVersion = fromEnv;
      return;
    }

    try {
      final pubspec = await rootBundle.loadString('pubspec.yaml');
      for (final line in pubspec.split('\n')) {
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('version:')) {
          _appVersion = trimmed.split(':')[1].trim().split('+')[0];
          return;
        }
      }
    } catch (_) {
      // ignore – fallback remains '0.0.0'
    }
  }

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
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 45000;

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