import 'package:dio/dio.dart';
import 'package:printing/printing.dart';
import 'api_service.dart';

class AssetPrintService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  AssetPrintService(this._apiService);

  /// Llama al backend (Node.js) para obtener el PDF y lanzarlo a la impresora
  Future<bool> printAssetLabel(
    String assetId, {
    double width = 50.0,
    double height = 30.0,
  }) async {
    try {
      // 1. Pedimos el PDF al backend
      // Usamos responseType: ResponseType.bytes porque recibimos un archivo, no un JSON
      final response = await _dio.get(
        '/items/$assetId/print-label',
        // 💡 Enviamos las dimensiones al Backend
        queryParameters: {'width': width, 'height': height},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // 2. Usamos la librería 'printing' para abrir el menú nativo
        await Printing.layoutPdf(
          onLayout: (format) =>
              response.data, // response.data contiene los bytes
          name: 'Etiqueta_Asset_$assetId',
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      // Log de error similar al que ya usas
      print("Error Status Code: ${e.response?.statusCode}");
      print("Error Data: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error inesperado al imprimir: $e");
      return false;
    }
  }
}
