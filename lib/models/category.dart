// lib/models/category_model.dart

class Category {
  final int id;
  final String name;
  final String? description;
  final int? parentId; // ID de la categoría padre para anidación
  final List<Category> children; // Subcategorías anidadas

  Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parentId'] as int?,
      
      // Mapear subcategorías
      children: (json['children'] as List<dynamic>?)
          ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parentId': parentId,
      // Serializar recursivamente las subcategorías
      'children': children.map((e) => e.toJson()).toList(), 
    };
  }
}