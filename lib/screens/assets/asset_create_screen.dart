import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/integration_field_type.dart';
import 'package:invenicum/data/services/integrations_service.dart';
import 'package:invenicum/screens/assets/local_widgets/ai_button_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/api_field_mapping_dialog.dart';
import 'package:invenicum/screens/assets/local_widgets/barcode_scanner_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/candidate_card_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/external_import_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/save_asset_button.dart';
import 'package:invenicum/screens/assets/local_widgets/status_section_widget.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/inventory_item.dart';

import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/data/services/ai_service.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/core/utils/asset_form_utils.dart';

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
  final _serialController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _minStockController = TextEditingController(text: '1');
  final _aiSearchController = TextEditingController();
  final FocusNode _nameAutocompleteFocusNode = FocusNode();
  final Map<int, FocusNode> _customAutocompleteFocusNodes = {};
  bool _isEnrichLoading = false;
  final ScrollController _scrollController = ScrollController();
  ItemCondition _selectedCondition = ItemCondition.loose;
  bool _isMagicLoading = false;
  final Set<String> _highlightedFields = {};
  String? selectedId;

  int? _selectedLocationId;
  List<String> _imagePreviewUrls = [];

  AssetType? _assetType;
  int? _containerId;
  int? _assetTypeId;

  final Map<int, TextEditingController> _customControllers = {};
  final Map<int, List<String>> _listFieldValues = {};
  final Map<int, String?> _selectedListValues = {};
  final Map<int, bool> _booleanFieldValues = {};
  double _marketValue = 0.0;
  List<IntegrationModel> _availableDataSources = [];
  String? _selectedSource;
  late AIService _aiService;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late IntegrationService _integrationService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final apiService = context.read<ApiService>();
    _integrationService = IntegrationService(apiService);
    final sources = AppIntegrations.getAvailableIntegrations(
      context,
    ).where((i) => i.isDataSource).toList();
    if (sources.length != _availableDataSources.length) {
      _availableDataSources = sources;
      if (_selectedSource == null && sources.isNotEmpty) {
        _selectedSource = sources.first.id;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _containerId = int.tryParse(widget.containerId);
    _assetTypeId = int.tryParse(widget.assetTypeId);
    _aiService = AIService(context.read<ApiService>());
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
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
      _selectedCondition = ItemCondition.loose;
      _selectedLocationId = container.locations.isNotEmpty
          ? container.locations.first.id
          : null;
      for (var field in assetType.fieldDefinitions) {
        if (field.type == CustomFieldType.dropdown &&
            field.dataListId != null) {
          _loadListValues(field.dataListId!, field.id!);
        } else if (field.type == CustomFieldType.boolean) {
          _booleanFieldValues[field.id!] = false;
        } else {
          _customControllers[field.id!] = TextEditingController();
          _customAutocompleteFocusNodes[field.id!] = FocusNode();
        }
      }
    });

    Future.microtask(
      () => context.read<InventoryItemProvider>().loadInventoryItems(
        containerId: _containerId!,
        assetTypeId: _assetTypeId!,
      ),
    );

    _fadeController.forward();
  }

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
      if (mounted) {
        ToastService.error(
          AppLocalizations.of(context)!.errorLoadingListValues(e.toString()),
        );
      }
    }
  }

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
          _marketValue = suggestedItem.marketValue;
          if (suggestedItem.images.isNotEmpty) {
            _imagePreviewUrls = suggestedItem.images
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

  Future<void> _handleEnrichSearch() async {
    final l10n = AppLocalizations.of(context)!;
    final query = _aiSearchController.text.trim();
    if (query.isEmpty) {
      ToastService.error(l10n.typeSomethingToSearch);
      return;
    }
    // Construye un mapa con los campos dropdown y sus opciones disponibles
    final Map<String, List<String>> dropdownContext = {};
    for (final fieldDef in _assetType!.fieldDefinitions) {
      if (fieldDef.type == CustomFieldType.dropdown) {
        final options = _listFieldValues[fieldDef.id!] ?? [];
        if (options.isNotEmpty) {
          dropdownContext[fieldDef.name] = options;
        }
      }
    }
    setState(() => _isEnrichLoading = true);
    try {
      final locale = Localizations.localeOf(context).languageCode;
      Map<String, dynamic>? enrichedData = await _integrationService.enrichItem(
        query: query,
        source: _selectedSource!,
        locale: locale,
        dropdownContext: dropdownContext
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
      }

      if (enrichedData != null && mounted) {
        // 1) Apply basic fields (name, images, market value)
        setState(() {
          _nameController.text = enrichedData!['name'] ?? _nameController.text;
          final enrichedMarketValue = _extractMarketValue(enrichedData);
          if (enrichedMarketValue != null) _marketValue = enrichedMarketValue;
          final String baseDescription = enrichedData['description'] ?? '';
          if (enrichedData['images'] != null &&
              (enrichedData['images'] as List).isNotEmpty) {
            final imageUrl = enrichedData['images'][0]['url'];
            if (imageUrl != null) _imagePreviewUrls.insert(0, imageUrl);
          } else if (enrichedData['imageUrl'] != null) {
            _imagePreviewUrls.insert(0, enrichedData['imageUrl']);
          }
          _descriptionController.text = baseDescription;
        });

        // 2) Automatic mapping for known fields
        final Map<String, dynamic> aiFields = Map<String, dynamic>.from(
          enrichedData['customFieldValues'] ?? {},
        );
        final Set<String> usedAiKeys = {};

        setState(() {
          for (final fieldDef in _assetType!.fieldDefinitions) {
            final matchEntry = aiFields.entries.firstWhere(
              (e) => e.key.toLowerCase() == fieldDef.name.toLowerCase(),
              orElse: () => const MapEntry('', null),
            );
            if (matchEntry.value != null) {
              usedAiKeys.add(matchEntry.key);
              final val = matchEntry.value;
              if (fieldDef.type == CustomFieldType.boolean) {
                _booleanFieldValues[fieldDef.id!] = (val is bool)
                    ? val
                    : val.toString().toLowerCase() == 'true';
              } else if (fieldDef.type == CustomFieldType.dropdown) {
                final options = _listFieldValues[fieldDef.id!] ?? [];
                final match = options.firstWhere(
                  (o) =>
                      o.toLowerCase().contains(val.toString().toLowerCase()) ||
                      val.toString().toLowerCase().contains(o.toLowerCase()),
                  orElse: () => '',
                );
                if (match.isNotEmpty) _selectedListValues[fieldDef.id!] = match;
              } else {
                _customControllers[fieldDef.id!]?.text = val?.toString() ?? '';
              }
              _highlightedFields.add(fieldDef.name);
            }
          }
        });

        // 3) Collect unmapped keys (exclude dropdowns from being mappable here)
        final Map<String, dynamic> unmapped = {};
        aiFields.forEach((key, value) {
          if (key.toLowerCase() == 'external_id') return;
          final alreadyMapped = usedAiKeys.contains(key);
          //if (alreadyMapped) return;
          if (!alreadyMapped) unmapped[key] = value;
          // if key doesn't match any non-dropdown field name, add to unmapped
          /*final hasNonDropdownMatch = _assetType!.fieldDefinitions.any(
            (f) =>
                f.type != CustomFieldType.dropdown &&
                f.name.toLowerCase() == key.toLowerCase(),
          );
          if (!hasNonDropdownMatch) unmapped[key] = value;*/
        });

        // 4) If unmapped exist, show mapping dialog for non-dropdown fields
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
                if (_customControllers.containsKey(fieldId)) {
                  _customControllers[fieldId]?.text = value?.toString() ?? '';
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

        // 5) Append remaining unmapped data to description
        final List<String> leftover = [];
        aiFields.forEach((key, value) {
          final mappedToField = _assetType!.fieldDefinitions.any(
            (f) => f.name.toLowerCase() == key.toLowerCase(),
          );
          if (!mappedToField && key.toLowerCase() != 'external_id') {
            leftover.add('$key: $value');
          }
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
          l10n.itemImportedSuccessfully(enrichedData['name']?.toString() ?? ''),
        );
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
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: candidates.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  final subtitle = _buildCandidateSubtitle(candidate);

                  return CandidateCard(
                    candidate: candidate,
                    subtitle: subtitle,
                    isSelected: selectedId == candidate['id'],
                    onTap: () {
                      setState(() {
                        selectedId = candidate['id'];
                      });
                      Navigator.of(dialogContext).pop(candidate);
                    },
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
        final imageUrl =
            lowerCaseResult['imageurl'] ?? lowerCaseResult['image'];
        if (imageUrl != null && imageUrl.toString().startsWith('data:image')) {
          _imagePreviewUrls.add(imageUrl.toString());
        }
        if (lowerCaseResult['name'] != null) {
          _nameController.text = lowerCaseResult['name'].toString();
          _highlightedFields.add('name');
        }
        if (lowerCaseResult['description'] != null) {
          _descriptionController.text = lowerCaseResult['description']
              .toString();
          _highlightedFields.add('description');
        }
        final dynamic barcodeValue =
            lowerCaseResult['barcode'] ?? lowerCaseResult['upc'];
        if (barcodeValue != null) {
          _barcodeController.text = barcodeValue.toString().replaceAll(
            RegExp(r'[^a-zA-Z0-9]'),
            '',
          );
          _highlightedFields.add('barcode');
        }
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
    final assetTypeId = _assetTypeId;
    if (assetTypeId == null) return const <InventoryItem>[];

    return itemProvider.allDownloadedItems
        .where((item) => item.assetTypeId == assetTypeId)
        .toList();
  }

  List<String> _buildNameSuggestions(InventoryItemProvider itemProvider) {
    return _getSameTypeItems(itemProvider)
        .map((item) => item.name.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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

  Future<void> _saveAsset() async {
    final l10n = AppLocalizations.of(context)!;
    final itemProvider = context.read<InventoryItemProvider>();
    if (!AssetFormUtils.validateForm(_formKey) ||
        _assetType == null ||
        _selectedLocationId == null) {
      if (_selectedLocationId == null) {
        ToastService.error(l10n.selectLocationRequired);
      } else {
        ToastService.error(l10n.completeRequiredFields);
      }
      return;
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
        serialNumber: _serialController.text.trim(),
        locationId: _selectedLocationId,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        minStock: int.tryParse(_minStockController.text) ?? 1,
        name: _nameController.text.trim(),
        condition: _selectedCondition,
        description: _descriptionController.text.trim(),
        marketValue: _marketValue,
        customFieldValues: customFieldValues,
      );
      await context.read<InventoryItemProvider>().createInventoryItem(
        newItem,
        filesData: AssetFormUtils.processImages(_imagePreviewUrls),
      );
      if (mounted) {
        ToastService.success(l10n.assetCreatedSuccess);
        await itemProvider.loadInventoryItems(
          containerId: _containerId!,
          assetTypeId: _assetTypeId!,
        );
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.goNamed(
            RouteNames.assetList,
            pathParameters: {
              'containerId': widget.containerId,
              'assetTypeId': widget.assetTypeId.toString(),
            },
          );
        }
      }
    } catch (e) {
      ToastService.error(l10n.errorCreatingAsset(e.toString()));
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
    _serialController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _aiSearchController.dispose();
    _scrollController.dispose();
    _nameAutocompleteFocusNode.dispose();
    for (var n in _customAutocompleteFocusNodes.values) {
      n.dispose();
    }
    _customControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;
    final itemProvider = context.watch<InventoryItemProvider>();

    final nameSuggestions = _buildNameSuggestions(itemProvider);
    final customFieldSuggestions = _buildCustomFieldSuggestions(itemProvider);

    final containerProvider = context.watch<ContainerProvider>();
    final liveContainer = containerProvider.containers.firstWhere(
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
    final liveLocations = liveContainer.locations;

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
                    child: _AssetFormLayout(
                      // ── Fila 0: Banner IA (URL mágica) ──
                      aiBanner: aiEnabled
                          ? AiMagicBannerWidget(
                              isLoading: _isMagicLoading,
                              onPressed: _showMagicDialog,
                            )
                          : null,

                      // ── Fila 1: Importar desde fuente externa ──
                      importBento: BentoBoxWidget(
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
                      ),

                      // ── Fila 2a: Datos principales ──
                      mainDataBento: BentoBoxWidget(
                        title: l10n.mainDataTitle,
                        icon: Icons.info_outline,
                        child: MainDataSectionWidget(
                          nameController: _nameController,
                          descriptionController: _descriptionController,
                          nameSuggestions: nameSuggestions,
                          nameAutocompleteFocusNode: _nameAutocompleteFocusNode,
                          availableLocations: liveLocations,
                          selectedLocationId: _selectedLocationId,
                          onLocationChanged: (v) =>
                              setState(() => _selectedLocationId = v),
                          highlightedFields: _highlightedFields,
                          containerId: _containerId,
                        ),
                      ),

                      // ── Fila 2b: Galería ──
                      galleryBento: BentoBoxWidget(
                        title: l10n.galleryTitle,
                        icon: Icons.camera_alt_outlined,
                        child: ImagesSectionWidget(
                          imageUrls: _imagePreviewUrls,
                          onAddImage: _addImage,
                          onRemoveImage: (url) =>
                              setState(() => _imagePreviewUrls.remove(url)),
                        ),
                      ),

                      // ── Fila 3a: Estado ──
                      statusWidget: StatusSectionWidget(
                        selectedCondition: _selectedCondition,
                        onConditionChanged: (val) =>
                            setState(() => _selectedCondition = val),
                      ),

                      // ── Fila 3b: Stock y Codificación ──
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

                      // ── Fila 4: Especificaciones (full width si hay campos) ──
                      specsBento: _assetType!.fieldDefinitions.isNotEmpty
                          ? BentoBoxWidget(
                              title: l10n.specificationsTitle,
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
                                autocompleteSuggestionsByField:
                                    customFieldSuggestions,
                                autocompleteFocusNodesByField:
                                    _customAutocompleteFocusNodes,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout compartido — usado tanto en Create como en Edit
// ---------------------------------------------------------------------------

class _AssetFormLayout extends StatelessWidget {
  final Widget? aiBanner;
  final Widget? importBento; // Solo en Create
  final Widget mainDataBento;
  final Widget galleryBento;
  final Widget statusWidget;
  final Widget stockBento;
  final Widget? specsBento;

  const _AssetFormLayout({
    this.aiBanner,
    this.importBento,
    required this.mainDataBento,
    required this.galleryBento,
    required this.statusWidget,
    required this.stockBento,
    this.specsBento,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Banner IA ──────────────────────────────────────────────────────
        if (aiBanner != null) ...[aiBanner!, const SizedBox(height: 24)],

        // ── Importar (solo create) ─────────────────────────────────────────
        if (importBento != null) ...[importBento!, const SizedBox(height: 24)],

        // ── Fila: Datos Principales (2/3) + Galería (1/3) ─────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            // En pantallas anchas: side-by-side. En estrechas: apiladas.
            if (w >= 700) {
              final galleryWidth = (w * 0.35).clamp(260.0, 380.0);
              final mainWidth = w - galleryWidth - 24;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: mainWidth, child: mainDataBento),
                  const SizedBox(width: 24),
                  SizedBox(width: galleryWidth, child: galleryBento),
                ],
              );
            }
            return Column(
              children: [
                mainDataBento,
                const SizedBox(height: 16),
                galleryBento,
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // ── Fila: Estado (auto) + Stock (flex) ────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            if (w >= 600) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // StatusSectionWidget tiene su propio BentoBox internamente;
                    // lo envolvemos en Flexible para que tome el espacio justo.
                    Flexible(flex: 2, child: statusWidget),
                    const SizedBox(width: 24),
                    Flexible(flex: 3, child: stockBento),
                  ],
                ),
              );
            }
            return Column(
              children: [statusWidget, const SizedBox(height: 16), stockBento],
            );
          },
        ),

        // ── Especificaciones (full width, solo si hay campos) ─────────────
        if (specsBento != null) ...[const SizedBox(height: 24), specsBento!],
      ],
    );
  }
}
