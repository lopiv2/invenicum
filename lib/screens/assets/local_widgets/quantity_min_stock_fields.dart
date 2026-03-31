import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'common_form_field.dart';

/// Widget para los campos de cantidad y stock mínimo
class QuantityMinStockFieldsWidget extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController minStockController;

  const QuantityMinStockFieldsWidget({
    super.key,
    required this.quantityController,
    required this.minStockController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: CommonFormField(
            controller: quantityController,
            label: l10n.quantity,
            icon: Icons.layers_outlined,
            helper: l10n.availableLabel,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterQuantity;
              }
              final q = int.tryParse(value);
              if (q == null || q < 1) {
                return l10n.mustBeGreaterThanZero;
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CommonFormField(
            controller: minStockController,
            label: l10n.minStock,
            icon: Icons.warning_amber_outlined,
            helper: l10n.alertThresholdLabel,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterMinimumStock;
              }
              final m = int.tryParse(value);
              if (m == null || m < 1) {
                return l10n.mustBeGreaterThanZero;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
