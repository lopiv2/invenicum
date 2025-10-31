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
    // Nota: El backend debería devolver la lista de 'children' si se solicita en la consulta.
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      containerId: json['containerId'],
      parentId: json['parentId'],
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