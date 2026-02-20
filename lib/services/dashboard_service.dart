import 'package:dio/dio.dart';
import 'package:invenicum/models/dashboard_stats.dart';
import 'api_service.dart'; // Importamos el servicio base

class DashboardService {
  final ApiService _apiService;

  // Acceso a la instancia de Dio a través de ApiService
  Dio get _dio => _apiService.dio; 

  // Constructor que recibe ApiService (Inyección de dependencia)
  DashboardService(this._apiService);

  // ------------------------------------------------------------------
  // --- R (READ): Obtener Estadísticas Globales para el Dashboard ---
  // ------------------------------------------------------------------
  
  /// Obtiene los contadores clave (contenedores, ítems totales, ítems pendientes) 
  /// de un endpoint dedicado en la API.
  Future<DashboardStats> getGlobalStats() async {
    try {
      // ⚠️ Ajusta esta URL al endpoint real de tu API para estadísticas globales
      const url = '/dashboard/stats'; 
      
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        // Asumimos que la respuesta de estadísticas se anida en 'data'
        if (responseData.containsKey('data') && responseData['data'] != null) {
          // Usamos el modelo DashboardStats para un parsing seguro
          return DashboardStats.fromJson(responseData['data']);
        } else {
          // Si el servidor devuelve 200 pero sin datos
          throw Exception('Respuesta de API exitosa, pero el objeto de estadísticas está ausente o es nulo.');
        }
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicie sesión nuevamente.');
      }
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Error de conexión o de servidor al cargar el Dashboard: $message');
    } catch (e) {
      throw Exception('Error inesperado al obtener estadísticas: $e');
    }
  }

  // ------------------------------------------------------------------
  // --- Puedes añadir más métodos relacionados con el Dashboard aquí ---
  // ------------------------------------------------------------------

  /// Ejemplo: Obtener una lista de ítems recientes
  /*
  Future<List<InventoryItem>> getRecentItems() async {
    // Implementación similar a getGlobalStats, pero devolviendo una lista de ítems
  }
  */
}