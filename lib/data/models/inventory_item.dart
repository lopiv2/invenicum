// lib/models/inventory_item.dart

import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/data/models/price_history_point.dart';

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

class InventoryItemModel3D {
  final int id;
  final String sourceType;
  final String relativePath;
  final String url;
  final String? originalName;
  final int order;

  const InventoryItemModel3D({
    required this.id,
    required this.sourceType,
    required this.relativePath,
    required this.url,
    this.originalName,
    required this.order,
  });

  factory InventoryItemModel3D.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel3D(
      id: (json['id'] ?? 0).toInt(),
      sourceType: json['sourceType'] as String? ?? 'upload',
      relativePath: json['relativePath'] as String? ?? '',
      url: json['url'] as String? ?? '',
      originalName: json['originalName'] as String?,
      order: (json['order'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceType': sourceType,
      'relativePath': relativePath,
      'url': url,
      'originalName': originalName,
      'order': order,
    };
  }

  InventoryItemModel3D copyWith({
    int? id,
    String? sourceType,
    String? relativePath,
    String? url,
    String? originalName,
    int? order,
  }) {
    return InventoryItemModel3D(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      relativePath: relativePath ?? this.relativePath,
      url: url ?? this.url,
      originalName: originalName ?? this.originalName,
      order: order ?? this.order,
    );
  }
}

class InventoryItem {
  final int id;
  final String name;
  final String? description;
  final String? barcode;
  final String? serialNumber;
  final int containerId;
  final int assetTypeId;
  final int? locationId;
  final int quantity;
  final int minStock;
  final Location? location;
  final List<InventoryItemImage> images;
  final List<InventoryItemModel3D> model3dFiles;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? customFieldValues;
  final List<PriceHistoryPoint>? priceHistory;
  ItemCondition condition = ItemCondition.mint;

  // Market
  final double marketValue;
  final String currency;
  final double totalMarketValue;
  final DateTime? lastPriceUpdate;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    this.barcode,
    this.serialNumber,
    required this.containerId,
    required this.assetTypeId,
    this.locationId,
    this.quantity = 1,
    this.minStock = 1,
    this.createdAt,
    this.updatedAt,
    this.customFieldValues,
    this.images = const [],
    this.model3dFiles = const [],
    this.location,
    this.marketValue = 0.0,
    this.currency = AppCurrencies.defaultCurrency,
    this.totalMarketValue = 0.0,
    this.lastPriceUpdate,
    this.priceHistory,
    this.condition = ItemCondition.mint,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // 1. Safe unpacking (supports backend wrappers)
    final itemData = json['itemData'] ?? json;

    // 2. Custom fields with key cleanup (JS sometimes sends ints as keys)
    final Map<String, dynamic>? rawCustomFields =
        itemData['customFieldValues'] is Map
        ? Map<String, dynamic>.from(itemData['customFieldValues'])
        : null;

    // 3. Images with null and type filtering
    final List<dynamic> imageListJson =
        itemData['images'] as List<dynamic>? ?? [];
    final List<InventoryItemImage> images = imageListJson
        .where((e) => e != null && e is Map<String, dynamic>)
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();
    final modelListJson = itemData['model3dFiles'] as List<dynamic>? ?? [];
    final model3dFiles = modelListJson
        .whereType<Map<String, dynamic>>()
        .map(InventoryItemModel3D.fromJson)
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
      id: (itemData['id'] ?? 0).toInt(),
      name: itemData['name'] as String? ?? 'N/A',
      description: itemData['description'] as String?,
      condition: ItemConditionExtension.fromString(
        itemData['condition'] as String?,
      ),
      barcode: itemData['barcode'] as String?,
      serialNumber: itemData['serialNumber'] as String?,
      containerId: (itemData['containerId'] ?? 0).toInt(),
      assetTypeId: (itemData['assetTypeId'] ?? 0).toInt(),
      priceHistory: history,
      // For optional fields we use prior nullability check
      locationId: itemData['locationId'] != null
          ? (itemData['locationId'] as num).toInt()
          : null,

      quantity: (itemData['quantity'] ?? 1).toInt(),
      minStock: (itemData['minStock'] ?? 1).toInt(),

      createdAt: parseDate(itemData['createdAt']),
      updatedAt: parseDate(itemData['updatedAt']),
      customFieldValues: rawCustomFields,
      images: images,
      model3dFiles: model3dFiles,

      location: itemData['location'] != null
          ? Location.fromJson(itemData['location'] as Map<String, dynamic>)
          : null,

      marketValue: (itemData['marketValue'] ?? 0.0).toDouble(),
      currency:
          itemData['currency'] as String? ?? AppCurrencies.defaultCurrency,
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
      'condition': (condition as Enum).name,
      'barcode': (barcode?.trim().isEmpty ?? true) ? null : barcode,
      'serialNumber': (serialNumber?.trim().isEmpty ?? true)
          ? null
          : serialNumber,

      'customFieldValues': customFieldValues != null
          ? Map<String, dynamic>.from(
              customFieldValues!.map((k, v) => MapEntry(k.toString(), v)),
            )
          : null,

      'images': images.map((img) => img.toJson()).toList(),
      'model3dFiles': model3dFiles.map((m) => m.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),

      'marketValue': marketValue,
      'currency': currency,
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
    bool wishlisted = false,
    ItemCondition? condition,
    String? barcode,
    String? serialNumber,
    int? containerId,
    int? assetTypeId,
    int? locationId,
    int? quantity,
    int? minStock,
    List<InventoryItemImage>? images,
    List<InventoryItemModel3D>? model3dFiles,
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
      condition: condition ?? this.condition,
      barcode: barcode ?? this.barcode,
      serialNumber: serialNumber ?? this.serialNumber,
      containerId: containerId ?? this.containerId,
      assetTypeId: assetTypeId ?? this.assetTypeId,
      locationId: locationId ?? this.locationId,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      images: finalImages,
      model3dFiles: model3dFiles ?? this.model3dFiles,
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
