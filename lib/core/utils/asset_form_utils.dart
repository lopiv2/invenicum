import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';

class AssetFormUtils {
  /// Obtiene los formateadores de entrada según el tipo de campo
  static List<TextInputFormatter>? getInputFormatters(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case CustomFieldType.price:
        return [
          // Permitir números y un punto decimal en cualquier posición
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          // Formateador personalizado para asegurar formato correcto de precio
          TextInputFormatter.withFunction((oldValue, newValue) {
            final text = newValue.text;
            
            // Permitir campo vacío
            if (text.isEmpty) return newValue;
            
            // Si es solo un punto, convertir a "0."
            if (text == '.') {
              return const TextEditingValue(
                text: '0.',
                selection: TextSelection.collapsed(offset: 2),
              );
            }

            // Verificar que no haya más de un punto decimal
            if (text.indexOf('.') != text.lastIndexOf('.')) {
              return oldValue;
            }

            // Verificar que sea un número válido
            try {
              if (text.endsWith('.')) {
                // Permitir que el usuario esté escribiendo la parte decimal
                return newValue;
              }
              
              final value = double.parse(text);
              
              // Si tiene más de 2 decimales, formatear
              if (text.contains('.')) {
                final parts = text.split('.');
                if (parts[1].length > 2) {
                  final formatted = value.toStringAsFixed(2);
                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              }
              
              return newValue;
            } catch (e) {
              return oldValue;
            }
          }),
        ];
      case CustomFieldType.url:
        return [
          // Permitir caracteres válidos para URLs
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-zA-Z0-9\-._~:/?#\[\]@!$&\(\)*+,;=]'),
          ),
        ];
      default:
        return null;
    }
  }

  /// Obtiene el texto de ayuda según el tipo de campo
  static String getHintText(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.number:
        return 'Introduce un número entero';
      case CustomFieldType.price:
        return 'Introduce un precio (ej: 123.45)';
      case CustomFieldType.url:
        return 'Introduce una URL válida';
      case CustomFieldType.date:
        return 'DD/MM/AAAA';
      case CustomFieldType.boolean:
        return 'Sí/No';
      default:
        return 'Introduce el valor';
    }
  }

  // 🔑 NUEVO MÉTODO PARA CONVERTIR A BOOLEANO
  /// Convierte varios tipos de valores persistidos (String, bool, null) a bool?.
  /// Es crucial para inicializar los Checkbox en el formulario.
  static bool? toBoolean(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final lowerCaseValue = value.toLowerCase();
      if (lowerCaseValue == 'true' || lowerCaseValue == '1') {
        return true;
      }
      if (lowerCaseValue == 'false' || lowerCaseValue == '0') {
        return false;
      }
    }
    // Si no se puede determinar, devolvemos null
    return null;
  }

  /// Convierte una Data URL (Base64) a datos de archivo
  static Map<String, dynamic> dataUrlToFileData(String dataUrl, int index) {
    // 1. Extraer el tipo MIME (ej: image/png)
    final mimeTypeMatch = RegExp(r'data:([^;]+);base64,').firstMatch(dataUrl);
    final mimeType = mimeTypeMatch?.group(1);

    // 2. Extraer los bytes Base64 puros
    final base64String = dataUrl.split(',').last;
    final Uint8List bytes = base64Decode(base64String);

    // 3. Determinar la extensión y nombre simulado
    final extension = mimeType?.split('/').last ?? 'jpg';
    final fileName = 'asset_image_$index.$extension';

    return {'bytes': bytes, 'name': fileName};
  }

  /// Valida los campos del formulario
  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  /// Procesa las imágenes en formato Base64 para su envío
  static List<Map<String, dynamic>> processImages(List<String> imageUrls) {
    final List<Map<String, dynamic>> filesData = [];

    for (int i = 0; i < imageUrls.length; i++) {
      final dataUrl = imageUrls[i];
      if (dataUrl.startsWith('data:')) {
        filesData.add(dataUrlToFileData(dataUrl, i));
      }
    }

    return filesData;
  }
}