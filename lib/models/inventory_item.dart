// lib/models/inventory_item.dart (Actualizado)

// --- NUEVA CLASE PARA LAS IMÁGENES (Sin cambios) ---
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'altText': altText,
      'order': order,
    };
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

// --- CLASE PRINCIPAL (MODIFICADA) ---
class InventoryItem {
  final int id;
  final String name;
  final String? description;
  final int containerId;
  final int assetTypeId;
  final int? locationId; // 🔑 AÑADIDO: ID de la ubicación (nullable)

  final List<InventoryItemImage> images;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic>? customFieldValues;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.containerId,
    required this.assetTypeId,
    this.locationId, // 🔑 AÑADIDO AL CONSTRUCTOR (ahora nullable)
    this.createdAt,
    this.updatedAt,
    this.customFieldValues,
    this.images = const [],
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final itemData = json['itemData'] ?? json;

    // 1. Obtener el valor JSON de los campos custom
    final dynamic rawCustomFieldValues = itemData['customFieldValues'];

    // 2. Conversión segura a Map<String, dynamic>?
    final Map<String, dynamic>? customFieldValues =
        rawCustomFieldValues != null && rawCustomFieldValues is Map
            ? Map<String, dynamic>.from(rawCustomFieldValues)
            : null;

    // 3. Procesar las imágenes
    final List<dynamic> imageListJson =
        itemData['images'] as List<dynamic>? ?? [];
    final List<InventoryItemImage> images = imageListJson
        .where((e) => e != null)
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();

    // Función auxiliar (queda igual)
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
      locationId: itemData['locationId'] as int?, // 🔑 AÑADIDO: Ahora permite null
      createdAt: parseDate(itemData['createdAt']),
      updatedAt: parseDate(itemData['updatedAt']),
      customFieldValues: customFieldValues,
      images: images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerId': containerId,
      'assetTypeId': assetTypeId,
      'locationId': locationId, // 🔑 AÑADIDO: Incluido en el JSON de salida
      'name': name,
      'description': description,
      'customFieldValues': customFieldValues,
      'images': images.map((img) => img.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    int? id,
    String? name,
    String? description,
    int? containerId,
    int? assetTypeId,
    int? locationId, // 🔑 AÑADIDO: Incluido en copyWith
    List<InventoryItemImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFieldValues,
    // Flag para forzar el reseteo de IDs de imagen (para la operación de copia)
    bool resetImageIds = false,
  }) {
    // 1. Lógica de Imágenes (sin cambios)
    List<InventoryItemImage> finalImages;

    if (images != null) {
      finalImages = images;
    } else if (resetImageIds) {
      finalImages = this.images
          .map((img) => img.copyWith(id: 0))
          .toList();
    } else {
      finalImages = this.images;
    }

    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      containerId: containerId ?? this.containerId,
      assetTypeId: assetTypeId ?? this.assetTypeId,
      locationId: locationId ?? this.locationId, // 🔑 AÑADIDO: Usamos el nuevo o el existente
      images: finalImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFieldValues:
          customFieldValues ??
          (this.customFieldValues != null
              ? Map.from(this.customFieldValues!)
              : null),
    );
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name, locationId: $locationId, images: ${images.length})';
  }
}