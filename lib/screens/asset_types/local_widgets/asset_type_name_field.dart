import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Widget para el campo de nombre del tipo de activo
class AssetTypeNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;

  const AssetTypeNameField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText ?? l10n.assetTypeNameLabel,
        hintText: hintText ?? l10n.assetTypeNameHint,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
