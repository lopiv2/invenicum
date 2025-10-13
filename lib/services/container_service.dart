// services/container_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/models/list_data.dart';
import 'api_service.dart';

class ContainerService {
  // Ahora _apiService es final y DEBE ser inyectada.
  final ApiService _apiService;

  // Usamos el Dio del ApiService.
  Dio get _dio => _apiService.dio;

  // Constructor que recibe ApiService (Inyección de dependencia)
  ContainerService(this._apiService);

  // --- Métodos de la API ---

  Future<ContainerNode> createContainer(
    String name,
    String? description,
  ) async {
    try {
      final response = await _dio.post(
        '/containers',
        data: {'name': name, 'description': description},
      );

      if (response.statusCode == 201) {
        // CORRECCIÓN CLAVE: Accede a la clave 'data' dentro de la respuesta.
        // Si tu API devuelve el objeto anidado en 'data', debes hacer esto:
        final Map<String, dynamic> responseData = response.data;

        // Verifica que la clave 'data' exista y no sea nula antes de usarla
        if (responseData.containsKey('data') && responseData['data'] != null) {
          // Pasa solo el objeto contenedor al fromJson
          return ContainerNode.fromJson(responseData['data']);
        } else {
          // Manejar caso donde 'data' no está presente o es nulo
          throw Exception(
            'Respuesta de API exitosa, pero el objeto contenedor ("data") está ausente o es nulo.',
          );
        }
      } else {
        throw Exception('Error al crear el contenedor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // ... (Manejo de errores)
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<void> deleteContainer(int containerId) async {
    try {
      // Llama al DELETE /api/v1/containers/:containerId
      await _dio.delete('/containers/$containerId');
    } catch (e) {
      // Manejo de errores específicos (ej. 404, 401)
      rethrow;
    }
  }

  Future<List<ContainerNode>> getContainers() async {
    try {
      final response = await _dio.get('/containers');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> containersList = responseData['data'];

        return containersList
            .map((json) => ContainerNode.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Error al obtener los contenedores: ${response.statusCode}',
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

  Future<ContainerNode> updateContainer(int containerId, String name) async {
    try {
      final response = await _dio.patch(
        '/containers/$containerId', // Usar PATCH para actualizar parcialmente
        data: {
          'name': name,
          // Nota: Si quieres actualizar la descripción, puedes incluirla aquí también.
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return ContainerNode.fromJson(responseData['data']);
        } else {
          throw Exception(
            'Respuesta de API exitosa, pero el objeto contenedor actualizado ("data") está ausente o es nulo.',
          );
        }
      } else {
        throw Exception(
          'Error al actualizar el contenedor: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Contenedor no encontrado.');
      }
      // Re-lanza el error para que el ContainerProvider lo maneje.
      throw Exception('Error de conexión al renombrar: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al renombrar: $e');
    }
  }

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

  Future<void> deleteDataList(int dataListId) async {
    try {
      final response = await _dio.delete('/datalists/$dataListId');
      
      if (response.statusCode != 204 && response.statusCode != 200) {
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

  // Método para obtener las listas de un contenedor específico
  Future<List<ListData>> getDataLists(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/datalists');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> dataListsJson = responseData['data'];

        return dataListsJson.map((json) => ListData.fromJson(json)).toList();
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
}
