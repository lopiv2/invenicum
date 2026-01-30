import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../models/list_data.dart';
import '../models/asset_type_model.dart';
import '../models/custom_field_definition.dart';
import '../models/custom_field_definition_model.dart';
import '../providers/container_provider.dart';
import '../services/toast_service.dart';
import '../widgets/custom_field_editor.dart';
import '../config/environment.dart';

class AssetTypeEditScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;

  const AssetTypeEditScreen({
    super.key,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  State<AssetTypeEditScreen> createState() => _AssetTypeEditScreenState();
}

class _AssetTypeEditScreenState extends State<AssetTypeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  AssetType? _currentAssetType;
  List<CustomFieldDefinition> _fieldDefinitions = [];
  List<ListData> _availableDataLists = [];
  bool _isLoading = true;

  // Estado para la imagen
  String? _imagePreviewUrl;
  bool _imageWasRemoved =
      false; // Bandera para indicar que la imagen existente debe eliminarse
  bool _isNewImageBase64 =
      false; // Bandera para saber si la URL es Base64 (nueva) o remota (existente)

  @override
  void initState() {
    super.initState();
    // 🎯 Iniciamos la carga de datos del tipo de activo existente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  /// 🔑 CARGA INICIAL: Busca el AssetType y carga sus datos para edición.
  void _loadInitialData() {
    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.tryParse(widget.containerId);
    final assetTypeIdInt = int.tryParse(widget.assetTypeId);

    if (containerIdInt == null || assetTypeIdInt == null) {
      ToastService.error('ID de contenedor o tipo de activo inválido.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final container = containerProvider.containers.firstWhere(
        (c) => c.id == containerIdInt,
        orElse: () => throw Exception("Container not found"),
      );

      final assetType = container.assetTypes.firstWhere(
        (at) => at.id == assetTypeIdInt,
        orElse: () => throw Exception("AssetType not found"),
      );

      // 🔑 Establecer estados iniciales con los datos existentes
      _nameController.text = assetType.name;
      // Clonar la lista de definiciones de campo para que las ediciones no afecten el modelo directamente
      _fieldDefinitions = List.from(assetType.fieldDefinitions);
      _availableDataLists = container.dataLists;
      _currentAssetType = assetType;

      // Cargar la imagen existente si la hay
      if (assetType.images.isNotEmpty) {
        // Usamos la URL completa. La bandera _isNewImageBase64 permanece en false.
        _imagePreviewUrl = '${Environment.apiUrl}${assetType.images.first.url}';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ToastService.error('Error al cargar datos iniciales: ${e.toString()}');
      setState(() => _isLoading = false);
    }
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
          _isNewImageBase64 = true; // Es una imagen nueva
          _imageWasRemoved =
              false; // Si se carga una nueva, no eliminamos la anterior
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
      _isNewImageBase64 = false; // Ya no hay imagen Base64

      // Si el AssetType ya tenía una imagen, marcamos para eliminación
      if (_currentAssetType?.images.isNotEmpty ?? false) {
        _imageWasRemoved = true;
      }
    });
    ToastService.info('Imagen removida');
  }

  void _addNewField() {
    setState(() {
      _fieldDefinitions.add(
        CustomFieldDefinition(
          id: 0,
          name: '',
          type: CustomFieldType.text,
          isRequired: false,
          isSummable: false,
          isCountable: false,
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      _fieldDefinitions.removeAt(index);
    });
  }

  /// 🔑 GUARDA LA EDICIÓN: Llama a updateAssetType en el provider.
  void _saveAssetType() async {
    if (!_formKey.currentState!.validate() || _currentAssetType == null) return;

    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.tryParse(widget.containerId);
    final assetTypeIdInt = int.tryParse(widget.assetTypeId);

    if (containerIdInt == null || assetTypeIdInt == null) return;

    final updatedTypeName = _nameController.text;

    // Lógica de la imagen para la API
    Uint8List? newImageBytes;
    String? newImageName;

    if (_isNewImageBase64 && _imagePreviewUrl != null) {
      final parts = _imagePreviewUrl!.split(',');
      if (parts.length > 1) {
        newImageBytes = base64Decode(parts[1]);
        // Intentar obtener la extensión, por defecto 'jpeg'
        final mimeType =
            RegExp(r'data:image/([^;]+);').firstMatch(parts[0])?.group(1) ??
            'jpeg';
        newImageName = 'asset_type_image.$mimeType';
      }
    }

    try {
      await containerProvider.updateAssetType(
        containerId: containerIdInt,
        assetTypeId: assetTypeIdInt,
        name: updatedTypeName,
        fieldDefinitions: _fieldDefinitions,

        // Parámetros de imagen
        imageBytes: newImageBytes,
        imageName: newImageName,
        // Solo eliminamos la imagen si:
        // 1. La bandera de remoción está activa, Y
        // 2. No estamos subiendo una nueva imagen.
        removeExistingImage: _imageWasRemoved && !_isNewImageBase64,
      );

      if (context.mounted) {
        ToastService.success(
          'Tipo de Activo "${updatedTypeName}" actualizado exitosamente.',
        );
        // Volver a la vista de grid
        context.go('/container/${widget.containerId}/asset-types');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.error(
          'Error al actualizar el Tipo de Activo: ${e.toString()}',
          5,
        );
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // 🔑 Título de Edición
              'Editar Tipo de Activo: "${_currentAssetType?.name ?? 'Cargando...'}"',
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
                          child: _isNewImageBase64
                              ? Image.memory(
                                  // Nueva imagen (Base64)
                                  base64Decode(_imagePreviewUrl!.split(',')[1]),
                                  fit: BoxFit.contain,
                                  height: 180,
                                )
                              : Image.network(
                                  // Imagen existente (URL remota)
                                  _imagePreviewUrl!,
                                  fit: BoxFit.contain,
                                  height: 180,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
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

            ListView.builder(
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
                        // Nos aseguramos de PRESERVAR el ID que ya tenía este campo en la lista
                        _fieldDefinitions[index] = updatedField.copyWith(
                          id: _fieldDefinitions[index].id,
                        );
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

            // --- Botón de Guardar ---
            ElevatedButton.icon(
              onPressed: _saveAssetType,
              icon: const Icon(Icons.save),
              label: const Text(
                'Actualizar Tipo de Activo', // 🔑 Texto cambiado
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
