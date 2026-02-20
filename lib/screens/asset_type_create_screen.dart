// lib/screens/asset_type_create_screen.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/widgets/custom_field_editor.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/list_data.dart';
import '../providers/container_provider.dart';

class AssetTypeCreateScreen extends StatefulWidget {
  final String containerId;

  const AssetTypeCreateScreen({super.key, required this.containerId});

  @override
  State<AssetTypeCreateScreen> createState() => _AssetTypeCreateScreenState();
}

class _AssetTypeCreateScreenState extends State<AssetTypeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  List<CustomFieldDefinition> _fieldDefinitions = [];
  List<ListData> _availableDataLists = [];
  bool _isLoadingLists = true;

  // Estado para la imagen
  String? _imagePreviewUrl;

  // Estado para tipo seriado/no seriado
  bool _isSerialized = true;

  @override
  void initState() {
    super.initState();
    _loadDataLists();
  }

  /// Muestra el selector de archivos y obtiene la URL Base64 para previsualización
  Future<void> _addImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        final extension = file.extension ?? 'jpeg';
        final String base64Image =
            'data:image/$extension;base64,${base64Encode(file.bytes!)}';

        setState(() {
          _imagePreviewUrl = base64Image;
        });
        ToastService.info('Imagen seleccionada');
      } else {
        ToastService.error(
          'Error: No se pudo obtener la data de la imagen seleccionada.',
        );
      }
    } else {
      ToastService.info('Selección de archivo cancelada.');
    }
  }

  void _removeImage() {
    setState(() {
      _imagePreviewUrl = null;
    });
    ToastService.info('Imagen removida');
  }

  // Carga las listas de datos disponibles del contenedor
  void _loadDataLists() {
    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.tryParse(widget.containerId);

    if (containerIdInt != null) {
      final container = containerProvider.containers.firstWhere(
        (c) => c.id == containerIdInt,
        orElse: () => throw Exception("Container not found"),
      );
      setState(() {
        _availableDataLists = container.dataLists;
        _isLoadingLists = false;
      });
    } else {
      setState(() {
        _isLoadingLists = false;
      });
    }
  }

  void _addNewField() {
    setState(() {
      _fieldDefinitions.add(
        CustomFieldDefinition(
          id: 0,
          name: '', // Iniciamos con nombre vacío
          type: CustomFieldType.text,
          isRequired: false,
          // 🔑 Inicialización de los nuevos campos
          isSummable: false,
          isCountable: false,
          isMonetary: false,
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      _fieldDefinitions.removeAt(index);
    });
  }

  void _saveAssetType() async {
    if (_formKey.currentState!.validate()) {
      final containerProvider = context.read<ContainerProvider>();
      final containerIdInt = int.tryParse(widget.containerId);
      if (containerIdInt == null) return;

      final newTypeName = _nameController.text;

      // Procesar la imagen si existe
      Uint8List? imageBytes;
      String? imageName;

      if (_imagePreviewUrl != null) {
        final parts = _imagePreviewUrl!.split(',');
        if (parts.length > 1) {
          imageBytes = base64Decode(parts[1]);
          // Obtener la extensión del tipo MIME
          final mimeType =
              RegExp(r'data:image/([^;]+);').firstMatch(parts[0])?.group(1) ??
              'jpeg';
          imageName = 'asset_type_image.$mimeType';
        }
      }

      try {
        await containerProvider.addNewAssetTypeToContainer(
          containerId: containerIdInt,
          name: newTypeName,
          fieldDefinitions: _fieldDefinitions,
          imageBytes: imageBytes,
          imageName: imageName,
          isSerialized: _isSerialized,
        );

        if (context.mounted) {
          ToastService.success(
            'Tipo de Activo "${newTypeName}" creado exitosamente en el servidor.',
          );
          context.go('/container/${widget.containerId}/asset-types');
        }
      } catch (e) {
        if (context.mounted) {
          ToastService.error(
            'Error al crear el Tipo de Activo: ${e.toString()}',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🎨 Tu tema personalizado
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Nuevo Tipo de Activo',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- Campo de Nombre ---
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Tipo de Activo',
                hintText: 'Ej: Ordenador Portátil, Sustancia Química',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // --- Checkbox para Tipo de Activo (Seriado/No Seriado) ---
            Card(
              color: theme.secondaryHeaderColor,
              child: CheckboxListTile(
                value: _isSerialized,
                onChanged: (value) {
                  setState(() {
                    _isSerialized = value ?? true;
                  });
                },
                // Usamos el título para poner el texto y el icono de ayuda
                title: Row(
                  children: [
                    const Text('¿Es un artículo seriado?'),
                    const SizedBox(width: 8),
                    Tooltip(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      showDuration: const Duration(
                        seconds: 5,
                      ), // Duración en móvil tras pulsar
                      triggerMode: TooltipTriggerMode
                          .longPress, // En móvil se activa con pulsación larga
                      message:
                          'Los artículos seriados tienen cantidad fija de 1 (ej: número de serie).\n\n'
                          'Los no seriados pueden tener cantidades variables (ej: consumibles), '
                          'y añaden campos de "Cantidad" y "Stock Mínimo" en la creación de elementos.',
                      child: Icon(
                        Icons.help_outline,
                        size: 18,
                        color: theme.primaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  _isSerialized
                      ? 'Cantidad fija (1 unidad).'
                      : 'Cantidad variable y control de stock.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Sección de Imagen ---
            Text(
              'Imagen del Tipo de Activo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imagePreviewUrl != null
                  ? Stack(
                      children: [
                        Center(
                          child: Image.memory(
                            base64Decode(_imagePreviewUrl!.split(',')[1]),
                            fit: BoxFit.contain,
                            height: 180,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _removeImage,
                            color: Colors.red,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Seleccionar Imagen'),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 30),

            // --- Editor de Campos Dinámicos ---
            Text(
              'Definición de Campos Personalizados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),

            _isLoadingLists
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _fieldDefinitions.length,
                    itemBuilder: (context, index) {
                      final field = _fieldDefinitions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CustomFieldEditor(
                          field: field,
                          availableDataLists: _availableDataLists,
                          onDelete: () => _removeField(index),
                          onUpdate: (updatedField) {
                            setState(() {
                              _fieldDefinitions[index] = updatedField;
                            });
                          },
                        ),
                      );
                    },
                  ),

            TextButton.icon(
              onPressed: _addNewField,
              icon: const Icon(Icons.add_box),
              label: const Text('Añadir Nuevo Campo'),
            ),
            const SizedBox(height: 40),

            // --- Botones de Guardar y Cancelar ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveAssetType,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Crear Tipo de Activo',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
