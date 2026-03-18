
import 'package:flutter/material.dart';

enum IntegrationFieldType { text, boolean, number, password }

class IntegrationField {
  final String id;
  final String label;
  final IntegrationFieldType type;
  final String? helperText;

  IntegrationField({
    required this.id,
    required this.label,
    required this.type,
    this.helperText,
  });
}

class IntegrationModel {
  final String id;
  final String name;
  final Widget icon;
  final String description;
  final List<IntegrationField> fields;
  final bool isDataSource;

  const IntegrationModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.fields,
    this.isDataSource = false,
  });
}