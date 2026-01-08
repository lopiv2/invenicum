// lib/models/asset_type.dart

import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/models/inventory_item.dart'; 

class AssetType {
  final int id;
  final String name; 
  final List<CustomFieldDefinition> fieldDefinitions;
  final List<InventoryItemImage> images;
  final String? possessionFieldId;
  final String? desiredFieldId;
  final bool isSerialized; // true = seriado (quantity = 1), false = no seriado (quantity variable)

  AssetType({
    required this.id,
    required this.name,
    this.fieldDefinitions = const [],
    this.images = const [], 
    this.possessionFieldId,
    this.desiredFieldId,
    this.isSerialized = true, // Por defecto, los elementos son seriados
  });

  // --- CONSTRUCTOR DE FÁBRICA Y JSON ---

  factory AssetType.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imageListJson = json['images'] as List<dynamic>? ?? [];

    final List<InventoryItemImage> images = imageListJson
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();

    // 🔑 Obtener el valor dinámico del JSON (puede ser int, String o null)
    final possessionIdDynamic = json['possessionFieldId'] ?? json['possession_field_id'];
    final desiredIdDynamic = json['desiredFieldId'] ?? json['desired_field_id'];

    return AssetType(
      id: json['id'] as int,
      name: json['name'] as String,
      images: images,
      isSerialized: json['isSerialized'] as bool? ?? true,
      fieldDefinitions: (json['fieldDefinitions'] as List<dynamic>?)
          ?.map((item) => CustomFieldDefinition.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      
      // 🎯 CORRECCIÓN: Conversión segura: si no es nulo, lo convierte a String. 
      // Si es un int (como el 5 que causó el error), .toString() lo maneja.
      possessionFieldId: possessionIdDynamic != null ? possessionIdDynamic.toString() : null,
      desiredFieldId: desiredIdDynamic != null ? desiredIdDynamic.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images.map((e) => e.toJson()).toList(), 
      'fieldDefinitions': fieldDefinitions.map((e) => e.toJson()).toList(),
      'possessionFieldId': possessionFieldId,
      'desiredFieldId': desiredFieldId,
      'isSerialized': isSerialized,
    };
  }

  // 🌟 MÉTODO copyWith AÑADIDO 🌟
  /// Crea una copia de esta instancia con los valores proporcionados.
  /// Los valores nulos en los argumentos (possessionFieldId, desiredFieldId) 
  /// SOBREESCRIBEN el valor actual, ya que son campos opcionales.
  AssetType copyWith({
    int? id,
    String? name,
    List<CustomFieldDefinition>? fieldDefinitions,
    List<InventoryItemImage>? images,
    // 🔑 Utilizamos String? como tipo de argumento para permitir borrar el campo (asignar null)
    String? possessionFieldId, 
    String? desiredFieldId,
    bool? isSerialized,   
  }) {
    return AssetType(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldDefinitions: fieldDefinitions ?? this.fieldDefinitions,
      images: images ?? this.images,
      isSerialized: isSerialized ?? this.isSerialized,
      
      // 💡 IMPORTANTE: Si el argumento es null, asignamos el null. 
      // Si no fue proporcionado (el argumento es null, pero queremos el valor anterior),
      // necesitamos una lógica especial, pero aquí asumimos que si se proporciona, es el nuevo valor.
      // Ya que los campos son String?, pasaremos el argumento directamente para poder "limpiar" el campo.
      // Si el argumento es omitido, Dart lo pasa como 'null'.
      possessionFieldId: possessionFieldId ?? this.possessionFieldId,
      desiredFieldId: desiredFieldId ?? this.desiredFieldId,
    );
  }
}