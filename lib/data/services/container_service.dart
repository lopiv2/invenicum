// services/container_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'api_service.dart';

class ContainerService {
  final ApiService _apiService;

  // Acceso directo al Dio configurado en ApiService
  Dio get _dio => _apiService.dio;

  ContainerService(this._apiService);

  // --- Helpers Privados ---

  /// Extrae la clave 'data' de la respuesta de forma segura
  dynamic _extractData(Response response) {
    final Map<String, dynamic> responseData = response.data;
    if (responseData.containsKey('data') && responseData['data'] != null) {
      return responseData['data'];
    }
    throw Exception('La respuesta del servidor no contiene el campo "data".');
  }

  /// Centraliza el manejo de excepciones de Dio
  Exception _handleError(DioException e, String context) {
    if (e.response?.statusCode == 401) {
      return Exception('No autorizado: Sesión expirada o token inválido.');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Recurso no encontrado ($context).');
    }
    final message = e.response?.data?['message'] ?? e.message;
    return Exception('Error en $context: $message');
  }

  // --- Métodos de Contenedores ---

  Future<List<dynamic>> searchItemsGlobal(String query) async {
    try {
      // Asumimos que tu API tiene un endpoint de búsqueda global
      final response = await _dio.get(
        '/search/assets',
        queryParameters: {'q': query},
      );

      // Usamos tu helper privado para extraer los datos
      return _extractData(response) as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, 'buscar elementos en la API');
    }
  }

  Future<ContainerNode> createContainer(
    String name,
    String? description, {
    bool isCollection = false,
  }) async {
    try {
      final response = await _dio.post(
        '/containers',
        data: {
          'name': name,
          'description': description,
          'isCollection': isCollection,
        },
      );
      return ContainerNode.fromJson(_extractData(response));
    } on DioException catch (e) {
      throw _handleError(e, 'crear contenedor');
    }
  }

  Future<List<ContainerNode>> getContainers() async {
    try {
      // Cargamos relaciones para evitar N+1 queries en el backend
      final response = await _dio.get(
        '/containers?include=datalists,assettypes',
      );
      final List<dynamic> list = _extractData(response);

      return list.map((json) {
        // Normalización: Aseguramos que existan las listas aunque el backend no las envíe
        json['dataLists'] ??= json['data_lists'] ?? [];
        json['assetTypes'] ??= json['asset_types'] ?? [];
        return ContainerNode.fromJson(json);
      }).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'obtener contenedores');
    }
  }

  Future<ContainerNode> updateContainer(int containerId, String name) async {
    try {
      final response = await _dio.patch(
        '/containers/$containerId',
        data: {'name': name},
      );
      return ContainerNode.fromJson(_extractData(response));
    } on DioException catch (e) {
      throw _handleError(e, 'actualizar contenedor');
    }
  }

  Future<void> deleteContainer(int containerId) async {
    try {
      await _dio.delete('/containers/$containerId');
    } on DioException catch (e) {
      throw _handleError(e, 'eliminar contenedor');
    }
  }

  // --- Métodos de DataLists (Listas Personalizadas) ---

  Future<ListData> createDataList({
    required int containerId,
    required String name,
    required String description,
    required List<String> items,
  }) async {
    try {
      final response = await _dio.post(
        '/containers/$containerId/datalists',
        data: {'name': name, 'description': description, 'items': items},
      );
      return ListData.fromJson(_extractData(response));
    } on DioException catch (e) {
      throw _handleError(e, 'crear lista personalizada');
    }
  }

  Future<ListData> updateDataList({
    required int dataListId,
    required String name,
    required String description,
    required List<String> items,
  }) async {
    try {
      final response = await _dio.put(
        '/datalists/$dataListId',
        data: {'name': name, 'description': description, 'items': items},
      );
      return ListData.fromJson(_extractData(response));
    } on DioException catch (e) {
      throw _handleError(e, 'actualizar lista personalizada');
    }
  }

  Future<void> deleteDataList(int dataListId) async {
    try {
      await _dio.delete('/datalists/$dataListId');
    } on DioException catch (e) {
      throw _handleError(e, 'eliminar lista personalizada');
    }
  }

  Future<ListData> getDataList(int dataListId) async {
    try {
      final response = await _dio.get('/datalists/$dataListId');
      return ListData.fromJson(_extractData(response));
    } on DioException catch (e) {
      throw _handleError(e, 'obtener lista personalizada');
    }
  }

  Future<List<ListData>> getDataLists(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/datalists');
      final List<dynamic> list = _extractData(response);
      return list.map((json) => ListData.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'obtener listas del contenedor');
    }
  }
}
