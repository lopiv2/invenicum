// lib/services/alert_service.dart
import 'package:dio/dio.dart';
import '../models/alert.dart';
import 'api_service.dart';

class AlertService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  AlertService(this._apiService);

  Future<List<Alert>> getAlerts() async {
    try {
      final response = await _dio.get('/alerts');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Alert.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error when fetching alerts: $e');
    }
  }

  Future<Alert> createAlert(Map<String, dynamic> alertData) async {
    final response = await _dio.post('/alerts', data: alertData);
    return Alert.fromJson(response.data['data']);
  }

  Future<void> updateAlert(int id, Map<String, dynamic> data) async {
    await _dio.put('/alerts/$id', data: data);
  }

  Future<void> deleteAlert(int id) async {
    await _dio.delete('/alerts/$id');
  }

  Future<void> markAsRead(int id) async {
    await _dio.patch('/alerts/$id/read');
  }
}