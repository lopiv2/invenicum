import 'package:dio/dio.dart';
import 'package:invenicum/data/models/loan.dart';
import 'api_service.dart';

class LoanService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  LoanService(this._apiService);

  /// Get all global loans (Dashboard)
  /// The backend already filters by the userId in the JWT token
  Future<List<Loan>> getAllLoans() async {
    try {
      final response = await _dio.get('/loans');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Loan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error fetching global loans');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get loans for a specific container
  Future<List<Loan>> getLoans(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/loans');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Loan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error fetching container loans');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new loan
  /// Note: we no longer pass userId in the body; the backend uses the Token
  Future<Loan> createLoan(int containerId, Loan loan) async { // 👈 Quita el context
  try {
    final response = await _dio.post(
      '/containers/$containerId/loans',
      data: loan.toJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Loan.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Error al crear el préstamo');
    }
  } on DioException catch (e) {
  throw Exception(e.response?.data['error'] ?? 'Error creating loan');
  }
}

  /// Mark a loan as returned
  /// The backend already increments stock automatically
  Future<Loan> returnLoan(int containerId, int loanId) async {
    try {
      final response = await _dio.put(
        '/containers/$containerId/loans/$loanId/return',
      );

      if (response.statusCode == 200) {
        return Loan.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error returning item');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error during return');
    }
  }

  /// Delete a loan (only if you are the owner)
  Future<void> deleteLoan(int containerId, int loanId) async {
    try {
      final response = await _dio.delete(
        '/containers/$containerId/loans/$loanId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Could not delete the loan');
      }
    } on DioException catch (e) {
      throw Exception('Error deleting: ${e.message}');
    }
  }

  /// Obtiene estadísticas para el widget del contenedor
  Future<Map<String, dynamic>> getLoanStats(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/loans-stats');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Error fetching statistics');
    } on DioException catch (e) {
      throw Exception('Statistics error: ${e.message}');
    }
  }
}
