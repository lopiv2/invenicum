import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/utils/asset_form_utils.dart';
import 'package:invenicum/widgets/location_dropdown_widget.dart';
import 'package:provider/provider.dart';
import '../models/asset_type_model.dart';
import '../models/container_node.dart';
import '../models/inventory_item.dart';
import '../models/location.dart'; // 🔑 NUEVO: Importar modelo Location
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';
import '../services/toast_service.dart';
import 'package:invenicum/widgets/image_preview_section.dart'; // Tu widget de previsualización

class AssetEditScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;
  final String assetItemId;
  final InventoryItem? initialItem;

  const AssetEditScreen({
    super.key,
    required this.containerId,
    required this.assetTypeId,
    required this.assetItemId,
    this.initialItem,
  });

  @override
  State<AssetEditScreen> createState() => _AssetEditScreenState();
}

class _AssetEditScreenState extends State<AssetEditScreen> {
  // Clave global para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // 1. Controllers para campos fijos
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  // 🔑 ESTADO PARA UBICACIÓN
  List<Location> _availableLocations = [];
  int? _selectedLocationId;

  // 2. Mapa de controllers para campos dinámicos
  late Map<int, TextEditingController> _dynamicControllers;

  // 🔑 ESTADO PARA CAMPOS DROPDOWN
  final Map<int, List<String>> _listFieldValues = {};
  final Map<int, String?> _selectedListValues = {};

  // 🔑 ESTADO PARA CAMPOS BOOLEANOS (Checkbox)
  final Map<int, bool?> _booleanValues = {};

  // Estado del modelo
  AssetType? _assetType;

  // 🚀 ESTADO PARA GESTIÓN DE IMÁGENES
  late List<InventoryItemImage> _currentImages;
  List<String> _newImagePreviewUrls = [];
  List<int> _imageIdsToDelete = [];

  Future<void> _loadListValues(int dataListId, int fieldId) async {
    try {
      final containerProvider = context.read<ContainerProvider>();
      final listData = await containerProvider.getDataList(dataListId);

      if (mounted) {
        setState(() {
          _listFieldValues[fieldId] = listData.items;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al cargar los valores de la lista: $e');
      }
    }
  }

  // ------------------------------------

  // 🚀 GETTER UNIFICADO PARA EL WIDGET ImagePreviewSection
  List<String> get _allImageUrls {
    // 1. Mapeamos las imágenes existentes, AÑADIENDO el prefijo de la API
    final existingUrls = _currentImages.map((img) {
      final String apiUrl = Environment.apiUrl;
      // Añadimos el prefijo solo si no es una URL completa
      return img.url.startsWith('http') ? img.url : '$apiUrl${img.url}';
    }).toList();

    // 2. Concatenamos las URLs de red completas con las Data URLs Base64 (que ya están completas)
    return [...existingUrls, ..._newImagePreviewUrls];
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialItem?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialItem?.description ?? '',
    );
    _dynamicControllers = {};

    // 🔑 Inicializar estado de ubicación con el valor del item inicial
    _selectedLocationId = widget.initialItem?.locationId;

    // 🚀 Inicializar el estado de imágenes existentes haciendo una copia
    _currentImages = List.from(widget.initialItem?.images ?? []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_assetType == null) {
      _initializeDynamicFields();
    }
  }

  void _initializeDynamicFields() {
    final containerProvider = context.read<ContainerProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) return;

    final container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

    final assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
      (at) => at?.id == atIdInt,
      orElse: () => null,
    );

