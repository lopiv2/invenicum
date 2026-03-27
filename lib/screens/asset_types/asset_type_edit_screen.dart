import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
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
import 'local_widgets/asset_type_serialized_toggle.dart'; // Asegúrate de importar este
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
  bool _isSerialized = true;
  bool _isCollection = false;

  // Estado para la imagen
  String? _imagePreviewUrl;
  bool _imageWasRemoved = false;
  bool _isNewImageBase64 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  static String _buildImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://'))
      return rawUrl;
    final host = Environment.apiUrl.endsWith('/')
        ? Environment.apiUrl.substring(0, Environment.apiUrl.length - 1)
        : Environment.apiUrl;
    if (rawUrl.startsWith('/')) return '$host$rawUrl';
    return '$host/images/$rawUrl';
  }

  void _loadInitialData() {
    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.tryParse(widget.containerId);
    final assetTypeIdInt = int.tryParse(widget.assetTypeId);

    if (containerIdInt == null || assetTypeIdInt == null) {
      ToastService.error('ID inválido.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final container = containerProvider.containers.firstWhere(
        (c) => c.id == containerIdInt,
      );
      final assetType = container.assetTypes.firstWhere(
        (at) => at.id == assetTypeIdInt,
      );

      _nameController.text = assetType.name;
      _isSerialized = assetType.isSerialized; // Cargamos el estado real
      _fieldDefinitions = List.from(assetType.fieldDefinitions);
      _availableDataLists = container.dataLists;
      _currentAssetType = assetType;
      _isCollection = container.isCollection;

      if (assetType.images.isNotEmpty) {
        _imagePreviewUrl = _buildImageUrl(assetType.images.first.url);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      ToastService.error('Error al cargar datos: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  // --- Lógica de archivos y campos (Mantenida igual) ---

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
        final base64Image =
            'data:image/$extension;base64,${base64Encode(file.bytes!)}';
        setState(() {
          _imagePreviewUrl = base64Image;
          _isNewImageBase64 = true;
          _imageWasRemoved = false;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imagePreviewUrl = null;
      _isNewImageBase64 = false;
      if (_currentAssetType?.images.isNotEmpty ?? false)
        _imageWasRemoved = true;
    });
  }

  void _addNewField() {
    setState(() {
      _fieldDefinitions.add(
        CustomFieldDefinition(
          id: 0,
          name: '',
          type: CustomFieldType.text,
          isRequired: false,
        ),
      );
    });
  }

  void _saveAssetType() async {
    if (!_formKey.currentState!.validate() || _currentAssetType == null) return;

    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.parse(widget.containerId);
    final assetTypeIdInt = int.parse(widget.assetTypeId);

    Uint8List? newImageBytes;
    String? newImageName;

    if (_isNewImageBase64 && _imagePreviewUrl != null) {
      final parts = _imagePreviewUrl!.split(',');
      if (parts.length > 1) {
        newImageBytes = base64Decode(parts[1]);
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
        name: _nameController.text,
        isSerialized: _isSerialized, // IMPORTANTE: enviamos el cambio
        fieldDefinitions: _fieldDefinitions,
        imageBytes: newImageBytes,
        imageName: newImageName,
        removeExistingImage: _imageWasRemoved && !_isNewImageBase64,
      );
      ToastService.success('Tipo de activo actualizado con éxito.');
      if (mounted) {
        context.goNamed(
          RouteNames.assetTypes,
          pathParameters: {'containerId': widget.containerId},
        );
      }
    } catch (e) {
      ToastService.error('Error al actualizar: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AssetTypeFormTitle(
                    title: 'Editar: ${_currentAssetType?.name ?? ""}',
                  ),
                  const SizedBox(height: 32),

                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      // 1. Imagen (Bento 350)
                      _buildBentoBox(
                        width: 350,
                        child: AssetTypeImageSectionExtended(
                          imagePreviewUrl: _imagePreviewUrl,
                          isNewImageBase64: _isNewImageBase64,
                          onAddImage: _addImage,
                          onRemoveImage: _removeImage,
                        ),
                      ),

                      // 2. Configuración (Bento 480)
                      _buildBentoBox(
                        width: 480,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Configuración General",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AssetTypeNameField(controller: _nameController),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            if (_isCollection) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Este contenedor es una colección. Puedes crear tipos seriados o no seriados, pero los campos de posesión y deseados solo se podrán configurar en tipos no seriados.",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            AssetTypeSerializedToggle(
                              isSerialized: _isSerialized,
                              onChanged: (value) =>
                                  setState(() => _isSerialized = value),
                            ),
                          ],
                        ),
                      ),

                      // 3. Campos Dinámicos (Bento 854)
                      _buildBentoBox(
                        width: 854,
                        child: AssetTypeCustomFieldsSection(
                          fieldDefinitions: _fieldDefinitions,
                          availableDataLists: _availableDataLists,
                          isLoading: false,
                          onAddField: _addNewField,
                          onRemoveField: (index) =>
                              setState(() => _fieldDefinitions.removeAt(index)),
                          onUpdateField: (index, updatedField) {
                            setState(() {
                              _fieldDefinitions[index] = updatedField.copyWith(
                                id: _fieldDefinitions[index]
                                    .id, // Preservar ID para la API
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  AssetTypeActionButtons(
                    onSave: _saveAssetType,
                    saveLabel: 'Actualizar Tipo de Activo',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoBox({required double width, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
