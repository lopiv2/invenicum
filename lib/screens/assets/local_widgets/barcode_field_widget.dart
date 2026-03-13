import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/assets/local_widgets/common_form_field.dart';

class BarcodeFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool highlighted;
  final VoidCallback? onScanPressed; // 🚩 Nuevo parámetro

  const BarcodeFieldWidget({
    super.key,
    required this.controller,
    this.highlighted = false,
    this.onScanPressed, // 🚩 Lo recibimos
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CommonFormField(
      controller: controller,
      label: '${l10n.barCode} (Opcional)',
      icon: Icons.qr_code_scanner_outlined,
      helper: 'Escanee o introduzca el código del producto',
      keyboardType: TextInputType.text,
      highlighted: highlighted,
      // 🚩 Asumiendo que CommonFormField acepta un suffixIcon o similar
      suffixIcon: onScanPressed != null 
        ? IconButton(
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.indigo),
            onPressed: onScanPressed,
          ) 
        : null,
    );
  }
}