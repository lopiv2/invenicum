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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'altText': altText,
      'order': order,
      // Nota: No incluimos 'inventoryItemId' ni 'assetTypeId' aquí,
      // ya que típicamente se gestionan en el nivel superior (InventoryItem o AssetType)
      // al hacer una inserción o actualización. Si el backend lo espera, añádelo.
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
      // Al copiar un activo, la URL de la imagen existente (que apunta a un archivo ya subido)
      // es lo que necesitamos para que el backend la clone.
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
    this.createdAt,
    this.updatedAt,
    // Aseguramos que el constructor siempre tenga un valor por defecto
    this.customFieldValues,
    this.images = const [],
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final itemData = json['itemData'] ?? json;

    // 1. Obtener el valor JSON (puede ser null)
    final dynamic rawCustomFieldValues = itemData['customFieldValues'];

    // 2. 🎯 CORRECCIÓN CLAVE: Conversión segura a Map<String, dynamic>?
    // Si no es null y es un Map, lo convertimos. Si es null, o si la conversión falla, es null.
    final Map<String, dynamic>? customFieldValues =
        rawCustomFieldValues != null && rawCustomFieldValues is Map
        ? Map<String, dynamic>.from(rawCustomFieldValues)
        : null;

    // 3. Procesar las imágenes (tu código está bien aquí, pero lo incluimos por contexto)
    final List<dynamic> imageListJson =
        itemData['images'] as List<dynamic>? ?? [];
    final List<InventoryItemImage> images = imageListJson
        .where((e) => e != null) // 👈 Añadir este filtro
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();

    // Función auxiliar (queda igual)
    DateTime? parseDate(dynamic value) {
      // ... (código igual)
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

      // Pasamos el mapa ya verificado (que ahora es nullable)
      customFieldValues: customFieldValues, // 🎯 PASAR LA VARIABLE CORRECTA
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
    List<InventoryItemImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFieldValues,
    // 🔑 NUEVO: Flag para forzar el reseteo de IDs de imagen (para la operación de copia)
    bool resetImageIds = false,
  }) {
    // 1. Lógica de Imágenes
    List<InventoryItemImage> finalImages;

    if (images != null) {
      // Si se proporciona una lista, la usamos
      finalImages = images;
    } else if (resetImageIds) {
      // Si queremos resetear IDs (operación de copia):
      // Clonamos la lista existente, mapeando cada imagen y forzando id: 0
      finalImages = this.images
          .map((img) => img.copyWith(id: 0)) // 🔑 Reseteamos el ID
          .toList();
    } else {
      // Uso normal (actualización): usamos la lista existente
      finalImages = this.images;
    }

    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      containerId: containerId ?? this.containerId,
      assetTypeId: assetTypeId ?? this.assetTypeId,
      // Usamos la lista de imágenes procesada
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
    return 'Item(id: $id, name: $name, images: ${images.length})';
  }
}
