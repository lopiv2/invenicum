// lib/models/custom_field_definition_model.dart

enum CustomFieldType {
  text,
  number,
  date,
  boolean,
  dropdown,
  // Podemos añadir 'location' aquí si quieres un manejo especial.
}

class CustomFieldDefinition {
  final int id;
  final String name;        // Ej: 'Ubicación', 'Voltaje'
  final CustomFieldType type;
  final bool isRequired;
  final int? listDataId;    // <<-- ID si el 'type' es 'dropdown'

  CustomFieldDefinition({
    required this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.listDataId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // Convertir el Enum de vuelta a String
      'type': type.toString().split('.').last, 
      'isRequired': isRequired,
      'listDataId': listDataId,
    };
  }

  CustomFieldDefinition copyWith({
    int? id,
    String? name,
    CustomFieldType? type,
    bool? isRequired,
    int? listDataId,
  }) {
    return CustomFieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      listDataId: listDataId ?? this.listDataId,
    );
  }

  factory CustomFieldDefinition.fromJson(Map<String, dynamic> json) {
    return CustomFieldDefinition(
      id: json['id'] as int,
      name: json['name'] as String,
      isRequired: json['isRequired'] as bool? ?? false,
      listDataId: json['listDataId'] as int?,
      
      // Convertir String de la API a Enum
      type: CustomFieldType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CustomFieldType.text, // Valor por defecto seguro
      ),
    );
  }
}