import 'inventory_item.dart'; // Tu modelo de ítem existente

class InventoryResponse {
  final List<InventoryItem> items;
  final List<dynamic> aggregationDefinitions;
  final Map<String, dynamic> aggregationResults;

  InventoryResponse({
    required this.items,
    required this.aggregationDefinitions,
    required this.aggregationResults,
  });

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    // --- 1. Mapeo de Items (Clave: 'items') ---
    // 🔑 CORRECCIÓN: Usar la clave 'items' directamente del JSON principal
    final itemsListJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsListJson
        .map((i) => InventoryItem.fromJson(i as Map<String, dynamic>))
        .toList();

    // --- 2. Mapeo de aggregationDefinitions (Clave: 'aggregationDefinitions') ---
    // 🔑 CORRECCIÓN: Usar la clave 'aggregationDefinitions' directamente
    final definitions = json['aggregationDefinitions'] as List<dynamic>? ?? [];

    // --- 3. Mapeo de aggregationResults (Clave: 'aggregationResults') ---
    // 🔑 CORRECCIÓN: Usar la clave 'aggregationResults' directamente
    final aggregations =
        json['aggregationResults'] as Map<String, dynamic>? ?? {};

    return InventoryResponse(
      items: items,
      aggregationDefinitions: definitions,
      aggregationResults: aggregations,
    );
  }
}
