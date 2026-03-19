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
  bool _isPrinting = false;
  bool get isPrinting => _isPrinting;

  // --- Estado de Paginación ---
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  int _currentContainerId = 0;
  int _currentAssetTypeId = 0;

  int get currentContainerId => _currentContainerId;
  int get currentAssetTypeId => _currentAssetTypeId;

  double _globalEconomicValue = 0.0;
  bool _isStatsLoading = false;

  double get globalEconomicValue => _globalEconomicValue;
  bool get isStatsLoading => _isStatsLoading;

  List<PriceHistoryPoint> _itemHistory = [];
  List<PriceHistoryPoint> get itemHistory => _itemHistory;

  bool _loadingHistory = false;
  bool get loadingHistory => _loadingHistory;

  double _totalMarketValue = 0.0;
  bool _isMarketValueLoading = false;

  double get totalMarketValue => _totalMarketValue;
  bool get isMarketValueLoading => _isMarketValueLoading;

  // --- Gestión de Caché ---
  final Map<String, InventoryResponse> _itemsCache = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  int _totalFilteredItems = 0;
  int get totalItems => _totalFilteredItems;

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

  Future<void> loadTotalMarketValue() async {
    _isMarketValueLoading = true;
    notifyListeners(); // Notificamos para mostrar el estado de carga en el widget

    try {
      _totalMarketValue = await _itemService.fetchTotalMarketValue();
    } catch (e) {
      debugPrint("Error cargando valor de mercado en Provider: $e");
    } finally {
      _isMarketValueLoading = false;
      notifyListeners(); // Notificamos para mostrar el valor final
    }
  }

  Future<void> loadPriceHistory(int itemId) async {
    _loadingHistory = true;
    _itemHistory = []; // Reset para evitar mostrar datos viejos
    notifyListeners();

    try {
      // 🚀 Llamada al SERVICIO
      final history = await _itemService.getItemPriceHistory(itemId);
      _itemHistory = history;
    } catch (e) {
      debugPrint("Error en Provider: $e");
      // Aquí puedes manejar el error o guardarlo en una variable para la UI
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> syncWithUPC(int itemId) async {
    _isSyncing = true;
    notifyListeners();

    try {
      // 1. Llamada al servicio
      final updatedItem = await _itemService.syncItemWithUPC(itemId);

      // 2. 🔑 CLAVE: Actualizamos el historial que el Consumer está escuchando
      // Como el backend devuelve el item con el historial actualizado:
      if (updatedItem.priceHistory != null) {
        _itemHistory = updatedItem.priceHistory!;
      }

      // 3. Actualizamos el ítem en la caché (tu lógica actual)
      bool updated = false;
      _itemsCache.forEach((key, response) {
        final index = response.items.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          response.items[index] = updatedItem;
          updated = true;
        }
      });

      if (updated) {
        _recalculateTotalsAndNotify(); // Esto ya llama a notifyListeners()
      }
    } catch (e) {
      debugPrint("Error en Provider syncWithUPC: $e");
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners(); // Notifica el fin de la carga para que el gráfico se repinte
    }
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
    final cId = _currentContainerId;
    final atId = _currentAssetTypeId;

    final key = _getCacheKey(cId, atId);
    final response = _itemsCache[key];

    if (response == null) return [];

    // ✅ CORRECCIÓN: Si estamos en modo global (0), usamos todos los items.
    // Si tenemos IDs específicos, entonces sí filtramos por contexto.
    final List<InventoryItem> filteredByContext = (cId == 0 && atId == 0)
        ? response.items
        : response.items.where((item) {
            return item.containerId == cId && item.assetTypeId == atId;
          }).toList();

    // Aplicamos filtros de búsqueda (search bar), ordenamiento y paginación
    Iterable<InventoryItem> processedItems = _applyFilters(filteredByContext);
    List<InventoryItem> sortedList = processedItems.toList();
    _applySort(sortedList);

    _totalFilteredItems = sortedList.length;

    // Paginación
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= _totalFilteredItems && _totalFilteredItems != 0)
      return [];

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

  _currentPage = 1;
  _filters.clear();
  _globalSearchTerm = null;
  _aggregationDefinitions = [];
  _aggregationResults = {};
  _isLoading = true;

  // Notificar después del primer frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
}

  /// Calcula el valor económico total de TODO el inventario en caché,
  /// agrupando las definiciones monetarias de todos los tipos de activos.
  // En InventoryItemProvider
  double getTotalGlobalEconomicValue(
    List<CustomFieldDefinition> allDefinitions,
  ) {
    double totalValue = 0.0;

    // Filtramos solo los IDs que son monetarios
    final monetaryFieldIds = allDefinitions
        .where((def) => def.isMonetary)
        .map((def) => def.id.toString())
        .toSet();

    if (monetaryFieldIds.isEmpty) return 0.0;

    // Sumamos todos los items que tengamos en la caché
    for (var response in _itemsCache.values) {
      for (var item in response.items) {
        item.customFieldValues?.forEach((fieldId, value) {
          if (monetaryFieldIds.contains(fieldId)) {
            double unitValue = double.tryParse(value.toString()) ?? 0.0;
            totalValue += (unitValue * (item.quantity));
          }
        });
      }
    }
    return totalValue;
  }

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

  InventoryItem? getItemById(int id) {
    // Buscamos en todas las respuestas guardadas en caché
    for (var response in _itemsCache.values) {
      final item = response.items.cast<InventoryItem?>().firstWhere(
        (i) => i?.id == id,
        orElse: () => null,
      );
      if (item != null) return item;
    }
    return null;
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

    if (_itemsCache.containsKey(key) && !forceReload) {
      _isLoading = false; // Por si acaso venía de updateContextIds
      _recalculateTotalsAndNotify();
      return;
    }

    // Si ya es true (por el updateContextIds), no hace falta notificar otra vez aquí
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

      // 🛡️ PROTECCIÓN: Usa dynamic o Map para evitar el error de subtype
      _aggregationDefinitions = List<dynamic>.from(
        loadedResponse.aggregationDefinitions,
      );

      _aggregationResults = Map<String, dynamic>.from(
        loadedResponse.aggregationResults,
      );

      _itemsCache[key] = loadedResponse;
    } catch (e, stack) {
      // 🕵️ ESTO ES VITAL: Si vuelve a fallar, mira la consola y verás la línea exacta
      print("❌ Error en Provider: $e");
      print("Stack: $stack");
      rethrow;
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify();
    }
  }

  Future<void> loadAllItemsGlobal() async {
    if (_isLoading) return;
    _isLoading = true;

    // 🚩 CAMBIO 1: Sincronizamos los IDs a global inmediatamente
    // Esto asegura que cualquier lectura durante la carga sepa que estamos en modo global
    _currentPage = 1;
    _currentContainerId = 0;
    _currentAssetTypeId = 0;
    notifyListeners();

    try {
      final response = await _itemService.fetchInventoryItems(
        containerId: null, // Tu API debe entender que null = todo
        assetTypeId: null,
      );

      if (_isDisposed) return;

      // Guardamos en la caché global
      _itemsCache[_getCacheKey(0, 0)] = response;
    } catch (e) {
      debugPrint("Error en carga global: $e");
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify(); // Esto dispara el redibujado final
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

  // lib/providers/inventory_item_provider.dart

  Future<InventoryItem> updateAssetWithFiles(
    // Cambiamos void por Future<InventoryItem>
    InventoryItem updatedItem, {
    FileData filesToUpload = const [],
    List<int> imageIdsToDelete = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Actualizamos
      final result = await _itemService.updateInventoryItem(
        updatedItem,
        filesToUpload: filesToUpload,
        imageIdsToDelete: imageIdsToDelete,
      );

      // 2. Recargamos localmente
      await loadInventoryItems(
        containerId: updatedItem.containerId,
        assetTypeId: updatedItem.assetTypeId,
        forceReload: true,
      );
      _recalculateTotalsAndNotify();

      return result; // Devolvemos el item fresco del servidor
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

  // Añadimos parámetros opcionales con valores por defecto (50x30)
  Future<void> printLabel(
    String assetId, {
    double width = 50.0,
    double height = 30.0,
  }) async {
    _isPrinting = true;
    notifyListeners();

    // Pasamos las dimensiones al servicio
    final success = await _printService.printAssetLabel(
      assetId,
      width: width,
      height: height,
    );

    _isPrinting = false;
    notifyListeners();

    if (!success) {
      // ToastService.error("No se pudo generar la etiqueta");
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
          // Filtro por estado
          if (e.key == 'condition') {
            return item.condition.name == e.value;
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
          if (e.key == 'barcode') {
            return (item.barcode ?? '').toLowerCase().contains(val);
          }
          if (e.key == 'marketValue') {
            return _compareNumeric(item.marketValue, val);
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
        case 'barcode':
          aVal = (a.barcode ?? '').toLowerCase();
          bVal = (b.barcode ?? '').toLowerCase();
          break;
        case 'marketValue':
          aVal = a.marketValue;
          bVal = b.marketValue;
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
    final cId = _currentContainerId;
    final atId = _currentAssetTypeId;
    final key = _getCacheKey(cId, atId);
    final response = _itemsCache[key];

    if (response != null) {
      _totalFilteredItems = _applyFilters(response.items).length;

      // 🚩 CRUCIAL: Recuperar las definiciones de la caché.
      // Tras un F5, si el widget pide un redibujado, necesitamos asegurar que
      // las definiciones estén presentes.
      if (response.aggregationDefinitions.isNotEmpty) {
        _aggregationDefinitions = List<dynamic>.from(
          response.aggregationDefinitions,
        );
      }

      if (response.aggregationResults.isNotEmpty) {
        _aggregationResults = Map.from(response.aggregationResults);
      }
    } else {
      // Si no hay respuesta (está cargando), reseteamos totales para evitar
      // mostrar datos de la categoría anterior
      _totalFilteredItems = 0;
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
