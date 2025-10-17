import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/utils/asset_form_utils.dart';
import 'package:invenicum/widgets/image_preview_section.dart';
import 'package:provider/provider.dart';

import '../models/asset_type_model.dart';
import '../models/container_node.dart';
import '../models/inventory_item.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';
import '../services/toast_service.dart';
// Importamos el nuevo widget separado

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

  // Mapa para los controladores de campos custom
  final Map<int, TextEditingController> _customControllers = {};
  final Map<int, List<String>> _listFieldValues =
      {}; // Valores de las listas desplegables
  final Map<int, String?> _selectedListValues = {}; // Valores seleccionados

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
        status: '',
      ),
    );

    final assetType = container.assetTypes.firstWhere(
      (at) => at.id == _assetTypeId,
      orElse: () => AssetType(id: -1, name: '', fieldDefinitions: []),
    );

    setState(() {
      _assetType = assetType;
      // Inicializa los controladores para cada campo custom
      for (var field in assetType.fieldDefinitions) {
        _customControllers[field.id!] = TextEditingController();
        if (field.type == CustomFieldType.dropdown &&
            field.dataListId != null) {
          _loadListValues(field.dataListId!, field.id!);
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

  // --- LÓGICA DE GESTIÓN DE IMÁGENES (Subida de Archivo) ---

  /// Muestra el selector de archivos y obtiene la URL Base64 para previsualización.
  Future<void> _addImage() async {
    // Configuración de File Picker: permite múltiples imágenes y carga los datos.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    // Verificamos si se seleccionaron archivos.
    if (result != null && result.files.isNotEmpty) {
      // Lista temporal para almacenar las URLs Base64 de las nuevas imágenes.
      final List<String> newImageUrls = [];
      int successfulSelections = 0;

      // 1. ITERAR sobre CADA archivo seleccionado
      for (final file in result.files) {
        // Verificamos si los bytes del archivo se cargaron correctamente.
        if (file.bytes != null) {
          // Obtenemos la extensión o usamos 'jpeg' como fallback
          final extension = file.extension ?? 'jpeg';

          // Generamos la URL Base64 para previsualización instantánea.
          final String base64Image =
              'data:image/$extension;base64,${base64Encode(file.bytes!)}';

          newImageUrls.add(base64Image);
          successfulSelections++;
        }
      }

      // 2. Actualizar el estado (una sola vez para todas las nuevas imágenes)
      if (newImageUrls.isNotEmpty) {
        setState(() {
          _imagePreviewUrls.addAll(newImageUrls);
        });

        ToastService.info('Se seleccionaron $successfulSelections imágenes.');
      } else {
        // Si se seleccionaron archivos pero todos fallaron al cargar los bytes
        ToastService.error(
          'Error: No se pudo obtener la data de las imágenes seleccionadas.',
        );
      }
    } else {
      // El usuario canceló la selección.
      ToastService.info('Selección de archivos cancelada.');
    }
  }

  void _removeImage(String url) {
    setState(() {
      _imagePreviewUrls.remove(url);
    });
  }

  Future<void> _saveAsset() async {
    if (!AssetFormUtils.validateForm(_formKey) || _assetType == null) {
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();

    // 1. Recoger los valores custom
    final Map<String, dynamic> customFieldValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      if (fieldDef.type == CustomFieldType.dropdown) {
        final selectedValue = _selectedListValues[fieldDef.id];
        if (selectedValue != null) {
          customFieldValues[fieldDef.id.toString()] = selectedValue;
        }
      } else {
        final controller = _customControllers[fieldDef.id];
        if (controller != null && controller.text.isNotEmpty) {
          customFieldValues[fieldDef.id.toString()] = controller.text;
        }
      }
    }

    // 2. Preparar los datos de los archivos
    final filesData = AssetFormUtils.processImages(_imagePreviewUrls);

    // 3. Crear el nuevo objeto InventoryItem
    final newItem = InventoryItem(
      id: 0,
      containerId: _containerId!,
      assetTypeId: _assetTypeId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      customFieldValues: customFieldValues,
    );

    // 4. Llamar al proveedor para guardar con los archivos
    try {
      await itemProvider.createInventoryItem(newItem, filesData: filesData);

      // 5. Navegar de vuelta al listado
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

  // --- WIDGETS DE VISTA ---

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
    // ... (Inicialización y estado de carga) ...
    if (_assetType == null) {
      context.watch<ContainerProvider>();
      if (_containerId == null || _assetTypeId == null) {
        return const Center(child: Text('IDs no válidos.'));
      }
      _initializeForm();
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TÍTULO ---
            Text(
              'Crear Activo: ${_assetType!.name}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CAMPOS COMUNES ---
                    const Text(
                      'Datos Comunes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
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

                    // --- SECCIÓN DE IMÁGENES (Widget Separado) ---
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
    );
  }
}
