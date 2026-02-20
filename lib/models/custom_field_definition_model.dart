// lib/models/custom_field_definition.dart

import 'package:invenicum/models/custom_field_definition.dart';

class CustomFieldDefinition {
  final int? id;
  final String name;
  final CustomFieldType type;
  final bool isRequired;
  final int? dataListId;

  // 🔑 CAMPOS PARA SUMATORIOS, CONTADORES Y VALOR ECONÓMICO
  final bool isSummable;  // Para acumulados físicos (ej: kg, litros)
  final bool isCountable; // Para contar cuántos items tienen este campo
  final bool isMonetary;  // 💰 NUEVO: Para valor económico real (Precio, Costo)

  const CustomFieldDefinition({
    this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.dataListId,
    this.isSummable = false,
    this.isCountable = false,
    this.isMonetary = false, // Por defecto false
  });

  // ----------------------------------------------------------------
  // Método copyWith (Actualizado)
  // ----------------------------------------------------------------

  CustomFieldDefinition copyWith({
    int? id,
    String? name,
    CustomFieldType? type,
    bool? isRequired,
    Object? dataListId = const _Sentinel(),
    bool? isSummable,
    bool? isCountable,
    bool? isMonetary,
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
      isMonetary: isMonetary ?? this.isMonetary,
    );
  }

  // ----------------------------------------------------------------
  // Constructor fromJson (Actualizado)
  // ----------------------------------------------------------------

  factory CustomFieldDefinition.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    int? parsedId;
    if (id != null) {
      parsedId = id is int ? id : int.tryParse(id.toString());
    }

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
      type: CustomFieldTypeExtension.fromString(json['type'] as String),
      isRequired: json['isRequired'] as bool? ?? json['is_required'] as bool? ?? false,
      dataListId: parsedDataListId,

      // DESERIALIZACIÓN (Soporta snake_case de Prisma y camelCase)
      isSummable: json['isSummable'] as bool? ?? json['is_summable'] as bool? ?? false,
      isCountable: json['isCountable'] as bool? ?? json['is_countable'] as bool? ?? false,
      isMonetary: json['isMonetary'] as bool? ?? json['is_monetary'] as bool? ?? false,
    );
  }

  // ----------------------------------------------------------------
  // Método toJson (Actualizado)
  // ----------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type.dbName,
      'isRequired': isRequired,
      
      // Enviamos como camelCase para tu API, o puedes cambiarlo a 'is_monetary'
      // si tu backend lo requiere estrictamente en snake_case
      if (isSummable) 'isSummable': true,
      if (isCountable) 'isCountable': true,
      if (isMonetary) 'isMonetary': true,

      if (dataListId != null) 'dataListId': dataListId,
    };
  }
}

class _Sentinel {
  const _Sentinel();
}