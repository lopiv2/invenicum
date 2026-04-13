// lib/services/asset_type_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/asset_type_model.dart';
import 'api_service.dart'; // Import the base service

class AssetTypeService {
  // Now _apiService is final and MUST be injected.
  final ApiService _apiService;

  // Access to the Dio instance via ApiService
  Dio get _dio => _apiService.dio;

  // Constructor that receives ApiService (Dependency injection)
  AssetTypeService(this._apiService);

  // ------------------------------------------------------------------
  // --- C (CREATE): Create a New Asset Type in the Container ---
  // ------------------------------------------------------------------
  /// Sends a new `AssetType` and its field definitions to the backend.
  /// Returns the created `AssetType` including the real database ID.
  Future<AssetType> createAssetType({
    required int containerId,
    required String name,
    required List<dynamic> fieldDefinitionsJson,
    Uint8List? imageBytes,
    String? imageName,
    bool isSerialized = true,
  }) async {
    try {
      final url = '/containers/$containerId/asset-types';

      // Create FormData to send the image
      final formData = FormData.fromMap({
        'name': name,
        'isSerialized': isSerialized,
        'fieldDefinitions': jsonEncode(fieldDefinitionsJson),
        if (imageBytes != null && imageName != null)
          'files': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName,
            contentType: MediaType.parse('image/jpeg'),
          ),
      });

      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;

        // We assume the creation response is similar: object nested in 'data'
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return AssetType.fromJson(responseData['data']);
        } else {
          throw Exception(
            'API response successful, but the AssetType object ("data") is missing or null.',
          );
        }
      } else {
        throw Exception(
          'Error creating AssetType: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Connection or server error: $message');
    } catch (e) {
      throw Exception('Unexpected error creating AssetType: $e');
    }
  }

  // ------------------------------------------------------------------
  // --- R (READ): Get a single AssetType ---
  // ------------------------------------------------------------------
  Future<AssetType> getAssetType(int assetTypeId) async {
    try {
      final response = await _dio.get('/asset-types/$assetTypeId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        // We assume the individual response also nests in 'data'
        return AssetType.fromJson(responseData['data']);
      } else {
        throw Exception('Error fetching AssetType: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Simplified error handling
      throw Exception('Connection error: ${e.message}');
    }
  }

  // ------------------------------------------------------------------
  // --- U (UPDATE): Update an AssetType ---
  // ------------------------------------------------------------------
  Future<AssetType> updateAssetType({
    required int assetTypeId,
    required String name,
    required List<dynamic> fieldDefinitionsJson,
    Uint8List? imageBytes,
    String? imageName,
    bool isSerialized = true,
    required bool removeExistingImage,
  }) async {
    try {
      final url = '/asset-types/$assetTypeId';

      // 1. Build the FormData
      final formData = FormData.fromMap({
        'name': name,
        'isSerialized': isSerialized,
        'fieldDefinitions': jsonEncode(fieldDefinitionsJson),

        // 2. Logic to upload a new image
        if (imageBytes != null && imageName != null)
          'files': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName,
            contentType: MediaType.parse('image/jpeg'), // Asume JPEG/PNG
          ),

        // 3. Logic to remove the existing image (if true, API should delete it)
        'removeExistingImage': removeExistingImage,
      });

      // 4. Perform PATCH request (more appropriate for partial updates)
      final response = await _dio.patch(url, data: formData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        // Assume successful response returns the updated AssetType object in 'data'
        return AssetType.fromJson(responseData['data']);
      } else {
        throw Exception(
          'Error updating AssetType: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Connection or server error: $message');
    } catch (e) {
      throw Exception('Unexpected error updating AssetType: $e');
    }
  }

  // ------------------------------------------------------------------
  // --- U (UPDATE): Update collection fields of an AssetType ---
  // ------------------------------------------------------------------
  Future<AssetType> updateAssetTypeCollectionFields({
    required int assetTypeId,
    String? possessionFieldId,
    String? desiredFieldId,
  }) async {
    try {
      // Prepare data - send null as null, not as empty strings
      final Map<String, dynamic> data = {
        'possessionFieldId': possessionFieldId,
        'desiredFieldId': desiredFieldId,
      };

      final response = await _dio.patch(
        '/asset-types/$assetTypeId/collection-fields',
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return AssetType.fromJson(responseData['data']);
        } else {
          throw Exception(
            'API response successful, but the AssetType object ("data") is missing or null.',
          );
        }
      } else {
        throw Exception(
          'Error updating collection fields: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Connection or server error: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ------------------------------------------------------------------
  // --- D (DELETE): Delete an AssetType and its associated items ---
  // ------------------------------------------------------------------
  Future<void> deleteAssetType(int assetTypeId) async {
    try {
      // First, delete all associated items
      await _dio.delete('/asset-types/$assetTypeId/assets');

      // Then delete the asset type
      final response = await _dio.delete('/asset-types/$assetTypeId');

      // Successful deletion may be 200 or 204 (No Content)
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete AssetType: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Asset type does not exist or has already been deleted.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Error deleting asset type: $message');
    } catch (e) {
      throw Exception('Unexpected error deleting asset type: $e');
    }
  }
}