    if (assetType != null && container != null) {
      // 🔑 Check para 'container'
      setState(() {
        _assetType = assetType;

        // 🔑 Cargar ubicaciones disponibles del contenedor
        _availableLocations = container.locations;

        for (var fieldDef in assetType.fieldDefinitions) {
          final fieldId = fieldDef.id ?? 0;
          final initialValue =
              widget.initialItem?.customFieldValues?[fieldId.toString()];

          if (fieldDef.type == CustomFieldType.dropdown) {
            _selectedListValues[fieldId] = initialValue;

            if (fieldDef.dataListId != null) {
              _loadListValues(fieldDef.dataListId!, fieldId);
            }
          } else if (fieldDef.type == CustomFieldType.boolean) {
            bool? value = AssetFormUtils.toBoolean(initialValue);
            _booleanValues[fieldId] = value;
          } else {
            _dynamicControllers[fieldId] = TextEditingController(
              text: initialValue?.toString() ?? '',
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dynamicControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // ----------------------------------------------------
  // LÓGICA DE GESTIÓN DE IMÁGENES (No se requiere cambiar)
  // ----------------------------------------------------

  Future<void> _addNewImages() async {
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
          _newImagePreviewUrls.addAll(newImageUrls);
        });

        ToastService.info(
          'Se seleccionaron $successfulSelections nuevas imágenes.',
        );
      }
    } else {
      ToastService.info('Selección de archivos cancelada.');
    }
  }

  void _deleteExistingImage(InventoryItemImage image) {
    setState(() {
      _currentImages.removeWhere((img) => img.id == image.id);
      _imageIdsToDelete.add(image.id);
    });
    ToastService.info('Imagen existente marcada para eliminación al guardar.');
  }

  void _removeNewImage(String url) {
    setState(() {
      _newImagePreviewUrls.remove(url);
    });
    ToastService.info('Archivo nuevo removido de la lista de subida.');
  }

  void _handleRemoveImage(String url) {
    if (url.startsWith('data:')) {
      _removeNewImage(url);
    } else {
      final String apiUrl = Environment.apiUrl;
      final String relativeUrl = url.replaceAll(apiUrl, '');

      final existingImage = _currentImages.firstWhere(
        (img) => img.url == relativeUrl,
        orElse: () => InventoryItemImage(id: -1, url: '', order: 0),
      );

      if (existingImage.id != -1) {
        _deleteExistingImage(existingImage);
      } else {
        ToastService.error(
          'Error interno: No se pudo identificar la imagen para eliminar.',
        );
      }
    }
  }

  Map<String, dynamic> _dataUrlToFileData(String dataUrl, int index) {
    final mimeTypeMatch = RegExp(r'data:([^;]+);base64,').firstMatch(dataUrl);
    final mimeType = mimeTypeMatch?.group(1);

    final base64String = dataUrl.split(',').last;
    final Uint8List bytes = base64Decode(base64String);

    final extension = mimeType?.split('/').last ?? 'jpg';
    final fileName = 'asset_new_image_$index.$extension';

    return {'bytes': bytes, 'name': fileName};
  }

  // --- LÓGICA DE GUARDADO ---
  Future<void> _saveAsset() async {
    // 0. Validaciones iniciales
    if (!AssetFormUtils.validateForm(_formKey) ||
        widget.initialItem == null ||
        _assetType == null ||
        _selectedLocationId ==
            null // 🔑 NUEVO: Validar ubicación
            ) {
      if (_selectedLocationId == null) {
        if (mounted) {
          ToastService.error('Debe seleccionar una ubicación para el activo.');
        }
      }
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);
    final assetItemIdInt = int.tryParse(widget.assetItemId);

    if (cIdInt == null || atIdInt == null || assetItemIdInt == null) {
      if (mounted) {
        ToastService.error('Error: IDs de navegación no válidos.');
      }
      return;
    }

    // 1. Recoger los valores custom ACTUALIZADOS (Lógica sin cambios)
    final Map<String, dynamic> updatedCustomValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      final fieldId = fieldDef.id!;

      if (fieldDef.type == CustomFieldType.dropdown) {
        final selectedValue = _selectedListValues[fieldId];
        if (selectedValue != null) {
          updatedCustomValues[fieldId.toString()] = selectedValue;
        } else if (fieldDef.isRequired) {
          if (mounted) {
            ToastService.error('El campo "${fieldDef.name}" es obligatorio.');
          }
          return;
        }
      } else if (fieldDef.type == CustomFieldType.boolean) {
        final boolValue = _booleanValues[fieldId];

        if (fieldDef.isRequired && boolValue == null) {
          if (mounted) {
            ToastService.error('El campo "${fieldDef.name}" es obligatorio.');
          }
          return;
        }

        if (boolValue != null) {
          updatedCustomValues[fieldId.toString()] = boolValue;
        }
      } else {
        final controller = _dynamicControllers[fieldId];
        if (controller != null && controller.text.isNotEmpty) {
          updatedCustomValues[fieldId.toString()] = controller.text;
        } else if (fieldDef.isRequired) {
          if (mounted) {
            ToastService.error('El campo "${fieldDef.name}" es obligatorio.');
          }
          return;
        }
      }
    }

    // 2. Preparar los datos de los archivos NUEVOS
    final List<Map<String, dynamic>> filesData = [];
    for (int i = 0; i < _newImagePreviewUrls.length; i++) {
      filesData.add(_dataUrlToFileData(_newImagePreviewUrls[i], i));
    }

    // 3. Crear el objeto InventoryItem actualizado
    final updatedItem = InventoryItem(
      id: assetItemIdInt,
      containerId: cIdInt,
      assetTypeId: atIdInt,
      // 🔑 MODIFICADO: Añadir la ubicación seleccionada
      locationId: _selectedLocationId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      customFieldValues: updatedCustomValues,
      images: _currentImages,
    );

    // 4. Llamar al proveedor para actualizar el activo con archivos/eliminaciones
    try {
      await itemProvider.updateAssetWithFiles(
        updatedItem,
        filesToUpload: filesData,
        imageIdsToDelete: _imageIdsToDelete,
      );

      // 5. Navegar de vuelta (al listado)
      if (mounted) {
        ToastService.success(
          'Activo "${updatedItem.name}" actualizado correctamente.',
        );

        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      // 6. Manejo de errores
      if (mounted) {
        ToastService.error('Error al actualizar activo: ${e.toString()}');
      }
    }
  }

  // ----------------------------------------------------
  // WIDGETS AUXILIARES PARA LA UI (Sin cambios en custom fields)
  // ----------------------------------------------------

  Widget _buildCustomFields() {
    if (_assetType == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campos Personalizados de ${_assetType!.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(height: 20),
        if (_assetType!.fieldDefinitions.isEmpty)
          const Text('Este tipo de activo no tiene campos personalizados.'),

        ..._assetType!.fieldDefinitions.map((fieldDef) {
          final fieldId = fieldDef.id!;

          // 🔑 1. Campo DROPDOWN
          if (fieldDef.type == CustomFieldType.dropdown) {
            final values = _listFieldValues[fieldId];
            final selectedValue = _selectedListValues[fieldId];

            if (values == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 10),
                    Text('Cargando ${fieldDef.name}...'),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  labelText: fieldDef.name,
                  border: const OutlineInputBorder(),
                  helperText: fieldDef.isRequired ? 'Obligatorio' : 'Opcional',
                ),
                items: values.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedListValues[fieldId] = newValue;
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

          // 🔑 2. Campo BOOLEANO
          if (fieldDef.type == CustomFieldType.boolean) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormField<bool>(
                initialValue: _booleanValues[fieldId],
                validator: (value) {
                  if (fieldDef.isRequired && value == null) {
                    return 'Este campo es obligatorio.';
                  }
                  return null;
                },
                builder: (FormFieldState<bool> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      helperText: fieldDef.isRequired
                          ? 'Obligatorio'
                          : 'Opcional',
                      errorText: state.errorText,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: CheckboxListTile(
                      title: Text(fieldDef.name),
                      value: state.value ?? false,
                      onChanged: (newValue) {
                        setState(() {
                          _booleanValues[fieldId] = newValue;
                          state.didChange(newValue);
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  );
                },
              ),
            );
          }

          // 3. Otros campos (Texto, Número, URL, etc.)
          final controller = _dynamicControllers[fieldDef.id];
          if (controller == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: TextFormField(
              controller: controller,
              keyboardType: fieldDef.type.keyboardType,
              inputFormatters: AssetFormUtils.getInputFormatters(fieldDef.type),
              decoration: InputDecoration(
                labelText: fieldDef.name,
                border: const OutlineInputBorder(),
                helperText: fieldDef.isRequired ? 'Obligatorio' : 'Opcional',
                hintText: AssetFormUtils.getHintText(fieldDef.type),
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

  // ----------------------------------------------------
  // BUILD METHOD PRINCIPAL
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Si _assetType no está cargado o initialItem es null, muestra un indicador de carga.
    // Usamos context.watch para asegurarnos de que el widget se reconstruya si el proveedor cambia.
    context.watch<ContainerProvider>();
    if (widget.initialItem == null || _assetType == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Activo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final assetName = widget.initialItem!.name;

    return Scaffold(
      appBar: AppBar(title: Text('Editar Activo: $assetName')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TÍTULO ---
              Text(
                'Editando Activo: ${widget.initialItem!.name}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // 🔑 NUEVO: Selector de Ubicación
              LocationDropdownField(
                availableLocations: _availableLocations,
                selectedLocationId: _selectedLocationId,
                onChanged: (newValue) {
                  setState(() {
                    _selectedLocationId = newValue;
                  });
                },
                // El validador por defecto ya se encarga de que no sea nulo si es obligatorio (y lo es)
              ),
              const SizedBox(height: 30),

              // --- 1. CAMPOS FIJOS ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Activo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Activo',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // ------------------------------------
              // 🚀 SECCIÓN: GESTIÓN DE IMÁGENES (UNIFICADA)
              // ------------------------------------
              ImagePreviewSection(
                imageUrls: _allImageUrls, // Usa el getter unificado
                onAddImage: _addNewImages, // Añade a _newImagePreviewUrls
                onRemoveImage: _handleRemoveImage, // Maneja la eliminación
              ),
              const SizedBox(height: 40),
              // ------------------------------------

              // --- 2. CAMPOS DINÁMICOS ---
              _buildCustomFields(),

              const SizedBox(height: 40),

              // --- 3. BOTÓN DE GUARDADO ---
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveAsset,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar Cambios',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
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
