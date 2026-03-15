import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/models/list_data.dart';
import '../../data/models/asset_type_model.dart';
import '../../data/models/custom_field_definition.dart';
import '../../data/models/custom_field_definition_model.dart';
import '../../providers/container_provider.dart';
import '../../data/services/toast_service.dart';
import 'local_widgets/asset_type_action_buttons.dart';
import 'local_widgets/asset_type_custom_fields_section.dart';
import 'local_widgets/asset_type_form_title.dart';
import 'local_widgets/asset_type_image_section_extended.dart';
import 'local_widgets/asset_type_name_field.dart';
import '../../config/environment.dart';

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

  /// Construye la URL completa de imagen de forma segura.
  /// Mismo comportamiento que en AssetTypeCard — fuente de verdad única.
  static String _buildImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    final host = Environment.apiUrl.endsWith('/')
        ? Environment.apiUrl.substring(0, Environment.apiUrl.length - 1)
        : Environment.apiUrl;
    if (rawUrl.startsWith('/')) return '$host$rawUrl';
    return '$host/images/$rawUrl'; // registros viejos sin barra inicial
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

      // Cargar la imagen existente si la hay.
      // Usamos _buildImageUrl para manejar de forma segura cualquier formato
      // de URL que pueda venir de la DB (absoluta, relativa con /, sin /).
      if (assetType.images.isNotEmpty) {
        _imagePreviewUrl = _buildImageUrl(assetType.images.first.url);
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
            AssetTypeFormTitle(
              title: 'Editar Tipo de Activo: "${_currentAssetType?.name ?? 'Cargando...'}"',
            ),
            const SizedBox(height: 20),

            // --- Campo de Nombre ---
            AssetTypeNameField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // --- Sección de Imagen (Extendida para edición) ---
            AssetTypeImageSectionExtended(
              imagePreviewUrl: _imagePreviewUrl,
              isNewImageBase64: _isNewImageBase64,
              onAddImage: _addImage,
              onRemoveImage: _removeImage,
            ),
            const SizedBox(height: 30),

            // --- Editor de Campos Dinámicos ---
            AssetTypeCustomFieldsSection(
              fieldDefinitions: _fieldDefinitions,
              availableDataLists: _availableDataLists,
              isLoading: false,
              onAddField: _addNewField,
              onRemoveField: _removeField,
              onUpdateField: (index, updatedField) {
                setState(() {
                  // Nos aseguramos de PRESERVAR el ID que ya tenía este campo en la lista
                  _fieldDefinitions[index] = updatedField.copyWith(
                    id: _fieldDefinitions[index].id,
                  );
                });
              },
            ),
            const SizedBox(height: 40),

            // --- Botón de Guardar ---
            AssetTypeActionButtons(
              onSave: _saveAssetType,
              saveLabel: 'Actualizar Tipo de Activo',
            ),
          ],
        ),
      ),
    );
  }
}