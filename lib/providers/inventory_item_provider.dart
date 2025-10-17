import 'package:flutter/foundation.dart';
import 'package:invenicum/models/inventory_item.dart';
// Asumimos que esta clase encapsula la lista de ítems, las definiciones y los resultados de agregación
import 'package:invenicum/models/inventory_item_response.dart';
import 'package:invenicum/services/inventory_item_service.dart';

// Definimos el tipo de datos esperado para los archivos que vienen del frontend
typedef FileData = List<Map<String, dynamic>>;

class InventoryItemProvider with ChangeNotifier {
  final InventoryItemService _itemService;

  // 🔑 PROTECCIÓN 1: Flag para indicar si el Provider ha sido descartado
  bool _isDisposed = false;

  // Estado de Filtrado y Ordenamiento
  Map<String, String> _filters = {};
  Map<String, String> get filters => _filters;
  String? _globalSearchTerm;
  String? get globalSearchTerm => _globalSearchTerm;

  // Campos para Totales y Agregaciones (actualizados desde InventoryResponse)
  List<dynamic> _aggregationDefinitions = [];
  Map<String, dynamic> _aggregationResults = {};

  List<dynamic> get aggregationDefinitions => _aggregationDefinitions;
  Map<String, dynamic> get aggregationResults => _aggregationResults;

  String sortKey = 'name';
  bool sortAscending = true;

  // Estado de Paginación
  int _currentPage = 1;
  int _itemsPerPage = 10;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  // IDs de la vista actual (necesarios para el caché y el getter)
  int _currentContainerId = 0;
  int _currentAssetTypeId = 0;

  // 🔑 CACHÉ CORREGIDA: Almacena el objeto InventoryResponse completo
  final Map<String, InventoryResponse> _itemsCache = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int _totalFilteredItems = 0;
  int get totalItems => _totalFilteredItems;

  InventoryItemProvider(this._itemService);

  // ----------------------------------------------------------------------
  // MANEJO DE ESTADO Y CACHÉ
  // ----------------------------------------------------------------------

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  int get totalPages {
    if (_totalFilteredItems == 0 || _itemsPerPage == 0) return 1;
    return (_totalFilteredItems / _itemsPerPage).ceil();
  }

  String _getCacheKey(
    int containerId,
    int assetTypeId, {
    Map<String, String>? aggFilters,
  }) {
    // Aseguramos un orden consistente del JSON
    final sortedAggFilters = aggFilters?.entries.toList()
      ?..sort((a, b) => a.key.compareTo(b.key));

    final aggString = sortedAggFilters != null && sortedAggFilters.isNotEmpty
        ? '&agg=${sortedAggFilters.map((e) => '${e.key}:${e.value}').join(',')}'
        : '';

    return '$containerId-$assetTypeId$aggString';
  }

  int getItemCountForAssetType(int containerId, int assetTypeId) {
    final key = _getCacheKey(containerId, assetTypeId);
    // 🔑 CORRECCIÓN: Acceder a la lista de ítems dentro del objeto caché
    return _itemsCache[key]?.items.length ?? 0;
  }

  void clearViewItems() {
    _currentContainerId = 0;
    _currentAssetTypeId = 0;
    _currentPage = 1;
    _filters = {};
    _globalSearchTerm = null;
    _totalFilteredItems = 0;
  }

  // ----------------------------------------------------------------------
  // OBTENCIÓN Y PROCESAMIENTO DE ÍTEMS
  // ----------------------------------------------------------------------

  List<InventoryItem> get inventoryItems {
    return _processAndPaginateItems(_currentContainerId, _currentAssetTypeId);
  }

