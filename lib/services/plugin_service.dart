import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/utils/sdk_plugin_parser.dart';
import 'package:stac/stac.dart';

class InvenicumAction {
  final String method;
  final Map<String, dynamic> params;

  InvenicumAction({required this.method, required this.params});

  factory InvenicumAction.fromJson(Map<String, dynamic> json) =>
      InvenicumAction(
        method: json['method'] ?? '',
        params: json['params'] ?? {},
      );
}

// --- NUESTRO SDK DE FUNCIONES ---

class PluginService {
  final ApiService _apiService;

  static bool _isInitialized = false;

  PluginService(this._apiService);

  Dio get _dio => _apiService.dio;

  /// Inicializa el SDK de Stac con tus funciones core
  Future<void> initSdk({String? userName}) async {
    if (_isInitialized) return; // Si ya se inicializó, salimos.

    await Stac.initialize(
      actionParsers: [InvenicumSdkParser(userName: userName)],
    );
    _isInitialized = true;
    debugPrint("✅ Stac SDK initialized for first time");
  }

  /// --- MÉTODOS PARA LA TIENDA DE GITHUB ---

  /// Obtiene el catálogo (repository.json) desde GitHub
  Future<List<Map<String, dynamic>>> getStoreCatalog() async {
    // Ahora apuntas a TU propia API, no a GitHub
    final response = await _dio.get('/store/plugins');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Descarga el código STAC del plugin
  Future<Map<String, dynamic>> downloadPluginStac(String url) async {
  try {
    final response = await _dio.get(
      '/plugins/preview-stac', 
      queryParameters: {'url': url}
    );
    
    return response.data;
  } catch (e) {
    debugPrint("Error obteniendo preview a través del backend: $e");
    rethrow;
  }
}

  Future<void> toggleUserPlugin(String pluginId, bool isActive) async {
    // Apuntamos al nuevo endpoint que maneja la tabla UserPlugin
    await _dio.put(
      '/plugins/user/toggle',
      data: {'pluginId': pluginId, 'isActive': isActive},
    );
  }

  /// [C] CREATE: Crea un nuevo plugin desde cero
  Future<Map<String, dynamic>> createPlugin(
    Map<String, dynamic> pluginData,
  ) async {
    // El backend asignará el authorId automáticamente por el Token
    final response = await _dio.post('/plugins', data: pluginData);
    return Map<String, dynamic>.from(response.data);
  }

  /// [U] UPDATE: Actualiza un plugin existente
  Future<Map<String, dynamic>> updatePlugin(
    Map<String, dynamic> pluginData,
  ) async {
    final String id = pluginData['id'];
    // 💡 Importante: El backend ahora verifica autoría con el token
    final response = await _dio.put('/plugins/$id', data: pluginData);
    return Map<String, dynamic>.from(response.data);
  }

  /// [D] DELETE (Físico): Elimina el plugin de la base de datos global
  Future<void> deletePlugin(String pluginId) async {
    // 💡 El backend responderá 403 si el usuario no es el autor
    await _dio.delete('/plugins/$pluginId');
  }

  /// Obtiene los plugins que el usuario ya tiene comprados/instalados
  Future<List<Map<String, dynamic>>> getMyPlugins() async {
    final response = await _dio.get('/plugins/installed');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Obtiene los plugins de la comunidad
  /// Ahora 'Community' ya trae los de GitHub + los de la DB mezclados
  Future<List<Map<String, dynamic>>> getCommunityPlugins() async {
    final response = await _dio.get('/plugins/community');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Acción de instalar un plugin
  Future<void> installPlugin(Map<String, dynamic> pluginData) async {
    // Al enviar todo el mapa, el backend puede leer 'isOfficial'
    // y 'download_url' para bajarlo de GitHub si hace falta.
    await _dio.post('/plugins/install', data: pluginData);
  }

  Future<void> uninstallPlugin(String pluginId) async {
    // Asumiendo que tu API usa DELETE o un POST específico
    await _dio.delete('/plugins/uninstall/$pluginId');
  }
}
