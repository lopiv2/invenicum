import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:provider/provider.dart';

// Asegúrate de que estas importaciones son correctas y los modelos existen
import '../models/asset_type_model.dart';
import '../models/container_node.dart';
import '../models/inventory_item.dart';
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

  // 2. Mapa de controllers para campos dinámicos
  late Map<int, TextEditingController> _dynamicControllers;

  // Estado del modelo
  AssetType? _assetType;

  // 🚀 ESTADO PARA GESTIÓN DE IMÁGENES
  // Lista de objetos InventoryItemImage existentes (se eliminan de aquí al marcar para borrar)
  late List<InventoryItemImage> _currentImages;

  // Data URLs Base64 de las imágenes nuevas (para previsualización)
  List<String> _newImagePreviewUrls = [];

  // IDs de las imágenes existentes que deben ser eliminadas en el backend
  List<int> _imageIdsToDelete = [];
  // ------------------------------------

  // 🚀 GETTER UNIFICADO PARA EL WIDGET ImagePreviewSection
  List<String> get _allImageUrls {
    // 1. Mapeamos las imágenes existentes, AÑADIENDO el prefijo de la API
    final existingUrls = _currentImages.map((img) {
      // APLICAMOS LA FUNCIÓN DE URL COMPLETA
      final String apiUrl =
          Environment.apiUrl; // O usa Environment.apiUrl
      return '$apiUrl${img.url}';
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

    // 🚀 Inicializar el estado de imágenes existentes haciendo una copia
    _currentImages = List.from(widget.initialItem?.images ?? []);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // No necesario aquí si usamos didChangeDependencies
    });
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

    if (assetType != null) {
      setState(() {
        _assetType = assetType;

        for (var fieldDef in assetType.fieldDefinitions) {
          final initialValue =
              widget.initialItem?.customFieldValues[fieldDef.id.toString()] ??
              '';
          _dynamicControllers[fieldDef.id ?? 0] = TextEditingController(
            text: initialValue.toString(),
          );
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
  // LÓGICA DE GESTIÓN DE IMÁGENES
  // ----------------------------------------------------

  /// Muestra el selector de archivos y obtiene la URL Base64 para previsualización.
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

  /// Marca una imagen existente para ser eliminada (solo remueve del UI y añade al listado de IDs).
  void _deleteExistingImage(InventoryItemImage image) {
    setState(() {
      // 1. Quitar de la lista de imágenes actuales (desaparece de la UI)
      _currentImages.removeWhere((img) => img.id == image.id);

      // 2. Añadir a la lista de IDs a eliminar en el backend
      _imageIdsToDelete.add(image.id);
    });
    ToastService.info('Imagen existente marcada para eliminación al guardar.');
  }

  /// Elimina una Data URL de previsualización (un archivo nuevo)
  void _removeNewImage(String url) {
    setState(() {
      _newImagePreviewUrls.remove(url);
    });
    ToastService.info('Archivo nuevo removido de la lista de subida.');
  }

  /// 🚀 FUNCIÓN UNIFICADA DE ELIMINACIÓN
  void _handleRemoveImage(String url) {
    // 1. Es una imagen nueva (Data URL Base64)
    if (url.startsWith('data:')) {
      _removeNewImage(url);
    }
    // 2. Es una imagen existente (URL de red)
    else {
      // Buscamos la InventoryItemImage correspondiente a esta URL
      final existingImage = _currentImages.firstWhere(
        (img) => img.url == url,
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

  /// Convierte una Data URL (Base64) a Uint8List y extrae el nombre/tipo de archivo.
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
    if (!_formKey.currentState!.validate() ||
        widget.initialItem == null ||
        _assetType == null) {
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);
    final assetItemIdInt = int.tryParse(widget.assetItemId);

    if (cIdInt == null || atIdInt == null || assetItemIdInt == null) return;

    // 1. Recoger los valores custom
    final Map<String, dynamic> updatedCustomValues = {};
    _dynamicControllers.forEach((fieldId, controller) {
      updatedCustomValues[fieldId.toString()] = controller.text;
    });

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
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      customFieldValues: updatedCustomValues,
      // La lista de imágenes aquí solo incluye las que el usuario NO eliminó.
      images: _currentImages,
    );

    // 4. Llamar al proveedor para actualizar el activo con archivos/eliminaciones
    try {
      await itemProvider.updateAssetWithFiles(
        // Asumo que tienes un método updateAssetWithFiles o similar
        updatedItem,
        filesToUpload: filesData, // Archivos nuevos a subir
        imageIdsToDelete: _imageIdsToDelete, // IDs de imágenes a eliminar
      );

      // 5. Navegar de vuelta
      if (mounted) {
        ToastService.success(
          'Activo "${updatedItem.name}" actualizado correctamente.',
        );
        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al actualizar activo: ${e.toString()}');
      }
    }
  }

  // ----------------------------------------------------
  // WIDGETS AUXILIARES PARA LA UI (Manteniendo los Custom Fields)
  // ----------------------------------------------------

  Widget _buildCustomFields() {
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

        // ... (Tu código de TextFormField para campos dinámicos)
        ..._assetType!.fieldDefinitions.map((fieldDef) {
          final controller = _dynamicControllers[fieldDef.id];
          if (controller == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: TextFormField(
              controller: controller,
              keyboardType: _getKeyboardType(fieldDef.type.toString()),
              decoration: InputDecoration(
                labelText: fieldDef.name,
                hintText: 'Tipo: ${fieldDef.type.toString().toLowerCase()}',
                border: const OutlineInputBorder(),
                helperText: fieldDef.isRequired ? 'Obligatorio' : null,
              ),
              validator: fieldDef.isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio.';
                      }
                      return null;
                    }
                  : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  // Método auxiliar para el tipo de teclado (simulado)
  TextInputType _getKeyboardType(String fieldType) {
    switch (fieldType.toLowerCase()) {
      case 'integer':
      case 'decimal':
        return TextInputType.number;
      case 'date':
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }

  // ----------------------------------------------------
  // BUILD METHOD PRINCIPAL
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
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
