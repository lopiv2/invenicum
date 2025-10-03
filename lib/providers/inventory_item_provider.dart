import 'package:flutter/foundation.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/services/inventory_item_service.dart';

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
  static const int _itemsPerPage = 10;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  final Map<String, List<InventoryItem>> _itemsCache = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  InventoryItemProvider(this._itemService);

  String _getCacheKey(int containerId, int assetTypeId) {
    return '$containerId-$assetTypeId';
  }

  // --- FUNCIÓN AUXILIAR DE FILTRADO (Deduplicación) ---

  /// Aplica el filtro global y los filtros por columna a la lista de ítems.
  Iterable<InventoryItem> _applyFilters(List<InventoryItem> items) {
    Iterable<InventoryItem> processedItems = items;

    // 1. FILTRO GLOBAL (Busca en todas las propiedades)
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

    // 2. FILTRADO POR COLUMNA (Aplicado después del global)
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

  // --- GETTER PRINCIPAL (MODIFICADO) ---

  /// Obtiene los ítems del inventario, aplicando filtros, ordenamiento y PAGINACIÓN.
  List<InventoryItem> getInventoryItems(int containerId, int assetTypeId) {
    final key = _getCacheKey(containerId, assetTypeId);
    final items = _itemsCache[key] ?? [];

    // Aplicar todos los filtros
    Iterable<InventoryItem> processedItems = _applyFilters(items);

    // 3. ORDENAMIENTO
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

    // 4. PAGINACIÓN
    final totalItems = sortedList.length;
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

  /// NUEVO GETTER: Devuelve el total de ítems filtrados (antes de la paginación)
  int getTotalFilteredItems(int containerId, int assetTypeId) {
    final key = _getCacheKey(containerId, assetTypeId);
    final items = _itemsCache[key] ?? [];

    // Reutilizamos la función de filtrado
    final processedItems = _applyFilters(items);

    return processedItems.length;
  }

  // --- LÓGICA DE FILTROS Y ORDENAMIENTO ---

  void setFilter(String key, String? value) {
    if (value == null || value.isEmpty) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }
    notifyListeners();
  }

  void setGlobalSearchTerm(String? term) {
    if (term == null || term.trim().isEmpty) {
      _globalSearchTerm = null;
    } else {
      _globalSearchTerm = term.trim().toLowerCase();
    }
    notifyListeners();
  }

  void sortInventoryItems({required String dataKey, required bool ascending}) {
    sortKey = dataKey;
    sortAscending = ascending;
    notifyListeners();
  }

  // --- LÓGICA DE PAGINACIÓN ---

  void goToPage(int page) {
    if (_currentPage != page && page >= 1) {
      _currentPage = page;
      notifyListeners();
    }
  }

  // --- LÓGICA DE CRUD (Sin cambios mayores) ---

  Future<void> loadInventoryItems({
    required int containerId,
    required int assetTypeId,
    bool forceReload = false,
  }) async {
    final key = _getCacheKey(containerId, assetTypeId);

    if (_itemsCache.containsKey(key) && !forceReload) {
      notifyListeners();
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
      notifyListeners();
    }
  }

  Future<void> createInventoryItem(
    InventoryItem newItem, {
    // Argumento opcional para las URLs de las imágenes
    List<String> imageUrls = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Asumimos que tu InventoryItemService (en el backend)
      // ahora acepta las URLs para crear los registros InventoryItemImage.
      final createdItem = await _itemService.createInventoryItem(
        newItem,
        imageUrls: imageUrls, // <--- PASAMOS LAS URLS AL SERVICIO
      );

      final key = _getCacheKey(
        createdItem.containerId,
        createdItem.assetTypeId,
      );

      _itemsCache.putIfAbsent(key, () => []);
      // Si el servicio devuelve el ítem con las imágenes ya cargadas, mejor.
      // Si no, la próxima carga de la lista lo actualizará.
      _itemsCache[key]!.add(createdItem);

      // **IMPORTANTE**: Al crear un nuevo activo, normalmente queremos que el usuario
      // regrese a la página 1 de la lista para ver el nuevo registro inmediatamente.
      goToPage(1);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating inventory item: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInventoryItem(
    InventoryItem updatedItem,
    int assetTypeId,
  ) async {
    _isLoading = true;
    notifyListeners();

    final key = _getCacheKey(updatedItem.containerId, assetTypeId);
    final itemsList = _itemsCache[key];

    try {
      final resultItem = await _itemService.updateInventoryItem(updatedItem);

      if (itemsList != null) {
        final index = itemsList.indexWhere((item) => item.id == resultItem.id);
        if (index != -1) {
          itemsList[index] = resultItem;
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      if (kDebugMode) {
        print("Error deleting inventory item: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
