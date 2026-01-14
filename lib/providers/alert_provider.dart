// lib/providers/alert_provider.dart
import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/alert_service.dart';

class AlertProvider with ChangeNotifier {
  final AlertService _alertService;
  List<Alert> _alerts = [];
  bool _isLoading = false;

  AlertProvider(this._alertService);

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  Future<void> loadAlerts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _alerts = await _alertService.getAlerts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAlert(String title, String message, String type) async {
    await _alertService.createAlert({
      'title': title,
      'message': message,
      'type': type,
    });
    await loadAlerts();
  }

  Future<void> deleteAlert(int id) async {
    await _alertService.deleteAlert(id);
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    await _alertService.markAsRead(id);
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].isRead = true;
      notifyListeners();
    }
  }
}