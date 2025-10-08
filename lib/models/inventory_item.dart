// lib/models/inventory_item.dart

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

  // NUEVO CAMPO: Lista de imágenes asociadas al activo
  final List<InventoryItemImage> images;

  // Campos de gestión
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Mapa dinámico para almacenar los valores de los campos personalizados.
  final Map<String, dynamic> customFieldValues;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.containerId,
    required this.assetTypeId,
    this.createdAt,
    this.updatedAt,
    required this.customFieldValues,
    // Inicialización del nuevo campo
    this.images = const [],
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // 1. Extraer campos fijos (asumiendo que los datos base están en el nivel superior o en 'itemData')
    final itemData = json['itemData'] ?? json;

    // 2. Extraer los valores de los campos personalizados.
    final Map<String, dynamic> fieldValues = Map<String, dynamic>.from(
      itemData['customFieldValues'] ?? {},
    );

    // 3. Procesar las imágenes (NUEVO)
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

      customFieldValues: fieldValues,
      images: images, // Añadido el nuevo campo de imágenes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Campos requeridos para la creación/actualización
      'id': id,
      'containerId': containerId,
      'assetTypeId': assetTypeId,
      'name': name,
      'description': description,
      // Nota: customFieldValues es Map, que Dio/jsonEncode maneja bien.
      'customFieldValues': customFieldValues,

      // No incluimos 'images' en el body si las estamos enviando como FormData (CREATE).
      // Pero sí es útil para el UPDATE donde se envían las URLs existentes.
      // Para el UPDATE, el servicio extrae las URLs y las mapea a 'imageUrls'.
    };
  }

  // Opcional: Para debugging
  @override
  String toString() {
    return 'Item(id: $id, name: $name, images: ${images.length})';
  }
}
