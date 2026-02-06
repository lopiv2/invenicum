import 'package:flutter/foundation.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/models/inventory_item_response.dart';
import 'package:invenicum/services/inventory_item_service.dart';

typedef FileData = List<Map<String, dynamic>>;

class InventoryItemProvider with ChangeNotifier {
  final InventoryItemService _itemService;
  bool _isDisposed = false;

  // --- Estado de Filtrado y Ordenamiento ---
  Map<String, String> _filters = {};
  Map<String, String> get filters => _filters;
  String? _globalSearchTerm;
  String? get globalSearchTerm => _globalSearchTerm;

  List<dynamic> _aggregationDefinitions = [];
  Map<String, dynamic> _aggregationResults = {};
  List<dynamic> get aggregationDefinitions => _aggregationDefinitions;
  Map<String, dynamic> get aggregationResults => _aggregationResults;

  String sortKey = 'name';
  bool sortAscending = true;

  // --- Estado de Paginación ---
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  int? _currentContainerId;
  int? _currentAssetTypeId;

  int get currentContainerId => _currentContainerId ?? 0;
  int get currentAssetTypeId => _currentAssetTypeId ?? 0;

  // --- Gestión de Caché ---
  final Map<String, InventoryResponse> _itemsCache = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalFilteredItems = 0;
  int get totalItems => _totalFilteredItems;

  InventoryItemProvider(this._itemService);

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
  // MANEJO DE CACHÉ Y KEYS
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

  // 🚩 RESTAURADA: Función para los contadores de las tarjetas de categorías
  int getItemCountForAssetType(int containerId, int assetTypeId) {
    final key = _getCacheKey(containerId, assetTypeId);
    return _itemsCache[key]?.items.length ?? 0;
  }

  // ----------------------------------------------------------------------
  // GETTER PRINCIPAL (PROCESAMIENTO)
  // ----------------------------------------------------------------------

  List<InventoryItem> get inventoryItems {
    final cId = _currentContainerId ?? 0;
    final atId = _currentAssetTypeId ?? 0;

    if (cId == 0 || atId == 0) return [];

    // 🚩 CAMBIO CLAVE: Usa la función _getCacheKey para que la llave sea EXACTAMENTE
    // la misma que usaste en loadInventoryItems.
    final key = _getCacheKey(cId, atId);

    final response = _itemsCache[key];

    if (response == null) return [];

    // Filtrado por contexto
    final filteredByContext = response.items.where((item) {
      return item.containerId == cId && item.assetTypeId == atId;
    }).toList();

    Iterable<InventoryItem> processedItems = _applyFilters(filteredByContext);
    List<InventoryItem> sortedList = processedItems.toList();
    _applySort(sortedList);

    _totalFilteredItems = sortedList.length;

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= _totalFilteredItems) return [];
    final endIndex = startIndex + _itemsPerPage;

