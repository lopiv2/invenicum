import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'api_service.dart';

class IntegrationService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  IntegrationService(this._apiService);

  Future<Map<String, dynamic>> testIntegration(
    String type,
    Map<String, dynamic> config,
  ) async {
    try {
      final response = await _dio.post(
        '/integrations/test',
        data: {'type': type, 'config': config},
      );
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("Status Code: ${e.response?.statusCode}");
      }
      if (kDebugMode) {
        debugPrint(
        "Error data: ${e.response?.data}",
      );
      } // <--- This will show the real backend error
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Connection error',
      };
    }
  }

  // New method to delete an integration
  Future<void> deleteIntegration(String type) async {
    await _dio.delete('/integrations/$type');
  }

  // Get which integrations are active (for green checks)
  Future<Map<String, bool>> getIntegrationStatuses() async {
    final response = await _dio.get('/integrations/status');
    // Access response.data['data'] because backend sends { data: { ... } }
    final Map<String, dynamic> rawMap = response.data['data'];
    return rawMap.map((key, value) => MapEntry(key, value as bool));
  }

  // Get saved configuration (to prefill modal fields)
  Future<Map<String, dynamic>?> getIntegrationConfig(String type) async {
    try {
      final response = await _dio.get('/integrations/$type');
      return response.data['data']['config'];
    } catch (e) {
      // If it doesn't exist, return null instead of throwing
      return null;
    }
  }

  // Save or update an integration
  Future<void> saveIntegration(String type, Map<String, dynamic> config) async {
    try {
      await _dio.post('/integrations', data: {'type': type, 'config': config});
    } catch (e) {
      throw Exception('Error saving integration $type: $e');
    }
  }

  /// Calls the AI enrichment endpoint (Gemini + External API)
  /// Returns a map with [name, description, imageUrl, customFieldValues, etc.]
  Future<Map<String, dynamic>?> enrichItem({
    required String query,
    required String source,
    String locale = "es",
  }) async {
    try {
      // Call to endpoint: /api/integrations/enrich?query=...&source=...&locale=...
      final response = await _dio.get(
        '/integrations/enrich',
        queryParameters: {'query': query, 'source': source, 'locale': locale},
      );

      // Verify backend structure { success: true, data: { ... } }
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      // Capture specific errors (404 not found, 412 missing API Key, etc.)
      final errorMessage =
          e.response?.data['error'] ?? 'Error enriching item';
      debugPrint("[ENRICH-SERVICE-ERROR]: $errorMessage");

      // Throw the exception so UI (ToastService) can show the real message
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("[ENRICH-SERVICE-FATAL]: $e");
      return null;
    }
  }

  /// Process a specific candidate when /enrich returns multiple results
  Future<Map<String, dynamic>?> enrichSelectedItem({
    required String source,
    required String itemId,
    String locale = "es",
  }) async {
    try {
      final response = await _dio.get(
        '/integrations/enrich/select',
        queryParameters: {'source': source, 'itemId': itemId, 'locale': locale},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['error'] ?? 'Error processing selected result';
      debugPrint("[ENRICH-SELECT-SERVICE-ERROR]: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("[ENRICH-SELECT-SERVICE-FATAL]: $e");
      return null;
    }
  }

  Future<InventoryItem?> lookupBarcode(String barcode) async {
    try {
      final response = await _dio.get('/integrations/barcode/lookup/$barcode');

      if (response.data['data'] != null) {
        return InventoryItem.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      debugPrint("Error in barcode lookup: ${e.response?.data}");
      return null;
    }
  }
}
