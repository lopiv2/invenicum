import 'package:flutter/foundation.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/services/inventory_item_service.dart';

// Definimos el tipo de datos esperado para los archivos que vienen del frontend
typedef FileData = List<Map<String, dynamic>>;

class InventoryItemProvider with ChangeNotifier {
  final InventoryItemService _itemService;

  // Estado de Filtrado y Ordenamiento
  Map<String, String> _filters = {};
  Map<String, String> get filters => _filters;
  String? _globalSearchTerm;
  String? get globalSearchTerm => _globalSearchTerm;

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

  // Estado Interno (Cache/Loading)
  final Map<String, List<InventoryItem>> _itemsCache = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int _totalFilteredItems = 0;

  // 🚨 CLAVE 1: Getter 'totalItems' que usa el total filtrado
  int get totalItems => _totalFilteredItems;

  InventoryItemProvider(this._itemService);

  String _getCacheKey(int containerId, int assetTypeId) {
    return '$containerId-$assetTypeId';
  }

  int getItemCountForAssetType(int containerId, int assetTypeId) {
    final key = _getCacheKey(containerId, assetTypeId);
    // Retorna el tamaño de la lista, o 0 si no existe en caché.
    return _itemsCache[key]?.length ?? 0;
  }

  // ----------------------------------------------------------------------
  // 🚨 CLAVE 2: GETTER PÚBLICO para la tabla de datos
  // Llama a la función de procesamiento con los IDs de la vista actual.
  // ----------------------------------------------------------------------
  List<InventoryItem> get inventoryItems {
    return _processAndPaginateItems(_currentContainerId, _currentAssetTypeId);
  }

  // ----------------------------------------------------------------------
  // FUNCIÓN PRINCIPAL DE PROCESAMIENTO (Filtra, Ordena y Pagina)
  // ----------------------------------------------------------------------

