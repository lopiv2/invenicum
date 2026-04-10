import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import '../../data/models/asset_type_model.dart';
import '../../data/models/location.dart';
import '../../providers/container_provider.dart';
import '../../providers/location_provider.dart';

class ColumnMapping {
  final String assetFieldName;
  String? csvHeader;
  final String? assetFieldId;
  final String? fixedKey;

  ColumnMapping({
    required this.assetFieldName,
    this.csvHeader,
    this.assetFieldId,
    this.fixedKey,
  });
}

class AssetImportScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;

  const AssetImportScreen({
    super.key,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  State<AssetImportScreen> createState() => _AssetImportScreenState();
}

class _AssetImportScreenState extends State<AssetImportScreen> {
  AssetType? _assetType;
  List<String> _csvHeaders = [];
  List<List<dynamic>> _csvData = [];
  List<ColumnMapping> _mappings = [];
  bool _isLoading = false;
  String? _filePath;
  bool _isResolvingAssetType = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssetType());
  }

  Future<void> _loadAssetType() async {
    final containerProvider = context.read<ContainerProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) {
      if (mounted) {
        setState(() {
          _assetType = null;
          _isResolvingAssetType = false;
        });
      }
      return;
    }

    setState(() => _isResolvingAssetType = true);

    if (containerProvider.containers.isEmpty && !containerProvider.isLoading) {
      await containerProvider.loadContainers();
    }

    final locationProvider = context.read<LocationProvider>();
    await locationProvider.fetchLocations(cIdInt);

    final container = containerProvider.containers.cast<dynamic>().firstWhere(
      (c) => c?.id == cIdInt,
      orElse: () => null,
    );

    final loadedAssetType = container?.assetTypes.cast<AssetType?>().firstWhere(
      (at) => at?.id == atIdInt,
      orElse: () => null,
    );

    if (!mounted) return;

    setState(() {
      _assetType = loadedAssetType;
      _isResolvingAssetType = false;
    });

    if (_assetType != null) {
      _initializeMappings();
    }
  }

  void _initializeMappings() {
    if (_assetType == null) return;
    final l10n = AppLocalizations.of(context)!;

    _mappings = [
      ColumnMapping(assetFieldName: l10n.assetName),
      ColumnMapping(assetFieldName: l10n.description),
      ColumnMapping(assetFieldName: l10n.quantity, fixedKey: 'quantity'),
      ColumnMapping(assetFieldName: l10n.minStock, fixedKey: 'minStock'),
      ColumnMapping(assetFieldName: l10n.location, fixedKey: 'location'),
      ColumnMapping(assetFieldName: l10n.serialNumberLabel, fixedKey: 'serialNumber'),
      ColumnMapping(assetFieldName: l10n.barCode, fixedKey: 'barcode'),
      ColumnMapping(assetFieldName: l10n.marketValueField, fixedKey: 'marketValue'),
      ColumnMapping(assetFieldName: l10n.condition, fixedKey: 'condition'),
    ];

    final customMappings = _assetType!.fieldDefinitions
        .map(
          (def) => ColumnMapping(
            assetFieldName: def.name,
            assetFieldId: def.id.toString(),
          ),
        )
        .toList();

    _mappings.addAll(customMappings);

    if (_csvHeaders.isNotEmpty) {
      _attemptAutomaticMapping();
    }
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _csvHeaders = [];
      _mappings.clear();
      _filePath = null;
      _csvData = [];
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      try {
        final PlatformFile file = result.files.single;
        String content;

        if (kIsWeb) {
          final bytes = file.bytes;
          if (bytes == null) throw Exception(l10n.errorReadingBytes);

          try {
            content = utf8.decode(bytes);
          } catch (e) {
            content = latin1.decode(bytes);
          }
          _filePath = file.name;
        } else {
          final filePath = file.path;
          if (filePath == null) throw Exception(l10n.errorInvalidPath);

          final ioFile = File(filePath);
          content = await ioFile.readAsString(encoding: utf8);
          _filePath = filePath;
        }

        final List<List<dynamic>> rowsAsListOfLists = const CsvToListConverter(
          fieldDelimiter: ';',
          eol: '\n',
        ).convert(content);

        if (rowsAsListOfLists.isNotEmpty) {
          _csvData = rowsAsListOfLists;
          _csvHeaders = rowsAsListOfLists.first
              .map((e) => e.toString())
              .toList();
        } else {
          throw Exception(l10n.errorEmptyCsv);
        }

        setState(() {
          _isLoading = false;
          _initializeMappings();
          _attemptAutomaticMapping();
        });
      } catch (e) {
        if (mounted) {
          ToastService.error('${l10n.errorReadingFile}: ${e.toString()}');
        }
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _attemptAutomaticMapping() {
    if (_csvHeaders.isEmpty) return;

    for (var mapping in _mappings) {
      final match = _csvHeaders.firstWhere(
        (header) =>
            header.toLowerCase() == mapping.assetFieldName.toLowerCase() ||
            (mapping.fixedKey != null &&
                header.toLowerCase() == mapping.fixedKey!.toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        mapping.csvHeader = match;
      }
    }
  }

  void _startImport() async {
    final l10n = AppLocalizations.of(context)!;
    if (_csvData.isEmpty || _csvData.length < 2) {
      ToastService.error(l10n.errorCsvMinRows);
      return;
    }

    final nameMapping = _mappings.firstWhere(
      (m) => m.assetFieldName == l10n.assetName,
      orElse: () =>
          ColumnMapping(assetFieldName: l10n.assetName, csvHeader: null),
    );

    if (nameMapping.csvHeader == null) {
      ToastService.error(l10n.errorNameMappingRequired);
      return;
    }

    setState(() => _isLoading = true);

    final List<dynamic> csvHeaders = _csvData.first;
    final Map<int, String> csvIndexToFinalKey = {};

    for (var map in _mappings) {
      final csvHeaderName = map.csvHeader;
      if (csvHeaderName != null) {
        final index = csvHeaders.indexOf(csvHeaderName);
        if (index != -1) {
          final assetField = map.assetFieldName;

          if (assetField == l10n.assetName) {
            csvIndexToFinalKey[index] = 'name';
          } else if (assetField == l10n.description) {
            csvIndexToFinalKey[index] = 'description';
          } else if (map.fixedKey != null) {
            csvIndexToFinalKey[index] = map.fixedKey!;
          } else if (map.assetFieldId != null) {
            csvIndexToFinalKey[index] = map.assetFieldId!;
          }
        }
      }
    }

    final List<List<dynamic>> dataRows = _csvData.sublist(1);
    final List<Map<String, dynamic>> itemsToUpload = [];

    final locationProvider = context.read<LocationProvider>();

    for (var row in dataRows) {
      final Map<String, dynamic> itemData = {
        'containerId': widget.containerId.toString(),
        'assetTypeId': widget.assetTypeId.toString(),
        'customFieldValues': {},
      };
      bool isValid = true;

      csvIndexToFinalKey.forEach((csvIndex, finalKey) {
        if (csvIndex < row.length) {
          final rawValue = row[csvIndex]?.toString().trim() ?? '';

          if (finalKey == 'name') {
            itemData['name'] = rawValue;
            if (rawValue.isEmpty) isValid = false;
          } else if (finalKey == 'description') {
            itemData['description'] = rawValue;
          } else if (finalKey == 'location') {
            final loc = locationProvider.locations.cast<Location?>().firstWhere(
              (l) => l!.name.toLowerCase() == rawValue.toLowerCase(),
              orElse: () => null,
            );
            if (loc != null) {
              itemData['locationId'] = loc.id.toString();
            }
          } else if (finalKey == 'quantity' ||
              finalKey == 'minStock' ||
              finalKey == 'marketValue') {
            if (rawValue.isNotEmpty) itemData[finalKey] = rawValue;
          } else if (finalKey == 'serialNumber' ||
              finalKey == 'barcode' ||
              finalKey == 'condition') {
            if (rawValue.isNotEmpty) itemData[finalKey] = rawValue;
          } else {
            itemData['customFieldValues'][finalKey] = rawValue;
          }
        }
      });

      if (itemData['name'] == null || itemData['name'].toString().isEmpty) {
        isValid = false;
      }
      if (isValid) itemsToUpload.add(itemData);
    }

    try {
      final inventoryItemProvider = context.read<InventoryItemProvider>();
      final result = await inventoryItemProvider.createBatchFromCSV(
        containerId: int.parse(widget.containerId),
        assetTypeId: int.parse(widget.assetTypeId),
        itemsToUpload: itemsToUpload,
      );

      if (mounted) {
        final isSerialized =
            result['assetType']?['isSerialized'] == true;
        if (isSerialized) {
          ToastService.info(l10n.importSerializedWarning);
        } else {
          ToastService.success(l10n.importSuccessMessage(itemsToUpload.length));
        }
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('${l10n.errorDuringImport}: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isResolvingAssetType) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(l10n.loadingAssetType),
            ],
          ),
        ),
      );
    }

    if (_assetType == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.loadingAssetType),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadAssetType,
                child: Text(l10n.retryLabel),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.importAssetsTo} "${_assetType!.name}"'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.step1SelectFile,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.chooseFile),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    _filePath ?? l10n.noFileSelected,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _filePath != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              l10n.step2ColumnMapping,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_csvHeaders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    l10n.pleaseSelectCsvWithHeaders,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mappings.length,
                itemBuilder: (context, index) {
                  final mapping = _mappings[index];
                  final List<String?> dropdownOptions = [null, ..._csvHeaders];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            mapping.assetFieldName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: mapping.csvHeader,
                            hint: Text(l10n.selectCsvColumn),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            items: dropdownOptions.map((header) {
                              return DropdownMenuItem<String>(
                                value: header,
                                child: Text(header ?? l10n.ignoreField),
                              );
                            }).toList(),
                            onChanged: (String? newValue) =>
                                setState(() => mapping.csvHeader = newValue),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: (_isLoading || _csvHeaders.isEmpty)
                    ? null
                    : _startImport,
                icon: const Icon(Icons.cloud_upload),
                label: Text(l10n.startImport),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
