import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

// Imports de tus modelos y widgets
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_action_buttons.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_custom_fields_section.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_form_title.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_image_section.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_name_field.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_serialized_toggle.dart';
import '../../data/models/list_data.dart';
import '../../providers/container_provider.dart';

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
  String? _imagePreviewUrl;
  bool _isSerialized = true;
  bool _isCollection = false;

  @override
  void initState() {
    super.initState();
    _loadDataLists();
  }

  // --- Lógica de negocio (Mantenida igual para no romper funcionalidad) ---

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
        setState(() => _imagePreviewUrl = base64Image);
        ToastService.info('Imagen seleccionada');
      }
    }
  }

  void _removeImage() {
    setState(() => _imagePreviewUrl = null);
    ToastService.info('Imagen removida');
  }

  void _loadDataLists() {
    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.tryParse(widget.containerId);
    if (containerIdInt != null) {
      final container = containerProvider.containers.firstWhere(
        (c) => c.id == containerIdInt,
      );
      setState(() {
        _availableDataLists = container.dataLists;
        _isLoadingLists = false;
        _isCollection = container.isCollection;
      });
    }
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
          isMonetary: false,
        ),
      );
    });
  }

  void _removeField(int index) =>
      setState(() => _fieldDefinitions.removeAt(index));

  void _saveAssetType() async {
    if (_formKey.currentState!.validate()) {
      final containerProvider = context.read<ContainerProvider>();
      final containerIdInt = int.tryParse(widget.containerId);
      if (containerIdInt == null) return;

      Uint8List? imageBytes;
      String? imageName;
      if (_imagePreviewUrl != null) {
        final parts = _imagePreviewUrl!.split(',');
        if (parts.length > 1) {
          imageBytes = base64Decode(parts[1]);
          final mimeType =
              RegExp(r'data:image/([^;]+);').firstMatch(parts[0])?.group(1) ??
              'jpeg';
          imageName = 'asset_type_image.$mimeType';
        }
      }

      try {
        await containerProvider.addNewAssetTypeToContainer(
          containerId: containerIdInt,
          name: _nameController.text,
          fieldDefinitions: _fieldDefinitions,
          imageBytes: imageBytes,
          imageName: imageName,
          isSerialized: _isSerialized,
        );
        if (mounted) {
          context.goNamed(
            RouteNames.assetTypes,
            pathParameters: {'containerId': widget.containerId},
          );
        }
      } catch (e) {
        ToastService.error('Error: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- DISEÑO MODERNO 2026 ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Fondo sutilmente coloreado para dar profundidad
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: Container(
          // Restringimos el ancho para que en Web no se vea estirado
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Título y Header
                  AssetTypeFormTitle(title: 'Nuevo Tipo de Activo'),
                  const SizedBox(height: 32),

                  // 2. Bento Grid Layout
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      // Tarjeta de Imagen (Arriba y prominente)
                      _buildBentoBox(
                        width: 350,
                        child: AssetTypeImageSection(
                          imagePreviewUrl: _imagePreviewUrl,
                          onAddImage: _addImage,
                          onRemoveImage: _removeImage,
                        ),
                      ),

                      // Tarjeta de Configuración Principal
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

                      // Tarjeta de Campos Dinámicos (Ocupa el ancho total disponible)
                      _buildBentoBox(
                        width: 854, // Casi el ancho máximo del contenedor
                        child: AssetTypeCustomFieldsSection(
                          fieldDefinitions: _fieldDefinitions,
                          availableDataLists: _availableDataLists,
                          isLoading: _isLoadingLists,
                          onAddField: _addNewField,
                          onRemoveField: _removeField,
                          onUpdateField: (index, updatedField) {
                            setState(
                              () => _fieldDefinitions[index] = updatedField,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // 3. Botones de Acción (Flotantes o fijos al final)
                  AssetTypeActionButtons(
                    onSave: _saveAssetType,
                    saveLabel: 'Crear Tipo de Activo',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para crear las "Cajas Bento"
  Widget _buildBentoBox({required double width, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          28,
        ), // Bordes muy redondeados (2026 style)
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
