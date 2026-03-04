import 'package:flutter/material.dart';
import 'package:invenicum/data/services/integrations_service.dart';

class IntegrationProvider with ChangeNotifier {
  final IntegrationService _service;

  Map<String, bool> _statuses = {};
  bool _isLoading = false;

  IntegrationProvider(this._service);

  Map<String, bool> get statuses => _statuses;
  bool get isLoading => _isLoading;

  bool _isTesting = false;
  bool get isTesting => _isTesting;

  String _lastErrorMessage = "";
  String get lastErrorMessage => _lastErrorMessage;

  // Método para saber si una integración específica está vinculada
  bool isLinked(String id) => _statuses[id] ?? false;

  Future<void> loadStatuses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _statuses = await _service.getIntegrationStatuses();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> testConnection(String type, Map<String, dynamic> config) async {
    _isTesting = true;
    _lastErrorMessage = ""; // Limpiamos error previo
    notifyListeners();

    try {
      final result = await _service.testIntegration(type, config);
      if (result['success'] == true) {
        return true;
      } else {
        _lastErrorMessage = result['message'] ?? "Error desconocido";
        return false;
      }
    } catch (e) {
      _lastErrorMessage = "Error de servidor";
      return false;
    } finally {
      _isTesting = false;
      notifyListeners();
    }
  }

  // Nuevo método para desvincular una integración
  Future<bool> unlinkIntegration(String type) async {
    try {
      // 1. Llamada al servicio (DELETE /api/integrations/:type)
      await _service.deleteIntegration(type);

      // 2. Actualización local del estado
      _statuses[type] = false;

      // 3. Notificar a las pantallas (el tick verde se vuelve gris)
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error al desvincular: $e");
      return false;
    }
  }

  // Obtener config para el modal
  Future<Map<String, dynamic>?> getConfig(String type) async {
    return await _service.getIntegrationConfig(type);
  }

  // Guardar y actualizar el check verde al instante
  Future<bool> saveIntegration(String type, Map<String, dynamic> config) async {
    try {
      await _service.saveIntegration(type, config);
      _statuses[type] = true; // Actualización optimista del estado local
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
