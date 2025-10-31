import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/location.dart';
import 'package:invenicum/utils/asset_form_utils.dart';
import 'package:invenicum/widgets/image_preview_section.dart';
import 'package:invenicum/widgets/location_dropdown_widget.dart';
import 'package:provider/provider.dart';

import '../models/asset_type_model.dart';
import '../models/container_node.dart';
import '../models/inventory_item.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';
import '../services/toast_service.dart';

class AssetCreateScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;

  const AssetCreateScreen({
    super.key,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  State<AssetCreateScreen> createState() => _AssetCreateScreenState();
}

class _AssetCreateScreenState extends State<AssetCreateScreen> {
  // Controles para los campos comunes
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 🔑 ESTADO DE UBICACIÓN
  List<Location> _availableLocations = []; // Lista de ubicaciones disponibles
  int? _selectedLocationId; // ID de la ubicación seleccionada

  // Mapa para los controladores de campos custom
  final Map<int, TextEditingController> _customControllers = {};
  final Map<int, List<String>> _listFieldValues =
      {}; // Valores de las listas desplegables
  final Map<int, String?> _selectedListValues = {}; // Valores seleccionados

  final Map<int, bool> _booleanFieldValues = {};

  // Estado para gestionar las URLs de previsualización (Base64)
  List<String> _imagePreviewUrls = [];

  AssetType? _assetType;
  int? _containerId;
  int? _assetTypeId;

  @override
  void initState() {
    super.initState();
    _containerId = int.tryParse(widget.containerId);
    _assetTypeId = int.tryParse(widget.assetTypeId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    if (_containerId == null || _assetTypeId == null) return;

    final containerProvider = context.read<ContainerProvider>();
    final container = containerProvider.containers.firstWhere(
      (c) => c.id == _containerId,
      orElse: () => ContainerNode(
        id: -1,
        name: '',
        description: '',
        assetTypes: [],
        dataLists: [],
        locations: [], // Asegurarse de que el orElse maneje Locations
        status: '',
      ),
    );

    final assetType = container.assetTypes.firstWhere(
      (at) => at.id == _assetTypeId,
      orElse: () => AssetType(id: -1, name: '', fieldDefinitions: []),
    );

    setState(() {
      _assetType = assetType;
      // 🔑 CARGAR UBICACIONES
      _availableLocations = container.locations;
      // 🔑 Inicializar la ubicación seleccionada (opcionalmente a la primera o null)
      _selectedLocationId = _availableLocations.isNotEmpty
          ? _availableLocations.first.id
          : null;

      // Inicializa los controladores para cada campo custom
      for (var field in assetType.fieldDefinitions) {
        if (field.type == CustomFieldType.dropdown &&
            field.dataListId != null) {
          _loadListValues(field.dataListId!, field.id!);
        } else if (field.type == CustomFieldType.boolean) {
          _booleanFieldValues[field.id!] = false;
        } else {
          _customControllers[field.id!] = TextEditingController();
        }
      }
    });
  }

  Future<void> _loadListValues(int dataListId, int fieldId) async {
    try {
      final containerProvider = context.read<ContainerProvider>();
      final listData = await containerProvider.getDataList(dataListId);

      if (mounted) {
        setState(() {
          _listFieldValues[fieldId] = listData.items;
          _selectedListValues[fieldId] = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al cargar los valores de la lista: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // --- LÓGICA DE GESTIÓN DE IMÁGENES ---

  Future<void> _addImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final List<String> newImageUrls = [];
      int successfulSelections = 0;

      for (final file in result.files) {
        if (file.bytes != null) {
          final extension = file.extension ?? 'jpeg';

          final String base64Image =
              'data:image/$extension;base64,${base64Encode(file.bytes!)}';

          newImageUrls.add(base64Image);
          successfulSelections++;
        }
      }

      if (newImageUrls.isNotEmpty) {
        setState(() {
          _imagePreviewUrls.addAll(newImageUrls);
        });

        ToastService.info('Se seleccionaron $successfulSelections imágenes.');
      } else {
        ToastService.error(
          'Error: No se pudo obtener la data de las imágenes seleccionadas.',
        );
      }
    } else {
      ToastService.info('Selección de archivos cancelada.');
    }
  }

  void _removeImage(String url) {
    setState(() {
      _imagePreviewUrls.remove(url);
    });
  }

  Future<void> _saveAsset() async {
    // 🔑 1. VALIDACIÓN ADICIONAL DE UBICACIÓN
    if (!AssetFormUtils.validateForm(_formKey) ||
        _assetType == null ||
        _selectedLocationId ==
            null // 🔑 Debe haber una ubicación seleccionada
            ) {
      if (_selectedLocationId == null) {
        if (mounted) {
          ToastService.error('Debe seleccionar una ubicación para el activo.');
        }
      }
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();

    // 2. Recoger los valores custom (sin cambios)
    final Map<String, dynamic> customFieldValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      if (fieldDef.type == CustomFieldType.dropdown) {
        final selectedValue = _selectedListValues[fieldDef.id];
        if (selectedValue != null) {
          customFieldValues[fieldDef.id.toString()] = selectedValue;
        }
      } else if (fieldDef.type == CustomFieldType.boolean) {
        final value = _booleanFieldValues[fieldDef.id];
        if (value != null) {
          customFieldValues[fieldDef.id.toString()] = value;
        }
      } else {
        final controller = _customControllers[fieldDef.id];
        if (controller != null && controller.text.isNotEmpty) {
          customFieldValues[fieldDef.id.toString()] = controller.text;
        }
      }
    }

    // 3. Preparar los datos de los archivos
    final filesData = AssetFormUtils.processImages(_imagePreviewUrls);

    // 4. Crear el nuevo objeto InventoryItem
    final newItem = InventoryItem(
      id: 0,
      containerId: _containerId!,
      assetTypeId: _assetTypeId!,
      locationId: _selectedLocationId!, // 🔑 AÑADIDO: locationId
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      customFieldValues: customFieldValues,
      // images es null por defecto en creación
    );

    // 5. Llamar al proveedor para guardar con los archivos
    try {
      await itemProvider.createInventoryItem(newItem, filesData: filesData);

      // 6. Navegar de vuelta al listado
      if (mounted) {
        ToastService.success('Activo creado con éxito!');
        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al crear activo: ${e.toString()}');
      }
    }
  }

  // --- WIDGETS DE VISTA (buildCustomFields sin cambios) ---

  Widget _buildCustomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campos Personalizados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        if (_assetType!.fieldDefinitions.isEmpty)
          const Text('Este tipo de activo no tiene campos personalizados.'),

        ..._assetType!.fieldDefinitions.map((fieldDef) {
          if (fieldDef.type == CustomFieldType.boolean) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CheckboxListTile(
                title: Text(fieldDef.name),
                subtitle: fieldDef.isRequired
                    ? const Text('Obligatorio')
                    : null,
                value: _booleanFieldValues[fieldDef.id] ?? false,
                onChanged: (bool? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _booleanFieldValues[fieldDef.id!] = newValue;
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          }
          if (fieldDef.type == CustomFieldType.dropdown) {
            final values = _listFieldValues[fieldDef.id] ?? [];
            final selectedValue = _selectedListValues[fieldDef.id];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  labelText: fieldDef.name,
                  border: const OutlineInputBorder(),
                  helperText: fieldDef.isRequired ? 'Obligatorio' : null,
                ),
                items: values.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedListValues[fieldDef.id!] = newValue;
                  });
                },
                validator: (value) {
                  if (fieldDef.isRequired && value == null) {
                    return 'Este campo es obligatorio.';
                  }
                  return null;
                },
              ),
            );
          }

          final controller = _customControllers[fieldDef.id];
          if (controller == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: controller,
              keyboardType: fieldDef.type.keyboardType,
              inputFormatters: AssetFormUtils.getInputFormatters(fieldDef.type),
              decoration: InputDecoration(
                labelText: fieldDef.name,
                hintText: AssetFormUtils.getHintText(fieldDef.type),
                border: const OutlineInputBorder(),
                helperText: fieldDef.isRequired ? 'Obligatorio' : null,
              ),
              validator: (value) {
                if (fieldDef.isRequired && (value == null || value.isEmpty)) {
                  return 'Este campo es obligatorio.';
                }
                return fieldDef.type.validateValue(value);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar al proveedor para reconstrucción en caso de recarga de datos
    context.watch<ContainerProvider>();

    if (_assetType == null || _containerId == null || _assetTypeId == null) {
      // Intenta inicializar de nuevo si el assetType es nulo (puede ser la primera carga)
      if (_assetType == null) {
        _initializeForm();
      }
      return Scaffold(
        appBar: AppBar(title: Text('Crear Activo')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔑 Se envuelve la vista en un Scaffold para ser una pantalla completa
    return Scaffold(
      appBar: AppBar(title: Text('Crear Activo: ${_assetType!.name}')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- TÍTULO ---
                      Text(
                        'Crear Activo: ${_assetType!.name}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),

                      // --- CAMPOS COMUNES ---
                      const Text(
                        'Datos Comunes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),

                      // 🔑 NUEVO: Selector de Ubicación
                      LocationDropdownField(
                        availableLocations: _availableLocations,
                        selectedLocationId: _selectedLocationId,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocationId = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Activo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor introduce un nombre.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),

                      // --- SECCIÓN DE IMÁGENES ---
                      ImagePreviewSection(
                        imageUrls: _imagePreviewUrls,
                        onAddImage: _addImage,
                        onRemoveImage: _removeImage,
                      ),
                      const SizedBox(height: 30),

                      // --- CAMPOS CUSTOM (Dinámicos) ---
                      _buildCustomFields(),
                    ],
                  ),
                ),
              ),

              // --- BOTÓN DE GUARDAR ---
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _saveAsset,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar Activo',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
