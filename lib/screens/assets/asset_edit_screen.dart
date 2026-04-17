import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/services/inventory_item_service.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/routing/route_names.dart';
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
import 'package:invenicum/screens/assets/local_widgets/api_field_mapping_dialog.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_form_layout.dart';
import 'package:invenicum/screens/assets/local_widgets/barcode_scanner_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/custom_fields_section.dart';
import 'package:invenicum/screens/assets/local_widgets/external_import_widget.dart';
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
  late TextEditingController _serialController;
  late FocusNode _nameAutocompleteFocusNode;
  final Map<int, FocusNode> _dynamicAutocompleteFocusNodes = {};

  bool _isMagicLoading = false;
  bool _isEnrichLoading = false;
  final Set<String> _highlightedFields = {};
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
  double _marketValue = 0.0;

  InventoryItem? currentItem;
  bool _isInitialized = false;
  bool _autocompleteDataRequested = false;

  ItemCondition _selectedCondition = ItemCondition.mint;
  AssetType? _assetType;

  late List<InventoryItemImage> _currentImages;
  List<String> _newImagePreviewUrls = [];
  final List<int> _imageIdsToDelete = [];

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
    _serialController = TextEditingController();
    _nameAutocompleteFocusNode = FocusNode();
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
    final sources = AppIntegrations.getAvailableIntegrations(
      context,
    ).where((i) => i.isDataSource).toList();
    if (sources.length != _availableDataSources.length) {
      _availableDataSources = sources;
      if (_selectedSource == null && sources.isNotEmpty) {
        _selectedSource = sources.first.id;
      }
    }

    final containerProvider = context.watch<ContainerProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();
    final itemId = int.tryParse(widget.assetItemId);
    final cId = int.tryParse(widget.containerId);
    final atId = int.tryParse(widget.assetTypeId);

    if (!_autocompleteDataRequested && cId != null && atId != null) {
      _autocompleteDataRequested = true;
      Future.microtask(
        () => itemProvider.loadInventoryItems(
          containerId: cId,
          assetTypeId: atId,
        ),
      );
    }

    currentItem =
        widget.initialItem ??
        (itemId != null ? itemProvider.getItemById(itemId) : null);

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
    _serialController.text = item.serialNumber ?? '';
    _selectedLocationId = item.locationId;
    _currentImages = List.from(item.images);
    _selectedCondition = item.condition;
    _marketValue = item.marketValue;
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
              double dbValue = double.tryParse(initialValue.toString()) ?? 0.0;
              double localValue = preferences.convertPrice(dbValue);
              textToShow = localValue.toStringAsFixed(2);
            }
            _dynamicControllers[fieldId] = TextEditingController(
              text: textToShow,
            );
            _dynamicAutocompleteFocusNodes[fieldId] = FocusNode();
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
          AppLocalizations.of(context)!.errorLoadingListValues(e.toString()),
        );
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
    _serialController.dispose();
    _nameAutocompleteFocusNode.dispose();
    for (var n in _dynamicAutocompleteFocusNodes.values) {
      n.dispose();
    }
    for (var c in _dynamicControllers.values) {
      c.dispose();
    }
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
      ToastService.error(
        AppLocalizations.of(context)!.cameraPermissionRequired,
      );
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
      final InventoryItem? suggestedItem = await integrationService
          .lookupBarcode(scannedCode);

      if (suggestedItem != null && mounted) {
        setState(() {
          _nameController.text = suggestedItem.name;
          _descriptionController.text = suggestedItem.description ?? '';
          if (suggestedItem.images.isNotEmpty) {
            _newImagePreviewUrls = suggestedItem.images
                .map((img) => img.url)
                .toList();
          }
          _highlightedFields.addAll(['name', 'description', 'barcode']);
        });
        ToastService.success(AppLocalizations.of(context)!.cloudDataFound);
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
    final l10n = AppLocalizations.of(context)!;
    final query = _aiSearchController.text.trim();
    if (query.isEmpty) {
      ToastService.error(l10n.typeSomethingToSearch);
      return;
    }
    setState(() => _isEnrichLoading = true);
    try {
      final locale = Localizations.localeOf(context).languageCode;
      Map<String, dynamic>? enrichedData = await _integrationService.enrichItem(
        query: query,
        source: _selectedSource!,
        locale: locale,
      );

      if (enrichedData != null && enrichedData['multipleResults'] == true) {
        final candidates = _normalizeCandidates(enrichedData['candidates']);
        if (candidates.isEmpty) {
          throw Exception(
            'La búsqueda devolvió múltiples resultados sin candidatos.',
          );
        }

        final selectedCandidate = await _showCandidateSelectionDialog(
          candidates,
        );
        if (selectedCandidate == null) {
          ToastService.error(l10n.importCancelled);
          return;
        }

        final selectedId = selectedCandidate['id']?.toString();
        if (selectedId == null || selectedId.isEmpty) {
          throw Exception('El candidato seleccionado no tiene un ID válido.');
        }

        final selectedSource =
            enrichedData['source']?.toString() ?? _selectedSource!;
        enrichedData = await _integrationService.enrichSelectedItem(
          source: selectedSource,
          itemId: selectedId,
          locale: locale,
        );

        if (enrichedData != null && mounted) {
          // Apply basic fields
          setState(() {
            _nameController.text =
                enrichedData!['name'] ?? _nameController.text;
            final enrichedMarketValue = _extractMarketValue(enrichedData);
            if (enrichedMarketValue != null) _marketValue = enrichedMarketValue;
            final String baseDescription = enrichedData['description'] ?? '';
            if (enrichedData['images'] != null &&
                (enrichedData['images'] as List).isNotEmpty) {
              final imageUrl = enrichedData['images'][0]['url'];
              if (imageUrl != null) _newImagePreviewUrls.insert(0, imageUrl);
            } else if (enrichedData['imageUrl'] != null) {
              _newImagePreviewUrls.insert(0, enrichedData['imageUrl']);
            }
            _descriptionController.text = baseDescription;
          });

          // Automatic mapping
          final Map<String, dynamic> aiFields = Map<String, dynamic>.from(
            enrichedData['customFieldValues'] ?? {},
          );
          final Set<String> usedAiKeys = {};

          for (final fieldDef in _assetType!.fieldDefinitions) {
            final matchEntry = aiFields.entries.firstWhere(
              (e) => e.key.toLowerCase() == fieldDef.name.toLowerCase(),
              orElse: () => const MapEntry('', null),
            );
            if (matchEntry.value != null) {
              usedAiKeys.add(matchEntry.key);
              final val = matchEntry.value;
              if (fieldDef.type == CustomFieldType.boolean) {
                _booleanValues[fieldDef.id!] = (val is bool)
                    ? val
                    : val.toString().toLowerCase() == 'true';
              } else if (fieldDef.type == CustomFieldType.dropdown) {
                final options = _listFieldValues[fieldDef.id] ?? [];
                final match = options.firstWhere(
                  (o) => o.toLowerCase() == val.toString().toLowerCase(),
                  orElse: () => '',
                );
                if (match.isNotEmpty) _selectedListValues[fieldDef.id!] = match;
              } else {
                _dynamicControllers[fieldDef.id]?.text = val?.toString() ?? '';
              }
              _highlightedFields.add(fieldDef.name);
            }
          }

          // Collect unmapped keys (exclude dropdowns)
          final Map<String, dynamic> unmapped = {};
          aiFields.forEach((key, value) {
            if (key.toLowerCase() == 'external_id') return;
            if (usedAiKeys.contains(key)) return;
            final hasNonDropdownMatch = _assetType!.fieldDefinitions.any(
              (f) =>
                  f.type != CustomFieldType.dropdown &&
                  f.name.toLowerCase() == key.toLowerCase(),
            );
            if (!hasNonDropdownMatch) unmapped[key] = value;
          });

          if (unmapped.isNotEmpty) {
            final availableFields = _assetType!.fieldDefinitions
                .where((f) => f.type != CustomFieldType.dropdown)
                .toList();
            final Map<int, dynamic>? mappingResult =
                await showDialog<Map<int, dynamic>>(
                  context: context,
                  builder: (_) => ApiFieldMappingDialog(
                    unmappedFields: unmapped,
                    availableFields: availableFields,
                  ),
                );
            if (mappingResult != null && mappingResult.isNotEmpty) {
              setState(() {
                mappingResult.forEach((fieldId, value) {
                  if (_dynamicControllers.containsKey(fieldId)) {
                    _dynamicControllers[fieldId]?.text =
                        value?.toString() ?? '';
                  }
                  final idx = _assetType!.fieldDefinitions.indexWhere(
                    (f) => f.id == fieldId,
                  );
                  if (idx != -1)
                    _highlightedFields.add(
                      _assetType!.fieldDefinitions[idx].name,
                    );
                });
              });
            }
          }

          // Append leftovers to description
          final List<String> leftover = [];
          aiFields.forEach((key, value) {
            final mappedToField = _assetType!.fieldDefinitions.any(
              (f) => f.name.toLowerCase() == key.toLowerCase(),
            );
            if (!mappedToField && key.toLowerCase() != 'external_id')
              leftover.add('$key: $value');
          });
          if (leftover.isNotEmpty) {
            setState(() {
              final base = _descriptionController.text.isNotEmpty
                  ? '${_descriptionController.text}\n\n'
                  : '';
              _descriptionController.text =
                  '$base--- ${l10n.technicalDetailsTitle} ---\n${leftover.join('\n')}';
            });
          }

          ToastService.success(
            l10n.itemImportedSuccessfully(
              enrichedData['name']?.toString() ?? '',
            ),
          );
        }
      }
    } catch (e) {
      ToastService.error(l10n.couldNotCompleteImport);
    } finally {
      if (mounted) {
        setState(() => _isEnrichLoading = false);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _highlightedFields.clear());
        });
      }
    }
  }

  List<Map<String, dynamic>> _normalizeCandidates(dynamic rawCandidates) {
    if (rawCandidates is! List) return [];
    return rawCandidates
        .whereType<Map>()
        .map((candidate) => Map<String, dynamic>.from(candidate))
        .toList();
  }

  String _buildCandidateSubtitle(Map<String, dynamic> candidate) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[];
    final year = candidate['yearPublished']?.toString();
    final author = candidate['author']?.toString();
    if (year != null && year.isNotEmpty) {
      parts.add('${l10n.yearLabel}: $year');
    }
    if (author != null && author.isNotEmpty) {
      parts.add('${l10n.authorLabel}: $author');
    }
    return parts.join(' • ');
  }

  Widget? _buildCandidateLeading(Map<String, dynamic> candidate) {
    final image = candidate['image']?.toString();
    if (image == null || image.isEmpty) {
      return null;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        image,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: 48,
          height: 48,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showCandidateSelectionDialog(
    List<Map<String, dynamic>> candidates,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectResultTitle),
          content: SizedBox(
            width: 520,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: candidates.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  final subtitle = _buildCandidateSubtitle(candidate);
                  return ListTile(
                    leading: _buildCandidateLeading(candidate),
                    title: Text(
                      candidate['name']?.toString() ?? l10n.unnamedLabel,
                    ),
                    subtitle: subtitle.isEmpty ? null : Text(subtitle),
                    onTap: () => Navigator.of(dialogContext).pop(candidate),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runMagicAI(String url) async {
    if (_assetType == null) return;
    setState(() => _isMagicLoading = true);
    try {
      final List<String> customFields = _assetType!.fieldDefinitions
          .map((f) => f.name)
          .toList();
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

  double? _extractMarketValue(Map<String, dynamic> data) {
    final rawValue = data['marketValue'] ?? data['market_value'];
    if (rawValue is num) {
      return rawValue.toDouble();
    }
    if (rawValue is String) {
      return double.tryParse(rawValue.replaceAll(',', '.'));
    }
    return null;
  }

  List<InventoryItem> _getSameTypeItems(InventoryItemProvider itemProvider) {
    final assetTypeId = int.tryParse(widget.assetTypeId);
    if (assetTypeId == null) return const <InventoryItem>[];

    final currentId = currentItem?.id;
    return itemProvider.allDownloadedItems
        .where(
          (item) => item.assetTypeId == assetTypeId && item.id != currentId,
        )
        .toList();
  }

  List<String> _buildNameSuggestions(InventoryItemProvider itemProvider) {
    final suggestions =
        _getSameTypeItems(itemProvider)
            .map((item) => item.name.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return suggestions;
  }

  Map<int, List<String>> _buildCustomFieldSuggestions(
    InventoryItemProvider itemProvider,
  ) {
    final assetType = _assetType;
    if (assetType == null) return const <int, List<String>>{};

    final fieldIds = assetType.fieldDefinitions
        .where(
          (field) =>
              field.id != null &&
              field.type != CustomFieldType.boolean &&
              field.type != CustomFieldType.dropdown,
        )
        .map((field) => field.id!)
        .toList();

    final Map<int, Set<String>> accumulator = {
      for (final id in fieldIds) id: <String>{},
    };

    for (final item in _getSameTypeItems(itemProvider)) {
      final values = item.customFieldValues;
      if (values == null) continue;

      for (final fieldId in fieldIds) {
        final rawValue = values[fieldId.toString()];
        final normalized = rawValue?.toString().trim() ?? '';
        if (normalized.isNotEmpty) {
          accumulator[fieldId]!.add(normalized);
        }
      }
    }

    return {
      for (final entry in accumulator.entries)
        entry.key: (entry.value.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))),
    };
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
            'data:image/${file.extension ?? 'jpeg'};base64,${base64Encode(file.bytes!)}',
          );
        }
      }
      if (newImageUrls.isNotEmpty) {
        setState(() => _newImagePreviewUrls.addAll(newImageUrls));
        ToastService.info(
          AppLocalizations.of(context)!.newImagesSelected(newImageUrls.length),
        );
      }
    }
  }

  Future<void> _addImageFromUrl(String imageUrl) async {
    final l10n = AppLocalizations.of(context)!;
    final inventoryItemService = context.read<InventoryItemService>();

    try {
      final dataUrl = await inventoryItemService.downloadImageAsDataUrl(
        imageUrl,
      );

      if (mounted) {
        setState(() {
          _newImagePreviewUrls.add(dataUrl);
        });

        ToastService.success(l10n.imageDownloadedSuccessfully);
      }
    } catch (e) {
      ToastService.error(l10n.errorDownloadingImage(e.toString()));
    }
  }

  void _handleRemoveImage(String url) {
    if (url.startsWith('data:')) {
      setState(() => _newImagePreviewUrls.remove(url));
      ToastService.info(AppLocalizations.of(context)!.newFileRemoved);
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
        ToastService.info(AppLocalizations.of(context)!.imageMarkedForDeletion);
      } else {
        ToastService.error(AppLocalizations.of(context)!.couldNotIdentifyImage);
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
        if (fieldDef.type == CustomFieldType.price) {
          double localValue =
              double.tryParse(valueToSave.replaceAll(',', '.')) ?? 0;
          valueToSave = preferences
              .convertToBase(localValue)
              .toStringAsFixed(2);
        }
        updatedCustomValues[fieldId.toString()] = valueToSave;
      } else if (fieldDef.isRequired && mounted) {
        ToastService.error(
          AppLocalizations.of(context)!.fieldRequiredWithName(fieldDef.name),
        );
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
      serialNumber: _serialController.text.trim().isEmpty
          ? null
          : _serialController.text.trim(),
      quantity: int.tryParse(_quantityController.text) ?? 1,
      minStock: int.tryParse(_minStockController.text) ?? 1,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      condition: _selectedCondition,
      marketValue: _marketValue,
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
          AppLocalizations.of(context)!.assetUpdated(updatedItem.name),
        );
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.goNamed(
            RouteNames.assetList,
            pathParameters: {
              'containerId': widget.containerId,
              'assetTypeId': widget.assetTypeId,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(
          AppLocalizations.of(context)!.errorUpdatingAsset(e.toString()),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    context.watch<ContainerProvider>();
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;
    final itemProvider = context.watch<InventoryItemProvider>();
    final theme = Theme.of(context);

    final nameSuggestions = _buildNameSuggestions(itemProvider);
    final customFieldSuggestions = _buildCustomFieldSuggestions(itemProvider);

    if (_assetType == null || currentItem == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: Text(l10n.editAssetTitle(currentItem!.name))),
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
                    importBento: aiEnabled
                        ? BentoBoxWidget(
                            title: l10n.externalImportTitle,
                            icon: Icons.auto_awesome,
                            child: ExternalImportWidget(
                              selectedSource: _selectedSource,
                              availableSources: _availableDataSources,
                              searchController: _aiSearchController,
                              isLoading: _isEnrichLoading,
                              onSourceChanged: (val) =>
                                  setState(() => _selectedSource = val),
                              onSearch: _handleEnrichSearch,
                            ),
                          )
                        : null,

                    // ── Datos Principales ──
                    mainDataBento: BentoBoxWidget(
                      title: l10n.mainDataTitle,
                      icon: Icons.info_outline,
                      child: MainDataSectionWidget(
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                        nameSuggestions: nameSuggestions,
                        nameAutocompleteFocusNode: _nameAutocompleteFocusNode,
                        availableLocations: _availableLocations,
                        selectedLocationId: _selectedLocationId,
                        onLocationChanged: (v) =>
                            setState(() => _selectedLocationId = v),
                        highlightedFields: _highlightedFields,
                      ),
                    ),

                    // ── Galería ──
                    galleryBento: BentoBoxWidget(
                      title: l10n.galleryTitle,
                      icon: Icons.camera_alt_outlined,
                      child: ImagesSectionWidget(
                        imageUrls: _allImageUrls,
                        onAddImage: _addNewImages,
                        onRemoveImage: _handleRemoveImage,
                        onAddImageFromUrl: _addImageFromUrl,
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
                      title: l10n.stockAndCodingTitle,
                      icon: Icons.qr_code_scanner,
                      child: InventorySectionWidget(
                        barcodeController: _barcodeController,
                        serialNumberController: _serialController,
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
                            title: l10n.specificationsTitle,
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
                              autocompleteSuggestionsByField:
                                  customFieldSuggestions,
                              autocompleteFocusNodesByField:
                                  _dynamicAutocompleteFocusNodes,
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
