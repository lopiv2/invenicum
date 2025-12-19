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
  // 🔑 1. IDENTIFICADOR TÉCNICO (Usado para la API, DB, y validación en el Backend)
  /// Devuelve el nombre técnico del tipo de campo (ej: 'boolean', 'number').
  String get dbName {
    // Usamos el nombre del enum de Dart en minúsculas como estándar.
    return name.toLowerCase();
  }

  // 🗣️ 2. NOMBRE VISUAL (Reemplaza la propiedad 'name' anterior, usado para la UI)
  /// Devuelve el nombre del tipo de campo para mostrar en la interfaz de usuario (traducido).
  String get displayName {
    switch (this) {
      case CustomFieldType.text:
        return 'Texto';
      case CustomFieldType.number:
        return 'Número';
      case CustomFieldType.date:
        return 'Fecha';
      case CustomFieldType.dropdown:
        return 'Desplegable';
      case CustomFieldType.boolean:
        return 'Sí/No (Booleano)'; // El valor traducido para la UI
      case CustomFieldType.url:
        return 'URL';
      case CustomFieldType.price:
        return 'Precio';
    }
  }

  // 🔄 3. MÉTODO DE CONVERSIÓN (Para deserializar la cadena de la API a enum)
  /// Intenta obtener el CustomFieldType desde una cadena (usada en fromJson).
  static CustomFieldType fromString(String typeString) {
    final lowerCaseType = typeString.toLowerCase().trim();

    // Buscar por el nombre técnico estándar (dbName)
    try {
      return CustomFieldType.values.firstWhere(
        (type) => type.dbName == lowerCaseType,
      );
    } catch (_) {
      // 💡 Fallback si la BD o API devuelve la cadena traducida (e.g., "sí/no (booleano)")
      if (lowerCaseType.contains('booleano') ||
          lowerCaseType.contains('si/no')) {
        return CustomFieldType.boolean;
      }
      debugPrint('Error: Tipo de campo desconocido "$typeString". Usando texto.');
      return CustomFieldType.text; // Valor de fallback seguro
    }
  }

  /// Obtiene el tipo de teclado apropiado para cada tipo de campo
  TextInputType get keyboardType {
    switch (this) {
      case CustomFieldType.number:
        return TextInputType.number;
      case CustomFieldType.price:
        return TextInputType.numberWithOptions(decimal: true, signed: false); // Mejorado
      case CustomFieldType.url:
        return TextInputType.url;
      case CustomFieldType.date:
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }

  /// Valida el valor según el tipo de campo
  String? validateValue(String? value) {
    if (value == null || value.isEmpty) return null; // No validar si está vacío

    switch (this) {
      case CustomFieldType.url:
        // Patrón mejorado para URLs (simplificado)
        final urlPattern =
            RegExp(r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$');
        if (!urlPattern.hasMatch(value)) {
          return 'Introduce una URL válida';
        }
        break;
      case CustomFieldType.price:
        // Permite comas o puntos como separador decimal
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
        // Asegurarse de que use punto para el parseo y luego formato con dos decimales
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