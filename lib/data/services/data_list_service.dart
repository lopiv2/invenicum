import 'package:dio/dio.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'package:invenicum/data/services/api_service.dart';

class DataListService {
  final ApiService _apiService;
  
  // Use Dio from ApiService
  Dio get _dio => _apiService.dio;

  DataListService(this._apiService);

  Future<ListData> createDataList({
    required int containerId,
    required String name,
    required String description,
    required List<String> items,
  }) async {
    try {
      final response = await _dio.post(
        '/containers/$containerId/datalists',
        data: {
          'name': name,
          'description': description,
          'items': items,
        },
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return ListData.fromJson(responseData['data']);
        } else {
          throw Exception(
            'API returned success but the list object ("data") is missing or null.',
          );
        }
      } else {
        throw Exception(
          'Error creating custom list: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ListData>> getDataLists(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/datalists');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          final List<dynamic> lists = responseData['data'];
          return lists.map((json) => ListData.fromJson(json)).toList();
        } else {
          throw Exception(
            'API returned success but the list ("data") is missing or null.',
          );
        }
      } else {
        throw Exception(
          'Error fetching custom lists: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> deleteDataList(int dataListId) async {
    try {
      final response = await _dio.delete('/datalists/$dataListId');

      if (response.statusCode != 204) {
        throw Exception(
          'Error deleting custom list: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Custom list not found.');
      }
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
        data: {
          'name': name,
          'description': description,
          'items': items,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return ListData.fromJson(responseData['data']);
        } else {
          throw Exception(
            'API returned success but the list object ("data") is missing or null.',
          );
        }
        } else {
        throw Exception(
          'Error updating custom list: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Custom list not found.');
      }
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}