// lib/services/asset_type_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/asset_type_model.dart';
import '../models/uploadable_file.dart';
import 'api_service.dart'; // Importamos el servicio base

class AssetTypeService {
  // Ahora _apiService es final y DEBE ser inyectada.
  final ApiService _apiService;

  // Acceso a la instancia de Dio a través de ApiService
  Dio get _dio => _apiService.dio; 

  // Constructor que recibe ApiService (Inyección de dependencia)
  AssetTypeService(this._apiService);

  // ------------------------------------------------------------------
  // --- C (CREATE): Crear un Nuevo Tipo de Activo en el Contenedor ---
  // ------------------------------------------------------------------
  /// Envía un nuevo AssetType y sus definiciones de campo al backend.
  /// Retorna el AssetType creado con el ID real de la base de datos.
  Future<AssetType> createAssetType({
    required int containerId,
    required String name,
    required List<dynamic> fieldDefinitionsJson,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final url = '/containers/$containerId/asset-types';
      
      // Crear FormData para enviar la imagen
      final formData = FormData.fromMap({
        'name': name,
        'fieldDefinitions': jsonEncode(fieldDefinitionsJson),
        if (imageBytes != null && imageName != null)
          'files': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName,
            contentType: MediaType.parse('image/jpeg'), // Ajustar según el tipo
          ),
      });

      final response = await _dio.post(
        url,
        data: formData,
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;
        
        // Asumimos que la respuesta de creación es similar: objeto anidado en 'data'
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return AssetType.fromJson(responseData['data']);
        } else {
          throw Exception(
            'Respuesta de API exitosa, pero el objeto AssetType ("data") está ausente o es nulo.',
          );
        }
      } else {
        throw Exception('Error al crear el Tipo de Activo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Error de conexión o de servidor: $message');
    } catch (e) {
      throw Exception('Error inesperado al crear Tipo de Activo: $e');
    }
  }

  // ------------------------------------------------------------------
  // --- R (READ): Obtener un único AssetType ---
  // ------------------------------------------------------------------
  Future<AssetType> getAssetType(int assetTypeId) async {
    try {
      final response = await _dio.get('/asset-types/$assetTypeId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        // Asumimos que la respuesta individual también anida en 'data'
        return AssetType.fromJson(responseData['data']);
      } else {
        throw Exception('Error al obtener AssetType: ${response.statusCode}');
      }
    } on DioException catch (e) {
       // Manejo de errores simplificado
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // ------------------------------------------------------------------
  // --- U (UPDATE): Actualizar un AssetType ---
  // ------------------------------------------------------------------
  Future<AssetType> updateAssetType(AssetType assetType) async {
    try {
      final response = await _dio.put(
        '/asset-types/${assetType.id}',
        data: assetType.toJson(), // Utiliza el toJson() del modelo AssetType
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        return AssetType.fromJson(responseData['data']);
      } else {
        throw Exception('Error al actualizar AssetType: ${response.statusCode}');
      }
    } on DioException catch (e) {
       // Manejo de errores simplificado
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // ------------------------------------------------------------------
  // --- D (DELETE): Eliminar un AssetType y sus elementos asociados ---
  // ------------------------------------------------------------------
  Future<void> deleteAssetType(int assetTypeId) async {
    try {
      // Primero, eliminar todos los elementos asociados
      await _dio.delete('/asset-types/$assetTypeId/assets');
      
      // Luego, eliminar el tipo de activo
      final response = await _dio.delete('/asset-types/$assetTypeId');
      
      // La eliminación exitosa puede ser 200 o 204 (No Content)
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Fallo al eliminar AssetType: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('El tipo de activo no existe o ya fue eliminado.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Error al eliminar el tipo de activo: $message');
    } catch (e) {
      throw Exception('Error inesperado al eliminar el tipo de activo: $e');
    }
  }
}