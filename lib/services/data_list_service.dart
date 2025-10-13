import 'package:dio/dio.dart';
import 'package:invenicum/models/list_data.dart';
import 'package:invenicum/services/api_service.dart';

class DataListService {
  final ApiService _apiService;
  
  // Usamos el Dio del ApiService
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
            'Respuesta de API exitosa, pero el objeto lista ("data") está ausente o es nulo.',
          );
        }
      } else {
        throw Exception(
          'Error al crear la lista personalizada: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
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
            'Respuesta de API exitosa, pero la lista ("data") está ausente o es nula.',
          );
        }
      } else {
        throw Exception(
          'Error al obtener las listas personalizadas: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<void> deleteDataList(int dataListId) async {
    try {
      final response = await _dio.delete('/datalists/$dataListId');

      if (response.statusCode != 204) {
        throw Exception(
          'Error al eliminar la lista personalizada: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Lista personalizada no encontrada.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
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
            'Respuesta de API exitosa, pero el objeto lista ("data") está ausente o es nulo.',
          );
        }
      } else {
        throw Exception(
          'Error al actualizar la lista personalizada: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Lista personalizada no encontrada.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}