// lib/widgets/custom_field_editor.dart

import 'package:flutter/material.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import '../models/list_data.dart'; // Modelo ListData

// Asumo que el modelo CustomFieldDefinition contiene CustomFieldType
// ej: import 'package:invenicum/models/custom_field_definition_model.dart';

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
  // Usamos el tipo String para el estado local si la enumeración se inicializa de una cadena
  late CustomFieldType _selectedType; 
  late bool _isRequired;
  late int? _selectedListDataId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _selectedType = widget.field.type;
    _isRequired = widget.field.isRequired;
    _selectedListDataId = widget.field.dataListId;

    // Escuchar cambios en tiempo real en el campo de texto
    _nameController.addListener(_onNameChanged);
  }

  @override
  void didUpdateWidget(covariant CustomFieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.field != oldWidget.field) {
      // Remover listener temporalmente para evitar que se dispare al cambiar el texto
      _nameController.removeListener(_onNameChanged);
      
      _nameController.text = widget.field.name;
      _selectedType = widget.field.type;
      _isRequired = widget.field.isRequired;
      _selectedListDataId = widget.field.dataListId;
      
      // Volver a añadir listener
      _nameController.addListener(_onNameChanged);
    }
  } 
  
  // Nuevo método para manejar la actualización del nombre más seguido
  void _onNameChanged() {
    // Retrasar la notificación ligeramente o usar onEditingComplete
    // Aquí usamos onChanged del TextFormField en su lugar para más control.
    // Solo actualizamos el UI de la cabecera del campo aquí
    setState(() {});
  }

  // Notificar al padre de los cambios
  void _notifyUpdate() {
    // Limpiar dataListId si el tipo no es dropdown (protección extra)
    final int? finalDataListId = 
        _selectedType == CustomFieldType.dropdown ? _selectedListDataId : null;
        
    widget.onUpdate(
      widget.field.copyWith(
        name: _nameController.text.trim(), // Limpiar espacios en blanco
        type: _selectedType,
        isRequired: _isRequired,
        dataListId: finalDataListId,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged); // Importante
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay listas disponibles, forzamos la selección a null (Mejora UX/seguridad)
    final List<ListData> availableLists = widget.availableDataLists;
    if (availableLists.isEmpty && _selectedType == CustomFieldType.dropdown) {
      // No llamamos a setState, solo actualizamos el valor local si es necesario
      if (_selectedListDataId != null) {
        _selectedListDataId = null;
        WidgetsBinding.instance.addPostFrameCallback((_) => _notifyUpdate());
      }
    }


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
                  // Usamos _nameController.text para reflejar el texto actual
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
              // Usar onChanged para que el título se actualice en tiempo real
              onChanged: (value) {
                // El listener ya llama a setState, solo necesitamos notificar el valor final
              },
              // Usar onFieldSubmitted para notificar al padre solo al terminar de editar (enter, etc.)
              onFieldSubmitted: (value) => _notifyUpdate(), 
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
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
                  child: Text(type.name.toUpperCase()), // Muestra el enum en mayúsculas
                );
              }).toList(),
              onChanged: (CustomFieldType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedType = newValue;
                    // Limpiar listDataId si el tipo no es dropdown
                    if (_selectedType != CustomFieldType.dropdown) {
                      _selectedListDataId = null;
                    } else if (availableLists.isEmpty) {
                      // Si cambia a dropdown pero no hay listas, forzamos a null
                      _selectedListDataId = null; 
                    }
                  });
                  _notifyUpdate(); // Notificar cambio de tipo
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
              // Mostrar mensaje si no hay listas disponibles
              if (availableLists.isEmpty)
                const Text(
                  '⚠️ No hay listas de datos disponibles en este contenedor.',
                  style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                )
              else
                DropdownButtonFormField<int>(
                  value: _selectedListDataId, // Puede ser null
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Lista de Datos',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  hint: const Text('Elija una lista'),
                  items: availableLists.map((list) {
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
                    if (value == null) {
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