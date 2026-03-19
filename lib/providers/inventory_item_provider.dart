import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/data/models/inventory_item_response.dart';
import 'package:invenicum/data/models/price_history_point.dart';
import 'package:invenicum/data/services/asset_print_service.dart';
import 'package:invenicum/data/services/inventory_item_service.dart';

typedef FileData = List<Map<String, dynamic>>;

class InventoryItemProvider with ChangeNotifier {
  final InventoryItemService _itemService;
  final AssetPrintService _printService;
  bool _isDisposed = false;

  List<dynamic> _aggregationDefinitions = [];
  Map<String, dynamic> _aggregationResults = {};
  List<dynamic> get aggregationDefinitions => _aggregationDefinitions;
  Map<String, dynamic> get aggregationResults => _aggregationResults;

  bool _isPrinting = false;
  bool get isPrinting => _isPrinting;

  int _currentContainerId = 0;
  int _currentAssetTypeId = 0;
  int get currentContainerId => _currentContainerId;
  int get currentAssetTypeId => _currentAssetTypeId;

  List<PriceHistoryPoint> _itemHistory = [];
  List<PriceHistoryPoint> get itemHistory => _itemHistory;

  bool _loadingHistory = false;
  bool get loadingHistory => _loadingHistory;

  double _totalMarketValue = 0.0;
  bool _isMarketValueLoading = false;
  double get totalMarketValue => _totalMarketValue;
  bool get isMarketValueLoading => _isMarketValueLoading;

  // --- Caché ---
  final Map<String, InventoryResponse> _itemsCache = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  InventoryItemProvider(this._itemService, this._printService);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  // ----------------------------------------------------------------------
  // CACHÉ Y KEYS
  // ----------------------------------------------------------------------

  String _getCacheKey(
    int containerId,
    int assetTypeId, {
    Map<String, String>? aggFilters,
  }) {
    final sortedAggFilters = aggFilters?.entries.toList()
      ?..sort((a, b) => a.key.compareTo(b.key));
    final aggString = (sortedAggFilters != null && sortedAggFilters.isNotEmpty)
        ? '&agg=${sortedAggFilters.map((e) => '${e.key}:${e.value}').join(',')}'
        : '';
    return '$containerId-$assetTypeId$aggString';
  }

  // ----------------------------------------------------------------------
  // GETTER DE ITEMS
  // ----------------------------------------------------------------------

  /// Todos los items del contexto actual, sin paginación ni filtrado.
  /// PlutoGrid se encarga de filtrar, ordenar y paginar.
  List<InventoryItem> get allInventoryItems {
    final key = _getCacheKey(_currentContainerId, _currentAssetTypeId);
    final response = _itemsCache[key];
    if (response == null) return [];

    if (_currentContainerId == 0 && _currentAssetTypeId == 0) {
      return response.items;
    }

    return response.items.where((item) {
      return item.containerId == _currentContainerId &&
          item.assetTypeId == _currentAssetTypeId;
    }).toList();
  }

  // ----------------------------------------------------------------------
  // CONTADOR PARA TARJETAS DE CATEGORÍAS
  // ----------------------------------------------------------------------

  int getItemCountForAssetType(int containerId, int assetTypeId) {
    final key = _getCacheKey(containerId, assetTypeId);
    return _itemsCache[key]?.items.length ?? 0;
  }

  // ----------------------------------------------------------------------
  // CARGA DE DATOS
  // ----------------------------------------------------------------------

