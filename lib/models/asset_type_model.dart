// lib/models/asset_type.dart

import 'package:invenicum/models/custom_field_definition_model.dart';

class AssetType {
  final int id;
  final String name; // Ej: "Ordenador", "Reactivo Químico"
  final List<CustomFieldDefinition> fieldDefinitions;
  final String? imageUrl; 

  AssetType({
    required this.id,
    required this.name,
    this.fieldDefinitions = const [],
    this.imageUrl, // Inicialización de la nueva propiedad
  });

  factory AssetType.fromJson(Map<String, dynamic> json) {
    return AssetType(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?, // Mapeo de la nueva propiedad
      fieldDefinitions: (json['fieldDefinitions'] as List<dynamic>?)
          ?.map((item) => CustomFieldDefinition.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // MÉTODO NECESARIO PARA ContainerNode.toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl, // Serialización de la nueva propiedad
      // Llama a toJson() en cada definición de campo
      'fieldDefinitions': fieldDefinitions.map((e) => e.toJson()).toList(),
    };
  }
}