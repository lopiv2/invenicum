import 'package:dio/dio.dart';
import 'package:invenicum/data/services/api_service.dart';

class AchievementService {
  final ApiService _apiService;
  AchievementService(this._apiService);
  Dio get _dio => _apiService.dio;

  Future<List<Map<String, dynamic>>> getAchievements() async {
    final response = await _dio.get('/achievements');
    final List<dynamic> data = response.data['data'];
    return data.cast<Map<String, dynamic>>();
  }

  /// Dispara un evento al backend y devuelve los logros recién desbloqueados
  Future<List<Map<String, dynamic>>> processEvent(
    String type, {
    int value = 1,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/achievements/event',
        data: {'type': type, 'value': value, 'metadata': ?metadata},
      );
      final data = response.data['data'];
      final newUnlocks = data['newUnlocks'] as List? ?? [];
      return newUnlocks.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
}
