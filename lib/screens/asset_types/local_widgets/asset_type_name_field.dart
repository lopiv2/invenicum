import 'package:flutter/material.dart';

/// Widget para el campo de nombre del tipo de activo
class AssetTypeNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;

  const AssetTypeNameField({
    super.key,
    required this.controller,
    this.hintText = 'Ej: Ordenador Portátil, Sustancia Química',
    this.labelText = 'Nombre del Tipo de Activo',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
