import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/core/utils/asset_form_utils.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/screens/assets/local_widgets/smart_dropdown_field.dart';
import 'package:provider/provider.dart';
import 'card_section_widget.dart';
import 'common_form_field.dart';
import 'section_header_widget.dart';

class _DateFieldWidget extends StatefulWidget {
  final CustomFieldDefinition fieldDef;
  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateFieldWidget({
    required this.fieldDef,
    required this.controller,
    required this.onTap,
    required this.onClear,
  });

  @override
  State<_DateFieldWidget> createState() => _DateFieldWidgetState();
}

class _DateFieldWidgetState extends State<_DateFieldWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(_DateFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CommonFormField(
        controller: widget.controller,
        label: widget.fieldDef.name,
        icon: Icons.calendar_today_outlined,
        hint: 'DD/MM/YYYY',
        helper: widget.fieldDef.isRequired ? l10n.obligatory : null,
        readOnly: true,
        onTap: widget.onTap,
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: widget.onClear,
              )
            : null,
        validator: (value) {
          if (widget.fieldDef.isRequired && (value == null || value.isEmpty)) {
            return l10n.requiredFieldValidation;
          }
          return null;
        },
      ),
    );
  }
}

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
  final Map<int, List<String>> autocompleteSuggestionsByField;
  final Map<int, FocusNode> autocompleteFocusNodesByField;
  final String containerId;

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
    this.autocompleteSuggestionsByField = const {},
    this.autocompleteFocusNodesByField = const {},
    required this.containerId, // Asegúrate de pasar el containerId al crear este widget
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (fieldDefinitions.isEmpty) {
      return CardSectionWidget(
        child: Row(
          children: [
            Icon(
              Icons.tune_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
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
              return _buildDropdownField(l10n, context, fieldDef, containerId);
            }

            if (fieldDef.type == CustomFieldType.date) {
              return _buildDateField(
                context,
                fieldDef,
                customControllers.putIfAbsent(
                  fieldDef.id!,
                  () => TextEditingController(),
                ),
              );
            }

            return _buildTextField(context, fieldDef);
          }),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    CustomFieldDefinition fieldDef,
    TextEditingController controller,
  ) {
    Future<void> pickDate() async {
      final now = DateTime.now();

      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: Localizations.localeOf(context),
      );

      if (picked != null) {
        final formatted = AppUtils.formatDate(context, picked);

        controller.text = formatted;
        onControllerText(fieldDef.id!, controller);
      }
    }

    void clearDate() {
      controller.clear();
      onControllerText(fieldDef.id!, controller);
    }

    return _DateFieldWidget(
      fieldDef: fieldDef,
      controller: controller,
      onTap: pickDate,
      onClear: clearDate,
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
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Material(type: MaterialType.transparency, child: CheckboxListTile(
          title: Text(
            fieldDef.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: fieldDef.isRequired
              ? Text(
                  l10n.optional,
                  style: TextStyle(color: colorScheme.primary, fontSize: 12),
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
      ),
    );
  }

  Widget _buildDropdownField(
    AppLocalizations l10n,
    BuildContext context,
    CustomFieldDefinition fieldDef,
    String containerId,
  ) {
    // ✅ Read the items from the provider based on whether it's a data list or a static list
    final provider = context.watch<ContainerProvider>();
    final values = fieldDef.dataListId != null
        ? provider.getDataListItems(
            int.parse(containerId),
            fieldDef.dataListId!,
          )
        : (listFieldValues[fieldDef.id] ?? <String>[]);

    final selectedValue = selectedListValues[fieldDef.id];

    return AppDropdownField<String>(
      label: fieldDef.name,
      isRequired: fieldDef.isRequired,
      values: values,
      itemLabel: (v) => v,
      selectedValue: selectedValue,
      onChanged: (v) => onDropdownChanged(fieldDef.id!, v),
      validator: (v) {
        if (fieldDef.isRequired && v == null) {
          return AppLocalizations.of(context)!.requiredFieldValidation;
        }
        return null;
      },
      addNewDialogTitle: l10n.newDataListLabel,
      addNewHint: l10n.enterContainerName,
      onAddNew: (name) async {
        final provider = context.read<ContainerProvider>();

        await provider.addItemToDataList(
          containerId: int.parse(containerId),
          listId: fieldDef.dataListId!,
          value: name,
        );

        // Select the newly added item immediately after adding it
        onDropdownChanged(fieldDef.id!, name);

        return name;
      },
    );
  }

  Widget _buildTextField(BuildContext context, CustomFieldDefinition fieldDef) {
    final controller = customControllers[fieldDef.id];
    final preferences = context.read<PreferencesProvider>();

    if (controller == null) return const SizedBox.shrink();

    final inputFormatters =
        AssetFormUtils.getInputFormatters(fieldDef.type) ?? [];

    final suggestions =
        (autocompleteSuggestionsByField[fieldDef.id] ?? const <String>[]);
    final autocompleteFocusNode = autocompleteFocusNodesByField[fieldDef.id];

    String? validator(String? value) {
      if (fieldDef.isRequired && (value == null || value.isEmpty)) {
        return AppLocalizations.of(context)!.requiredFieldValidation;
      }
      return fieldDef.type.validateValue(value);
    }

    CommonFormField buildBaseField({
      required TextEditingController effectiveController,
      FocusNode? focusNode,
      void Function(String)? onFieldSubmitted,
      Widget? suffixIcon,
    }) {
      return CommonFormField(
        controller: effectiveController,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
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
        validator: validator,
        onChanged: (_) => onControllerText(fieldDef.id!, effectiveController),
        suffixIcon: suffixIcon,
      );
    }

    Iterable<String> optionsBuilder(TextEditingValue value) {
      final query = value.text.trim().toLowerCase();
      if (query.isEmpty) return suggestions.take(8);
      return suggestions
          .where((option) => option.toLowerCase().contains(query))
          .take(8);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: suggestions.isEmpty
          ? buildBaseField(effectiveController: controller)
          : RawAutocomplete<String>(
              textEditingController: controller,
              focusNode: autocompleteFocusNode,
              optionsBuilder: optionsBuilder,
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 220,
                        minWidth: 260,
                        maxWidth: 520,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: (selection) {
                controller
                  ..text = selection
                  ..selection = TextSelection.collapsed(
                    offset: selection.length,
                  );
                onControllerText(fieldDef.id!, controller);
              },
              fieldViewBuilder:
                  (context, textController, focusNode, onFieldSubmitted) {
                    return buildBaseField(
                      effectiveController: textController,
                      focusNode: focusNode,
                      onFieldSubmitted: (_) => onFieldSubmitted(),
                      suffixIcon: const Icon(Icons.history_outlined, size: 18),
                    );
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
