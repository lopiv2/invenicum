import 'package:invenicum/models/custom_field_definition.dart';
// (Asumo que CustomFieldType se define en otro archivo que se importa correctamente)

class CustomFieldDefinition {
  final int? id;
  final String name;
  final CustomFieldType type;
  final bool isRequired;
  final int? dataListId;

  // 🔑 NUEVOS CAMPOS PARA SUMATORIOS Y CONTADORES
  final bool isSummable;
  final bool isCountable;

  const CustomFieldDefinition({
    this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.dataListId,
    // Valores por defecto para los nuevos campos
    this.isSummable = false,
    this.isCountable = false,
  });

  // ----------------------------------------------------------------
  // Método copyWith actualizado
  // ----------------------------------------------------------------

  CustomFieldDefinition copyWith({
    int? id,
    String? name,
    CustomFieldType? type,
    bool? isRequired,
    Object? dataListId = const _Sentinel(),
    // 🔑 Nuevos parámetros en copyWith
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
      // 🔑 Asignación de los nuevos campos
      isSummable: isSummable ?? this.isSummable,
      isCountable: isCountable ?? this.isCountable,
    );
  }

  // ----------------------------------------------------------------
  // Constructor fromJson actualizado
  // ----------------------------------------------------------------

  factory CustomFieldDefinition.fromJson(Map<String, dynamic> json) {
    // ... (Lógica de manejo de id y dataListId es la misma)
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
      type: CustomFieldType.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['type'] as String).toLowerCase(),
        orElse: () => CustomFieldType.text,
      ),
      isRequired: json['isRequired'] as bool,
      dataListId: parsedDataListId,
      // 🔑 DESERIALIZACIÓN DE LOS NUEVOS CAMPOS (usando '?? false' como fallback seguro)
      isSummable: json['isSummable'] as bool? ?? false,
      isCountable: json['isCountable'] as bool? ?? false,
    );
  }

  // ----------------------------------------------------------------
  // Método toJson actualizado
  // ----------------------------------------------------------------

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};

    if (id != null && id! > 0) {
      map['id'] = id;
    }

    map['name'] = name;
    map['type'] = type.name.toLowerCase();
    map['isRequired'] = isRequired;

    // 🔑 SERIALIZACIÓN DE LOS NUEVOS CAMPOS
    // Solo incluimos si es true, o si tu API lo requiere siempre.
    // Generalmente, solo enviamos true, el backend asume false si no está.
    if (isSummable) {
      map['isSummable'] = true;
    }
    if (isCountable) {
      map['isCountable'] = true;
    }

    if (dataListId != null) {
      map['dataListId'] = dataListId;
    }

    return map;
  }
}

class _Sentinel {
  const _Sentinel();
}
