import 'package:dio/dio.dart';
import 'package:invenicum/services/api_service.dart';

class AchievementService {
  final ApiService _apiService;

  AchievementService(this._apiService);

  Dio get _dio => _apiService.dio;

  /// Recupera la lista de todos los logros y su estado para el usuario actual
  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final response = await _dio.get('/achievements');
      final List<dynamic> data = response.data['data'];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  /// Notifica al servidor que se ha cumplido una acción (opcional, 
  /// el backend suele calcular esto por su cuenta mediante triggers)
  Future<void> triggerAction(String actionType, dynamic value) async {
    try {
      await _dio.post('/achievements/check', data: {
        'action': actionType,
        'value': value,
      });
    } catch (e) {
      // Error silencioso para no interrumpir la UX
    }
  }
}