// lib/providers/alert_provider.dart
import 'package:flutter/material.dart';
import '../data/models/alert.dart';
import '../data/services/alert_service.dart';

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

  Future<void> updateAlert(int id, Map<String, dynamic> data) async {
    try {
      await _alertService.updateAlert(id, data);
      await loadAlerts(); // Reload to reflect changes
    } catch (e) {
      debugPrint("Error editing alert: $e");
      rethrow;
    }
  }

  Future<void> createAlert(
    String title,
    String message,
    String type, {
    bool isEvent = false,
    DateTime? scheduledAt,
    DateTime? notifyAt,
    List<String>?
    priorityChannels, // 👈 We add this for Telegram/Email priority ordering
  }) async {
    // 1. Call the service passing everything you already had + the channels
    final newAlert = await _alertService.createAlert({
      'title': title,
      'message': message,
      'type': type,
      'isEvent': isEvent,
      'isRead': false,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'notifyAt': notifyAt?.toIso8601String(),
      'priority_channels':
          priorityChannels, // 🚀 El Back usará esto para notificar
    });

    // 2. Instead of doing a full loadAlerts() (which uses network),
    // insert the alert returned by the server directly.
    _alerts.insert(0, newAlert);
    notifyListeners();
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
