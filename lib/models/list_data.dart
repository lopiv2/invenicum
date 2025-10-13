// lib/models/list_data.dart

class ListData {
  final int id;
  final String name;
  final String? description;
  final List<String> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ListData({
    required this.id,
    required this.name,
    this.description,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory ListData.fromJson(Map<String, dynamic> json) {
    return ListData(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}