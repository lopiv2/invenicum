// lib/providers/inventory_item_provider.dart

import 'package:flutter/foundation.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/services/inventory_item_service.dart';

class InventoryItemProvider with ChangeNotifier {
  final InventoryItemService _itemService;

  InventoryItemProvider(this._itemService);

  // Mapa para almacenar los ítems por la clave ContainerId-AssetTypeId
  final Map<String, List<InventoryItem>> _itemsCache = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Genera una clave única para la caché.
  String _getCacheKey(int containerId, int assetTypeId) {
    return '$containerId-$assetTypeId';
  }

  /// Getter: Obtiene los ítems del inventario para un AssetType específico.
  List<InventoryItem> getInventoryItems(int containerId, int assetTypeId) {
    final key = _getCacheKey(containerId, assetTypeId);
    return _itemsCache[key] ?? [];
  }

  // --- 1. READ (Lectura) ---
  Future<void> loadInventoryItems({
    required int containerId,
    required int assetTypeId,
    bool forceReload = false,
  }) async {
    final key = _getCacheKey(containerId, assetTypeId);

    if (_itemsCache.containsKey(key) && !forceReload) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Nota: Cambié _itemService.getInventoryItems por el nombre que implementaste antes (fetchInventoryItems)
      final loadedItems = await _itemService.fetchInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
      );

      _itemsCache[key] = loadedItems;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar ítems para $key: $e');
      }
      rethrow; // Re-lanzar el error para manejo en UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. CREATE (Creación) ---
  Future<void> createInventoryItem(InventoryItem newItem) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Llama al servicio para guardar y obtener el ítem con el ID de la API
      final createdItem = await _itemService.createInventoryItem(newItem);

      final key = _getCacheKey(
        createdItem.containerId,
        createdItem.assetTypeId,
      );

      // Aseguramos que la lista exista y añadimos el nuevo ítem
      _itemsCache.putIfAbsent(key, () => []);
      _itemsCache[key]!.add(createdItem);
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

  // --- 3. UPDATE (Actualización) ---
  Future<void> updateInventoryItem(
    InventoryItem updatedItem,
    int assetTypeId, // <--- NUEVO PARÁMETRO REQUERIDO
  ) async {
    _isLoading = true;
    notifyListeners();

    // Usamos el assetTypeId pasado en el argumento
    final key = _getCacheKey(updatedItem.containerId, assetTypeId);
    final itemsList = _itemsCache[key];

    try {
      // 1. Llama al servicio para actualizar la API
      // (Asegúrate de que tu service.updateInventoryItem use el updatedItem completo)
      final resultItem = await _itemService.updateInventoryItem(updatedItem);

      // 2. Actualiza el ítem en la caché si la lista existe
      if (itemsList != null) {
        final index = itemsList.indexWhere((item) => item.id == resultItem.id);
        if (index != -1) {
          itemsList[index] = resultItem;
        } else {
          // En caso de que el ítem no se encontrara (raro en edición),
          // podrías considerarlo un nuevo ítem y añadirlo, pero es menos común.
        }
      }
      // Nota: Si itemsList es nulo, significa que esa caché aún no se ha cargado/inicializado.
    } catch (e) {
      // Usamos `kDebugMode` si está disponible, sino `dart:developer` o solo `print`.
      // if (kDebugMode) {
      //   print("Error updating inventory item: $e");
      // }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 4. DELETE (Borrado) ---
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
      // 1. Llama al servicio para borrar en la API
      await _itemService.deleteInventoryItem(itemId);

      // 2. Elimina el ítem de la caché si la lista existe
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
