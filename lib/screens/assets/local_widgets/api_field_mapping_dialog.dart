import 'package:flutter/material.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class ApiFieldMappingDialog extends StatefulWidget {
  final Map<String, dynamic> unmappedFields;
  final List<CustomFieldDefinition> availableFields;

  const ApiFieldMappingDialog({
    super.key,
    required this.unmappedFields,
    required this.availableFields,
  });

  @override
  State<ApiFieldMappingDialog> createState() => _ApiFieldMappingDialogState();
}

class _ApiFieldMappingDialogState extends State<ApiFieldMappingDialog> {
  final Map<String, CustomFieldDefinition?> _selectedMappings = {};

  @override
  void initState() {
    super.initState();
    for (final key in widget.unmappedFields.keys) {
      _selectedMappings[key] = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nonDropdownFields = widget.availableFields
        .where((f) => f.type != CustomFieldType.dropdown)
        .toList();
    return AlertDialog(
      title: Text(l10n.mapFieldsManuallyTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.unmappedFields.entries.map((entry) {
            final fieldKey = entry.key;
            final fieldValue = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$fieldKey: $fieldValue',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<CustomFieldDefinition>(
                    value: _selectedMappings[fieldKey],
                    hint: Text(l10n.mapToHint),
                    items: nonDropdownFields.map((f) {
                      return DropdownMenuItem(value: f, child: Text(f.name));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedMappings[fieldKey] = val;
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final result = <int, dynamic>{};
            _selectedMappings.forEach((apiKey, fieldDef) {
              if (fieldDef != null) {
                result[fieldDef.id!] = widget.unmappedFields[apiKey];
              }
            });
            Navigator.of(context).pop(result);
          },
          child: Text(l10n.apply),
        ),
      ],
    );
  }
}