  /// Obtiene los ítems del inventario, aplicando filtros, ordenamiento y PAGINACIÓN.
  List<InventoryItem> _processAndPaginateItems(
    int containerId,
    int assetTypeId,
  ) {
    final key = _getCacheKey(containerId, assetTypeId);
    final items = _itemsCache[key] ?? [];

    // 1. Aplicar Filtros
    Iterable<InventoryItem> processedItems = _applyFilters(items);

    // 2. Ordenamiento
    final sortedList = processedItems.toList();

    sortedList.sort((a, b) {
      Comparable aValue;
      Comparable bValue;

      if (sortKey == 'name') {
        aValue = a.name;
        bValue = b.name;
      } else if (sortKey == 'description') {
        aValue = a.description ?? '';
        bValue = b.description ?? '';
      } else {
        aValue = a.customFieldValues[sortKey]?.toString() ?? '';
        bValue = b.customFieldValues[sortKey]?.toString() ?? '';
      }

      final comparison = aValue.compareTo(bValue);

      return sortAscending ? comparison : -comparison;
    });

    // 🚨 CLAVE 3: Actualizar el total de ítems filtrados ANTES de paginar
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

  // --- FUNCIÓN AUXILIAR DE FILTRADO (Deduplicación) ---

  /// Aplica el filtro global y los filtros por columna a la lista de ítems.
  Iterable<InventoryItem> _applyFilters(List<InventoryItem> items) {
    Iterable<InventoryItem> processedItems = items;

    // 1. FILTRO GLOBAL
    if (_globalSearchTerm != null) {
      final searchTerm = _globalSearchTerm!;
      processedItems = processedItems.where((item) {
        // Comprobar campos fijos
        if (item.name.toLowerCase().contains(searchTerm)) return true;
        if ((item.description ?? '').toLowerCase().contains(searchTerm))
          return true;

        // Comprobar campos personalizados
        return item.customFieldValues.values.any((value) {
          return (value?.toString().toLowerCase() ?? '').contains(searchTerm);
        });
      });
    }

    // 2. FILTRADO POR COLUMNA
    if (_filters.isNotEmpty) {
      processedItems = processedItems.where((item) {
        // El ítem debe cumplir con TODOS los criterios de filtro por columna
        return _filters.entries.every((filterEntry) {
          final filterKey = filterEntry.key;
          final filterValue = filterEntry.value.toLowerCase();
          String itemValue;

          // a) Campos fijos
          if (filterKey == 'name') {
            itemValue = item.name.toLowerCase();
          } else if (filterKey == 'description') {
            itemValue = (item.description ?? '').toLowerCase();
          }
          // b) Campos personalizados
          else {
            final rawValue = item.customFieldValues[filterKey];
            itemValue = (rawValue?.toString() ?? '').toLowerCase();
          }

          return itemValue.contains(filterValue);
        });
      });
    }

    return processedItems;
  }

  // ----------------------------------------------------------------------
  // FUNCIÓN AUXILIAR PARA NOTIFICAR Y RECALCULAR TOTALES
  // ----------------------------------------------------------------------
  void _recalculateTotalsAndNotify() {
    // Forzar el cálculo para actualizar _totalFilteredItems
    _processAndPaginateItems(_currentContainerId, _currentAssetTypeId);
    notifyListeners();
  }

  // --- LÓGICA DE FILTROS Y ORDENAMIENTO (Ahora llama a la nueva función) ---

  void setFilter(String key, String? value) {
    if (value == null || value.isEmpty) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }
    // Llama al nuevo notificador
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

  // --- LÓGICA DE PAGINACIÓN (Ahora llama a la nueva función) ---

  void goToPage(int page) {
    if (_currentPage != page && page >= 1) {
      _currentPage = page;
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

  // --- LÓGICA DE CRUD (Actualizada) ---

  Future<void> loadInventoryItems({
    required int containerId,
    required int assetTypeId,
    bool forceReload = false,
  }) async {
    _currentContainerId = containerId;
    _currentAssetTypeId = assetTypeId;

    final key = _getCacheKey(containerId, assetTypeId);

    if (_itemsCache.containsKey(key) && !forceReload) {
      _recalculateTotalsAndNotify();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final loadedItems = await _itemService.fetchInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
      );

      _itemsCache[key] = loadedItems;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar ítems para $key: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify();
    }
  }

  Future<void> createInventoryItem(
    InventoryItem newItem, {
    FileData filesData = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final createdItem = await _itemService.createInventoryItem(
        newItem,
        filesData: filesData,
      );

      final key = _getCacheKey(
        createdItem.containerId,
        createdItem.assetTypeId,
      );

      _itemsCache.putIfAbsent(key, () => []);
      _itemsCache[key]!.add(createdItem);

      goToPage(1);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify();
    }
  }

  // 🚀 NUEVA LÓGICA: Método unificado para actualizar datos y gestionar imágenes.
  Future<void> updateAssetWithFiles(
    InventoryItem updatedItem, {
    FileData filesToUpload = const [],
    List<int> imageIdsToDelete = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    final key = _getCacheKey(updatedItem.containerId, updatedItem.assetTypeId);
    final itemsList = _itemsCache[key];

    try {
      // 1. Llamar al servicio que gestionará el PATCH de los datos, 
      // la subida de nuevos archivos y la eliminación de IDs de imágenes.
      final resultItem = await _itemService.updateInventoryItem(
        updatedItem,
        filesToUpload: filesToUpload,
        imageIdsToDelete: imageIdsToDelete,
      );

      // 2. Actualizar el caché con el ítem recién devuelto por el servicio
      if (itemsList != null) {
        final index = itemsList.indexWhere((item) => item.id == resultItem.id);
        if (index != -1) {
          // Reemplazar el ítem con el resultado (que incluye las nuevas imágenes y sin las eliminadas)
          itemsList[index] = resultItem; 
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify();
    }
  }

  Future<void> deleteInventoryItem(
    int itemId,
    int containerId,
    int assetTypeId,
  ) async {
    _isLoading = true;
    notifyListeners();

    final key = _getCacheKey(containerId, assetTypeId);
    final itemsList = _itemsCache[key];

    try {
      await _itemService.deleteInventoryItem(itemId);

      if (itemsList != null) {
        itemsList.removeWhere((item) => item.id == itemId);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      _recalculateTotalsAndNotify();
    }
  }
}