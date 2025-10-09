import 'package:flutter/material.dart'; // Solo si usas widgets de Flutter

// --- NUEVA CLASE PARA LAS IMÁGENES ---
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
      id: json['id'] as int,
      url: json['url'] as String,
      altText: json['altText'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }
}

// --- CLASE PRINCIPAL (MODIFICADA) ---
class InventoryItem {
  final int id;
  final String name;
  final String? description;
  final int containerId;
  final int assetTypeId;

  final List<InventoryItemImage> images;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic> customFieldValues;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.containerId,
    required this.assetTypeId,
    this.createdAt,
    this.updatedAt,
    // Aseguramos que el constructor siempre tenga un valor por defecto
    required this.customFieldValues,
    this.images = const [],
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final itemData = json['itemData'] ?? json;

    // 🚀 SOLUCIÓN AL ERROR: Conversión segura de customFieldValues
    // 1. Intentamos obtener el valor y tratarlo como Map<String, dynamic> (con el ?)
    // 2. Si es null, o si la conversión implícita falla (porque es null), usamos {}
    final Map<String, dynamic> fieldValues =
        (itemData['customFieldValues'] as Map<String, dynamic>?) ?? {};

    // 3. Procesar las imágenes
    final List<dynamic> imageListJson =
        itemData['images'] as List<dynamic>? ?? [];
    final List<InventoryItemImage> images = imageListJson
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();

    // Función auxiliar para convertir String a DateTime
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
      id: itemData['id'] as int,
      name: itemData['name'] as String? ?? 'N/A',
      description: itemData['description'] as String?,
      containerId: itemData['containerId'] as int,
      assetTypeId: itemData['assetTypeId'] as int,
      createdAt: parseDate(itemData['createdAt']),
      updatedAt: parseDate(itemData['updatedAt']),

      // Pasamos el mapa ya verificado
      customFieldValues: fieldValues,
      images: images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerId': containerId,
      'assetTypeId': assetTypeId,
      'name': name,
      'description': description,
      'customFieldValues': customFieldValues,
    };
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name, images: ${images.length})';
  }
}
