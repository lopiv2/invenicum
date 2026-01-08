// lib/providers/loan_provider.dart

import 'package:flutter/material.dart';
import 'package:invenicum/models/loan.dart';
import 'package:invenicum/services/loan_service.dart';

class LoanProvider extends ChangeNotifier {
  final LoanService _loanService;

  List<Loan> _loans = [];
  bool _isLoading = false;
  String? _errorMessage;

  LoanProvider(this._loanService);

  // Getters
  List<Loan> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Loan> get activeLoans =>
      _loans.where((l) => l.status == 'active').toList();
  List<Loan> get returnedLoans =>
      _loans.where((l) => l.status == 'returned').toList();
  List<Loan> get overdueLoans => _loans.where((l) => l.isOverdue).toList();

  /// Obtiene todos los préstamos de un contenedor
  Future<void> fetchLoans(int containerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loans = await _loanService.getLoans(containerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Crea un nuevo préstamo
  Future<Loan> createLoan(int containerId, Loan loan) async {
    try {
      final newLoan = await _loanService.createLoan(containerId, loan);
      _loans.add(newLoan);
      notifyListeners();
      return newLoan;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Actualiza un préstamo existente
  Future<Loan> updateLoan(int containerId, Loan loan) async {
    try {
      final updatedLoan = await _loanService.updateLoan(containerId, loan);
      final index = _loans.indexWhere((l) => l.id == loan.id);
      if (index != -1) {
        _loans[index] = updatedLoan;
      }
      notifyListeners();
      return updatedLoan;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Devuelve un objeto prestado
  Future<Loan> returnLoan(int containerId, int loanId) async {
    try {
      final returnedLoan = await _loanService.returnLoan(containerId, loanId);
      final index = _loans.indexWhere((l) => l.id == loanId);
      if (index != -1) {
        _loans[index] = returnedLoan;
      }
      notifyListeners();
      return returnedLoan;
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

  /// Limpia los errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
