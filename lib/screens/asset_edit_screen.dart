import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/services/ai_service.dart';
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/utils/asset_form_utils.dart';
import 'package:invenicum/widgets/location_dropdown_widget.dart';
import 'package:invenicum/widgets/magic_ai_dialog_widget.dart';
import 'package:provider/provider.dart';
import '../models/asset_type_model.dart';
import '../models/container_node.dart';
import '../models/inventory_item.dart';
import '../models/location.dart'; // 🔑 NUEVO: Importar modelo Location
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';
import '../services/toast_service.dart';
import 'package:invenicum/widgets/image_preview_section.dart'; // Tu widget de previsualización
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
  // WIDGETS AUXILIARES PARA LA UI (Sin cambios en custom fields)
  // ----------------------------------------------------

  Widget _buildCustomFields() {
    if (_assetType == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.customFieldsOf(_assetType!.name),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(height: 20),
        if (_assetType!.fieldDefinitions.isEmpty)
          const Text('Este tipo de activo no tiene campos personalizados.'),

        ..._assetType!.fieldDefinitions.map((fieldDef) {
          final fieldId = fieldDef.id!;

          // 🔑 1. Campo DROPDOWN
          if (fieldDef.type == CustomFieldType.dropdown) {
            final values = _listFieldValues[fieldId];
            final selectedValue = _selectedListValues[fieldId];

            if (values == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 10),
                    Text('Cargando ${fieldDef.name}...'),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  labelText: fieldDef.name,
                  border: const OutlineInputBorder(),
                  filled: _highlightedFields.contains(fieldDef.name),
                  fillColor: Colors.green.withValues(alpha: 0.1),
                  helperText: fieldDef.isRequired
                      ? AppLocalizations.of(context)!.obligatory
                      : AppLocalizations.of(context)!.optional,
                ),
                items: values.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedListValues[fieldId] = newValue;
                  });
                },
                validator: (value) {
                  if (fieldDef.isRequired && value == null) {
                    return AppLocalizations.of(context)!.thisFieldIsRequired;
                  }
                  return null;
                },
              ),
            );
          }

          // 🔑 2. Campo BOOLEANO
          if (fieldDef.type == CustomFieldType.boolean) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormField<bool>(
                initialValue: _booleanValues[fieldId],
                validator: (value) {
                  if (fieldDef.isRequired && value == null) {
                    return AppLocalizations.of(context)!.thisFieldIsRequired;
                  }
                  return null;
                },
                builder: (FormFieldState<bool> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      helperText: fieldDef.isRequired
                          ? AppLocalizations.of(context)!.obligatory
                          : AppLocalizations.of(context)!.optional,
                      errorText: state.errorText,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: CheckboxListTile(
                      title: Text(fieldDef.name),
                      value: state.value ?? false,
                      onChanged: (newValue) {
                        setState(() {
                          _booleanValues[fieldId] = newValue;
                          state.didChange(newValue);
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  );
                },
              ),
            );
          }

          // 3. Otros campos (Texto, Número, URL, etc.)
          final controller = _dynamicControllers[fieldDef.id];
          final preferences = context.read<PreferencesProvider>();
          if (controller == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: TextFormField(
              controller: controller,
              keyboardType: fieldDef.type.keyboardType,
              inputFormatters: AssetFormUtils.getInputFormatters(fieldDef.type),
              decoration: InputDecoration(
                labelText: fieldDef.name,
                prefixText: fieldDef.type == CustomFieldType.price
                    ? '${preferences.getSymbolForCurrency(preferences.selectedCurrency)} '
                    : null,
                border: const OutlineInputBorder(),
                helperText: fieldDef.isRequired ? 'Obligatorio' : 'Opcional',
                hintText: AssetFormUtils.getHintText(fieldDef.type),
              ),
              validator: (value) {
                if (fieldDef.isRequired && (value == null || value.isEmpty)) {
                  return 'Este campo es obligatorio.';
                }
                return fieldDef.type.validateValue(value);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  // ----------------------------------------------------
  // BUILD METHOD PRINCIPAL
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Si _assetType no está cargado o initialItem es null, muestra un indicador de carga.
    // Usamos context.watch para asegurarnos de que el widget se reconstruya si el proveedor cambia.
    context.watch<ContainerProvider>();
    if (_assetType == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando Activo...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final assetName = currentItem!.name;
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;
    return Scaffold(
      appBar: AppBar(title: Text('Editar Activo: $assetName')),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TÍTULO ---
              Text(
                'Editando Activo: ${currentItem!.name}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (aiEnabled)
                Align(
                  alignment: Alignment.centerRight,
                  child: _isMagicLoading
                      ? ElevatedButton.icon(
                          onPressed: null,
                          icon: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.amber,
                            ),
                          ),
                          label: const Text('Analizando...'),
                        )
                      : ElevatedButton.icon(
                          key: const ValueKey('idle'),
                          onPressed: _showMagicDialog,
                          icon: const Icon(
                            Icons.auto_awesome,
                            color: Colors.amber,
                          ),
                          label: const Text('Rellenar con IA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade100,
                            foregroundColor: Colors.amber.shade900,
                          ),
                        ),
                ),
              const SizedBox(height: 30),

              // 🔑 NUEVO: Selector de Ubicación
              LocationDropdownField(
                availableLocations: _availableLocations,
                selectedLocationId: _selectedLocationId,
                onChanged: (newValue) {
                  setState(() {
                    _selectedLocationId = newValue;
                  });
                },
                // El validador por defecto ya se encarga de que no sea nulo si es obligatorio (y lo es)
              ),
              const SizedBox(height: 30),

              // --- 1. CAMPOS FIJOS ---
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Activo',
                  border: const OutlineInputBorder(),
                  filled: _highlightedFields.contains('name'), // 🔑 EFECTO IA
                  fillColor: Colors.green.withValues(alpha: 0.1),
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
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Código de Barras / UPC',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code_scanner),
                  filled: _highlightedFields.contains('barcode'),
                  fillColor: Colors.green.withValues(alpha: 0.1),
                  helperText: 'Código identificador del producto',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción del Activo',
                  border: const OutlineInputBorder(),
                  filled: _highlightedFields.contains(
                    'description',
                  ), // 🔑 EFECTO IA
                  fillColor: Colors.green.withValues(alpha: 0.1),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // 🔑 NUEVA: Campo de Cantidad (solo si no es seriado)
              if (!_assetType!.isSerialized)
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                    helperText: 'Cantidad disponible del artículo',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor introduce una cantidad.';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 1) {
                      return 'La cantidad debe ser mayor a 0.';
                    }
                    return null;
                  },
                ),
              if (_assetType!.isSerialized)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este es un artículo seriado. La cantidad es fija a 1.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),

              // 🔑 NUEVA: Campo de Stock Mínimo (solo si no es seriado)
              if (!_assetType!.isSerialized)
                TextFormField(
                  controller: _minStockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Mínimo',
                    border: OutlineInputBorder(),
                    helperText: 'Cantidad mínima recomendada del artículo',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor introduce un stock mínimo.';
                    }
                    final minStock = int.tryParse(value);
                    if (minStock == null || minStock < 1) {
                      return 'El stock mínimo debe ser mayor a 0.';
                    }
                    return null;
                  },
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
