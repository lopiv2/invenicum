import 'package:invenicum/models/custom_field_definition_model.dart';

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
    this.createdAt,
    this.updatedAt,
  });

  // 🚩 Mapeo desde el JSON del Backend (vía DTO)
  factory AssetTemplate.fromJson(Map<String, dynamic> json) {
    return AssetTemplate(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      author: json['author_name'] ?? json['author'] ?? 'Invenicum User',
      authorAvatarUrl: json['author_avatar_url'],
      downloadUrl: json['download_url'],
      // El DTO garantiza que 'fields' sea una List, evitando el error de _JsonMap
      fields: (json['fields'] as List? ?? [])
          .map((f) => CustomFieldDefinition.fromJson(f))
          .toList(),
      isOfficial: json['is_official'] ?? false,
      isPublic: json['is_public'] ?? false,
      // 🕒 Parseo seguro de fechas ISO8601
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
      'category': category,
      'tags': tags,
      'author_name': author,
      'author_avatar_url': authorAvatarUrl,
      'download_url': downloadUrl,
      'fields': fields.map((f) => f.toJson()).toList(),
      'is_official': isOfficial,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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