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

  Future<void> loadAllItemsGlobal() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Llamamos al servicio (asegúrate de que el servicio permita IDs opcionales como vimos antes)
      final response = await _itemService.fetchInventoryItems(
        containerId:
            null, // Enviamos null para que el servicio use la ruta global
        assetTypeId: null,
      );

      if (_isDisposed) return;

      // 2. 🔑 SOLUCIÓN AL ERROR:
      // En lugar de '_inventoryItems = ...', guardamos en el caché.
      // Usamos IDs 0 y 0 para representar la "Vista Global" del Dashboard.
      final dashboardKey = _getCacheKey(0, 0);
      _itemsCache[dashboardKey] = response;

      // 3. Establecemos la vista actual a 0,0 para que el getter 'inventoryItems'
      // sepa de dónde leer los datos inmediatamente.
      _currentContainerId = 0;
      _currentAssetTypeId = 0;
    } catch (e) {
      debugPrint('Error cargando items globales: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        // Recalculamos totales para que el Dashboard vea los resultados
        _recalculateTotalsAndNotify();
      }
    }
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

      switch (sortKey) {
        case 'name':
          aValue = a.name.trim().toLowerCase();
          bValue = b.name.trim().toLowerCase();
          break;
        case 'description':
          aValue = (a.description ?? '').trim().toLowerCase();
          bValue = (b.description ?? '').trim().toLowerCase();
          break;
        case 'quantity':
          aValue = a.quantity;
          bValue = b.quantity;
          break;
        case 'minStock':
          aValue = a.minStock;
          bValue = b.minStock;
          break;
        case 'createdAt':
          // Usar una fecha muy antigua para valores nulos para que aparezcan al principio/final
          aValue = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          bValue = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          break;
        case 'updatedAt':
          aValue = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          bValue = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          break;
        case 'location':
          aValue = (a.location?.name ?? '').trim().toLowerCase();
          bValue = (b.location?.name ?? '').trim().toLowerCase();

          // 🔑 Si las ubicaciones son iguales, usamos el nombre como segundo criterio
          if (aValue == bValue) {
            aValue = a.name.trim().toLowerCase();
            bValue = b.name.trim().toLowerCase();
          }
          break;
        default:
          // Lógica para campos personalizados
          final aCustom = a.customFieldValues ?? {};
          final bCustom = b.customFieldValues ?? {};
          final aRaw = (aCustom[sortKey]?.toString() ?? '').trim();
          final bRaw = (bCustom[sortKey]?.toString() ?? '').trim();

          final aNumber = num.tryParse(aRaw);
          final bNumber = num.tryParse(bRaw);

          if (aNumber != null && bNumber != null) {
            aValue = aNumber;
            bValue = bNumber;
          } else {
            aValue = aRaw.toLowerCase();
            bValue = bRaw.toLowerCase();
          }
          break;
      }

      // 🔑 IMPORTANTE: Comparación segura
      try {
        final comparison = aValue.compareTo(bValue);
        return sortAscending ? comparison : -comparison;
      } catch (e) {
        // Fallback en caso de que los tipos no coincidan (ej. comparar String con num)
        return sortAscending
            ? aValue.toString().compareTo(bValue.toString())
            : bValue.toString().compareTo(aValue.toString());
      }
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

  void resetState() {
    _itemsCache.clear();
    _filters.clear();
    _globalSearchTerm = null;
    _currentPage = 1;
    _currentContainerId = 0;
    _currentAssetTypeId = 0;
    _totalFilteredItems = 0;
    _isLoading = false;
    notifyListeners();
  }

  Iterable<InventoryItem> _applyFilters(List<InventoryItem> items) {
    return items.where((item) {
      // 1. FILTRO GLOBAL
      if (_globalSearchTerm != null) {
        final term = _globalSearchTerm!;
        bool matches =
            item.name.toLowerCase().contains(term) ||
            (item.description ?? '').toLowerCase().contains(term) ||
            (item.location?.name ?? '').toLowerCase().contains(
              term,
            ); // 📍 Búsqueda global incluye ubicación

        if (!matches) {
          matches =
              item.customFieldValues?.values.any(
                (value) =>
                    (value?.toString().toLowerCase() ?? '').contains(term),
              ) ??
              false;
        }
        if (!matches) return false;
      }

      // 2. FILTRADO POR COLUMNA
      if (_filters.isNotEmpty) {
        return _filters.entries.every((filterEntry) {
          final filterKey = filterEntry.key;
          final filterValue = filterEntry.value.toLowerCase();

          String itemValue = '';
          if (filterKey == 'name')
            itemValue = item.name;
          else if (filterKey == 'description')
            itemValue = item.description ?? '';
          else if (filterKey == 'location')
            itemValue =
                item.location?.name ?? ''; // 📍 Filtro específico columna
          else
            itemValue = item.customFieldValues?[filterKey]?.toString() ?? '';

          return itemValue.toLowerCase().contains(filterValue);
        });
      }

      return true;
    });
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

      // LÍNEAS ELIMINADAS: La lista _inventoryItems no existe ni es necesaria
      // en esta arquitectura. La lista se lee directamente del caché en el getter.
    } else {
      // LÍNEAS ELIMINADAS: La lista _inventoryItems no existe ni es necesaria
      _aggregationDefinitions = [];
      _aggregationResults = {};
    }

    // 2. Forzar el cálculo de filtros/paginación
    // Esto asegura que _totalFilteredItems se recalcule usando los datos ACTUALIZADOS del caché.
    _processAndPaginateItems(_currentContainerId, _currentAssetTypeId);

    // 3. Notificar a los oyentes
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

  Future<void> createBatchFromCSV({
    required int containerId,
    required int assetTypeId,
    required List<Map<String, dynamic>> itemsToUpload,
  }) async {
    if (itemsToUpload.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 🎯 CORRECCIÓN: Llamar al método del servicio (que está en _itemService)
      await _itemService.createBatchInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
        itemsData: itemsToUpload,
      );

      if (_isDisposed) return;

      // Recarga forzada para refrescar la lista y los totales
      await loadInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
        forceReload: true,
        goToPageOne: true,
      );
    } catch (e) {
      rethrow;
    } finally {
      if (_isDisposed) return;
    }
  }

  // NUEVO MÉTODO DE GESTIÓN DE ESTADO PARA CLONACIÓN
  Future<void> cloneInventoryItem(InventoryItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Llamada al servicio de clonación (backend)
      await _itemService.cloneInventoryItem(item);

      if (_isDisposed) return;

      // 2. Forzar la recarga (loadInventoryItems)
      await loadInventoryItems(
        containerId: item.containerId,
        assetTypeId: item.assetTypeId,
        forceReload: true,
        goToPageOne: true,
      );
      notifyListeners();
    } catch (e) {
      // 🔑 CORRECCIÓN CLAVE: Restablecer el estado de carga si hay un error
      // Esto evita que la UI se quede "colgada" cargando.
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      // Este 'finally' permanece vacío porque el estado de carga ahora se
      // maneja en el 'catch' o al final de 'loadInventoryItems'.
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
