import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'api_service.dart';

class AssetPrintService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  AssetPrintService(this._apiService);

  /// Calls the backend (Node.js) to retrieve the PDF and send it to the printer
  Future<bool> printAssetLabel(
    String assetId, {
    double width = 50.0,
    double height = 30.0,
  }) async {
    try {
      // 1. Request the PDF from the backend
      // We use `responseType: ResponseType.bytes` because we receive a file, not JSON
      final response = await _dio.get(
        '/items/$assetId/debugPrint-label',
        // 💡 Enviamos las dimensiones al Backend
        // 💡 We send the dimensions to the backend
        queryParameters: {'width': width, 'height': height},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // 2. Use the 'printing' package to open the native print dialog
        await Printing.layoutPdf(
          onLayout: (format) => response.data, // response.data contains the bytes
          name: 'Etiqueta_Asset_$assetId',
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      // Error log similar to existing ones
      debugPrint("Error Status Code: ${e.response?.statusCode}");
      debugPrint("Error Data: ${e.response?.data}");
      return false;
    } catch (e) {
      debugPrint("Unexpected error while printing: $e");
      return false;
    }
  }
}
