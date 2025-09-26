
import 'package:invenicum/models/custom_field_definition.dart';

class CustomFieldDefinition {
  final int? id; // Nullable: será null para nuevos campos
  final String name;
  final CustomFieldType  type;
  final bool isRequired;
  final int? dataListId; // Usar el nombre que espera la API/Prisma

  const CustomFieldDefinition({
    this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.dataListId,
  });

  CustomFieldDefinition copyWith({
    int? id,
    String? name,
    CustomFieldType? type,
    bool? isRequired,
    // Nota: dataListId debe ser de tipo int? para permitir pasar 'null' explícitamente.
    Object? dataListId = const _Sentinel(), 
  }) {
    // Usamos el patrón _Sentinel para distinguir entre no pasar un valor (mantener el original)
    // y pasar null (establecer el valor en null).
    final isDataListIdSentinel = dataListId is _Sentinel;

    return CustomFieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      // Lógica para dataListId: si no se pasó (Sentinel), usa el original. 
      // Si se pasó null o un valor, úsalo.
      dataListId: isDataListIdSentinel ? this.dataListId : dataListId as int?,
    );
  }

  factory CustomFieldDefinition.fromJson(Map<String, dynamic> json) {
    // 1. Manejo del ID: Debe ser seguro contra String o null
    // Esto es crucial para evitar el error 'String is not a subtype of int' 
    final id = json['id'];
    int? parsedId;
    if (id != null) {
      parsedId = id is int ? id : int.tryParse(id.toString());
    }

    // 2. Manejo de dataListId
    final dataListId = json['dataListId'] ?? json['data_list_id'];
    int? parsedDataListId;
    if (dataListId != null) {
      parsedDataListId = dataListId is int ? dataListId : int.tryParse(dataListId.toString());
    }
    
    // 3. Devolver la instancia del modelo
    return CustomFieldDefinition(
      id: parsedId,
      name: json['name'] as String,
      type: CustomFieldType.values.firstWhere(
        (e) => e.toString() == 'CustomFieldType.${json['type']}',
        orElse: () => CustomFieldType.text, // Valor por defecto si no coincide
      ),
      // Asegúrate de manejar la posibilidad de que el backend envíe '0' o '1' como string si es necesario
      isRequired: json['isRequired'] as bool, 
      dataListId: parsedDataListId,
    );
  }

  // Método para serializar a JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};

    // 1. Lógica Condicional para el 'id' (solo se envía si es una actualización)
    // Si el 'id' existe y es positivo, se incluye en el payload.
    // Para POST (creación), 'id' será null o 0 y, por lo tanto, se omite.
    if (id != null && id! > 0) {
      map['id'] = id;
    }

    // 2. Otros campos
    map['name'] = name;
    map['type'] = type;
    map['isRequired'] = isRequired;

    // 3. Incluir dataListId si tiene valor
    if (dataListId != null) {
      map['dataListId'] = dataListId;
    }

    return map;
  }
}

class _Sentinel {
  const _Sentinel();
}
