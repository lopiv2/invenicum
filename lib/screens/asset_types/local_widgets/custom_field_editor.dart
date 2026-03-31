// lib/widgets/custom_field_editor.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import '../../../data/models/list_data.dart'; // Modelo ListData

class CustomFieldEditor extends StatefulWidget {
  final CustomFieldDefinition field;
  final List<ListData> availableDataLists; // Listas disponibles del contenedor
  final VoidCallback onDelete;
  final Function(CustomFieldDefinition)
  onUpdate; // Callback para notificar cambios

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

  // 🔑 NUEVOS ESTADOS
  late bool _isSummable;
  late bool _isCountable;
  late bool _isMonetary;

  Timer? _debounceTimer;

  void _debounce(VoidCallback callback) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), callback);
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _selectedType = widget.field.type;
    _isRequired = widget.field.isRequired;
    _selectedListDataId = widget.field.dataListId;
    // 🔑 Inicialización de los nuevos estados
    _isSummable = widget.field.isSummable;
    _isCountable = widget.field.isCountable;
    _isMonetary = widget.field.isMonetary;

    _nameController.addListener(_onNameChanged);
  }

  @override
  void didUpdateWidget(covariant CustomFieldEditor oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  if (widget.field != oldWidget.field) {
    
    if (_nameController.text != widget.field.name) {
      _nameController.removeListener(_onNameChanged);
      _nameController.text = widget.field.name;
      _nameController.addListener(_onNameChanged);
    }

    _selectedType = widget.field.type;
    _isRequired = widget.field.isRequired;
    _selectedListDataId = widget.field.dataListId;
    _isSummable = widget.field.isSummable;
    _isCountable = widget.field.isCountable;
    _isMonetary = widget.field.isMonetary;
  }
}

  void _onNameChanged() {
    setState(() {}); // Solo actualiza la cabecera del campo
  }

  // Notificar al padre de los cambios
  void _notifyUpdate() {
    // Limpiar dataListId si el tipo no es dropdown (protección extra)
    final int? finalDataListId = _selectedType == CustomFieldType.dropdown
        ? _selectedListDataId
        : null;

    // 🔑 Lógica para limpiar isSummable si el tipo no es numérico
    final bool finalIsSummable;
    if (_selectedType == CustomFieldType.number ||
        _selectedType == CustomFieldType.price) {
      finalIsSummable = _isSummable;
    } else {
      finalIsSummable = false;
    }

    widget.onUpdate(
      widget.field.copyWith(
        name: _nameController.text.trim(), // Limpiar espacios en blanco
        type: _selectedType,
        isRequired: _isRequired,
        dataListId: finalDataListId,
        isSummable: finalIsSummable,
        isCountable: _isCountable,
        isMonetary: _isMonetary,
      ),
    );
  }

  // 🔑 Función de ayuda para determinar si el campo es de tipo numérico
  bool get _isNumericType =>
      _selectedType == CustomFieldType.number ||
      _selectedType == CustomFieldType.price;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<ListData> availableLists = widget.availableDataLists;

    // Si no hay listas y es dropdown, forzamos a null y notificamos
    if (availableLists.isEmpty && _selectedType == CustomFieldType.dropdown) {
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
            // --- Cabecera y Botón de Eliminar ---
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameController,
                    builder: (context, value, child) {
                      final displayName = value.text.isEmpty
                          ? 'Sin nombre'
                          : value.text;
                      return Text(
                        'Campo: "$displayName"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    },
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
              onChanged: (value) {
                //setState(() {});
                _debounce(() {
                  if (mounted) {
                    _notifyUpdate();
                  }
                });
              },
              onFieldSubmitted: (value) {
                _debounceTimer?.cancel();
                _notifyUpdate();
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.fieldNameRequired;
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
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (CustomFieldType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedType = newValue;
                    // Limpiar dataListId si el tipo no es dropdown
                    // 🚀 LÓGICA AUTOMÁTICA PARA PRECIOS
                    if (_selectedType == CustomFieldType.price) {
                      _isMonetary = true;
                      _isSummable =
                          true; // Generalmente los precios se quieren sumar
                    }
                    if (_selectedType != CustomFieldType.dropdown) {
                      _selectedListDataId = null;
                    }

                    // 🔑 Si el nuevo tipo no es numérico ni precio, desactivar monetario y sumatorio
                    if (_selectedType != CustomFieldType.number &&
                        _selectedType != CustomFieldType.price) {
                      _isSummable = false;
                      _isMonetary = false;
                    }
                  });
                  _notifyUpdate(); // Notificar cambio de tipo
                }
              },
            ),

            const SizedBox(height: 16),
            const Divider(),

            // --- Opciones de Comportamiento del Campo ---
            Text(l10n.fieldsOptions, style: Theme.of(context).textTheme.titleSmall),

            // 3. Campo Requerido (Switch)
            SwitchListTile(
              title: Text(l10n.isRequiredField),
              value: _isRequired,
              onChanged: (bool newValue) {
                setState(() {
                  _isRequired = newValue;
                });
                _notifyUpdate();
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // 🔑 4. Es Sumable (Visible solo para tipos numéricos)
            if (_isNumericType)
              SwitchListTile(
                title: Text(
                  l10n.isSummativeFieldLabel,
                ),
                value: _isSummable,
                onChanged: (bool newValue) {
                  setState(() {
                    _isSummable = newValue;
                  });
                  _notifyUpdate();
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            // 💰 5. NUEVO: Es Monetario (Visible para tipos numéricos y precios)
            if (_selectedType == CustomFieldType.number ||
                _selectedType == CustomFieldType.price)
              SwitchListTile(
                title: Text(l10n.isMonetaryValueLabel),
                subtitle: Text(
                  l10n.monetaryValueDescription,
                ),
                value: _isMonetary,
                activeColor: Colors.green, // Color sugerente para dinero
                onChanged: (bool newValue) {
                  setState(() {
                    _isMonetary = newValue;
                  });
                  _notifyUpdate();
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

            // 6. Selección de Lista de Datos (Condicional para tipo 'Desplegable')
            if (_selectedType == CustomFieldType.dropdown) ...[
              const SizedBox(height: 16),
              const Divider(),
              if (availableLists.isEmpty)
                Text(
                  l10n.noDataListsAvailable,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  value: _selectedListDataId,
                  decoration: InputDecoration(
                    labelText: l10n.selectDataList,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  hint: Text(l10n.chooseList),
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
