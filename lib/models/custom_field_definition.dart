// lib/models/custom_field_definition.dart

// Asegúrate de que el enum esté en el mismo archivo o importado
// import 'package:invenicum/enums/custom_field_type.dart'; // Si lo pones en un archivo separado

enum CustomFieldType {
  text,
  number,
  date,
  dropdown,
  boolean,
}

extension CustomFieldTypeExtension on CustomFieldType {
  String get name {
    switch (this) {
      case CustomFieldType.text: return 'Texto';
      case CustomFieldType.number: return 'Número';
      case CustomFieldType.date: return 'Fecha';
      case CustomFieldType.dropdown: return 'Desplegable';
      case CustomFieldType.boolean: return 'Sí/No (Booleano)';
    }
  }
}