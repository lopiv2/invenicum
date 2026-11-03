import 'package:invenicum/widgets/ui/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'package:invenicum/screens/asset_types/local_widgets/custom_field_editor.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Widget para la sección de campos personalizados (reordenables por drag).
class AssetTypeCustomFieldsSection extends StatelessWidget {
  final List<CustomFieldDefinition> fieldDefinitions;
  final List<ListData> availableDataLists;
  final bool isLoading;
  final VoidCallback onAddField;
  final Function(int) onRemoveField;
  final Function(int, CustomFieldDefinition) onUpdateField;
  final Function(int oldIndex, int newIndex) onReorderFields;

  const AssetTypeCustomFieldsSection({
    super.key,
    required this.fieldDefinitions,
    required this.availableDataLists,
    required this.isLoading,
    required this.onAddField,
    required this.onRemoveField,
    required this.onUpdateField,
    required this.onReorderFields,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Definición de Campos Personalizados',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        isLoading
            ? const Center(child: AppLoadingIndicator())
            : ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: fieldDefinitions.length,
                onReorderItem: onReorderFields,
                itemBuilder: (context, index) {
                  final field = fieldDefinitions[index];
                  return Padding(
                    key: ValueKey('custom-field-${field.id}'),
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CustomFieldEditor(
                      field: field,
                      availableDataLists: availableDataLists,
                      dragHandle: ReorderableDragStartListener(
                        index: index,
                        child: Tooltip(
                          message: l10n.reorderTooltip,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ),
                      onDelete: () => onRemoveField(index),
                      onUpdate: (updatedField) {
                        onUpdateField(index, updatedField);
                      },
                    ),
                  );
                },
              ),
        TextButton.icon(
          onPressed: onAddField,
          icon: const Icon(Icons.add_box),
          label: Text(AppLocalizations.of(context)!.addNewFieldButton),
        ),
      ],
    );
  }
}
