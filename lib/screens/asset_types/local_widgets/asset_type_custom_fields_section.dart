import 'package:flutter/material.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'package:invenicum/screens/asset_types/local_widgets/custom_field_editor.dart';

/// Widget para la sección de campos personalizados
class AssetTypeCustomFieldsSection extends StatelessWidget {
  final List<CustomFieldDefinition> fieldDefinitions;
  final List<ListData> availableDataLists;
  final bool isLoading;
  final VoidCallback onAddField;
  final Function(int) onRemoveField;
  final Function(int, CustomFieldDefinition) onUpdateField;

  const AssetTypeCustomFieldsSection({
    super.key,
    required this.fieldDefinitions,
    required this.availableDataLists,
    required this.isLoading,
    required this.onAddField,
    required this.onRemoveField,
    required this.onUpdateField,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Definición de Campos Personalizados',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fieldDefinitions.length,
                itemBuilder: (context, index) {
                  final field = fieldDefinitions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CustomFieldEditor(
                      field: field,
                      availableDataLists: availableDataLists,
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
          label: const Text('Añadir Nuevo Campo'),
        ),
      ],
    );
  }
}
