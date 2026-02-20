import 'package:invenicum/models/inventory_item.dart';

class InventoryResponse {
  final List<InventoryItem> items;
  final List<dynamic> aggregationDefinitions;
  final Map<String, dynamic> aggregationResults;
  final double totalMarketValue; // 🔑 Nuevo: Total de toda la lista

  InventoryResponse({
    required this.items,
    required this.aggregationDefinitions,
    required this.aggregationResults,
    required this.totalMarketValue,
  });

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
  // 1. Mapeo de ítems (esto está bien)
  final itemsListJson = json['items'] as List<dynamic>? ?? [];
  final items = itemsListJson
      .map((i) => InventoryItem.fromJson(i as Map<String, dynamic>))
      .toList();

  // 2. CORRECCIÓN: El JSON real no tiene un objeto 'totals', 
  // los campos están directamente en la raíz del objeto recibido.
  
  return InventoryResponse(
    items: items,
    // Buscamos directamente en 'json' en lugar de en 'totals'
    aggregationDefinitions: json['aggregationDefinitions'] as List<dynamic>? ?? [],
    aggregationResults: json['aggregationResults'] as Map<String, dynamic>? ?? {},
    
    // 🛡️ OJO: Tu JSON dice 'marketValueTotal' pero tu código antes buscaba 'marketValueTotal' dentro de 'totals'.
    // Usamos .toDouble() para asegurar que no haya problemas de cast.
    totalMarketValue: (json['marketValueTotal'] ?? 0).toDouble(),
  );
}
}