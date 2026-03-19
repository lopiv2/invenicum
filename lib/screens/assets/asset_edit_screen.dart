import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/data/services/ai_service.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/core/utils/asset_form_utils.dart';
import 'package:invenicum/screens/assets/local_widgets/ai_button_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/custom_fields_section.dart';
import 'package:invenicum/screens/assets/local_widgets/images_section.dart';
import 'package:invenicum/screens/assets/local_widgets/inventory_section.dart';
import 'package:invenicum/screens/assets/local_widgets/main_data_section.dart';
import 'package:invenicum/screens/assets/local_widgets/save_asset_button.dart';
import 'package:invenicum/screens/assets/local_widgets/status_section_widget.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';
import 'package:invenicum/widgets/ui/magic_ai_dialog_widget.dart';
import 'package:provider/provider.dart';
import '../../data/models/asset_type_model.dart';
import '../../data/models/container_node.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/location.dart';
import '../../providers/container_provider.dart';
import '../../providers/inventory_item_provider.dart';
import '../../data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';

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
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  late TextEditingController _barcodeController;
  bool _isMagicLoading = false; // Controla el spinner del botón IA
  Set<String> _highlightedFields = {}; // Para el efecto visual verde
  late AIService _aiService; // El servicio de IA
  final ScrollController _scrollController = ScrollController();

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
  InventoryItem? currentItem;
  bool _isInitialized = false;

  // 🔑 ESTADO DE CONDICIÓN DEL ACTIVO
  ItemCondition _selectedCondition = ItemCondition.mint;

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
        ToastService.error(
          AppLocalizations.of(context)!.errorLoadingListValues(e.toString()),
        );
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

    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _quantityController = TextEditingController();
    _minStockController = TextEditingController();
    _barcodeController = TextEditingController();
    _dynamicControllers = {};

    // 🔑 Inicializar estado de ubicación con el valor del item inicial
    _selectedLocationId = currentItem?.locationId;

    // 🚀 Inicializar el estado de imágenes existentes haciendo una copia
    _currentImages = List.from(currentItem?.images ?? []);
    _aiService = AIService(context.read<ApiService>());
  }

  void _initializeAllFields(InventoryItem item) {
    if (_isInitialized)
      return; // Evita sobrescribir si el usuario ya empezó a escribir

    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    _quantityController.text = item.quantity.toString();
    _minStockController.text = item.minStock.toString();
    _barcodeController.text = item.barcode ?? '';
    _selectedLocationId = item.locationId;
    _currentImages = List.from(item.images);
    _selectedCondition = item.condition;

    // Aquí llamamos a tu lógica de campos dinámicos
    _initializeDynamicFields(item);

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();
    final itemId = int.tryParse(widget.assetItemId);

    // 1. Intentar encontrar el item (Widget o Caché)
    currentItem =
        widget.initialItem ??
        (itemId != null ? itemProvider.getItemById(itemId) : null);

    // 2. Si no existe en ningún lado, pedirlo a la API
    if (currentItem == null && !itemProvider.isLoading && itemId != null) {
      final cId = int.tryParse(widget.containerId) ?? 0;
      final atId = int.tryParse(widget.assetTypeId) ?? 0;
      Future.microtask(
        () => itemProvider.loadInventoryItems(
          containerId: cId,
          assetTypeId: atId,
        ),
      );
      return;
    }

    // 3. Cuando tengamos TODO, inicializamos los controladores una sola vez
    if (!_isInitialized &&
        currentItem != null &&
        containerProvider.containers.isNotEmpty) {
      _initializeAllFields(currentItem!);
    }
  }

  Future<void> _runMagicAI(String url) async {
    if (_assetType == null) return;

    setState(() => _isMagicLoading = true);

    try {
      // 1. Obtener nombres de campos personalizados para enviarlos a la IA
      final List<String> customFields = _assetType!.fieldDefinitions
          .map((f) => f.name)
          .toList();

      final Map<String, dynamic> result = await _aiService.extractDataFromUrl(
        url: url,
        fields: customFields,
      );

      setState(() {
        // 2. Procesar imagen si la IA devuelve una (Base64)
        if (result['imageUrl'] != null &&
            result['imageUrl'].toString().startsWith('data:image')) {
          _newImagePreviewUrls.add(result['imageUrl']);
        }

        // 3. Rellenar campos comunes
        if (result.containsKey('name') && result['name'] != null) {
          _nameController.text = result['name'].toString();
          _highlightedFields.add('name');
        }
        if (result.containsKey('description') &&
            result['description'] != null) {
          _descriptionController.text = result['description'].toString();
          _highlightedFields.add('description');
        }

        // 4. Rellenar campos personalizados dinámicos
        for (var fieldDef in _assetType!.fieldDefinitions) {
          final key = fieldDef.name;
          if (!result.containsKey(key) || result[key] == null) continue;

          final value = result[key];
          _highlightedFields.add(key);

          if (fieldDef.type == CustomFieldType.boolean) {
            _booleanValues[fieldDef.id!] = value is bool
                ? value
                : value.toString().toLowerCase() == 'true';
          } else if (fieldDef.type == CustomFieldType.dropdown) {
            final List<String> options = _listFieldValues[fieldDef.id] ?? [];
            final String incomingValue = value.toString();

            final matchedOption = options.firstWhere(
              (opt) => opt.toLowerCase() == incomingValue.toLowerCase(),
              orElse: () => '',
            );

            if (matchedOption.isNotEmpty) {
              _selectedListValues[fieldDef.id!] = matchedOption;
            }
          } else {
            final controller = _dynamicControllers[fieldDef.id];
            if (controller != null) {
              String valStr = value.toString();
              if (fieldDef.type == CustomFieldType.number ||
                  fieldDef.type == CustomFieldType.price) {
                valStr = valStr.replaceAll(RegExp(r'[^0-9.,]'), '');
              }
              controller.text = valStr;
            }
          }
        }
      });

      ToastService.success(AppLocalizations.of(context)!.fieldsFilledSuccess);

      // Efecto visual temporal y scroll al inicio
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightedFields.clear());
      });

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      ToastService.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isMagicLoading = false);
    }
  }

  void _showMagicDialog() async {
    final String? url = await showDialog<String>(
      context: context,
      builder: (context) => const MagicAiDialog(),
    );

    if (url != null && url.isNotEmpty) {
      _runMagicAI(url);
    }
  }

  void _initializeDynamicFields(InventoryItem item) {
    final containerProvider = context.read<ContainerProvider>();
    // 🔑 Necesitamos el PreferencesProvider para convertir el precio al mostrarlo
    final preferences = context.read<PreferencesProvider>();

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
      setState(() {
        _assetType = assetType;
        _availableLocations = container.locations;

        for (var fieldDef in assetType.fieldDefinitions) {
          final fieldId = fieldDef.id ?? 0;
          final initialValue = item.customFieldValues?[fieldId.toString()];

          if (fieldDef.type == CustomFieldType.dropdown) {
            _selectedListValues[fieldId] = initialValue;
            if (fieldDef.dataListId != null) {
              _loadListValues(fieldDef.dataListId!, fieldId);
            }
          } else if (fieldDef.type == CustomFieldType.boolean) {
            _booleanValues[fieldId] = AssetFormUtils.toBoolean(initialValue);
          } else {
            // ---------------------------------------------------------
            // 🔑 LÓGICA DE CARGA PARA PRECIOS
            // ---------------------------------------------------------
            String textToShow = initialValue?.toString() ?? '';

            if (fieldDef.type == CustomFieldType.price &&
                initialValue != null) {
              // 1. Leemos el valor "universal" de la BBDD (ej: 17.66)
              double dbValue = double.tryParse(initialValue.toString()) ?? 0.0;

              // 2. Lo convertimos a la moneda actual del usuario (ej: de USD a EUR)
              double localValue = preferences.convertPrice(dbValue);

              // 3. Formateamos para que el usuario vea "15.00"
              textToShow = localValue.toStringAsFixed(2);
            }

            _dynamicControllers[fieldId] = TextEditingController(
              text: textToShow,
            );
            // ---------------------------------------------------------
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _barcodeController.dispose();
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
        _selectedLocationId == null) {
      if (_selectedLocationId == null && mounted) {
        ToastService.error(
          AppLocalizations.of(context)!.selectLocationRequired,
        );
      }
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();
    final preferences = context.read<PreferencesProvider>();
    final alertProvider = context.read<AlertProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);
    final assetItemIdInt = int.tryParse(widget.assetItemId);

    if (cIdInt == null || atIdInt == null || assetItemIdInt == null) {
      if (mounted)
        ToastService.error(AppLocalizations.of(context)!.invalidNavigationIds);
      return;
    }

    // 1. Recoger los valores custom y procesar Precios
    final Map<String, dynamic> updatedCustomValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      final fieldId = fieldDef.id!;
      final controller = _dynamicControllers[fieldId];

      if (fieldDef.type == CustomFieldType.dropdown) {
        final selectedValue = _selectedListValues[fieldId];
        if (selectedValue != null) {
          updatedCustomValues[fieldId.toString()] = selectedValue;
        } else if (fieldDef.isRequired && mounted) {
          ToastService.error(
            AppLocalizations.of(context)!.fieldRequiredWithName(fieldDef.name),
          );
          return;
        }
      } else if (fieldDef.type == CustomFieldType.boolean) {
        final boolValue = _booleanValues[fieldId];
        if (fieldDef.isRequired && boolValue == null && mounted) {
          ToastService.error(
            AppLocalizations.of(context)!.fieldRequiredWithName(fieldDef.name),
          );
          return;
        }
        if (boolValue != null)
          updatedCustomValues[fieldId.toString()] = boolValue;
      } else if (controller != null && controller.text.isNotEmpty) {
        var valueToSave = controller.text;

        // Conversión de Moneda Local -> USD (Base)
        if (fieldDef.type == CustomFieldType.price) {
          double localValue =
              double.tryParse(valueToSave.replaceAll(',', '.')) ?? 0;
          double baseValue = preferences.convertToBase(localValue);
          valueToSave = baseValue.toStringAsFixed(2);
        }
        updatedCustomValues[fieldId.toString()] = valueToSave;
      } else if (fieldDef.isRequired && mounted) {
        ToastService.error(
          AppLocalizations.of(context)!.fieldRequiredWithName(fieldDef.name),
        );
        return;
      }
    }

    // 2. Preparar archivos
    final List<Map<String, dynamic>> filesData = [];
    for (int i = 0; i < _newImagePreviewUrls.length; i++) {
      filesData.add(_dataUrlToFileData(_newImagePreviewUrls[i], i));
    }

    // 3. Crear objeto InventoryItem actualizado
    final updatedItem = InventoryItem(
      id: assetItemIdInt,
      containerId: cIdInt,
      assetTypeId: atIdInt,
      locationId: _selectedLocationId!,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      quantity: int.tryParse(_quantityController.text) ?? 1,
      minStock: int.tryParse(_minStockController.text) ?? 1,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      condition: _selectedCondition,
      customFieldValues: updatedCustomValues,
      images: _currentImages,
    );

    // 4. Actualizar en Base de Datos
    try {
      await itemProvider.updateAssetWithFiles(
        updatedItem,
        filesToUpload: filesData,
        imageIdsToDelete: _imageIdsToDelete,
      );

      await alertProvider.loadAlerts();

      // 5. Gestión de Notificaciones y Salida
      if (mounted) {
        await itemProvider.loadInventoryItems(
          containerId: cIdInt,
          assetTypeId: atIdInt,
        );
        ToastService.success(
          AppLocalizations.of(context)!.assetUpdated(updatedItem.name),
        );

        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      if (mounted) ToastService.error('Error: ${e.toString()}');
    }
  }

  // ----------------------------------------------------
  // BUILD METHOD PRINCIPAL
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    context.watch<ContainerProvider>();
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;

    if (_assetType == null || currentItem == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: Text('Editar: ${currentItem!.name}')),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (aiEnabled)
                        AiMagicBannerWidget(
                          isLoading: _isMagicLoading,
                          onPressed: _showMagicDialog,
                        ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          // Datos Principales
                          BentoBoxWidget(
                            width: 650,
                            title: "Datos Principales",
                            icon: Icons.info_outline,
                            child: MainDataSectionWidget(
                              nameController: _nameController,
                              descriptionController: _descriptionController,
                              availableLocations: _availableLocations,
                              selectedLocationId: _selectedLocationId,
                              onLocationChanged: (v) =>
                                  setState(() => _selectedLocationId = v),
                              highlightedFields: _highlightedFields,
                            ),
                          ),
                          // Galería
                          BentoBoxWidget(
                            width: 370,
                            title: "Galería",
                            icon: Icons.camera_alt_outlined,
                            child: ImagesSectionWidget(
                              imageUrls: _allImageUrls,
                              onAddImage: _addNewImages,
                              onRemoveImage: _handleRemoveImage,
                            ),
                          ),
                          StatusSectionWidget(
                            selectedCondition: _selectedCondition,
                            onConditionChanged: (val) =>
                                setState(() => _selectedCondition = val),
                          ),
                          // Stock y Codificación
                          BentoBoxWidget(
                            width: 450,
                            title: "Stock y Codificación",
                            icon: Icons.qr_code_scanner,
                            child: Column(
                              children: [
                                InventorySectionWidget(
                                  barcodeController: _barcodeController,
                                  quantityController: _quantityController,
                                  minStockController: _minStockController,
                                  assetType: _assetType,
                                  highlightedFields: _highlightedFields,
                                ),
                              ],
                            ),
                          ),
                          // Especificaciones
                          BentoBoxWidget(
                            width: 570,
                            title: "Especificaciones",
                            icon: Icons.list_alt,
                            child: CustomFieldsSectionWidget(
                              fieldDefinitions: _assetType!.fieldDefinitions,
                              customControllers: _dynamicControllers,
                              listFieldValues: _listFieldValues,
                              selectedListValues: _selectedListValues,
                              booleanFieldValues: Map.fromEntries(
                                _booleanValues.entries
                                    .where((e) => e.value != null)
                                    .map((e) => MapEntry(e.key, e.value!)),
                              ),
                              highlightedFields: _highlightedFields,
                              onDropdownChanged: (id, v) =>
                                  setState(() => _selectedListValues[id] = v),
                              onBooleanChanged: (id, v) =>
                                  setState(() => _booleanValues[id] = v),
                              onControllerText: (id, ctrl) {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SaveAssetFloatingButton(onPressed: _saveAsset),
        ],
      ),
    );
  }
}
