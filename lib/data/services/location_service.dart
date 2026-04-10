// lib/services/location_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:invenicum/data/models/location.dart'; // Asegúrate de importar tu modelo Location
import 'api_service.dart'; // Asumimos que ApiService está en un nivel accesible

class LocationService {
  final ApiService _apiService;

  // Acceso directo a la instancia de Dio
  Dio get _dio => _apiService.dio;

  // Inyección de dependencia
  LocationService(this._apiService);

  // --- Métodos de la API para Ubicaciones ---

  /// Obtiene el número total de ubicaciones en un contenedor.
  Future<int> getLocationsCount(int containerId) async {
    try {
      // Llama al método existente y devuelve la longitud de la lista.
      final locations = await getLocations(containerId);
      return locations.length;
    } catch (e) {
      // Re-lanzar la excepción para manejo en el Provider
      rethrow;
    }
  }

  /// Obtiene todas las ubicaciones asociadas a un contenedor específico.
  Future<List<Location>> getLocations(int containerId) async {
    try {
      // 🔑 ENDPOINT: /containers/{containerId}/locations
      final response = await _dio.get('/containers/$containerId/locations');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        // Asume que la lista de ubicaciones está en la clave 'data'
        final List<dynamic> locationsList = responseData['data'];

        return locationsList.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al obtener las ubicaciones: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al obtener ubicaciones: $e');
      }
      throw Exception('Error inesperado: $e');
    }
  }

  /// Crea una nueva ubicación.
  Future<Location> createLocation({
    required int containerId,
    required String name,
    String? description,
    int? parentId,
  }) async {
    try {
      // 🔑 ENDPOINT: /locations (POST)
      final response = await _dio.post(
        '/locations',
        data: {
          'container_id':
              containerId, // Usamos snake_case si tu API lo requiere
          'name': name,
          'description': description,
          'parent_id': parentId,
        },
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return Location.fromJson(responseData['data']);
        } else {
          throw Exception(
            'Respuesta de API exitosa, pero el objeto ubicación ("data") está ausente o es nulo.',
          );
        }
      } else {
        throw Exception('Error al crear la ubicación: ${response.statusCode}');
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

  /// Actualiza una ubicación existente.
  Future<Location> updateLocation({
    required int locationId,
    required String name,
    String? description,
    int? parentId,
  }) async {
    try {
      // 🔑 ENDPOINT: /locations/{locationId} (PATCH)
      final response = await _dio.patch(
        '/locations/$locationId',
        data: {'name': name, 'description': description, 'parent_id': parentId},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return Location.fromJson(responseData['data']);
        } else {
          throw Exception(
            'Respuesta de API exitosa, pero el objeto ubicación actualizada ("data") está ausente o es nulo.',
          );
        }
      } else {
        throw Exception(
          'Error al actualizar la ubicación: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Ubicación no encontrada.');
      }
      throw Exception('Error de conexión al actualizar: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar: $e');
    }
  }

  /// Elimina una ubicación.
  Future<void> deleteLocation(int locationId) async {
    try {
      // 🔑 ENDPOINT: /locations/{locationId} (DELETE)
      final response = await _dio.delete('/locations/$locationId');

      // La eliminación exitosa generalmente devuelve 204 No Content o 200 OK.
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error al eliminar la ubicación: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Ubicación no encontrada.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
