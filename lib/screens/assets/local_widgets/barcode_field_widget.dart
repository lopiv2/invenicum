import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'common_form_field.dart';

/// Widget para el campo de código de barras
class BarcodeFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool highlighted;

  const BarcodeFieldWidget({
    super.key,
    required this.controller,
    this.highlighted = false,
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
    );
  }
}
