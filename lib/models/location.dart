// lib/models/location_model.dart

class Location {
  final int id;
  final String name;
  final String? description;
  final int containerId;
  final int? parentId; // Para la jerarquía
  
  // Propiedad útil para el frontend: lista de sub-ubicaciones
  final List<Location>? children; 

  Location({
    required this.id,
    required this.name,
    this.description,
    required this.containerId,
    this.parentId,
    this.children,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
  return Location(
    // 🛡️ Usamos (value ?? 0).toInt() para asegurar que nunca sea null ni double
    id: (json['id'] ?? 0).toInt(),
    name: json['name'] as String? ?? 'Sin nombre',
    description: json['description'] as String?,
    
    // 🚩 CAMBIO CRÍTICO: Si el JSON viene de un "item", no trae containerId.
    // Le asignamos 0 por defecto o cámbialo a 'int?' en la definición de la clase.
    containerId: (json['containerId'] ?? 0).toInt(),
    
    parentId: json['parentId'] != null ? (json['parentId'] as num).toInt() : null,
    
    children: (json['children'] as List<dynamic>?)
        ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'containerId': containerId,
      'parentId': parentId,
      // No incluimos 'children' en el toJson para evitar bucles infinitos
    };
  }
}