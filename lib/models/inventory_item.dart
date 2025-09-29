// lib/models/inventory_item_model.dart

class InventoryItem {
  final int id;
  final String name;
  final int containerId;
  final int assetTypeId;
  
  // Mapa dinámico para almacenar los valores de los campos personalizados.
  // La clave será el 'id' del campo de definición (e.g., '123') y el valor será el contenido.
  final Map<String, dynamic> customFieldValues;

  InventoryItem({
    required this.id,
    required this.name,
    required this.containerId,
    required this.assetTypeId,
    required this.customFieldValues,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // 1. Extraer campos fijos
    final itemData = json['itemData'] ?? json; // Ajustar según tu estructura real de API
    
    // 2. Extraer los valores de los campos personalizados, si están anidados.
    // Asumimos que la API devuelve un mapa de valores bajo una clave como 'fieldValues'.
    final Map<String, dynamic> fieldValues = json['fieldValues'] ?? {}; 
    
    // Si tu API devuelve un arreglo que necesita ser transformado a un mapa, la lógica cambia aquí.

    return InventoryItem(
      id: itemData['id'] as int,
      name: itemData['name'] as String? ?? 'N/A',
      containerId: itemData['containerId'] as int,
      assetTypeId: itemData['assetTypeId'] as int,
      customFieldValues: fieldValues,
    );
  }

  // Opcional: Para debugging
  @override
  String toString() {
    return 'Item(id: $id, name: $name, customFields: $customFieldValues)';
  }
}