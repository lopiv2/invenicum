// lib/providers/inventory_item_provider.dart

import 'package:flutter/foundation.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/services/inventory_item_service.dart';

class InventoryItemProvider with ChangeNotifier {
  final InventoryItemService _itemService;

  InventoryItemProvider(this._itemService);

  // Mapa para almacenar los ítems por la clave ContainerId-AssetTypeId
  // Esto evita recargar datos innecesariamente al cambiar de pantalla.
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

  // --- Lógica de Carga de Ítems ---
  Future<void> loadInventoryItems({
    required int containerId,
    required int assetTypeId,
    bool forceReload = false,
  }) async {
    final key = _getCacheKey(containerId, assetTypeId);
    
    // Si ya están cargados y no se fuerza la recarga, salimos.
    if (_itemsCache.containsKey(key) && !forceReload) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final loadedItems = await _itemService.getInventoryItems(
        containerId: containerId,
        assetTypeId: assetTypeId,
      );
      
      // Actualizar la caché y notificar
      _itemsCache[key] = loadedItems;
    } catch (e) {
      print('Error al cargar ítems para $key: $e');
      // Podrías limpiar el caché aquí si la carga falla
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // --- Futuras funciones: createItem, updateItem, deleteItem irían aquí ---
}