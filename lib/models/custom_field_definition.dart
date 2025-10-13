// lib/models/custom_field_definition.dart
import 'package:flutter/material.dart';

enum CustomFieldType {
  text,
  number,
  date,
  dropdown,
  boolean,
  url,
  price,
}

extension CustomFieldTypeExtension on CustomFieldType {
  String get name {
    switch (this) {
      case CustomFieldType.text: return 'Texto';
      case CustomFieldType.number: return 'Número';
      case CustomFieldType.date: return 'Fecha';
      case CustomFieldType.dropdown: return 'Desplegable';
      case CustomFieldType.boolean: return 'Sí/No (Booleano)';
      case CustomFieldType.url: return 'URL';
      case CustomFieldType.price: return 'Precio';
    }
  }

  /// Obtiene el tipo de teclado apropiado para cada tipo de campo
  TextInputType get keyboardType {
    switch (this) {
      case CustomFieldType.number: return TextInputType.number;
      case CustomFieldType.price: return TextInputType.numberWithOptions(decimal: true);
      case CustomFieldType.url: return TextInputType.url;
      case CustomFieldType.date: return TextInputType.datetime;
      default: return TextInputType.text;
    }
  }

  /// Valida el valor según el tipo de campo
  String? validateValue(String? value) {
    if (value == null || value.isEmpty) return null; // No validar si está vacío

    switch (this) {
      case CustomFieldType.url:
        final urlPattern = RegExp(
          r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$'
        );
        if (!urlPattern.hasMatch(value)) {
          return 'Introduce una URL válida';
        }
        break;
      case CustomFieldType.price:
        final pricePattern = RegExp(r'^\d+([.,]\d{0,2})?$');
        if (!pricePattern.hasMatch(value)) {
          return 'Introduce un precio válido (ej: 123.45)';
        }
        break;
      default:
        break;
    }
    return null;
  }

  /// Formatea el valor según el tipo de campo
  String formatValue(String value) {
    switch (this) {
      case CustomFieldType.price:
        // Asegurarse de que tenga dos decimales
        final double? number = double.tryParse(value.replaceAll(',', '.'));
        if (number != null) {
          return number.toStringAsFixed(2);
        }
        return value;
      default:
        return value;
    }
  }
}