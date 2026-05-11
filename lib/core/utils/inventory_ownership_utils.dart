import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/inventory_item.dart';

class AssetTypeOwnershipMeta {
  final bool isCollection;
  final String? possessionFieldId;

  const AssetTypeOwnershipMeta({
    required this.isCollection,
    required this.possessionFieldId,
  });
}

class InventoryOwnershipUtils {
  /// Construye el mapa assetTypeId -> metadata de posesión
  static Map<int, AssetTypeOwnershipMeta> buildOwnershipMap(
    List<ContainerNode> containers,
  ) {
    final map = <int, AssetTypeOwnershipMeta>{};

    for (final container in containers) {
      for (final assetType in container.assetTypes) {
        map[assetType.id] = AssetTypeOwnershipMeta(
          isCollection: container.isCollection,
          possessionFieldId: assetType.possessionFieldId,
        );
      }
    }

    return map;
  }

  /// Determine if an item is considered "owned"
  static bool isOwned(
    InventoryItem item,
    Map<int, AssetTypeOwnershipMeta> ownershipMap,
  ) {
    final meta = ownershipMap[item.assetTypeId];

    // Unknown AssetType
    if (meta == null) return false;

    // Inventory => implicit ownership
    if (!meta.isCollection) return true;

    // Collection without ownership field
    if (meta.possessionFieldId == null) return false;

    final raw = item.customFieldValues?[meta.possessionFieldId];

    if (raw == null) return false;

    if (raw is bool) return raw;
    if (raw is int) return raw == 1;
    if (raw is String) {
      return raw == 'true' || raw == '1';
    }

    return false;
  }

  /// Returns only owned items
  static List<InventoryItem> filterOwnedItems(
    List<InventoryItem> items,
    List<ContainerNode> containers,
  ) {
    final ownershipMap = buildOwnershipMap(containers);

    return items.where((item) {
      return isOwned(item, ownershipMap);
    }).toList();
  }
}