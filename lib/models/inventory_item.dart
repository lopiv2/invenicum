// lib/models/inventory_item.dart

class InventoryItem {
  final int id;
  final String name;
  final String? description; // Nuevo campo
  final int containerId;
  final int assetTypeId;

  // Campos de gestión
  final DateTime? createdAt; // Nuevo campo
  final DateTime? updatedAt; // Nuevo campo

  // Mapa dinámico para almacenar los valores de los campos personalizados.
  final Map<String, dynamic> customFieldValues;

  InventoryItem({
    required this.id,
    required this.name,
    this.description, // Ahora opcional en el constructor
    required this.containerId,
    required this.assetTypeId,
    this.createdAt, // Ahora opcional en el constructor
    this.updatedAt, // Ahora opcional en el constructor
    required this.customFieldValues,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // 1. Extraer campos fijos (asumiendo que los datos base están en el nivel superior o en 'itemData')
    final itemData = json['itemData'] ?? json;

    // 2. Extraer los valores de los campos personalizados, si están anidados.
    final Map<String, dynamic> fieldValues = Map<String, dynamic>.from(
      itemData['customFieldValues'] ?? {},
    );

    // Función auxiliar para convertir String a DateTime, manejando nulos y errores
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
      description: itemData['description'] as String?, // Campo nuevo
      containerId: itemData['containerId'] as int,
      assetTypeId: itemData['assetTypeId'] as int,
      createdAt: parseDate(itemData['createdAt']), // Conversión de fecha
      updatedAt: parseDate(itemData['updatedAt']), // Conversión de fecha

      customFieldValues: fieldValues,
    );
  }

  // Opcional: Para debugging
  @override
  String toString() {
    return 'Item(id: $id, name: $name, customFields: $customFieldValues)';
  }
}
