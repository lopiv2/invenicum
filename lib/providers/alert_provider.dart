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

  Future<void> updateAlert(int id, Map<String, dynamic> data) async {
    try {
      await _alertService.updateAlert(id, data);
      await loadAlerts(); // Recargamos para ver los cambios
    } catch (e) {
      print("Error al editar: $e");
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
    priorityChannels, // 👈 Añadimos esto para el orden de Telegram/Email
  }) async {
    // 1. Llamamos al servicio pasando TODO lo que ya tenías + los canales
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

    // 2. En lugar de hacer un loadAlerts() completo (que gasta red),
    // insertamos directamente la alerta que nos devuelve el servidor.
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
