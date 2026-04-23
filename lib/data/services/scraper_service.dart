// lib/data/services/scraper_service.dart
import 'package:dio/dio.dart';
import 'package:invenicum/data/models/scraper.dart';
import 'package:invenicum/data/services/api_service.dart';

class ScraperService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  ScraperService(this._apiService);
  Future<List<Scraper>> getScrapers([int? containerId]) async {
    try {
      final response = await _dio.get(
        '/scrapers',
        queryParameters: {if (containerId != null) 'containerId': containerId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          list = data['data'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        }
        return list
            .where((e) => e is Map<String, dynamic>)
            .map((e) => Scraper.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Error fetching scrapers: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Scraper> createScraper({
    int? containerId,
    required String name,
    required String url,
    String? urlPattern,
    List<Map<String, dynamic>>? fields,
  }) async {
    try {
      final payload = {
        'name': name,
        'url': url,
        if (urlPattern != null) 'urlPattern': urlPattern,
        if (containerId != null) 'containerId': containerId,
        'fields': fields ?? [],
      };

      final response = await _dio.post('/scrapers', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Scraper.fromJson(data['data'] as Map<String, dynamic>);
        }
        if (data is Map<String, dynamic>) {
          return Scraper.fromJson(data);
        }
      }
      throw Exception('Error creating scraper: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Scraper> updateScraper({
    required int scraperId,
    required String name,
    required String url,
    String? urlPattern,
    List<Map<String, dynamic>>? fields,
  }) async {
    try {
      final payload = {
        'name': name,
        'url': url,
        if (urlPattern != null) 'urlPattern': urlPattern,
        'fields': fields ?? [],
      };

      final response = await _dio.put('/scrapers/$scraperId', data: payload);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Scraper.fromJson(data['data'] as Map<String, dynamic>);
        }
        if (data is Map<String, dynamic>) return Scraper.fromJson(data);
      }
      throw Exception('Error updating scraper: ${response.statusCode}');
    } on DioException catch (e) {
      // Surface backend error message when available
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? e.response?.data['message'])
          : e.message;
      throw Exception('Connection error while updating scraper: $msg');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteScraper(int scraperId) async {
    try {
      final response = await _dio.delete('/scrapers/$scraperId');
      // Accept 200 or 204 as successful delete responses to be tolerant with backend implementations
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error deleting scraper: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addField(
    int scraperId, {
    required String name,
    required String xpath,
    int? order,
  }) async {
    try {
      final response = await _dio.post(
        '/scrapers/$scraperId/fields',
        data: {'name': name, 'xpath': xpath, if (order != null) 'order': order},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data'))
          return data['data'] as Map<String, dynamic>;
        if (data is Map<String, dynamic>) return data;
      }
      throw Exception('Error adding field: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Run a scraper ad-hoc without creating it on backend.
  /// Expects backend endpoint POST `/scrapers/run-ad-hoc` that accepts
  /// `{ name?, url, urlPattern?, fields: [{name,xpath,order}] }` and returns
  /// the same results shape as `runScrape`.
  Future<Map<String, dynamic>> runAdHoc({
    String? name,
    required String url,
    String? urlPattern,
    List<Map<String, dynamic>>? fields,
  }) async {
    try {
      final payload = {
        if (name != null) 'name': name,
        'url': url,
        if (urlPattern != null) 'urlPattern': urlPattern,
        'fields': fields ?? [],
      };
      final response = await _dio.post('/scrapers/run-ad-hoc', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print(data); // Debug log to inspect response structure
        if (data is Map<String, dynamic> && data.containsKey('data'))
          return data['data'] as Map<String, dynamic>;
        if (data is Map<String, dynamic>) return data;
        return {'result': data};
      }
      throw Exception('Error running ad-hoc scraper: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
