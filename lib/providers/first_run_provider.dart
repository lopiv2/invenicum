import 'package:flutter/material.dart';
import 'package:invenicum/data/services/api_service.dart';

enum FirstRunStatus {
  unknown,
  checking,
  notFirstRun,
  firstRun,
}

class FirstRunProvider extends ChangeNotifier {
  final ApiService _apiService;

  FirstRunStatus _status = FirstRunStatus.unknown;
  FirstRunStatus get status => _status;

  bool get isChecking =>
      _status == FirstRunStatus.unknown || _status == FirstRunStatus.checking;

  bool get isFirstRun => _status == FirstRunStatus.firstRun;

  FirstRunProvider(this._apiService);

  Future<void> check() async {
    _status = FirstRunStatus.checking;
    notifyListeners(); // 🔑 Notificar SIEMPRE al entrar en checking.
    // Sin esto, al llamar check() desde la pantalla de setup el router
    // ve isChecking=true y devuelve null (congela la navegación) pero nunca
    // recibe el aviso de que el estado cambió a checking, por lo que
    // cuando llega notFirstRun el router ya no re-evalúa correctamente.

    final result = await _apiService.checkFirstRun();

    _status = result ? FirstRunStatus.firstRun : FirstRunStatus.notFirstRun;
    notifyListeners();
  }

  /// Usar este método desde [FirstRunSetupScreen] tras crear el admin,
  /// en lugar de llamar a check().
  ///
  /// Motivo: si llamamos check() justo después del POST /setup existe una
  /// condición de carrera — el backend puede no haber confirmado aún la
  /// escritura y devolver firstRun: true de nuevo. Con markAsComplete()
  /// forzamos el estado localmente sin petición extra, ya que sabemos con
  /// certeza que el usuario acaba de ser creado con éxito.
  void markAsComplete() {
    _status = FirstRunStatus.notFirstRun;
    notifyListeners();
  }
}