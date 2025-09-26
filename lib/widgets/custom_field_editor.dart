// lib/widgets/custom_field_editor.dart

import 'package:flutter/material.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import '../models/list_data.dart'; // Modelo ListData

class CustomFieldEditor extends StatefulWidget {
  final CustomFieldDefinition field;
  final List<ListData> availableDataLists; // Listas disponibles del contenedor
  final VoidCallback onDelete;
  final Function(CustomFieldDefinition) onUpdate; // Callback para notificar cambios

  const CustomFieldEditor({
    super.key,
    required this.field,
    required this.availableDataLists,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<CustomFieldEditor> createState() => _CustomFieldEditorState();
}

class _CustomFieldEditorState extends State<CustomFieldEditor> {
  late TextEditingController _nameController;
  late CustomFieldType _selectedType;
  late bool _isRequired;
  late int? _selectedListDataId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _selectedType = widget.field.type;
    _isRequired = widget.field.isRequired;
    _selectedListDataId = widget.field.listDataId;
  }

  // Asegurarse de que los controladores se actualicen si el widget.field cambia (ej. reordenar)
  @override
  void didUpdateWidget(covariant CustomFieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.field != oldWidget.field) {
      _nameController.text = widget.field.name;
      _selectedType = widget.field.type;
      _isRequired = widget.field.isRequired;
      _selectedListDataId = widget.field.listDataId;
    }
  }

  // Notificar al padre de los cambios
  void _notifyUpdate() {
    widget.onUpdate(
      widget.field.copyWith(
        name: _nameController.text,
        type: _selectedType,
        isRequired: _isRequired,
        listDataId: _selectedType == CustomFieldType.dropdown ? _selectedListDataId : null,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Campo: "${_nameController.text.isEmpty ? 'Sin nombre' : _nameController.text}"',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                  tooltip: 'Eliminar campo',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Nombre del Campo
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Campo',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onEditingComplete: _notifyUpdate,
              onFieldSubmitted: (value) => _notifyUpdate(), 
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del campo es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 2. Tipo de Campo (Dropdown)
            DropdownButtonFormField<CustomFieldType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Dato',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: CustomFieldType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (CustomFieldType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedType = newValue;
                    // Si el tipo cambia y ya no es dropdown, limpiar listDataId
                    if (_selectedType != CustomFieldType.dropdown) {
                      _selectedListDataId = null;
                    }
                  });
                  _notifyUpdate();
                }
              },
            ),
            const SizedBox(height: 16),

            // 3. Campo Requerido (Checkbox)
            Row(
              children: [
                Checkbox(
                  value: _isRequired,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isRequired = newValue ?? false;
                    });
                    _notifyUpdate();
                  },
                ),
                const Text('Es Requerido'),
              ],
            ),

            // 4. Selección de Lista de Datos (Condicional para tipo 'Desplegable')
            if (_selectedType == CustomFieldType.dropdown) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedListDataId, // Puede ser null
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Lista de Datos',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                hint: const Text('Elija una lista'),
                items: widget.availableDataLists.map((list) {
                  return DropdownMenuItem(
                    value: list.id,
                    child: Text(list.name),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedListDataId = newValue;
                  });
                  _notifyUpdate();
                },
                validator: (value) {
                  if (_selectedType == CustomFieldType.dropdown && value == null) {
                    return 'Debe seleccionar una lista para campos desplegables';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}