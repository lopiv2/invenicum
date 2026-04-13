import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:invenicum/config/environment.dart';
import 'api_service.dart';

class VoucherService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  VoucherService(this._apiService);

  // Get the single global configuration
  Future<Map<String, dynamic>?> getVoucherConfig() async {
    try {
      final response = await _dio.get('/voucher-config');
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching voucher config: $e');
      return null;
    }
  }

  // Save global configuration (Multipart for text and image)
  Future<void> saveVoucherTemplate(
    String template,
    Uint8List? logoBytes,
  ) async {
    final Map<String, dynamic> data = {'template': template};

    if (logoBytes != null) {
      data['logo'] = MultipartFile.fromBytes(
        logoBytes,
        filename: 'logo.png',
        contentType: DioMediaType('image', 'png'),
      );
    }

    final FormData formData = FormData.fromMap(data);

    try {
      await _dio.post('/voucher-config', data: formData);
    } catch (e) {
      debugPrint('Error saving voucher config: $e');
      rethrow;
    }
  }

  // NEW: Get image bytes (URL) using Dio
  Future<Uint8List?> fetchImageBytes(String logoPathFromDb) async {
    try {
      // 1. Extract only the file name or the clean subpath
      // If the backend stores "vouchers/image.png", we leave it as is.
      // If it stores "uploads/inventory/vouchers/image.png", we clean the base.
      String fileName = logoPathFromDb.replaceFirst('uploads/inventory/', '');
      if (fileName.startsWith('/')) fileName = fileName.substring(1);

      // 2. Build the URL using the static prefix defined in your app.js
      // In app.js: STATIC_URL_PREFIX = "/images"
      // Final URL: http://localhost:3000/images/vouchers/logo-xxx.png
      final String fullImageUrl = '${Environment.apiUrl}/images/$fileName';

      debugPrint("Downloading logo from: $fullImageUrl");

      final response = await _dio.get(
        fullImageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          // Al pasar la URL completa (http://...), Dio ignora el baseUrl automático
        ),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      debugPrint("Error downloading image bytes: $e");
      return null;
    }
  }
}
