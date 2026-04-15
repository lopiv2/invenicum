// lib/models/asset_type.dart

import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/models/inventory_item.dart';

class AssetType {
  static const Object _unset = Object();

  final int id;
  final String name;
  final List<CustomFieldDefinition> fieldDefinitions;
  final List<InventoryItemImage> images;
  final String? possessionFieldId;
  final String? desiredFieldId;
  final bool
  isSerialized; // true = serialized (quantity = 1), false = non-serialized (quantity variable)

  AssetType({
    required this.id,
    required this.name,
    this.fieldDefinitions = const [],
    this.images = const [],
    this.possessionFieldId,
    this.desiredFieldId,
    this.isSerialized = true, // By default, items are serialized
  });

  // --- FACTORY CONSTRUCTOR AND JSON ---

  factory AssetType.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imageListJson = json['images'] as List<dynamic>? ?? [];

    final List<InventoryItemImage> images = imageListJson
        .map(
          (imgJson) =>
              InventoryItemImage.fromJson(imgJson as Map<String, dynamic>),
        )
        .toList();

    // 🔑 Get the dynamic value from JSON (can be int, String, or null)
    final possessionIdDynamic =
        json['possessionFieldId'] ?? json['possession_field_id'];
    final desiredIdDynamic = json['desiredFieldId'] ?? json['desired_field_id'];

    return AssetType(
      id: json['id'] as int,
      name: json['name'] as String,
      images: images,
      isSerialized: json['isSerialized'] as bool? ?? true,
      fieldDefinitions:
          (json['fieldDefinitions'] as List<dynamic>?)
              ?.map(
                (item) => CustomFieldDefinition.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],

      // 🎯 CORRECTION: Safe conversion: if not null, convert to String.
      // If it's an int (like the 5 that caused the error), .toString() handles it.
      possessionFieldId: possessionIdDynamic?.toString(),
      desiredFieldId: desiredIdDynamic?.toString(),
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

  /// Creates a copy of this instance with the provided values.
  /// Null values in the arguments (possessionFieldId, desiredFieldId)
  /// OVERWRITE the current value, as they are optional fields.
  AssetType copyWith({
    int? id,
    String? name,
    List<CustomFieldDefinition>? fieldDefinitions,
    List<InventoryItemImage>? images,
    Object? possessionFieldId = _unset,
    Object? desiredFieldId = _unset,
    bool? isSerialized,
  }) {
    return AssetType(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldDefinitions: fieldDefinitions ?? this.fieldDefinitions,
      images: images ?? this.images,
      isSerialized: isSerialized ?? this.isSerialized,

      possessionFieldId: identical(possessionFieldId, _unset)
          ? this.possessionFieldId
          : possessionFieldId as String?,
      desiredFieldId: identical(desiredFieldId, _unset)
          ? this.desiredFieldId
          : desiredFieldId as String?,
    );
  }
}
