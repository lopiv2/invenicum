import 'package:web/web.dart' as web;
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:dio/dio.dart';
import 'package:invenicum/data/services/api_service.dart';

class ReportService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  ReportService(this._apiService);

  /// Solicita la generación de un informe al backend y lo descarga
  /// 
  /// [containerId] - ID del contenedor
  /// [reportType] - Tipo de informe: 'inventory', 'loans', 'assets'
  /// [format] - Formato: 'pdf' o 'excel'
  /// [filters] - Filtros opcionales para el informe
  Future<void> generateReport({
    required int containerId,
    required String reportType,
    required String format,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'type': reportType,
        'format': format,
        if (filters != null) ...filters,
      };

      // Solicitar al backend con responseType: arraybuffer para descargar binarios
      final response = await _dio.get(
        '/reports/generate/$containerId',
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data as List<int>);
        final fileName = _generateFileName(reportType, format);
        _downloadFile(bytes, fileName, _getMimeType(format));
      } else {
        throw Exception('Error al generar el informe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ??
          e.response?.data['error'] ??
          'Error al generar el informe';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtiene la vista previa de un informe
  /// 
  /// [containerId] - ID del contenedor
  /// [reportType] - Tipo de informe
  Future<String?> getReportPreview({
    required int containerId,
    required String reportType,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/preview/$containerId',
        queryParameters: {'type': reportType},
      );

      return response.data['preview'];
    } on DioException catch (e) {
      throw Exception('Error al obtener la vista previa: $e');
    } catch (e) {
      // No es un error crítico si no hay preview
      return null;
    }
  }

  /// Obtiene el historial de reportes generados
  Future<List<Map<String, dynamic>>> getReportHistory({
    required int containerId,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/history/$containerId',
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception('Error al obtener historial de reportes: $e');
    }
  }

  /// Descarga un reporte previamente generado por su ID
  Future<void> downloadReport({
    required int reportId,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/download/$reportId',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data as List<int>);
        final fileName = response.headers.value('content-disposition') ??
            'reporte_$reportId.pdf';
        _downloadFile(bytes, fileName, _getMimeType('pdf'));
      }
    } on DioException catch (e) {
      throw Exception('Error al descargar el reporte: $e');
    }
  }

  /// Elimina un reporte del historial
  Future<void> deleteReport({
    required int reportId,
  }) async {
    try {
      await _dio.delete('/reports/$reportId');
    } on DioException catch (e) {
      throw Exception('Error al eliminar el reporte: $e');
    }
  }

  // ========================
  // MÉTODOS PRIVADOS
  // ========================

  /// Descarga un archivo en el navegador
  static void _downloadFile(
  Uint8List bytes,
  String fileName,
  String mimeType,
) {
  // 1. Convertir la lista de Dart a un Array de JS y envolverlo en un Blob
  // package:web requiere que los datos sean JSAny
  final blob = web.Blob(
    [bytes.toJS].toJS, 
    web.BlobPropertyBag(type: mimeType),
  );

  // 2. Generar la URL (En package:web se usa web.URL, no web.Url)
  final url = web.URL.createObjectURL(blob);

  // 3. Crear el elemento Anchor usando el documento
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;

  // 4. Disparar la descarga y limpiar
  anchor.click();
  web.URL.revokeObjectURL(url);
}

  /// Genera un nombre de archivo basado en el tipo y formato
  static String _generateFileName(String reportType, String format) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '').split('.')[0];
    final extension = format == 'pdf' ? 'pdf' : 'xlsx';
    return 'informe_${reportType}_$timestamp.$extension';
  }

  /// Obtiene el MIME type según el formato
  static String _getMimeType(String format) {
    switch (format) {
      case 'pdf':
        return 'application/pdf';
      case 'excel':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }
}
