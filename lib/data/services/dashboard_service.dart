import 'package:dio/dio.dart';
import 'package:invenicum/data/models/dashboard_stats.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService;

  // Access to the Dio instance via ApiService
  Dio get _dio => _apiService.dio;

  // Constructor receiving ApiService (dependency injection)
  DashboardService(this._apiService);

  // ------------------------------------------------------------------
  // --- R (READ): Get Global Statistics for the Dashboard ---
  // ------------------------------------------------------------------
  
  /// Retrieves key counters (containers, total items, pending items)
  /// from a dedicated API endpoint.
  Future<DashboardStats> getGlobalStats() async {
    try {
      // ⚠️ Adjust this URL to your API's real global stats endpoint
      const url = '/dashboard/stats';
      
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        // Assume the statistics response is nested under 'data'
        if (responseData.containsKey('data') && responseData['data'] != null) {
          // Use the DashboardStats model for safe parsing
          return DashboardStats.fromJson(responseData['data']);
        } else {
          // If the server returns 200 but without data
          throw Exception('API returned success but the statistics object is missing or null.');
        }
      } else {
        throw Exception('Error fetching statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Connection or server error loading the Dashboard: $message');
    } catch (e) {
      throw Exception('Unexpected error fetching statistics: $e');
    }
  }
}