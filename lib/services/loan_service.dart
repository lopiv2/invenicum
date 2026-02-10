// lib/services/loan_service.dart

import 'package:dio/dio.dart';
import 'package:invenicum/models/loan.dart';
import 'api_service.dart';

class LoanService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  LoanService(this._apiService);

  /// Obtiene todos los préstamos de forma global (para el Dashboard)
  Future<List<Loan>> getAllLoans() async {
    try {
      // 🚩 Ajusta esta ruta según tu API (ej: '/loans' o '/users/me/loans')
      final response = await _dio.get('/loans');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Loan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener todos los préstamos: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error en getAllLoans: $e');
    }
  }

  /// Obtiene todos los préstamos de un contenedor
  Future<List<Loan>> getLoans(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/loans');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Loan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener préstamos: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error en getLoans: $e');
    }
  }

  /// Obtiene un préstamo específico por ID
  Future<Loan> getLoan(int containerId, int loanId) async {
    try {
      final response = await _dio.get('/containers/$containerId/loans/$loanId');

      if (response.statusCode == 200) {
        return Loan.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al obtener el préstamo: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error en getLoan: $e');
    }
  }

  /// Crea un nuevo préstamo
  Future<Loan> createLoan(int containerId, Loan loan) async {
    try {
      final response = await _dio.post(
        '/containers/$containerId/loans',
        data: loan.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Loan.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al crear préstamo: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error en createLoan: $e');
    }
  }

  /// Actualiza un préstamo existente
  Future<Loan> updateLoan(int containerId, Loan loan) async {
    try {
      final response = await _dio.put(
        '/containers/$containerId/loans/${loan.id}',
        data: loan.toJsonForUpdate(),
      );

      if (response.statusCode == 200) {
        return Loan.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al actualizar préstamo: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error en updateLoan: $e');
    }
  }

  /// Devuelve un objeto prestado (marca como returned)
  Future<Loan> returnLoan(int containerId, int loanId) async {
    try {
      final response = await _dio.put(
        '/containers/$containerId/loans/$loanId/return',
      );

      if (response.statusCode == 200) {
        return Loan.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al devolver préstamo: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error en returnLoan: $e');
    }
  }

  /// Elimina un préstamo
  Future<void> deleteLoan(int containerId, int loanId) async {
    try {
      final response = await _dio.delete(
        '/containers/$containerId/loans/$loanId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar préstamo: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error en deleteLoan: $e');
    }
  }
}