  void updateContextIds(int cId, int atId) {
    if (_currentContainerId == cId && _currentAssetTypeId == atId) return;

    _currentContainerId = cId;
    _currentAssetTypeId = atId;
    _aggregationDefinitions = [];
    _aggregationResults = {};
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadInventoryItems({
    required int containerId,
    required int assetTypeId,
    Map<String, String>? aggregationFilters,
    bool forceReload = false,
    bool goToPageOne = false,
  }) async {
    final key = _getCacheKey(
      containerId,
      assetTypeId,
      aggFilters: aggregationFilters,
    );

    if (forceReload) _itemsCache.remove(key);

    if (_itemsCache.containsKey(key)) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final InventoryResponse loadedResponse = await _itemService
          .fetchInventoryItems(
            containerId: containerId,
            assetTypeId: assetTypeId,
            aggregationFilters: aggregationFilters,
          );

      _aggregationDefinitions =
          List<dynamic>.from(loadedResponse.aggregationDefinitions);
      _aggregationResults =
          Map<String, dynamic>.from(loadedResponse.aggregationResults);
      _itemsCache[key] = loadedResponse;
    } catch (e, stack) {
      debugPrint('❌ Error en Provider: $e');
      debugPrint('Stack: $stack');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllItemsGlobal() async {
    if (_isLoading) return;
    _isLoading = true;
    _currentContainerId = 0;
    _currentAssetTypeId = 0;
    notifyListeners();

    try {
      final response = await _itemService.fetchInventoryItems(
        containerId: null,
        assetTypeId: null,
      );
      if (_isDisposed) return;
      _itemsCache[_getCacheKey(0, 0)] = response;
    } catch (e) {
      debugPrint('Error en carga global: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTotalMarketValue() async {
    _isMarketValueLoading = true;
    notifyListeners();
    try {
      _totalMarketValue = await _itemService.fetchTotalMarketValue();
    } catch (e) {
      debugPrint('Error cargando valor de mercado: $e');
    } finally {
      _isMarketValueLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPriceHistory(int itemId) async {
    _loadingHistory = true;
    _itemHistory = [];
    notifyListeners();
    try {
      _itemHistory = await _itemService.getItemPriceHistory(itemId);
    } catch (e) {
      debugPrint('Error cargando historial: $e');
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> syncWithUPC(int itemId) async {
    _isSyncing = true;
    notifyListeners();
    try {
      final updatedItem = await _itemService.syncItemWithUPC(itemId);

      if (updatedItem.priceHistory != null) {
        _itemHistory = updatedItem.priceHistory!;
      }

      _itemsCache.forEach((key, response) {
        final index = response.items.indexWhere((i) => i.id == itemId);
        if (index != -1) response.items[index] = updatedItem;
      });
    } catch (e) {
      debugPrint('Error en syncWithUPC: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------------
  // VALOR ECONÓMICO GLOBAL
  // ----------------------------------------------------------------------

  double getTotalGlobalEconomicValue(
    List<CustomFieldDefinition> allDefinitions,
  ) {
    double totalValue = 0.0;
    final monetaryFieldIds = allDefinitions
        .where((def) => def.isMonetary)
        .map((def) => def.id.toString())
        .toSet();

    if (monetaryFieldIds.isEmpty) return 0.0;

    for (var response in _itemsCache.values) {
      for (var item in response.items) {
        item.customFieldValues?.forEach((fieldId, value) {
          if (monetaryFieldIds.contains(fieldId)) {
            totalValue +=
                (double.tryParse(value.toString()) ?? 0.0) * item.quantity;
          }
        });
      }
    }
    return totalValue;
  }

  // ----------------------------------------------------------------------
  // BÚSQUEDA EN CACHÉ
  // ----------------------------------------------------------------------

  InventoryItem? getItemFromCache(int id) {
    for (var response in _itemsCache.values) {
      final item = response.items.cast<InventoryItem?>().firstWhere(
            (i) => i?.id == id,
            orElse: () => null,
          );
      if (item != null) return item;
    }
    return null;
  }

  // Alias para compatibilidad con código existente
  InventoryItem? getItemById(int id) => getItemFromCache(id);

  // ----------------------------------------------------------------------
  // CRUD
  // ----------------------------------------------------------------------

  Future<void> createInventoryItem(
    InventoryItem newItem, {
    FileData filesData = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _itemService.createInventoryItem(newItem, filesData: filesData);
      await loadInventoryItems(
        containerId: newItem.containerId,
        assetTypeId: newItem.assetTypeId,
        forceReload: true,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<InventoryItem> updateAssetWithFiles(
    InventoryItem updatedItem, {
    FileData filesToUpload = const [],
    List<int> imageIdsToDelete = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _itemService.updateInventoryItem(
        updatedItem,
        filesToUpload: filesToUpload,
        imageIdsToDelete: imageIdsToDelete,
      );
      await loadInventoryItems(
        containerId: updatedItem.containerId,
        assetTypeId: updatedItem.assetTypeId,
        forceReload: true,
      );
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteInventoryItem(
    int itemId,
    int containerId,
    int assetTypeId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _itemService.deleteInventoryItem(itemId);
      await loadInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
        forceReload: true,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cloneInventoryItem(InventoryItem item) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _itemService.cloneInventoryItem(item);
      await loadInventoryItems(
        containerId: item.containerId,
        assetTypeId: item.assetTypeId,
        forceReload: true,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createBatchFromCSV({
    required int containerId,
    required int assetTypeId,
    required List<Map<String, dynamic>> itemsToUpload,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _itemService.createBatchInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
        itemsData: itemsToUpload,
      );
      await loadInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
        forceReload: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> printLabel(
    String assetId, {
    double width = 50.0,
    double height = 30.0,
  }) async {
    _isPrinting = true;
    notifyListeners();
    await _printService.printAssetLabel(assetId, width: width, height: height);
    _isPrinting = false;
    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // RESET
  // ----------------------------------------------------------------------

  void resetState() {
    _itemsCache.clear();
    _currentContainerId = 0;
    _currentAssetTypeId = 0;
    notifyListeners();
  }
}