// lib/models/asset_type.dart (CORREGIDO)

import 'package:invenicum/models/custom_field_definition_model.dart';
// 💡 Necesitas importar el modelo de imagen, en este caso InventoryItemImage
import 'package:invenicum/models/inventory_item.dart'; 

class AssetType {
  final int id;
  final String name; // Ej: "Ordenador", "Reactivo Químico"
  final List<CustomFieldDefinition> fieldDefinitions;
  // 🔑 CAMBIO: Reemplazamos String? imageUrl por List<InventoryItemImage> images
  final List<InventoryItemImage> images; 

  AssetType({
    required this.id,
    required this.name,
    this.fieldDefinitions = const [],
    this.images = const [], // 🔑 Inicialización de la nueva propiedad
  });

  factory AssetType.fromJson(Map<String, dynamic> json) {
    // 1. Procesar la lista de imágenes desde el JSON
    final List<dynamic> imageListJson = json['images'] as List<dynamic>? ?? [];
    
    // 2. Mapear la lista de JSON a objetos InventoryItemImage
    final List<InventoryItemImage> images = imageListJson
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();

    return AssetType(
      id: json['id'] as int,
      name: json['name'] as String,
      // 🔑 Mapeamos la lista de imágenes
      images: images, 
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
      // 🔑 Serializamos la lista de imágenes
      'images': images.map((e) => e.toJson()).toList(), 
      // Llama a toJson() en cada definición de campo
      'fieldDefinitions': fieldDefinitions.map((e) => e.toJson()).toList(),
    };
  }
}