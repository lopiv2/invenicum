// lib/services/inventory_item_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:invenicum/data/models/inventory_item.dart';
// 🔑 Import the class that contains the list of items AND totals
import 'package:invenicum/data/models/inventory_item_response.dart';
import 'package:invenicum/data/models/price_history_point.dart';
import 'api_service.dart';
import 'dart:convert';

// Define a TypeDef to make the signature more readable
typedef FileData = List<Map<String, dynamic>>;

class InventoryItemService {
  final ApiService _apiService;
  Dio get _dio => _apiService.dio;

  InventoryItemService(this._apiService);

  // --- 1. READ ---
  Future<InventoryResponse> fetchInventoryItems({
    int? containerId,
    int? assetTypeId,
    Map<String, String>? aggregationFilters,
  }) async {
    try {
      String path = (containerId != null && assetTypeId != null)
          ? '/containers/$containerId/asset-types/$assetTypeId/items'
          : '/items';

      final Map<String, dynamic> queryParameters = {};
      if (aggregationFilters != null && aggregationFilters.isNotEmpty) {
        queryParameters['aggFilters'] = aggregationFilters.entries
            .map((e) => '${e.key}:${e.value}')
            .join(',');
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      // 1. Basic null check
      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final responseData = response.data as Map<String, dynamic>;

      // 2. Extract the 'data' field.
      // NOTE: If your backend route doesn't wrap in 'data', use responseData directly
      final dataField = responseData['data'] is Map<String, dynamic>
          ? responseData['data'] as Map<String, dynamic>
          : responseData;

      try {
        // 3. Call the parser
        return InventoryResponse.fromJson(dataField);
      } catch (e) {
        // 🕵️ DEBUG: This will show which JSON field breaks the model
        if (kDebugMode) {
          debugPrint("❌ InventoryResponse parser error: $e");
          debugPrint("Received JSON: $dataField");
        }
        rethrow;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("DioError: ${e.response?.data}");
      }
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error fetching items: $e');
    }
  }

  // inventory_item_service.dart

  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  // NEW CLONE METHOD
  Future<InventoryItem> cloneInventoryItem(InventoryItem item) async {
    // Ensure your HTTP client (e.g. Dio, http) uses the correct route
    final containerId = item.containerId;
    final assetTypeId = item.assetTypeId;

    // 🎯 KEY ROUTE: Call the new endpoint without Multer
    final url = '/containers/$containerId/asset-types/$assetTypeId/items/clone';
    // Make the POST request with a JSON body
    final response = await _dio.post(
      url,
      data: item
          .toJson(), // Sends the InventoryItem object (with images: [{id: 0, url: '...'}])
    );

    return InventoryItem.fromJson(response.data);
  }

  /// Descarga una imagen desde URL y la convierte en Data URL Base64.
  Future<String> downloadImageAsDataUrl(String imageUrl) async {
    try {
      // Ask backend to fetch the image server-side to avoid CORS issues
      // Backend endpoint expected: POST /proxy/image { url: string }
      final proxyPath = '/items/image-url-to-base64';
      final response = await _dio.post(
        proxyPath,
        data: {'url': imageUrl},
        options: Options(responseType: ResponseType.bytes),
      );

      final contentType = response.headers.value('content-type') ?? 'image/jpeg';
      final bytes = response.data as List<int>;
      final base64String = base64Encode(bytes);
      return 'data:$contentType;base64,$base64String';
    } on DioException catch (e) {
      // Provide a friendly error message
      throw Exception('Error descargando la imagen desde el servidor: ${e.message}');
    } catch (e) {
      throw Exception('Error descargando la imagen: $e');
    }
  }

  // ----------------------------------------------------------------------
  // --- 2. CREATE ---
  // ----------------------------------------------------------------------
  Future<InventoryItem> createInventoryItem(
    InventoryItem item, {
    FileData filesData = const [],
  }) async {
    try {
      // 1. Build FormData manually to handle nulls correctly
      final formData = FormData();

      formData.fields.add(MapEntry('name', item.name));
      formData.fields.add(MapEntry('description', item.description ?? ''));
      formData.fields.add(MapEntry('barcode', item.barcode ?? ''));
      formData.fields.add(MapEntry('serialNumber', item.serialNumber ?? ''));
      formData.fields.add(MapEntry('condition', item.condition.name));
      formData.fields.add(MapEntry('containerId', item.containerId.toString()));
      formData.fields.add(MapEntry('assetTypeId', item.assetTypeId.toString()));
      formData.fields.add(MapEntry('quantity', item.quantity.toString()));
      formData.fields.add(
        MapEntry('minStock', item.minStock.toString()),
      ); // 🔑 NEW: minStock
      formData.fields.add(MapEntry('marketValue', item.marketValue.toString()));

      // 🔑 Handle locationId correctly: only add it if not null
      if (item.locationId != null) {
        formData.fields.add(MapEntry('locationId', item.locationId.toString()));
      }

      formData.fields.add(
        MapEntry('customFieldValues', jsonEncode(item.customFieldValues)),
      );

      // 2. Add files to FormData
      for (var file in filesData) {
        final bytes = file['bytes'] as Uint8List;
        final name = file['name'] as String;

        final multipartFile = MultipartFile.fromBytes(bytes, filename: name);

        // The backend (Multer) expects 'images'
        formData.files.add(MapEntry('images', multipartFile));
      }

      // 3. Send the POST request with FormData
      final response = await _dio.post('/items', data: formData);
      if (response.statusCode == 201) {
        // The backend returns a nested structure: { data: { data: InventoryItemJson } }
        final responseData = response.data;

        // Handle possible nesting
        dynamic itemData = responseData;
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }

        return InventoryItem.fromJson(itemData as Map<String, dynamic>);
      } else {
        throw Exception(
          'Error creating asset: Code ${response.statusCode} - ${response.data['message'] ?? response.statusMessage}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error creating asset: $e');
    }
  }

  // ----------------------------------------------------------------------------------
  // 🚀 --- 3. UPDATE ---
  // ----------------------------------------------------------------------------------
  Future<InventoryItem> updateInventoryItem(
    InventoryItem item, {
    FileData filesToUpload = const [],
    List<int> imageIdsToDelete = const [],
  }) async {
    try {
      // 1. Build FormData manually to handle nulls correctly
      final formData = FormData();

      formData.fields.add(MapEntry('name', item.name));
      formData.fields.add(MapEntry('description', item.description ?? ''));
      formData.fields.add(MapEntry('barcode', item.barcode ?? ''));
      formData.fields.add(MapEntry('serialNumber', item.serialNumber ?? ''));
      formData.fields.add(
        MapEntry(
          'condition',
          item.condition.name == 'new_' ? 'new' : item.condition.name,
        ),
      );
      formData.fields.add(MapEntry('containerId', item.containerId.toString()));
      formData.fields.add(MapEntry('assetTypeId', item.assetTypeId.toString()));
      formData.fields.add(MapEntry('quantity', item.quantity.toString()));
      formData.fields.add(
        MapEntry('minStock', item.minStock.toString()),
      );
      formData.fields.add(MapEntry('marketValue', item.marketValue.toString()));

      // 🔑 Handle locationId correctly: only add it if not null
      if (item.locationId != null) {
        formData.fields.add(MapEntry('locationId', item.locationId.toString()));
      }

      formData.fields.add(
        MapEntry('customFieldValues', jsonEncode(item.customFieldValues)),
      );
      formData.fields.add(
        MapEntry('imageIdsToDelete', jsonEncode(imageIdsToDelete)),
      );

      // 2. Add NEW files to FormData
      for (var file in filesToUpload) {
        final bytes = file['bytes'] as Uint8List;
        final name = file['name'] as String;

        final multipartFile = MultipartFile.fromBytes(bytes, filename: name);

        formData.files.add(MapEntry('images', multipartFile));
      }

      // 3. Send the PATCH request with FormData
      // The backend should return the updated InventoryItem directly.
      final response = await _dio.patch('/items/${item.id}', data: formData);

      if (response.statusCode == 200) {
        // Handle possible nested structure
        dynamic itemData = response.data;
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }
        if (itemData is Map && itemData.containsKey('data')) {
          itemData = itemData['data'];
        }

        return InventoryItem.fromJson(itemData as Map<String, dynamic>);
      } else {
        throw Exception(
          'Error updating asset: Code ${response.statusCode} - ${response.data['message'] ?? response.statusMessage}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error updating asset: $e');
    }
  }

  // --- 4. DELETE ---
  Future<void> deleteInventoryItem(int itemId) async {
    try {
      final response = await _dio.delete('/items/$itemId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error deleting asset: Code ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error deleting asset: $e');
    }
  }

  // ----------------------------------------------------------------------
  // 📦 --- 5. CREATE BATCH (Bulk Import) ---
  // ----------------------------------------------------------------------

  /// Sends a list of mapped asset data to a batch-processing endpoint.
  ///
  /// Uses a simple POST (JSON body) since there are no file attachments.
  Future<Map<String, dynamic>> createBatchInventoryItems({
    required int containerId,
    required int assetTypeId,
    required List<Map<String, dynamic>> itemsData,
  }) async {
    final url = '/containers/$containerId/asset-types/$assetTypeId/items/batch';
    final Map<String, dynamic> requestBody = {'items': itemsData};

    try {
      final response = await _dio.post(url, data: requestBody);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Error importing assets in batch: Code ${response.statusCode} - ${response.data['message'] ?? response.statusMessage}',
        );
      }

      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error during batch import: $e');
    }
  }

  Future<double> fetchTotalMarketValue() async {
    try {
      // Call the global endpoint defined on the backend
      final response = await _dio.get('/total-market-value');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // Extract the summed value returned by the server
        return (data['totalMarketValue'] as num).toDouble();
      } else {
        throw Exception('Error fetching market value');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("Dio error in fetchTotalMarketValue: ${e.response?.data}");
      }
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<PriceHistoryPoint>> getItemPriceHistory(int itemId) async {
    try {
      final response = await _dio.get('/items/$itemId/price-history');

      if (response.statusCode == 200) {
        // If the backend sends the array directly [{}, {}]
        // Use response.data directly if Dio already parsed it as a List
        final List data = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        return data.map((json) => PriceHistoryPoint.fromJson(json)).toList();
      } else {
        throw response.data['error'] ?? 'Error fetching price history';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Service error: $e");
      }
      rethrow;
    }
  }

  Future<InventoryItem> syncItemWithUPC(int itemId) async {
    try {
      final response = await _dio.post('/market/sync-item/$itemId');
      return InventoryItem.fromJson(response.data['data']);
    } on DioException catch (e) {
      // 🛡️ Extract the message sent by the backend
      String errorMessage = "Error syncing";

      if (e.response?.data != null && e.response?.data['error'] != null) {
        errorMessage = e.response!.data['error']; // e.g. "Item has no barcode"
      }

      throw errorMessage; // Throw only the error text
    } catch (e) {
      throw "Unexpected error: $e";
    }
  }

  Future<void> toggleWishlist(int itemId, bool status) async {
    try {
      await _dio.patch('/items/$itemId/wishlist', data: {'wishlisted': status});
    } catch (e) {
      throw Exception('Error communicating with server');
    }
  }

  /// Synchronizes market values for all barcode-bearing items of an assetType.
  /// Returns a summary map: { total, updated, skipped, errors, details }.
  Future<Map<String, dynamic>> syncAssetTypeMarketValues({
    required int assetTypeId,
    required int containerId,
  }) async {
    try {
      final response = await _dio.post(
        '/market/sync-asset-type',
        data: {'assetTypeId': assetTypeId, 'containerId': containerId},
      );
      final data = response.data as Map<String, dynamic>;
      return data['summary'] as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error syncing prices';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