  List<InventoryItem> _processAndPaginateItems(
    int containerId,
    int assetTypeId,
  ) {
    final key = _getCacheKey(containerId, assetTypeId);
    // 🔑 CORRECCIÓN: Extraer la lista de ítems del objeto InventoryResponse
    final items = _itemsCache[key]?.items ?? [];

    // 1. Aplicar Filtros
    Iterable<InventoryItem> processedItems = _applyFilters(items);

    // 2. Ordenamiento
    final sortedList = processedItems.toList();

    sortedList.sort((a, b) {
      Comparable aValue;
      Comparable bValue;

      final aCustom = a.customFieldValues ?? {};
      final bCustom = b.customFieldValues ?? {};

      if (sortKey == 'name') {
        aValue = a.name;
        bValue = b.name;
      } else if (sortKey == 'description') {
        aValue = a.description ?? '';
        bValue = b.description ?? '';
      } else {
        aValue = aCustom[sortKey]?.toString() ?? '';
        bValue = bCustom[sortKey]?.toString() ?? '';
      }

      final comparison = aValue.compareTo(bValue);

      return sortAscending ? comparison : -comparison;
    });

    _totalFilteredItems = sortedList.length;

    // 3. Paginación
    final totalItems = _totalFilteredItems;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= totalItems) {
      return [];
    }

