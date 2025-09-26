// lib/models/list_data.dart

class ListData {
  final int id;
  final String name; // Ej: "Proveedores", "Colores de Inventario"
  final List<String> options;

  ListData({
    required this.id,
    required this.name,
    required this.options,
  });

  factory ListData.fromJson(Map<String, dynamic> json) {
    return ListData(
      id: json['id'] as int,
      name: json['name'] as String,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'options': options, // Se serializa directamente como array de strings
    };
  }
}