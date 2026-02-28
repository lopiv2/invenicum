import 'package:flutter/material.dart';
import 'package:invenicum/models/loan.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/services/loan_service.dart';

class LoanProvider extends ChangeNotifier {
  final LoanService _loanService;

  List<Loan> _loans = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Nuevo: para guardar estadísticas por contenedor si fuera necesario
  Map<String, dynamic>? _currentStats;

  LoanProvider(this._loanService);

  // Getters
  List<Loan> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentStats => _currentStats;

  // Filtros inteligentes usando las propiedades del DTO
  List<Loan> get activeLoans =>
      _loans.where((l) => l.status == 'active').toList();

  List<Loan> get returnedLoans =>
      _loans.where((l) => l.status == 'returned').toList();

  // 🚩 Ahora usamos la propiedad que viene calculada del Backend
  List<Loan> get overdueLoans => _loans.where((l) => l.isOverdue).toList();

  /// Obtiene préstamos de forma global (Dashboard)
  Future<void> fetchAllLoans() async {
    _setLoading(true);
    try {
      _loans = await _loanService.getAllLoans();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene los préstamos de un contenedor
  Future<void> fetchLoans(int containerId) async {
    _setLoading(true);
    try {
      _loans = await _loanService.getLoans(containerId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Crea un nuevo préstamo
  Future<Loan> createLoan(
    int containerId,
    Loan loan, {
    AlertProvider? alertProvider,
  }) async {
    _setLoading(true);
    try {
      // 1. Llamamos al servicio (solo red)
      final createdLoan = await _loanService.createLoan(containerId, loan);

      // 2. Actualizamos la lista local
      _loans.insert(0, createdLoan);

      // 🚀 REFRESCAR ALERTAS:
      // Como el back creó una alerta de stock, le pedimos al AlertProvider que recargue
      if (alertProvider != null) {
        // loadAlerts() traerá la alerta que el backend acaba de crear
        await alertProvider.loadAlerts();
      }

      _errorMessage = null;
      notifyListeners();
      return createdLoan;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Marca como devuelto (Simplificado)
  Future<void> returnLoan(int containerId, int loanId) async {
    try {
      final returnedLoan = await _loanService.returnLoan(containerId, loanId);
      final index = _loans.indexWhere((l) => l.id == loanId);
      if (index != -1) {
        _loans[index] = returnedLoan;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Elimina un préstamo
  Future<void> deleteLoan(int containerId, int loanId) async {
    try {
      await _loanService.deleteLoan(containerId, loanId);
      _loans.removeWhere((l) => l.id == loanId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Obtiene estadísticas específicas (opcional para widgets de resumen)
  Future<void> fetchStats(int containerId) async {
    try {
      _currentStats = await _loanService.getLoanStats(containerId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching stats: $e");
    }
  }

  // Método privado para evitar repetición de notifyListeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