    return sortedList.sublist(
      startIndex,
      endIndex < _totalFilteredItems ? endIndex : _totalFilteredItems,
    );
  }

  // ----------------------------------------------------------------------
  // CARGA DE DATOS
  // ----------------------------------------------------------------------
  void updateContextIds(int cId, int atId) {
    if (_currentContainerId == cId && _currentAssetTypeId == atId) return;
    _currentContainerId = cId;
    _currentAssetTypeId = atId;
    notifyListeners();
  }

  Future<void> loadInventoryItems({
    required int containerId,
    required int assetTypeId,
    Map<String, String>? aggregationFilters,
    bool forceReload = false,
    bool goToPageOne = false,
  }) async {
    if (_currentAssetTypeId != assetTypeId ||
        _currentContainerId != containerId) {
      _aggregationDefinitions = [];
      _aggregationResults = {};
      _itemsCache.clear(); // Limpieza selectiva
    }
    // 2. Sincronización inmediata
    _currentContainerId = containerId;
    _currentAssetTypeId = assetTypeId;

    final key = _getCacheKey(
      containerId,
      assetTypeId,
      aggFilters: aggregationFilters,
    );

    if (forceReload) _itemsCache.remove(key);
    if (_itemsCache.containsKey(key) && !forceReload) {
      _recalculateTotalsAndNotify();
      return;
    }

    _isLoading = true;
    notifyListeners(); // Notifica a la UI que use los nuevos IDs (4 y 1)

    try {
      final InventoryResponse loadedResponse = await _itemService
          .fetchInventoryItems(
            containerId: containerId,
            assetTypeId: assetTypeId,
            aggregationFilters: aggregationFilters,
          );
      _aggregationDefinitions = List.from(
        loadedResponse.aggregationDefinitions,
      );
      _aggregationResults = Map.from(loadedResponse.aggregationResults);
      _itemsCache[key] = loadedResponse;
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify();
    }
  }

  Future<void> loadAllItemsGlobal() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _itemService.fetchInventoryItems(
        containerId: null,
        assetTypeId: null,
      );
      if (_isDisposed) return;
      _itemsCache[_getCacheKey(0, 0)] = response;
      _currentContainerId = 0;
      _currentAssetTypeId = 0;
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify();
    }
  }

  // ----------------------------------------------------------------------
  // OPERACIONES CRUD
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

  Future<void> updateAssetWithFiles(
    InventoryItem updatedItem, {
    FileData filesToUpload = const [],
    List<int> imageIdsToDelete = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _itemService.updateInventoryItem(
        updatedItem,
        filesToUpload: filesToUpload,
        imageIdsToDelete: imageIdsToDelete,
      );
      await loadInventoryItems(
        containerId: updatedItem.containerId,
        assetTypeId: updatedItem.assetTypeId,
        forceReload: true,
      );
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
      _currentPage = 1;
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
        goToPageOne: true,
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
        goToPageOne: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------------
  // FILTRADO Y ORDENACIÓN
  // ----------------------------------------------------------------------

  Iterable<InventoryItem> _applyFilters(List<InventoryItem> items) {
    return items.where((item) {
      if (_globalSearchTerm != null) {
        final term = _globalSearchTerm!;
        bool matches =
            item.name.toLowerCase().contains(term) ||
            (item.description ?? '').toLowerCase().contains(term) ||
            (item.location?.name ?? '').toLowerCase().contains(term);
        if (!matches) {
          matches =
              item.customFieldValues?.values.any(
                (v) => v.toString().toLowerCase().contains(term),
              ) ??
              false;
        }
        if (!matches) return false;
      }
      if (_filters.isNotEmpty) {
        return _filters.entries.every((e) {
          final val = e.value.toLowerCase();
          // Manejo de Cantidad (Stock)
          if (e.key == 'quantity') {
            return _compareNumeric(item.quantity, val);
          }
          // Manejo de Stock Mínimo
          if (e.key == 'minStock') {
            return _compareNumeric(item.minStock, val);
          }
          if (e.key == 'name') return item.name.toLowerCase().contains(val);
          if (e.key == 'description') {
            return (item.description ?? '').toLowerCase().contains(val);
          }
          if (e.key == 'location') {
            return (item.location?.name ?? '').toLowerCase().contains(val);
          }
          return (item.customFieldValues?[e.key]?.toString() ?? '')
              .toLowerCase()
              .contains(val);
        });
      }
      return true;
    });
  }

  bool _compareNumeric(num? itemValue, String filterText) {
    if (itemValue == null) return false;

    // Limpiamos el filtro (ej: "> 10" -> ">10")
    final cleanFilter = filterText.replaceAll(' ', '');

    try {
      if (cleanFilter.startsWith('>=')) {
        return itemValue >= (num.tryParse(cleanFilter.substring(2)) ?? 0);
      } else if (cleanFilter.startsWith('<=')) {
        return itemValue <= (num.tryParse(cleanFilter.substring(2)) ?? 0);
      } else if (cleanFilter.startsWith('>')) {
        return itemValue > (num.tryParse(cleanFilter.substring(1)) ?? 0);
      } else if (cleanFilter.startsWith('<')) {
        return itemValue < (num.tryParse(cleanFilter.substring(1)) ?? 0);
      } else if (cleanFilter.startsWith('=')) {
        return itemValue == (num.tryParse(cleanFilter.substring(1)) ?? 0);
      }

      // Si solo pone el número, buscamos coincidencia exacta o "contiene"
      final target = num.tryParse(cleanFilter);
      if (target != null) return itemValue == target;
    } catch (e) {
      return false;
    }
    return false;
  }

  void _applySort(List<InventoryItem> list) {
    list.sort((a, b) {
      Comparable aVal;
      Comparable bVal;
      switch (sortKey) {
        case 'name':
          aVal = a.name.toLowerCase();
          bVal = b.name.toLowerCase();
          break;
        case 'description':
          aVal = (a.description ?? '').toLowerCase();
          bVal = (b.description ?? '').toLowerCase();
          break;
        case 'quantity':
          aVal = a.quantity;
          bVal = b.quantity;
          break;
        case 'minStock':
          aVal = a.minStock;
          bVal = b.minStock;
          break;
        case 'location':
          aVal = (a.location?.name ?? '').toLowerCase();
          bVal = (b.location?.name ?? '').toLowerCase();
          break;
        case 'createdAt':
          aVal = a.createdAt ?? DateTime(0);
          bVal = b.createdAt ?? DateTime(0);
          break;
        case 'updatedAt':
          aVal = a.updatedAt ?? DateTime(0);
          bVal = b.updatedAt ?? DateTime(0);
          break;
        default:
          final aRaw = a.customFieldValues?[sortKey]?.toString() ?? '';
          final bRaw = b.customFieldValues?[sortKey]?.toString() ?? '';
          aVal = num.tryParse(aRaw) ?? aRaw.toLowerCase();
          bVal = num.tryParse(bRaw) ?? bRaw.toLowerCase();
      }
      return sortAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });
  }

  // ----------------------------------------------------------------------
  // AUXILIARES
  // ----------------------------------------------------------------------

  void _recalculateTotalsAndNotify() {
    final cId = _currentContainerId ?? 0;
    final atId = _currentAssetTypeId ?? 0;

    if (cId == 0 || atId == 0) return;

    final key = _getCacheKey(cId, atId);
    final response = _itemsCache[key];

    if (response != null) {
      // 🚩 SOLO actualizamos si la respuesta de esta llave tiene datos.
      // No tocamos _aggregationDefinitions si ya fueron asignadas en loadInventoryItems.
      _totalFilteredItems = _applyFilters(response.items).length;

      // Solo sincronizamos resultados si vienen en este objeto
      if (response.aggregationResults.isNotEmpty) {
        _aggregationResults = Map.from(response.aggregationResults);
      }
    }
    notifyListeners();
  }

  void setFilter(String key, String? value) {
    if (value == null || value.isEmpty)
      _filters.remove(key);
    else
      _filters[key] = value;
    _recalculateTotalsAndNotify();
  }

  void setGlobalSearchTerm(String? term) {
    _globalSearchTerm = (term == null || term.trim().isEmpty)
        ? null
        : term.trim().toLowerCase();
    _currentPage = 1;
    _recalculateTotalsAndNotify();
  }

  void sortInventoryItems({required String dataKey, required bool ascending}) {
    sortKey = dataKey;
    sortAscending = ascending;
    _recalculateTotalsAndNotify();
  }

  int get totalPages {
    if (_totalFilteredItems == 0 || _itemsPerPage == 0) return 1;
    return (_totalFilteredItems / _itemsPerPage).ceil();
  }

  void goToPage(int page) {
    _currentPage = page.clamp(1, totalPages);
    notifyListeners();
  }

  void setItemsPerPage(int count) {
    _itemsPerPage = count;
    _currentPage = 1;
    _recalculateTotalsAndNotify();
  }

  void clearViewItems() {
    //_currentContainerId = 0;
    //_currentAssetTypeId = 0;
    _currentPage = 1;
    _filters.clear();
    _globalSearchTerm = null;
    notifyListeners();
  }

  void resetState() {
    _itemsCache.clear();
    _currentContainerId = 0;
    _currentAssetTypeId = 0;
    clearViewItems();
  }
}
