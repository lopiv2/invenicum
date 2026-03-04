import 'package:flutter/material.dart';
import 'package:invenicum/data/models/dashboard_stats.dart';
import '../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service;
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider(this._service);

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStats() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _service.getGlobalStats();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}