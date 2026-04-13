import 'package:dio/dio.dart';
import 'api_service.dart';

class AIService {
  final ApiService _apiService;

  Dio get _dio => _apiService.dio;

  AIService(this._apiService);

  /// Sends a URL to the backend for the AI to extract data.
  Future<Map<String, dynamic>> extractDataFromUrl({
    required String url,
    required List<String> fields,
  }) async {
    try {
      const path = '/ai/extract';

      final response = await _dio.post(
        path,
        data: {'url': url, 'fields': fields},
      );

      final responseData = response.data;

      // Dio on Flutter Web sometimes returns the body already as a Map,
      // other times as a String — we normalize it here.
      final Map<String, dynamic> body;
      if (responseData is Map<String, dynamic>) {
        body = responseData;
      } else if (responseData is Map) {
        body = Map<String, dynamic>.from(responseData);
      } else {
        throw 'Unexpected server response: ${responseData.runtimeType}';
      }

      if (body['success'] != true) {
        throw body['error'] ?? body['message'] ?? 'Unknown AI error';
      }

      final data = body['data'];

      if (data == null) {
        throw 'The server did not return extracted data. Check that the URL is accessible.';
      }

      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);

      throw 'Invalid data format: received ${data.runtimeType} instead of a JSON object.';
    } on DioException catch (e) {
      String errorMessage = 'AI service error';

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage =
              (data['error'] ?? data['message'] ?? errorMessage).toString();
        }
      }

      throw errorMessage;
    } catch (e) {
      // Re-throw strings (our error messages) directly.
      if (e is String) rethrow;
      throw 'Unexpected error: $e';
    }
  }

  /// Ask the backend AI to search external sources and return mapping suggestions.
  /// Expects backend endpoint POST /ai/suggest with { containerId, query, fields }.
  Future<List<Map<String, dynamic>>> suggestMappings({
    required int containerId,
    required String query,
    required List<String> fields,
  }) async {
    try {
      const path = '/ai/suggest';

      final response = await _dio.post(path, data: {
        'containerId': containerId,
        'query': query,
        'fields': fields,
      });

      final body = response.data;
      if (body is Map && body['success'] == true && body['suggestions'] is List) {
        final List suggestions = body['suggestions'];
        return suggestions
            .map((s) => s is Map ? Map<String, dynamic>.from(s) : <String, dynamic>{})
            .toList();
      }

      throw 'Invalid suggestions response';
    } on DioException catch (e) {
      String err = 'AI suggest error';
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        err = (data['error'] ?? data['message'] ?? err).toString();
      }
      throw err;
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }
}