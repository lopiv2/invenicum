import 'package:invenicum/data/models/inventory_item.dart';

class InventoryResponse {
  final List<InventoryItem> items;
  final List<dynamic> aggregationDefinitions;
  final Map<String, dynamic> aggregationResults;
  final double totalMarketValue; 
  final int totalItems; // 🔑 Añadido para consistencia con tu Provider

  InventoryResponse({
    required this.items,
    required this.aggregationDefinitions,
    required this.aggregationResults,
    required this.totalMarketValue,
    required this.totalItems,
  });

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    // 1. Mapeo de ítems
    final itemsListJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsListJson
        .map((i) => InventoryItem.fromJson(i as Map<String, dynamic>))
        .toList();

    // 2. Extraemos los metadatos directamente de la raíz del JSON
    // Usamos .from() para asegurar que sean colecciones mutables y evitar errores de "ReadOnly"
    final aggDefs = List<dynamic>.from(json['aggregationDefinitions'] ?? []);
    final aggResults = Map<String, dynamic>.from(json['aggregationResults'] ?? {});
    
    // 3. Totales y conteos
    // Usamos num y toDouble()/toInt() para evitar errores si el server manda int en vez de double
    final marketValue = (json['marketValueTotal'] ?? 0);
    final count = (json['totalItems'] ?? items.length);

    return InventoryResponse(
      items: items,
      aggregationDefinitions: aggDefs,
      aggregationResults: aggResults,
      totalMarketValue: (marketValue is num) ? marketValue.toDouble() : 0.0,
      totalItems: (count is num) ? count.toInt() : items.length,
    );
  }

  // 🔄 Método auxiliar para el Provider (para crear copias rápidas)
  InventoryResponse copyWith({
    List<InventoryItem>? items,
    List<dynamic>? aggregationDefinitions,
    Map<String, dynamic>? aggregationResults,
    double? totalMarketValue,
    int? totalItems,
  }) {
    return InventoryResponse(
      items: items ?? this.items,
      aggregationDefinitions: aggregationDefinitions ?? this.aggregationDefinitions,
      aggregationResults: aggregationResults ?? this.aggregationResults,
      totalMarketValue: totalMarketValue ?? this.totalMarketValue,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}