// lib/models/container_node.dart

import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/list_data.dart';

class ContainerNode {
  final int id;
  final String name;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // CAMPOS DE PERSONALIZACIÓN
  final List<ListData> dataLists;
  final List<AssetType> assetTypes;

  ContainerNode({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.dataLists = const [],
    this.assetTypes = const [],
  });

  // **********************************************
  // MÉTODO copyWith: Implementación requerida
  // **********************************************
  ContainerNode copyWith({
    int? id,
    String? name,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ListData>? dataLists,
    List<AssetType>? assetTypes,
  }) {
    return ContainerNode(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataLists: dataLists ?? this.dataLists,
      assetTypes: assetTypes ?? this.assetTypes, // <- Usado en el Provider
    );
  }


  factory ContainerNode.fromJson(Map<String, dynamic> json) {
    // ... (El cuerpo de fromJson se mantiene igual)
    List<T> _parseList<T>(dynamic listJson, T Function(Map<String, dynamic>) fromJsonFn) {
      if (listJson is List) {
        return listJson.map((item) => fromJsonFn(item as Map<String, dynamic>)).toList();
      }
      return [];
    }
    
    return ContainerNode(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      dataLists: _parseList<ListData>(
        json['dataLists'] ?? json['data_lists'],
        ListData.fromJson,
      ),
      assetTypes: _parseList<AssetType>(
        json['assetTypes'] ?? json['asset_types'],
        AssetType.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    // ... (El cuerpo de toJson se mantiene igual)
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dataLists': dataLists.map((e) => e.toJson()).toList(),
      'assetTypes': assetTypes.map((e) => e.toJson()).toList(),
    };
  }
}