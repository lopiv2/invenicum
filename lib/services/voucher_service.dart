import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:invenicum/config/environment.dart';
import '../services/api_service.dart';

class VoucherService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  VoucherService(this._apiService);

  // Obtener la configuración global única
  Future<Map<String, dynamic>?> getVoucherConfig() async {
    try {
      final response = await _dio.get('/voucher-config');
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error al obtener voucher config: $e');
      return null;
    }
  }

  // Guardar configuración global (Multipart para texto e imagen)
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
      print('Error al guardar voucher config: $e');
      rethrow;
    }
  }

  // NUEVO: Obtener bytes de una imagen (URL) usando Dio
  Future<Uint8List?> fetchImageBytes(String logoPathFromDb) async {
    try {
      // 1. Obtenemos solo el nombre del archivo o la subruta limpia
      // Si el backend guarda "vouchers/imagen.png", lo dejamos así.
      // Si guarda "uploads/inventory/vouchers/imagen.png", limpiamos la base.
      String fileName = logoPathFromDb.replaceFirst('uploads/inventory/', '');
      if (fileName.startsWith('/')) fileName = fileName.substring(1);

      // 2. Construimos la URL usando el prefijo estático definido en tu app.js
      // En app.js: STATIC_URL_PREFIX = "/images"
      // URL Final: http://localhost:3000/images/vouchers/logo-xxx.png
      final String fullImageUrl = '${Environment.apiUrl}/images/$fileName';

      print("Descargando logo desde: $fullImageUrl");

      final response = await _dio.get(
        fullImageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          // Al pasar la URL completa (http://...), Dio ignora el baseUrl automático
        ),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      print("Error al descargar bytes de imagen: $e");
      return null;
    }
  }
}
