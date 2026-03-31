import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/core/utils/asset_form_utils.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:provider/provider.dart';
import 'card_section_widget.dart';
import 'common_form_field.dart';
import 'section_header_widget.dart';

/// Widget para la sección de campos personalizados
class CustomFieldsSectionWidget extends StatelessWidget {
  final List<CustomFieldDefinition> fieldDefinitions;
  final Map<int, TextEditingController> customControllers;
  final Map<int, List<String>> listFieldValues;
  final Map<int, String?> selectedListValues;
  final Map<int, bool> booleanFieldValues;
  final Set<String> highlightedFields;
  final Function(int, TextEditingController) onControllerText;
  final Function(int, String?) onDropdownChanged;
  final Function(int, bool?) onBooleanChanged;

  const CustomFieldsSectionWidget({
    super.key,
    required this.fieldDefinitions,
    required this.customControllers,
    required this.listFieldValues,
    required this.selectedListValues,
    required this.booleanFieldValues,
    required this.highlightedFields,
    required this.onControllerText,
    required this.onDropdownChanged,
    required this.onBooleanChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (fieldDefinitions.isEmpty) {
      return CardSectionWidget(
        child: Row(
          children: [
            Icon(Icons.tune_outlined,
                color: colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Text(
              l10n.noCustomFields,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return CardSectionWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: l10n.customFields,
            icon: Icons.tune_outlined,
          ),
          ...fieldDefinitions.map((fieldDef) {
            if (fieldDef.type == CustomFieldType.boolean) {
              return _buildBooleanField(context, fieldDef, l10n);
            }

            if (fieldDef.type == CustomFieldType.dropdown) {
              return _buildDropdownField(context, fieldDef);
            }

            return _buildTextField(context, fieldDef);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBooleanField(
    BuildContext context,
    CustomFieldDefinition fieldDef,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: CheckboxListTile(
          title: Text(
            fieldDef.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: fieldDef.isRequired
              ? Text(
                  l10n.optional,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                  ),
                )
              : null,
          value: booleanFieldValues[fieldDef.id] ?? false,
          onChanged: (bool? newValue) {
            onBooleanChanged(fieldDef.id!, newValue);
          },
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    CustomFieldDefinition fieldDef,
  ) {
    final values = listFieldValues[fieldDef.id] ?? [];
    final selectedValue = selectedListValues[fieldDef.id];

    InputDecoration _fieldDecoration({
      required String label,
      required IconData icon,
      String? helper,
    }) {
      final colorScheme = Theme.of(context).colorScheme;

      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        helperText: helper,
        helperMaxLines: 2,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        decoration: _fieldDecoration(
          label: fieldDef.name,
          icon: Icons.expand_circle_down_outlined,
          helper: fieldDef.isRequired ? 'Obligatorio' : null,
        ),
        borderRadius: BorderRadius.circular(14),
        items: values.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          onDropdownChanged(fieldDef.id!, newValue);
        },
        validator: (value) {
          if (fieldDef.isRequired && value == null) {
            return AppLocalizations.of(context)!.requiredFieldValidation;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    CustomFieldDefinition fieldDef,
  ) {
    final controller = customControllers[fieldDef.id];
    final preferences = context.read<PreferencesProvider>();

    if (controller == null) return const SizedBox.shrink();

    final inputFormatters = AssetFormUtils.getInputFormatters(fieldDef.type) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CommonFormField(
        controller: controller,
        label: fieldDef.name,
        icon: _iconForFieldType(fieldDef.type),
        prefix: fieldDef.type == CustomFieldType.price
            ? '${preferences.getSymbolForCurrency(preferences.selectedCurrency)} '
            : null,
        hint: AssetFormUtils.getHintText(fieldDef.type),
        helper: fieldDef.isRequired ? 'Obligatorio' : null,
        keyboardType: fieldDef.type.keyboardType,
        inputFormatters: inputFormatters,
        highlighted: highlightedFields.contains(fieldDef.name),
        validator: (value) {
          if (fieldDef.isRequired && (value == null || value.isEmpty)) {
            return AppLocalizations.of(context)!.requiredFieldValidation;
          }
          return fieldDef.type.validateValue(value);
        },
      ),
    );
  }

  IconData _iconForFieldType(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.price:
        return Icons.sell_outlined;
      case CustomFieldType.number:
        return Icons.pin_outlined;
      case CustomFieldType.date:
        return Icons.calendar_today_outlined;
      default:
        return Icons.notes_outlined;
    }
  }
}
