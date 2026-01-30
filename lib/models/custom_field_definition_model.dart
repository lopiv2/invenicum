// lib/models/custom_field_definition.dart
import 'package:invenicum/models/custom_field_definition.dart';
// Asumo que tu CustomFieldType y CustomFieldTypeExtension están aquí

class CustomFieldDefinition {
  final int? id;
  final String name;
  final CustomFieldType type;
  final bool isRequired;
  final int? dataListId;

  // 🔑 CAMPOS PARA SUMATORIOS Y CONTADORES
  final bool isSummable;
  final bool isCountable;

  const CustomFieldDefinition({
    this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.dataListId,
    this.isSummable = false,
    this.isCountable = false,
  });

  // ----------------------------------------------------------------
  // Método copyWith (Correcto y Limpio)
  // ----------------------------------------------------------------

  CustomFieldDefinition copyWith({
    int? id,
    String? name,
    CustomFieldType? type,
    bool? isRequired,
    Object? dataListId = const _Sentinel(),
    bool? isSummable,
    bool? isCountable,
  }) {
    final isDataListIdSentinel = dataListId is _Sentinel;

    return CustomFieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      dataListId: isDataListIdSentinel ? this.dataListId : dataListId as int?,
      isSummable: isSummable ?? this.isSummable,
      isCountable: isCountable ?? this.isCountable,
    );
  }

  // ----------------------------------------------------------------
  // Constructor fromJson (CORREGIDO)
  // ----------------------------------------------------------------

  factory CustomFieldDefinition.fromJson(Map<String, dynamic> json) {
    // Manejo de ID: soporta camelCase y snake_case para compatibilidad futura
    final id = json['id'];
    int? parsedId;
    if (id != null) {
      parsedId = id is int ? id : int.tryParse(id.toString());
    }

    // Manejo de dataListId
    final dataListId = json['dataListId'] ?? json['data_list_id'];
    int? parsedDataListId;
    if (dataListId != null) {
      parsedDataListId = dataListId is int
          ? dataListId
          : int.tryParse(dataListId.toString());
    }

    return CustomFieldDefinition(
      id: parsedId,
      name: json['name'] as String,

      // 🐛 CORRECCIÓN CRÍTICA: Usar el método fromString de la extensión
      // para manejar el parsing robusto de la cadena de la API.
      type: CustomFieldTypeExtension.fromString(json['type'] as String),

      // isRequired puede venir como 'is_required' o 'isRequired'
      isRequired:
          json['isRequired'] as bool? ?? json['is_required'] as bool? ?? false,

      dataListId: parsedDataListId,

      // DESERIALIZACIÓN DE LOS NUEVOS CAMPOS (usando '?? false' como fallback seguro)
      // Se asume que en el JSON serán 'isSummable' y 'isCountable'
      isSummable: json['isSummable'] as bool? ?? false,
      isCountable: json['isCountable'] as bool? ?? false,
    );
  }

  // ----------------------------------------------------------------
  // Método toJson (Mejorado)
  // ----------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type.dbName,
      'isRequired': isRequired,

      // 💡 Solo enviamos a la API si es TRUE.
      // Si lo cambias a Texto y pasa a ser false, desaparece del JSON
      // y Prisma ya no se queja del "Unknown argument".
      if (isSummable) 'isSummable': true,
      if (isCountable) 'isCountable': true,

      if (dataListId != null) 'dataListId': dataListId,
    };
  }
}

class _Sentinel {
  const _Sentinel();
}
