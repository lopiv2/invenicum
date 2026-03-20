import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/integration_field_type.dart';
import 'package:invenicum/data/services/integrations_service.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/data/services/ai_service.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/core/utils/asset_form_utils.dart';
import 'package:invenicum/screens/assets/local_widgets/ai_button_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_form_layout.dart';
import 'package:invenicum/screens/assets/local_widgets/barcode_scanner_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/custom_fields_section.dart';
import 'package:invenicum/screens/assets/local_widgets/images_section.dart';
import 'package:invenicum/screens/assets/local_widgets/inventory_section.dart';
import 'package:invenicum/screens/assets/local_widgets/main_data_section.dart';
import 'package:invenicum/screens/assets/local_widgets/save_asset_button.dart';
import 'package:invenicum/screens/assets/local_widgets/status_section_widget.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';
import 'package:invenicum/widgets/ui/magic_ai_dialog_widget.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  late TextEditingController _barcodeController;

  bool _isMagicLoading = false;
  bool _isEnrichLoading = false;
  Set<String> _highlightedFields = {};
  late AIService _aiService;
  late IntegrationService _integrationService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _aiSearchController = TextEditingController();
  List<IntegrationModel> _availableDataSources = [];
  String? _selectedSource;

  List<Location> _availableLocations = [];
  int? _selectedLocationId;

  late Map<int, TextEditingController> _dynamicControllers;
  final Map<int, List<String>> _listFieldValues = {};
  final Map<int, String?> _selectedListValues = {};
  final Map<int, bool?> _booleanValues = {};

  InventoryItem? currentItem;
  bool _isInitialized = false;

  ItemCondition _selectedCondition = ItemCondition.mint;
  AssetType? _assetType;

  late List<InventoryItemImage> _currentImages;
  List<String> _newImagePreviewUrls = [];
  List<int> _imageIdsToDelete = [];

  // ---------------------------------------------------------------------------
  // Imagen helpers
  // ---------------------------------------------------------------------------

  List<String> get _allImageUrls {
    final existingUrls = _currentImages.map((img) {
      final String apiUrl = Environment.apiUrl;
      return img.url.startsWith('http') ? img.url : '$apiUrl${img.url}';
    }).toList();
    return [...existingUrls, ..._newImagePreviewUrls];
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _quantityController = TextEditingController();
    _minStockController = TextEditingController();
    _barcodeController = TextEditingController();
    _dynamicControllers = {};
    _selectedLocationId = currentItem?.locationId;
    _currentImages = List.from(currentItem?.images ?? []);
    _aiService = AIService(context.read<ApiService>());
    final apiService = context.read<ApiService>();
    _integrationService = IntegrationService(apiService);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Cargar fuentes de datos para el enriquecimiento
    final sources = AppIntegrations.getAvailableIntegrations(context)
        .where((i) => i.isDataSource)
        .toList();
    if (sources.length != _availableDataSources.length) {
      _availableDataSources = sources;
      if (_selectedSource == null && sources.isNotEmpty) {
        _selectedSource = sources.first.id;
      }
    }

    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();
    final itemId = int.tryParse(widget.assetItemId);

    currentItem =
        widget.initialItem ??
        (itemId != null ? itemProvider.getItemById(itemId) : null);

    if (currentItem == null && !itemProvider.isLoading && itemId != null) {
      final cId = int.tryParse(widget.containerId) ?? 0;
      final atId = int.tryParse(widget.assetTypeId) ?? 0;
      Future.microtask(() => itemProvider.loadInventoryItems(
            containerId: cId,
            assetTypeId: atId,
          ));
      return;
    }

    if (!_isInitialized &&
        currentItem != null &&
        containerProvider.containers.isNotEmpty) {
      _initializeAllFields(currentItem!);
    }
  }

  void _initializeAllFields(InventoryItem item) {
    if (_isInitialized) return;
    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    _quantityController.text = item.quantity.toString();
    _minStockController.text = item.minStock.toString();
    _barcodeController.text = item.barcode ?? '';
    _selectedLocationId = item.locationId;
    _currentImages = List.from(item.images);
    _selectedCondition = item.condition;
    _initializeDynamicFields(item);
    setState(() => _isInitialized = true);
  }

  void _initializeDynamicFields(InventoryItem item) {
    final containerProvider = context.read<ContainerProvider>();
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
            String textToShow = initialValue?.toString() ?? '';
            if (fieldDef.type == CustomFieldType.price &&
                initialValue != null) {
              double dbValue =
                  double.tryParse(initialValue.toString()) ?? 0.0;
              double localValue = preferences.convertPrice(dbValue);
              textToShow = localValue.toStringAsFixed(2);
            }
            _dynamicControllers[fieldId] =
                TextEditingController(text: textToShow);
          }
        }
      });
    }
  }

  Future<void> _loadListValues(int dataListId, int fieldId) async {
    try {
      final containerProvider = context.read<ContainerProvider>();
      final listData = await containerProvider.getDataList(dataListId);
      if (mounted) {
        setState(() => _listFieldValues[fieldId] = listData.items);
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(
            AppLocalizations.of(context)!.errorLoadingListValues(e.toString()));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _barcodeController.dispose();
    _dynamicControllers.values.forEach((c) => c.dispose());
    _aiSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // IA
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Escáner de código de barras
  // ---------------------------------------------------------------------------

  Future<void> _startScan() async {
    var status = await Permission.camera.status;
    if (status.isDenied) status = await Permission.camera.request();
    if (status.isGranted) {
      _handleBarcodeScan();
    } else {
      ToastService.error("Se requiere permiso de cámara para escanear");
    }
  }

  Future<void> _handleBarcodeScan() async {
    final String? scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BarcodeScannerWidget(),
    );
    if (scannedCode == null || !mounted) return;

    setState(() {
      _barcodeController.text = scannedCode;
      _isMagicLoading = true;
    });

    try {
      final integrationService = IntegrationService(context.read<ApiService>());
      final InventoryItem? suggestedItem =
          await integrationService.lookupBarcode(scannedCode);

      if (suggestedItem != null && mounted) {
        setState(() {
          _nameController.text = suggestedItem.name;
          _descriptionController.text = suggestedItem.description ?? '';
          if (suggestedItem.images.isNotEmpty) {
            _newImagePreviewUrls =
                suggestedItem.images.map((img) => img.url).toList();
          }
          _highlightedFields.addAll(['name', 'description', 'barcode']);
        });
        ToastService.success("¡Datos encontrados en la nube!");
      }
    } catch (e) {
      debugPrint("Error procesando sugerencia: $e");
    } finally {
      if (mounted) setState(() => _isMagicLoading = false);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _highlightedFields.clear());
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Importar desde fuente externa (Enrich)
  // ---------------------------------------------------------------------------

  Future<void> _handleEnrichSearch() async {
    final query = _aiSearchController.text.trim();
    if (query.isEmpty) {
      ToastService.error("Escribe algo para buscar");
      return;
    }
    setState(() => _isEnrichLoading = true);
    try {
      final Map<String, dynamic>? enrichedData =
          await _integrationService.enrichItem(
              query: query, source: _selectedSource!);

      if (enrichedData != null && mounted) {
        setState(() {
          _nameController.text = enrichedData['name'] ?? _nameController.text;
          String baseDescription = enrichedData['description'] ?? '';

          if (enrichedData['images'] != null &&
              (enrichedData['images'] as List).isNotEmpty) {
            final imageUrl = enrichedData['images'][0]['url'];
            if (imageUrl != null) _newImagePreviewUrls.insert(0, imageUrl);
          } else if (enrichedData['imageUrl'] != null) {
            _newImagePreviewUrls.insert(0, enrichedData['imageUrl']);
          }

          final Map<String, dynamic> aiFields =
              enrichedData['customFieldValues'] ?? {};
          final Set<String> usedAiKeys = {};
          final List<String> unusedDataLines = [];

          for (var fieldDef in _assetType!.fieldDefinitions) {
            final entry = aiFields.entries.firstWhere(
              (e) => e.key.toLowerCase() == fieldDef.name.toLowerCase(),
              orElse: () => const MapEntry('', null),
            );
            if (entry.value != null) {
              usedAiKeys.add(entry.key);
              final val = entry.value.toString();
              if (fieldDef.type == CustomFieldType.boolean) {
                _booleanValues[fieldDef.id!] = val.toLowerCase() == 'true';
              } else if (fieldDef.type == CustomFieldType.dropdown) {
                final options = _listFieldValues[fieldDef.id] ?? [];
                final match = options.firstWhere(
                  (o) => o.toLowerCase() == val.toLowerCase(),
                  orElse: () => '',
                );
                if (match.isNotEmpty) _selectedListValues[fieldDef.id!] = match;
              } else {
                _dynamicControllers[fieldDef.id]?.text = val;
              }
              _highlightedFields.add(fieldDef.name);
            }
          }

          aiFields.forEach((key, value) {
            if (!usedAiKeys.contains(key) && key.toLowerCase() != 'external_id') {
              unusedDataLines.add("$key: $value");
            }
          });

          if (unusedDataLines.isNotEmpty) {
            final extraInfo =
                '\n\n--- Detalles Técnicos ---\n${unusedDataLines.join('\n')}';
            _descriptionController.text = baseDescription + extraInfo;
          } else {
            _descriptionController.text = baseDescription;
          }

          _highlightedFields.addAll(['name', 'description']);
        });
        ToastService.success("¡${enrichedData['name']} importado con éxito!");
      }
    } catch (e) {
      ToastService.error("No se pudo completar la importación");
    } finally {
      if (mounted) {
        setState(() => _isEnrichLoading = false);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _highlightedFields.clear());
        });
      }
    }
  }

  Future<void> _runMagicAI(String url) async {
    if (_assetType == null) return;
    setState(() => _isMagicLoading = true);
    try {
      final List<String> customFields =
          _assetType!.fieldDefinitions.map((f) => f.name).toList();
      final Map<String, dynamic> result = await _aiService.extractDataFromUrl(
        url: url,
        fields: customFields,
      );
      setState(() {
        if (result['imageUrl'] != null &&
            result['imageUrl'].toString().startsWith('data:image')) {
          _newImagePreviewUrls.add(result['imageUrl']);
        }
        if (result.containsKey('name') && result['name'] != null) {
          _nameController.text = result['name'].toString();
          _highlightedFields.add('name');
        }
        if (result.containsKey('description') &&
            result['description'] != null) {
          _descriptionController.text = result['description'].toString();
          _highlightedFields.add('description');
        }
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
            final matchedOption = options.firstWhere(
              (opt) => opt.toLowerCase() == value.toString().toLowerCase(),
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
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightedFields.clear());
      });
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
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
    if (url != null && url.isNotEmpty) _runMagicAI(url);
  }

  // ---------------------------------------------------------------------------
  // Imágenes
  // ---------------------------------------------------------------------------

  Future<void> _addNewImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final List<String> newImageUrls = [];
      for (final file in result.files) {
        if (file.bytes != null) {
          newImageUrls.add(
              'data:image/${file.extension ?? 'jpeg'};base64,${base64Encode(file.bytes!)}');
        }
      }
      if (newImageUrls.isNotEmpty) {
        setState(() => _newImagePreviewUrls.addAll(newImageUrls));
        ToastService.info(
            'Se seleccionaron ${newImageUrls.length} nuevas imágenes.');
      }
    }
  }

  void _handleRemoveImage(String url) {
    if (url.startsWith('data:')) {
      setState(() => _newImagePreviewUrls.remove(url));
      ToastService.info('Archivo nuevo removido.');
    } else {
      final String apiUrl = Environment.apiUrl;
      final String relativeUrl = url.replaceAll(apiUrl, '');
      final existingImage = _currentImages.firstWhere(
        (img) => img.url == relativeUrl,
        orElse: () => InventoryItemImage(id: -1, url: '', order: 0),
      );
      if (existingImage.id != -1) {
        setState(() {
          _currentImages.removeWhere((img) => img.id == existingImage.id);
          _imageIdsToDelete.add(existingImage.id);
        });
        ToastService.info('Imagen marcada para eliminación al guardar.');
      } else {
        ToastService.error('No se pudo identificar la imagen.');
      }
    }
  }

  Map<String, dynamic> _dataUrlToFileData(String dataUrl, int index) {
    final mimeTypeMatch = RegExp(r'data:([^;]+);base64,').firstMatch(dataUrl);
    final mimeType = mimeTypeMatch?.group(1);
    final bytes = base64Decode(dataUrl.split(',').last);
    final extension = mimeType?.split('/').last ?? 'jpg';
    return {'bytes': bytes, 'name': 'asset_new_image_$index.$extension'};
  }

  // ---------------------------------------------------------------------------
  // Guardar
  // ---------------------------------------------------------------------------

  Future<void> _saveAsset() async {
    if (!AssetFormUtils.validateForm(_formKey) ||
        widget.initialItem == null ||
        _assetType == null ||
        _selectedLocationId == null) {
      if (_selectedLocationId == null && mounted) {
        ToastService.error(
            AppLocalizations.of(context)!.selectLocationRequired);
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
        ToastService.error(
            AppLocalizations.of(context)!.invalidNavigationIds);
      return;
    }

    final Map<String, dynamic> updatedCustomValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      final fieldId = fieldDef.id!;
      final controller = _dynamicControllers[fieldId];

      if (fieldDef.type == CustomFieldType.dropdown) {
        final selectedValue = _selectedListValues[fieldId];
        if (selectedValue != null) {
          updatedCustomValues[fieldId.toString()] = selectedValue;
        } else if (fieldDef.isRequired && mounted) {
          ToastService.error(AppLocalizations.of(context)!
              .fieldRequiredWithName(fieldDef.name));
          return;
        }
      } else if (fieldDef.type == CustomFieldType.boolean) {
        final boolValue = _booleanValues[fieldId];
        if (fieldDef.isRequired && boolValue == null && mounted) {
          ToastService.error(AppLocalizations.of(context)!
              .fieldRequiredWithName(fieldDef.name));
          return;
        }
        if (boolValue != null)
          updatedCustomValues[fieldId.toString()] = boolValue;
      } else if (controller != null && controller.text.isNotEmpty) {
        var valueToSave = controller.text;
        if (fieldDef.type == CustomFieldType.price) {
          double localValue =
              double.tryParse(valueToSave.replaceAll(',', '.')) ?? 0;
          valueToSave =
              preferences.convertToBase(localValue).toStringAsFixed(2);
        }
        updatedCustomValues[fieldId.toString()] = valueToSave;
      } else if (fieldDef.isRequired && mounted) {
        ToastService.error(AppLocalizations.of(context)!
            .fieldRequiredWithName(fieldDef.name));
        return;
      }
    }

    final List<Map<String, dynamic>> filesData = [];
    for (int i = 0; i < _newImagePreviewUrls.length; i++) {
      filesData.add(_dataUrlToFileData(_newImagePreviewUrls[i], i));
    }

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

    try {
      await itemProvider.updateAssetWithFiles(
        updatedItem,
        filesToUpload: filesData,
        imageIdsToDelete: _imageIdsToDelete,
      );
      await alertProvider.loadAlerts();
      if (mounted) {
        await itemProvider.loadInventoryItems(
          containerId: cIdInt,
          assetTypeId: atIdInt,
        );
        ToastService.success(
            AppLocalizations.of(context)!.assetUpdated(updatedItem.name));
        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      if (mounted) ToastService.error('Error: ${e.toString()}');
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    context.watch<ContainerProvider>();
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;
    final theme = Theme.of(context);

    if (_assetType == null || currentItem == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

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
                  child: AssetFormLayout(
                    // ── Banner IA ──
                    aiBanner: aiEnabled
                        ? AiMagicBannerWidget(
                            isLoading: _isMagicLoading,
                            onPressed: _showMagicDialog,
                          )
                        : null,

                    // ── Importar desde fuente externa ──
                    importBento: BentoBoxWidget(
                      title: "Importar desde Fuente Externa",
                      icon: Icons.auto_awesome,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // En ancho suficiente: selector + buscador en la misma fila.
                          // En ancho estrecho: apilados verticalmente.
                          final wide = constraints.maxWidth >= 480;
                          final dropdown = DropdownButtonFormField<String>(
                            value: _selectedSource,
                            isExpanded: true, // evita overflow del texto del item
                            decoration: const InputDecoration(
                              labelText: "Fuente de datos",
                              prefixIcon: Icon(Icons.api),
                            ),
                            items: _availableDataSources
                                .map((source) => DropdownMenuItem(
                                      value: source.id,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              width: 20, child: source.icon),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              source.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSource = val),
                          );
                          final searchField = TextFormField(
                            controller: _aiSearchController,
                            decoration: InputDecoration(
                              labelText: "Buscar por nombre",
                              hintText: "Ej: Pikachu, Catan, El Quijote...",
                              suffixIcon: _isEnrichLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: _handleEnrichSearch,
                                    ),
                            ),
                            onFieldSubmitted: (_) => _handleEnrichSearch(),
                          );

                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(width: 220, child: dropdown),
                                const SizedBox(width: 16),
                                Expanded(child: searchField),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              dropdown,
                              const SizedBox(height: 12),
                              searchField,
                            ],
                          );
                        },
                      ),
                    ),

                    // ── Datos Principales ──
                    mainDataBento: BentoBoxWidget(
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

                    // ── Galería ──
                    galleryBento: BentoBoxWidget(
                      title: "Galería",
                      icon: Icons.camera_alt_outlined,
                      child: ImagesSectionWidget(
                        imageUrls: _allImageUrls,
                        onAddImage: _addNewImages,
                        onRemoveImage: _handleRemoveImage,
                      ),
                    ),

                    // ── Estado ──
                    statusWidget: StatusSectionWidget(
                      selectedCondition: _selectedCondition,
                      onConditionChanged: (val) =>
                          setState(() => _selectedCondition = val),
                    ),

                    // ── Stock y Codificación ──
                    stockBento: BentoBoxWidget(
                      title: "Stock y Codificación",
                      icon: Icons.qr_code_scanner,
                      child: InventorySectionWidget(
                        barcodeController: _barcodeController,
                        quantityController: _quantityController,
                        minStockController: _minStockController,
                        assetType: _assetType,
                        highlightedFields: _highlightedFields,
                        onScanPressed: _startScan,
                      ),
                    ),

                    // ── Especificaciones ──
                    specsBento: _assetType!.fieldDefinitions.isNotEmpty
                        ? BentoBoxWidget(
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
                          )
                        : null,
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