// services/container_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'api_service.dart';

class ContainerService {
  final ApiService _apiService;

  // Direct access to the Dio instance configured in ApiService
  Dio get _dio => _apiService.dio;

  ContainerService(this._apiService);

  // --- Private helpers ---

  /// Safely extract the 'data' key from the response
  dynamic _extractData(Response response) {
    final Map<String, dynamic> responseData = response.data;
    if (responseData.containsKey('data') && responseData['data'] != null) {
      return responseData['data'];
    }
    throw Exception('Server response does not contain the "data" field.');
  }

  /// Centralized Dio exception handler
  Exception _handleError(DioException e, String context) {
    if (e.response?.statusCode == 401) {
      return Exception('Unauthorized: session expired or invalid token.');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Resource not found ($context).');
    }
    final message = e.response?.data?['message'] ?? e.message;
    return Exception('Error in $context: $message');
  }

  // --- Container methods ---

  Future<List<dynamic>> searchItemsGlobal(String query) async {
    try {
      // Assume the API has a global search endpoint
      final response = await _dio.get(
        '/search/assets',
        queryParameters: {'q': query},
      );

      // Use the private helper to extract data
      return _extractData(response) as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, 'search items in API');
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
      throw _handleError(e, 'create container');
    }
  }

  Future<List<ContainerNode>> getContainers() async {
    try {
      // Load relations to avoid N+1 queries on the backend
      final response = await _dio.get(
        '/containers?include=datalists,assettypes',
      );
      final List<dynamic> list = _extractData(response);

      return list.map((json) {
        // Normalization: ensure lists exist even if the backend doesn't send them
        json['dataLists'] ??= json['data_lists'] ?? [];
        json['assetTypes'] ??= json['asset_types'] ?? [];
        return ContainerNode.fromJson(json);
      }).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'get containers');
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
      throw _handleError(e, 'update container');
    }
  }

  Future<void> deleteContainer(int containerId) async {
    try {
      await _dio.delete('/containers/$containerId');
    } on DioException catch (e) {
      throw _handleError(e, 'delete container');
    }
  }

  // --- DataLists methods (custom lists) ---

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
      throw _handleError(e, 'create datalist');
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
      throw _handleError(e, 'update datalist');
    }
  }

  Future<void> deleteDataList(int dataListId) async {
    try {
      await _dio.delete('/datalists/$dataListId');
    } on DioException catch (e) {
      throw _handleError(e, 'delete datalist');
    }
  }

  Future<ListData> getDataList(int dataListId) async {
    try {
      final response = await _dio.get('/datalists/$dataListId');
      return ListData.fromJson(_extractData(response));
    } on DioException catch (e) {
      throw _handleError(e, 'get datalist');
    }
  }

  Future<List<ListData>> getDataLists(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/datalists');
      final List<dynamic> list = _extractData(response);
      return list.map((json) => ListData.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'get container datalists');
    }
  }
}
