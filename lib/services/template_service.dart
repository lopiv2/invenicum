import 'package:dio/dio.dart';
import 'package:invenicum/models/asset_template_model.dart';
import 'api_service.dart';

class TemplateService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  TemplateService(this._apiService);

  // ------------------------------------------------------------------
  // --- MARKET: Obtener plantillas globales ---
  // ------------------------------------------------------------------
  Future<List<AssetTemplate>> getMarketTemplates() async {
    try {
      const url = '/templates/market';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // El DTO devuelve directamente el Array o un objeto con data: []
        // Si tu router hace res.json(AssetTemplateDTO.fromList(templates))
        // response.data será una lista.
        final List<dynamic> data = response.data;
        return data.map((json) => AssetTemplate.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener el mercado: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ------------------------------------------------------------------
  // --- DOWNLOAD: Incrementar contador en el repositorio ---
  // ------------------------------------------------------------------
  Future<void> trackDownload(String templateId) async {
    try {
      final url = '/templates/$templateId/download';
      // No necesitamos esperar la respuesta ni validar el código de estado
      // de forma crítica, ya que es una métrica analítica.
      await _dio.post(url);
    } on DioException catch (e) {
      // Logueamos el error pero no interrumpimos al usuario
      print("❌ Error al trackear descarga en GitHub: ${e.message}");
    }
  }

  // ------------------------------------------------------------------
  // --- DETAIL: Obtener detalle completo (Hidratado) ---
  // ------------------------------------------------------------------
  Future<AssetTemplate> getTemplateById(String id) async {
    try {
      final url = '/templates/detail/$id';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // El router devuelve new AssetTemplateDTO(template).toJSON()
        // por lo que response.data es el objeto de la plantilla.
        return AssetTemplate.fromJson(response.data);
      } else {
        throw Exception('No se encontró la plantilla');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ------------------------------------------------------------------
  // --- PUBLISH: Publicar en el Market (Devuelve el objeto creado) ---
  // ------------------------------------------------------------------
  Future<AssetTemplate> publishTemplate(AssetTemplate template) async {
    try {
      final response = await _dio.post(
        '/templates/publish',
        data: template.toJson(), // Envía snake_case gracias a tu nuevo modelo
      );

      // 🚩 REVISIÓN IMPORTANTE:
      // Tu router de Express devuelve res.status(201).json({ success: true, data: result })
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data']; // Extraemos el campo 'data'
        return AssetTemplate.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? "Error al publicar");
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ------------------------------------------------------------------
  // --- LIBRARY: Obtener biblioteca personal ---
  // ------------------------------------------------------------------
  Future<List<AssetTemplate>> getUserLibrary() async {
    try {
      const url = '/templates/my-library';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Asumiendo que esta ruta también devuelve una lista de DTOs
        final List<dynamic> data = response.data;
        return data.map((json) => AssetTemplate.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Helper centralizado para errores
  Exception _handleError(DioException e) {
    final message = e.response?.data is Map
        ? (e.response?.data['message'] ?? e.message)
        : e.message;
    return Exception(message);
  }
}
