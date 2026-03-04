import 'package:invenicum/data/models/custom_field_definition_model.dart';

class AssetTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final String author;
  final String? authorAvatarUrl;
  final String? downloadUrl;
  final List<CustomFieldDefinition> fields;
  final bool isOfficial;
  final bool isPublic;
  int downloadCount;
  // 🕒 Nuevos campos de tiempo
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssetTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.tags = const [],
    required this.author,
    this.authorAvatarUrl,
    this.downloadUrl,
    required this.fields,
    this.isOfficial = false,
    this.isPublic = false,
    this.downloadCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // 🚩 Mapeo desde el JSON del Backend (vía DTO)
  factory AssetTemplate.fromJson(Map<String, dynamic> json) {
    return AssetTemplate(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      downloadUrl: json['downloadUrl'], // 🚩 Antes era download_url
      category: json['category'] ?? 'General',
      tags: List<String>.from(json['tags'] ?? []),
      author: json['author'] ?? 'Invenicum User',
      authorAvatarUrl: json['authorAvatarUrl'], // 🚩 Coincide con el debugger
      fields: (json['fields'] as List? ?? [])
          .map((f) => CustomFieldDefinition.fromJson(f))
          .toList(),
      downloadCount: json['downloadCount'] ?? 0,
      isOfficial: json['isOfficial'] ?? false, // 🚩 Cambiado de 'is_official'
      isPublic: json['isPublic'] ?? false, // 🚩 Cambiado de 'is_public'
      // Parseo de fechas corregido para camelCase
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'tags': tags,
    'author': author, // 🚩 Antes era author_name
    'authorAvatarUrl': authorAvatarUrl, // 🚩 Antes era author_avatar_url
    'downloadUrl': downloadUrl, // 🚩 Antes era download_url
    'fields': fields.map((f) => f.toJson()).toList(),
    'isOfficial': isOfficial, // 🚩 Antes era is_official
    'isPublic': isPublic,
    'downloadCount': downloadCount,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

  Map<String, dynamic> toAssetTypeJson(int containerId) {
    return {
      'container_id': containerId,
      'name': name,
      'description': description,
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }
}
