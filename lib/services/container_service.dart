import 'package:dio/dio.dart';
import '../models/container_model.dart';
import 'api_service.dart';

class ContainerService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  ContainerService() : _apiService = ApiService();

  Future<ContainerNode> createContainer(String name, String? description) async {
    try {
      final response = await _dio.post(
        '/containers',
        data: {
          'name': name,
          'description': description,
        },
      );

      if (response.statusCode == 201) {
        return ContainerNode.fromJson(response.data);
      } else {
        throw Exception('Error al crear el contenedor: ${response.statusCode}');
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

  Future<List<ContainerNode>> getContainers() async {
    try {
      final response = await _dio.get('/containers');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ContainerNode.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener los contenedores: ${response.statusCode}');
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