    return sortedList.sublist(
      startIndex,
      endIndex < totalItems ? endIndex : totalItems,
    );
  }

  Iterable<InventoryItem> _applyFilters(List<InventoryItem> items) {
    Iterable<InventoryItem> processedItems = items;

    // 1. FILTRO GLOBAL
    if (_globalSearchTerm != null) {
      final searchTerm = _globalSearchTerm!;
      processedItems = processedItems.where((item) {
        if (item.name.toLowerCase().contains(searchTerm)) return true;
        if ((item.description ?? '').toLowerCase().contains(searchTerm))
          return true;
        return item.customFieldValues?.values.any((value) {
              return (value?.toString().toLowerCase() ?? '').contains(
                searchTerm,
              );
            }) ??
            false;
      });
    }

    // 2. FILTRADO POR COLUMNA
    if (_filters.isNotEmpty) {
      processedItems = processedItems.where((item) {
        return _filters.entries.every((filterEntry) {
          final filterKey = filterEntry.key;
          final filterValue = filterEntry.value.toLowerCase();
          String itemValue;

          if (filterKey == 'name') {
            itemValue = item.name.toLowerCase();
          } else if (filterKey == 'description') {
            itemValue = (item.description ?? '').toLowerCase();
          } else {
            final rawValue = item.customFieldValues?[filterKey];
            itemValue = (rawValue?.toString() ?? '').toLowerCase();
          }

          return itemValue.contains(filterValue);
        });
      });
    }

    return processedItems;
  }

  // ----------------------------------------------------------------------
  // LÓGICA DE TOTALES Y NOTIFICACIÓN
  // ----------------------------------------------------------------------

  void _recalculateTotalsAndNotify() {
    final key = _getCacheKey(_currentContainerId, _currentAssetTypeId);
    final response = _itemsCache[key];

    // 1. Actualizar agregaciones
    if (response != null) {
      _aggregationDefinitions = response.aggregationDefinitions;
      _aggregationResults = response.aggregationResults;
    } else {
      _aggregationDefinitions = [];
      _aggregationResults = {};
    }

    // 2. Forzar el cálculo de filtros/paginación (la llamada a este método solo es para el efecto secundario de calcular la sublista)
    // El valor de retorno se ignora, solo se actualiza _totalFilteredItems
    _processAndPaginateItems(_currentContainerId, _currentAssetTypeId);

    // 3. Notificar a los oyentes (Esto debe estar al final)
    notifyListeners();
  }

  // --- LÓGICA DE FILTROS Y PAGINACIÓN (Llaman a _recalculateTotalsAndNotify) ---
  void setFilter(String key, String? value) {
    if (value == null || value.isEmpty) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }
    _recalculateTotalsAndNotify();
  }

  void setGlobalSearchTerm(String? term) {
    if (term == null || term.trim().isEmpty) {
      _globalSearchTerm = null;
    } else {
      _globalSearchTerm = term.trim().toLowerCase();
    }
    _recalculateTotalsAndNotify();
  }

  void sortInventoryItems({required String dataKey, required bool ascending}) {
    sortKey = dataKey;
    sortAscending = ascending;
    _recalculateTotalsAndNotify();
  }

  void goToPage(int page) {
    // Asegurarse de que la página es al menos 1 y no excede el total
    // (El totalPages ya utiliza el _totalFilteredItems actualizado en _processAndPaginateItems)
    final newPage = page.clamp(1, totalPages);

    if (_currentPage != newPage) {
      _currentPage = newPage;
      _recalculateTotalsAndNotify();
    } else if (_currentPage == newPage && page != newPage) {
      // Caso especial: forzar la notificación si la página ya era inválida (ej: 11)
      // pero se clamp a la página válida (ej: 2) y el estado visual debe cambiar.
      _currentPage = newPage;
      _recalculateTotalsAndNotify();
    }
  }

  void setItemsPerPage(int count) {
    if (_itemsPerPage != count) {
      _itemsPerPage = count;
      _currentPage = 1;
      _recalculateTotalsAndNotify();
    }
  }

  // ----------------------------------------------------------------------
  // LÓGICA DE CARGA
  // ----------------------------------------------------------------------

  Future<void> loadInventoryItems({
    required int containerId,
    required int assetTypeId,
    Map<String, String>? aggregationFilters,
    bool forceReload = false,
    bool goToPageOne = false,
  }) async {
    _currentContainerId = containerId;
    _currentAssetTypeId = assetTypeId;

    if (goToPageOne) {
      _currentPage = 1;
    }

    final key = _getCacheKey(
      containerId,
      assetTypeId,
      aggFilters: aggregationFilters,
    );

    if (_itemsCache.containsKey(key) && !forceReload) {
      _recalculateTotalsAndNotify();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 🔑 Recibimos el objeto InventoryResponse completo (asumimos que el service fue actualizado)
      final InventoryResponse loadedResponse = await _itemService
          .fetchInventoryItems(
            containerId: containerId,
            assetTypeId: assetTypeId,
            aggregationFilters: aggregationFilters,
          );

      if (_isDisposed) return;

      // 🔑 Almacenamos el objeto InventoryResponse completo en la caché
      _itemsCache[key] = loadedResponse;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar ítems para $key: $e');
      }
      rethrow;
    } finally {
      if (_isDisposed) return;

      _isLoading = false;

      _recalculateTotalsAndNotify();
    }
  }

  // ----------------------------------------------------------------------
  // LÓGICA CRUD (SIMPLIFICADA)
  // ----------------------------------------------------------------------

  // Después de cualquier operación CRUD, la recarga forzada es la mejor práctica
  // para garantizar que los totales agregados (count/sum) sean correctos.

  Future<void> createInventoryItem(
    InventoryItem newItem, {
    FileData filesData = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemService.createInventoryItem(newItem, filesData: filesData);

      if (_isDisposed) return;

      // 🔑 Recarga forzada: Obtiene el ítem recién creado y los nuevos totales.
      await loadInventoryItems(
        containerId: newItem.containerId,
        assetTypeId: newItem.assetTypeId,
        forceReload: true,
      );
    } catch (e) {
      rethrow;
    } finally {
      // loadInventoryItems se encarga de _isLoading = false y notifyListeners.
      if (_isDisposed) return;
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

      if (_isDisposed) return;

      // 🔑 Recarga forzada: Obtiene el ítem actualizado y los nuevos totales.
      await loadInventoryItems(
        containerId: updatedItem.containerId,
        assetTypeId: updatedItem.assetTypeId,
        forceReload: true,
      );
    } catch (e) {
      rethrow;
    } finally {
      if (_isDisposed) return;
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

      if (_isDisposed) return;

      // 🎯 PASO 1: Establecer la página actual a 1.
      _currentPage = 1;

      // 🎯 PASO 2: Recargar la lista. loadInventoryItems usará _currentPage=1.
      await loadInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
        forceReload: true,
      );
    } catch (e) {
      rethrow;
    } finally {
      if (_isDisposed) return;
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
