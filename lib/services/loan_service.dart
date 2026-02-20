import 'package:dio/dio.dart';
import 'package:invenicum/models/loan.dart';
import 'api_service.dart';

class LoanService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  LoanService(this._apiService);

  /// Obtiene todos los préstamos globales (Dashboard)
  /// El backend ya filtra por el userId del Token JWT
  Future<List<Loan>> getAllLoans() async {
    try {
      final response = await _dio.get('/loans');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Loan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener préstamos globales');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  /// Obtiene los préstamos de un contenedor específico
  Future<List<Loan>> getLoans(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/loans');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => Loan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener préstamos del contenedor');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  /// Crea un nuevo préstamo
  /// Nota: Ya no pasamos el userId en el body, el backend lo pone del Token
  Future<Loan> createLoan(int containerId, Loan loan) async {
    try {
      final response = await _dio.post(
        '/containers/$containerId/loans',
        data: loan.toJson(), // El backend ignora campos que no necesita
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Loan.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al crear el préstamo');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error al crear préstamo');
    }
  }

  /// Marca un préstamo como devuelto
  /// El backend ya incrementa el stock automáticamente
  Future<Loan> returnLoan(int containerId, int loanId) async {
    try {
      final response = await _dio.put(
        '/containers/$containerId/loans/$loanId/return',
      );

      if (response.statusCode == 200) {
        return Loan.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al devolver el objeto');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error en la devolución');
    }
  }

  /// Elimina un préstamo (Solo si eres el dueño)
  Future<void> deleteLoan(int containerId, int loanId) async {
    try {
      final response = await _dio.delete(
        '/containers/$containerId/loans/$loanId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('No se pudo eliminar el préstamo');
      }
    } on DioException catch (e) {
      throw Exception('Error al borrar: ${e.message}');
    }
  }

  /// Obtiene estadísticas para el widget del contenedor
  Future<Map<String, dynamic>> getLoanStats(int containerId) async {
    try {
      final response = await _dio.get('/containers/$containerId/loans-stats');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Error al obtener estadísticas');
    } on DioException catch (e) {
      throw Exception('Error de estadísticas: ${e.message}');
    }
  }
}