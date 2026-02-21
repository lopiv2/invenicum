// lib/models/inventory_item.dart

import 'package:invenicum/models/location.dart';
import 'package:invenicum/models/price_history_point.dart';

// --- CLASE PARA LAS IMÁGENES BLINDADA ---
class InventoryItemImage {
  final int id;
  final String url;
  final String? altText;
  final int order;

  InventoryItemImage({
    required this.id,
    required this.url,
    this.altText,
    required this.order,
  });

  factory InventoryItemImage.fromJson(Map<String, dynamic> json) {
    return InventoryItemImage(
      // 🛡️ Cambiado 'as int' por protección contra nulos y casts de JS
      id: (json['id'] ?? 0).toInt(),
      url: json['url'] as String? ?? '',
      altText: json['altText'] as String?,
      order: (json['order'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'altText': altText, 'order': order};
  }

  InventoryItemImage copyWith({
    int? id,
    String? url,
    String? altText,
    int? order,
  }) {
    return InventoryItemImage(
      id: id ?? this.id,
      url: url ?? this.url,
      altText: altText ?? this.altText,
      order: order ?? this.order,
    );
  }
}

// --- CLASE PRINCIPAL BLINDADA ---
class InventoryItem {
  final int id;
  final String name;
  final String? description;
  final String? barcode;
  final int containerId;
  final int assetTypeId;
  final int? locationId;
  final int quantity;
  final int minStock;
  final Location? location;
  final List<InventoryItemImage> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? customFieldValues;
  final List<PriceHistoryPoint>? priceHistory;

  // Mercado
  final double marketValue;
  final String currency;
  final double totalMarketValue;
  final DateTime? lastPriceUpdate;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    this.barcode,
    required this.containerId,
    required this.assetTypeId,
    this.locationId,
    this.quantity = 1,
    this.minStock = 1,
    this.createdAt,
    this.updatedAt,
    this.customFieldValues,
    this.images = const [],
    this.location,
    this.marketValue = 0.0,
    this.currency = 'EUR',
    this.totalMarketValue = 0.0,
    this.lastPriceUpdate,
    this.priceHistory,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // 1. Desempaquetado seguro (soporta wrappers del backend)
    final itemData = json['itemData'] ?? json;

    // 2. Custom fields con limpieza de llaves (JS a veces envía ints como keys)
    final Map<String, dynamic>? rawCustomFields =
        itemData['customFieldValues'] is Map
        ? Map<String, dynamic>.from(itemData['customFieldValues'])
        : null;

    // 3. Imágenes con filtrado de nulos y tipos
    final List<dynamic> imageListJson =
        itemData['images'] as List<dynamic>? ?? [];
    final List<InventoryItemImage> images = imageListJson
        .where((e) => e != null && e is Map<String, dynamic>)
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();

    final List<dynamic> priceHistoryJson =
        itemData['priceHistory'] as List<dynamic>? ?? [];
    final List<PriceHistoryPoint> history = priceHistoryJson
        .where((e) => e != null && e is Map<String, dynamic>)
        .map(
          (hJson) => PriceHistoryPoint.fromJson(hJson as Map<String, dynamic>),
        )
        .toList();

    DateTime? parseDate(dynamic value) {
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return InventoryItem(
      // 🛡️ PROTECCIÓN TOTAL CONTRA TIPOS NULOS E INT/DOUBLE EN WEB
      id: (itemData['id'] ?? 0).toInt(),
      name: itemData['name'] as String? ?? 'N/A',
      description: itemData['description'] as String?,
      barcode: itemData['barcode'] as String?,
      containerId: (itemData['containerId'] ?? 0).toInt(),
      assetTypeId: (itemData['assetTypeId'] ?? 0).toInt(),
      priceHistory: history,
      // Para campos opcionales usamos chequeo de nulidad previo
      locationId: itemData['locationId'] != null
          ? (itemData['locationId'] as num).toInt()
          : null,

      quantity: (itemData['quantity'] ?? 1).toInt(),
      minStock: (itemData['minStock'] ?? 1).toInt(),

      createdAt: parseDate(itemData['createdAt']),
      updatedAt: parseDate(itemData['updatedAt']),
      customFieldValues: rawCustomFields,
      images: images,

      location: itemData['location'] != null
          ? Location.fromJson(itemData['location'] as Map<String, dynamic>)
          : null,

      marketValue: (itemData['marketValue'] ?? 0.0).toDouble(),
      currency: itemData['currency'] as String? ?? 'EUR',
      totalMarketValue: (itemData['totalMarketValue'] ?? 0.0).toDouble(),
      lastPriceUpdate: parseDate(itemData['lastPriceUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerId': containerId,
      'assetTypeId': assetTypeId,
      'locationId': locationId,
      'quantity': quantity,
      'minStock': minStock,
      'name': name,
      'description': description,
      'barcode': barcode,
      'customFieldValues': customFieldValues,
      'images': images.map((img) => img.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'location': location?.toJson(),
      'marketValue': marketValue,
      'currency': currency,
      'totalMarketValue': totalMarketValue,
      'lastPriceUpdate': lastPriceUpdate?.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    int? id,
    String? name,
    double? marketValue,
    double? totalMarketValue,
    String? currency,
    DateTime? lastPriceUpdate,
    String? description,
    String? barcode,
    int? containerId,
    int? assetTypeId,
    int? locationId,
    int? quantity,
    int? minStock,
    List<InventoryItemImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFieldValues,
    bool resetImageIds = false,
    List<PriceHistoryPoint>? priceHistory,
  }) {
    List<InventoryItemImage> finalImages;
    if (images != null) {
      finalImages = images;
    } else if (resetImageIds) {
      finalImages = this.images.map((img) => img.copyWith(id: 0)).toList();
    } else {
      finalImages = this.images;
    }

    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      marketValue: marketValue ?? this.marketValue,
      totalMarketValue: totalMarketValue ?? this.totalMarketValue,
      currency: currency ?? this.currency,
      lastPriceUpdate: lastPriceUpdate ?? this.lastPriceUpdate,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      containerId: containerId ?? this.containerId,
      assetTypeId: assetTypeId ?? this.assetTypeId,
      locationId: locationId ?? this.locationId,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      images: finalImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location,
      priceHistory: priceHistory ?? this.priceHistory,
      customFieldValues:
          customFieldValues ??
          (this.customFieldValues != null
              ? Map.from(this.customFieldValues!)
              : null),
    );
  }
}
