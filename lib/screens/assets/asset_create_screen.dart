import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/integration_field_type.dart';
import 'package:invenicum/data/services/integrations_service.dart';
import 'package:invenicum/screens/assets/local_widgets/ai_button_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/barcode_scanner_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/save_asset_button.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// Modelos y Datos
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/inventory_item.dart';

// Providers y Servicios
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/data/services/ai_service.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/core/utils/asset_form_utils.dart';

// UI Widgets
import 'package:invenicum/widgets/ui/magic_ai_dialog_widget.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_create_app_bar.dart';
import 'package:invenicum/screens/assets/local_widgets/custom_fields_section.dart';
import 'package:invenicum/screens/assets/local_widgets/images_section.dart';
import 'package:invenicum/screens/assets/local_widgets/inventory_section.dart';
import 'package:invenicum/screens/assets/local_widgets/main_data_section.dart';

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

class _AssetCreateScreenState extends State<AssetCreateScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _minStockController = TextEditingController(text: '1');
  final _aiSearchController = TextEditingController();
  bool _isEnrichLoading = false;
  final ScrollController _scrollController = ScrollController();

  bool _isMagicLoading = false;
  final Set<String> _highlightedFields = {};

  List<Location> _availableLocations = [];
  int? _selectedLocationId;
  List<String> _imagePreviewUrls = [];

  AssetType? _assetType;
  int? _containerId;
  int? _assetTypeId;

  final Map<int, TextEditingController> _customControllers = {};
  final Map<int, List<String>> _listFieldValues = {};
  final Map<int, String?> _selectedListValues = {};
  final Map<int, bool> _booleanFieldValues = {};
  List<IntegrationModel> _availableDataSources = [];
  String? _selectedSource;
  late AIService _aiService;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late IntegrationService _integrationService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Este es el lugar seguro para inicializar cosas que usan context.read o context.watch
    final apiService = context.read<ApiService>();
    _integrationService = IntegrationService(apiService);
  }

  @override
  void initState() {
    super.initState();
    _containerId = int.tryParse(widget.containerId);
    _assetTypeId = int.tryParse(widget.assetTypeId);
    _aiService = AIService(context.read<ApiService>());
    _availableDataSources = AppIntegrations.getAvailableIntegrations(
      context,
    ).where((i) => i.isDataSource).toList();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    if (_availableDataSources.isNotEmpty) {
      _selectedSource = _availableDataSources.first.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
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
        locations: [],
        status: '',
      ),
    );

    final assetType = container.assetTypes.firstWhere(
      (at) => at.id == _assetTypeId,
      orElse: () => AssetType(id: -1, name: '', fieldDefinitions: []),
    );

    setState(() {
      _assetType = assetType;
      _availableLocations = container.locations;
      _selectedLocationId = _availableLocations.isNotEmpty
          ? _availableLocations.first.id
          : null;

      for (var field in assetType.fieldDefinitions) {
        if (field.type == CustomFieldType.dropdown &&
            field.dataListId != null) {
          _loadListValues(field.dataListId!, field.id!);
        } else if (field.type == CustomFieldType.boolean) {
          _booleanFieldValues[field.id!] = false;
        } else {
          _customControllers[field.id!] = TextEditingController();
        }
      }
    });

    _fadeController.forward();
  }

  // --- MÉTODOS DE LÓGICA ORIGINALES REINSTAURADOS ---

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
      if (mounted) ToastService.error('Error al cargar listas: $e');
    }
  }

  // En tu AssetCreateScreen, antes de llamar al modal
  Future<void> _startScan() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _handleBarcodeScan(); // Tu función que abre el BarcodeScannerWidget
    } else {
      ToastService.error("Se requiere permiso de cámara para escanear");
    }
  }

  Future<void> _handleBarcodeScan() async {
    // 1. Abrimos el scanner (tu widget Stateful que ya definimos)
    final String? scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BarcodeScannerWidget(),
    );

    if (scannedCode == null || !mounted) return;

    // 2. Iniciamos carga y ponemos el código en el campo
    setState(() {
      _barcodeController.text = scannedCode;
      _isMagicLoading = true; // Si tienes un overlay de carga
    });

    try {
      final integrationService = IntegrationService(context.read<ApiService>());
      final InventoryItem? suggestedItem = await integrationService
          .lookupBarcode(scannedCode);

      if (suggestedItem != null && mounted) {
        setState(() {
          // Rellenamos controladores
          _nameController.text = suggestedItem.name;
          _descriptionController.text = suggestedItem.description ?? '';

          // 🖼️ Gestión de Imágenes
          // Si el DTO trajo imágenes de la API externa (como UPCItemDB)
          if (suggestedItem.images.isNotEmpty) {
            _imagePreviewUrls = suggestedItem.images
                .map((img) => img.url)
                .toList();
          }

          // Resaltamos los campos para que el usuario vea qué ha cambiado
          _highlightedFields.addAll([
            'name',
            'description',
            'barcode',
            'marketValue',
          ]);
        });

        ToastService.success("¡Datos encontrados en la nube!");
      }
    } catch (e) {
      debugPrint("Error procesando sugerencia: $e");
    } finally {
      if (mounted) setState(() => _isMagicLoading = false);
      // Limpiamos el resaltado después de un tiempo
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _highlightedFields.clear());
      });
    }
  }

  Future<void> _handleEnrichSearch() async {
    final query = _aiSearchController.text.trim();
    if (query.isEmpty) {
      ToastService.error("Escribe algo para buscar");
      return;
    }

    setState(() => _isEnrichLoading = true);

    try {
      final Map<String, dynamic>? enrichedData = await _integrationService
          .enrichItem(query: query, source: _selectedSource!);

      if (enrichedData != null && mounted) {
        setState(() {
          // 1. Datos básicos
          _nameController.text = enrichedData['name'] ?? '';
          _descriptionController.text = enrichedData['description'] ?? '';

          // 2. Imagen (Base64 que viene del DTO del back)
          if (enrichedData['imageUrl'] != null) {
            _imagePreviewUrls.insert(0, enrichedData['imageUrl']);
          }

          // 3. Campos dinámicos (customFieldValues)
          final Map<String, dynamic> aiFields =
              enrichedData['customFieldValues'] ?? {};

          for (var fieldDef in _assetType!.fieldDefinitions) {
            // Buscamos si la IA trajo un valor para este campo (insensible a mayúsculas)
            final aiValue = aiFields.entries
                .firstWhere(
                  (e) => e.key.toLowerCase() == fieldDef.name.toLowerCase(),
                  orElse: () => const MapEntry('', null),
                )
                .value;

            if (aiValue == null) continue;

            // Asignamos según el tipo de campo
            if (fieldDef.type == CustomFieldType.boolean) {
              _booleanFieldValues[fieldDef.id!] =
                  aiValue.toString().toLowerCase() == 'true';
            } else if (fieldDef.type == CustomFieldType.dropdown) {
              final options = _listFieldValues[fieldDef.id] ?? [];
              final match = options.firstWhere(
                (o) => o.toLowerCase() == aiValue.toString().toLowerCase(),
                orElse: () => '',
              );
              if (match.isNotEmpty) _selectedListValues[fieldDef.id!] = match;
            } else {
              _customControllers[fieldDef.id]?.text = aiValue.toString();
            }

            _highlightedFields.add(fieldDef.name);
          }

          _highlightedFields.addAll(['name', 'description']);
        });

        ToastService.success("¡Datos importados desde $_selectedSource!");
      }
    } catch (e) {
      ToastService.error("Error al enriquecer: $e");
    } finally {
      if (mounted) setState(() => _isEnrichLoading = false);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _highlightedFields.clear());
      });
    }
  }

  Future<void> _runMagicAI(String url) async {
    if (_assetType == null) return;
    setState(() => _isMagicLoading = true);

    try {
      final List<String> fieldsToExtract = _assetType!.fieldDefinitions
          .map((f) => f.name)
          .toList();
      if (!fieldsToExtract.any((f) => f.toLowerCase() == 'barcode')) {
        fieldsToExtract.add('barcode');
      }

      final Map<String, dynamic> result = await _aiService.extractDataFromUrl(
        url: url,
        fields: fieldsToExtract,
      );
      final lowerCaseResult = result.map(
        (key, value) => MapEntry(key.toLowerCase(), value),
      );

      setState(() {
        // Imagen
        final imageUrl =
            lowerCaseResult['imageurl'] ?? lowerCaseResult['image'];
        if (imageUrl != null && imageUrl.toString().startsWith('data:image')) {
          _imagePreviewUrls.add(imageUrl.toString());
        }
        // Campos base
        if (lowerCaseResult['name'] != null) {
          _nameController.text = lowerCaseResult['name'].toString();
          _highlightedFields.add('name');
        }
        if (lowerCaseResult['description'] != null) {
          _descriptionController.text = lowerCaseResult['description']
              .toString();
          _highlightedFields.add('description');
        }
        // Barcode
        final dynamic barcodeValue =
            lowerCaseResult['barcode'] ?? lowerCaseResult['upc'];
        if (barcodeValue != null) {
          _barcodeController.text = barcodeValue.toString().replaceAll(
            RegExp(r'[^a-zA-Z0-9]'),
            '',
          );
          _highlightedFields.add('barcode');
        }
        // Campos custom
        for (var fieldDef in _assetType!.fieldDefinitions) {
          final key = fieldDef.name;
          if (!result.containsKey(key) || result[key] == null) continue;
          final value = result[key];
          _highlightedFields.add(key);

          if (fieldDef.type == CustomFieldType.boolean) {
            _booleanFieldValues[fieldDef.id!] = value is bool
                ? value
                : value.toString().toLowerCase() == 'true';
          } else if (fieldDef.type == CustomFieldType.dropdown) {
            final options = _listFieldValues[fieldDef.id] ?? [];
            final match = options.firstWhere(
              (o) => o.toLowerCase() == value.toString().toLowerCase(),
              orElse: () => '',
            );
            if (match.isNotEmpty) _selectedListValues[fieldDef.id!] = match;
          } else {
            final controller = _customControllers[fieldDef.id];
            if (controller != null) controller.text = value.toString();
          }
        }
      });
      ToastService.success(AppLocalizations.of(context)!.fieldsFilledSuccess);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightedFields.clear());
      });
    } catch (e) {
      ToastService.error(e.toString());
    } finally {
      setState(() => _isMagicLoading = false);
    }
  }

  Future<void> _saveAsset() async {
    if (!AssetFormUtils.validateForm(_formKey) ||
        _assetType == null ||
        _selectedLocationId == null) {
      if (_selectedLocationId == null) {
        ToastService.error('Seleccione una ubicación.');
      } else {
        ToastService.error('Por favor, complete los campos obligatorios.');
        return;
      }
    }

    final Map<String, dynamic> customFieldValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      if (fieldDef.type == CustomFieldType.dropdown) {
        if (_selectedListValues[fieldDef.id] != null) {
          customFieldValues[fieldDef.id.toString()] =
              _selectedListValues[fieldDef.id];
        }
      } else if (fieldDef.type == CustomFieldType.boolean) {
        customFieldValues[fieldDef.id.toString()] =
            _booleanFieldValues[fieldDef.id] ?? false;
      } else {
        final controller = _customControllers[fieldDef.id];
        if (controller != null && controller.text.isNotEmpty) {
          String val = controller.text;
          if (fieldDef.type == CustomFieldType.price) {
            double localVal = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
            val = context
                .read<PreferencesProvider>()
                .convertToBase(localVal)
                .toStringAsFixed(2);
          }
          customFieldValues[fieldDef.id.toString()] = val;
        }
      }
    }

    try {
      final newItem = InventoryItem(
        id: 0,
        containerId: _containerId!,
        assetTypeId: _assetTypeId!,
        barcode: _barcodeController.text.trim(),
        locationId: _selectedLocationId,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        minStock: int.tryParse(_minStockController.text) ?? 1,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        customFieldValues: customFieldValues,
      );

      await context.read<InventoryItemProvider>().createInventoryItem(
        newItem,
        filesData: AssetFormUtils.processImages(_imagePreviewUrls),
      );
      if (mounted) {
        ToastService.success('Activo creado!');
        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      ToastService.error('Error: $e');
    }
  }

  Future<void> _addImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        for (var f in result.files) {
          if (f.bytes != null) {
            _imagePreviewUrls.add(
              'data:image/${f.extension};base64,${base64Encode(f.bytes!)}',
            );
          }
        }
      });
    }
  }

  void _showMagicDialog() async {
    final url = await showDialog<String>(
      context: context,
      builder: (c) => const MagicAiDialog(),
    );
    if (url != null && url.isNotEmpty) _runMagicAI(url);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _scrollController.dispose();
    _customControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  // --- UI BENTO GRID 2026 ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;

    if (_assetType == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AssetCreateAppBarWidget(assetTypeName: _assetType!.name),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
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
                            BentoBoxWidget(
                              width:
                                  1044, // Ancho completo (aprox) para destacar sobre el resto
                              title: "Importar desde Fuente Externa",
                              icon: Icons.auto_awesome,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // 1. Selector de Fuente (Basado en tus constantes)
                                  SizedBox(
                                    width: 250,
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedSource,
                                      decoration: const InputDecoration(
                                        labelText: "Fuente de datos",
                                        prefixIcon: Icon(Icons.api),
                                      ),
                                      items: _availableDataSources
                                          .map(
                                            (source) => DropdownMenuItem(
                                              value: source.id,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    child: source.icon,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(source.name),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) =>
                                          setState(() => _selectedSource = val),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 2. Campo de búsqueda y botón de acción
                                  Expanded(
                                    child: TextFormField(
                                      controller: _aiSearchController,
                                      decoration: InputDecoration(
                                        labelText: "Buscar por nombre",
                                        hintText:
                                            "Ej: Pikachu, Catan, El Quijote...",
                                        suffixIcon: _isEnrichLoading
                                            ? const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : IconButton(
                                                icon: const Icon(Icons.search),
                                                onPressed:
                                                    _handleEnrichSearch, // La función que creamos antes
                                              ),
                                      ),
                                      onFieldSubmitted: (_) =>
                                          _handleEnrichSearch(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                            BentoBoxWidget(
                              width: 370,
                              title: "Galería",
                              icon: Icons.camera_alt_outlined,
                              child: ImagesSectionWidget(
                                imageUrls: _imagePreviewUrls,
                                onAddImage: _addImage,
                                onRemoveImage: (url) => setState(
                                  () => _imagePreviewUrls.remove(url),
                                ),
                              ),
                            ),
                            BentoBoxWidget(
                              width: 450,
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
                            BentoBoxWidget(
                              width: 570,
                              title: "Especificaciones",
                              icon: Icons.list_alt,
                              child: CustomFieldsSectionWidget(
                                fieldDefinitions: _assetType!.fieldDefinitions,
                                customControllers: _customControllers,
                                listFieldValues: _listFieldValues,
                                selectedListValues: _selectedListValues,
                                booleanFieldValues: _booleanFieldValues,
                                highlightedFields: _highlightedFields,
                                onDropdownChanged: (id, v) =>
                                    setState(() => _selectedListValues[id] = v),
                                onBooleanChanged: (id, v) => setState(
                                  () => _booleanFieldValues[id] = v ?? false,
                                ),
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
      ),
    );
  }
}
