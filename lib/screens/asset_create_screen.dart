import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/location.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/services/ai_service.dart';
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/utils/asset_form_utils.dart';
import 'package:invenicum/widgets/image_preview_section.dart';
import 'package:invenicum/widgets/location_dropdown_widget.dart';
import 'package:invenicum/widgets/magic_ai_dialog_widget.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/asset_type_model.dart';
import '../models/container_node.dart';
import '../models/inventory_item.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';
import '../services/toast_service.dart';

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

class _AssetCreateScreenState extends State<AssetCreateScreen> {
  // Controles para los campos comunes
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController(
    text: '1',
  ); // 🔑 NUEVA: Controlador de cantidad
  final _minStockController = TextEditingController(
    text: '1',
  ); // 🔑 NUEVA: Controlador de stock mínimo
  bool _isMagicLoading = false;
  Set<String> _highlightedFields = {};

  // 🔑 ESTADO DE UBICACIÓN
  List<Location> _availableLocations = []; // Lista de ubicaciones disponibles
  int? _selectedLocationId; // ID de la ubicación seleccionada

  // Mapa para los controladores de campos custom
  final Map<int, TextEditingController> _customControllers = {};
  final Map<int, List<String>> _listFieldValues =
      {}; // Valores de las listas desplegables
  final Map<int, String?> _selectedListValues = {}; // Valores seleccionados

  final Map<int, bool> _booleanFieldValues = {};
  final ScrollController _scrollController = ScrollController();

  // Estado para gestionar las URLs de previsualización (Base64)
  List<String> _imagePreviewUrls = [];

  AssetType? _assetType;
  int? _containerId;
  int? _assetTypeId;
  late AIService _aiService;

  @override
  void initState() {
    super.initState();
    _containerId = int.tryParse(widget.containerId);
    _assetTypeId = int.tryParse(widget.assetTypeId);
    _aiService = AIService(context.read<ApiService>());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
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
        locations: [], // Asegurarse de que el orElse maneje Locations
        status: '',
      ),
    );

    final assetType = container.assetTypes.firstWhere(
      (at) => at.id == _assetTypeId,
      orElse: () => AssetType(id: -1, name: '', fieldDefinitions: []),
    );

    setState(() {
      _assetType = assetType;
      // 🔑 CARGAR UBICACIONES
      _availableLocations = container.locations;
      // 🔑 Inicializar la ubicación seleccionada (opcionalmente a la primera o null)
      _selectedLocationId = _availableLocations.isNotEmpty
          ? _availableLocations.first.id
          : null;

      // Inicializa los controladores para cada campo custom
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
  }

  Future<void> _runMagicAI(String url) async {
    if (_assetType == null) return;

    setState(() => _isMagicLoading = true);

    try {
      // 1. Obtener nombres de campos personalizados
      final List<String> fieldsToExtract = _assetType!.fieldDefinitions
          .map((f) => f.name)
          .toList();

      // 💡 AÑADIMOS ESTO: Forzamos a la IA a buscar códigos de barras
      if (!fieldsToExtract.any((f) => f.toLowerCase() == 'barcode'))
        fieldsToExtract.add('barcode');
      if (!fieldsToExtract.any((f) => f.toLowerCase() == 'upc'))
        fieldsToExtract.add('upc');

      final Map<String, dynamic> result = await _aiService.extractDataFromUrl(
        url: url,
        fields: fieldsToExtract,
      );

      // Normalizamos las llaves a minúsculas para que UPC, upc, Upc... todo valga.
      final lowerCaseResult = result.map(
        (key, value) => MapEntry(key.toLowerCase(), value),
      );

      setState(() {
        // 2. Imagen (Soportamos varias llaves posibles)
        final imageUrl =
            lowerCaseResult['imageurl'] ??
            lowerCaseResult['image'] ??
            lowerCaseResult['thumbnail'];
        if (imageUrl != null && imageUrl.toString().startsWith('data:image')) {
          _imagePreviewUrls.add(imageUrl.toString());
        }

        // 3. Nombre y Descripción
        if (lowerCaseResult['name'] != null) {
          _nameController.text = lowerCaseResult['name'].toString();
          _highlightedFields.add('name');
        }
        if (lowerCaseResult['description'] != null) {
          _descriptionController.text = lowerCaseResult['description']
              .toString();
          _highlightedFields.add('description');
        }

        // 4. Código de Barras / UPC / EAN (Limpiando espacios y guiones)
        final dynamic barcodeValue =
            lowerCaseResult['barcode'] ??
            lowerCaseResult['upc'] ??
            lowerCaseResult['ean'];
        if (barcodeValue != null) {
          // 💡 LIMPIEZA: Eliminamos cualquier cosa que no sea un número o letra
          _barcodeController.text = barcodeValue.toString().replaceAll(
            RegExp(r'[^a-zA-Z0-9]'),
            '',
          );
          _highlightedFields.add('barcode');
        }

        // 5. Rellenar campos personalizados dinámicos
        for (var fieldDef in _assetType!.fieldDefinitions) {
          final key = fieldDef.name;
          // Aquí buscamos en el 'result' original para respetar mayúsculas si el usuario las definió así
          if (!result.containsKey(key) || result[key] == null) continue;

          final value = result[key];
          _highlightedFields.add(key);

          if (fieldDef.type == CustomFieldType.boolean) {
            _booleanFieldValues[fieldDef.id!] = value is bool
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
            final controller = _customControllers[fieldDef.id];
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
        ToastService.error('Error al cargar los valores de la lista: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _customControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // --- LÓGICA DE GESTIÓN DE IMÁGENES ---

  Future<void> _addImage() async {
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
          _imagePreviewUrls.addAll(newImageUrls);
        });

        ToastService.info('Se seleccionaron $successfulSelections imágenes.');
      } else {
        ToastService.error(
          'Error: No se pudo obtener la data de las imágenes seleccionadas.',
        );
      }
    } else {
      ToastService.info('Selección de archivos cancelada.');
    }
  }

  void _showMagicDialog() async {
    // Mostramos el diálogo y esperamos el resultado (la URL)
    final String? url = await showDialog<String>(
      context: context,
      builder: (context) => const MagicAiDialog(),
    );

    // Si el usuario no canceló y la URL no es nula, ejecutamos la lógica
    if (url != null && url.isNotEmpty) {
      _runMagicAI(url);
    }
  }

  void _removeImage(String url) {
    setState(() {
      _imagePreviewUrls.remove(url);
    });
  }

  Future<void> _saveAsset() async {
    // 🔑 1. VALIDACIÓN ADICIONAL DE UBICACIÓN
    if (!AssetFormUtils.validateForm(_formKey) ||
        _assetType == null ||
        _selectedLocationId ==
            null // 🔑 Debe haber una ubicación seleccionada
            ) {
      if (_selectedLocationId == null) {
        if (mounted) {
          ToastService.error('Debe seleccionar una ubicación para el activo.');
        }
      }
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();

    // 2. Recoger los valores custom (sin cambios)
    final Map<String, dynamic> customFieldValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      if (fieldDef.type == CustomFieldType.dropdown) {
        final selectedValue = _selectedListValues[fieldDef.id];
        if (selectedValue != null) {
          customFieldValues[fieldDef.id.toString()] = selectedValue;
        }
      } else if (fieldDef.type == CustomFieldType.boolean) {
        final value = _booleanFieldValues[fieldDef.id];
        if (value != null) {
          customFieldValues[fieldDef.id.toString()] = value;
        }
      } else {
        final controller = _customControllers[fieldDef.id];
        if (controller != null && controller.text.isNotEmpty) {
          customFieldValues[fieldDef.id.toString()] = controller.text;
        }
      }
    }

    // 3. Preparar los datos de los archivos
    final filesData = AssetFormUtils.processImages(_imagePreviewUrls);

    // 4. Crear el nuevo objeto InventoryItem
    final newItem = InventoryItem(
      id: 0,
      containerId: _containerId!,
      assetTypeId: _assetTypeId!,
      barcode: _barcodeController.text.trim(),
      locationId:
          _selectedLocationId, // 🔑 Ahora puede ser null si no hay ubicaciones
      quantity:
          int.tryParse(_quantityController.text) ??
          1, // 🔑 NUEVA: Obtener cantidad del controlador
      minStock:
          int.tryParse(_minStockController.text) ??
          1, // 🔑 NUEVA: Obtener minStock del controlador
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      customFieldValues: customFieldValues,
      // images es null por defecto en creación
    );

    // 5. Llamar al proveedor para guardar con los archivos
    try {
      await itemProvider.createInventoryItem(newItem, filesData: filesData);

      // 6. Navegar de vuelta al listado
      if (mounted) {
        ToastService.success('Activo creado con éxito!');
        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      if (mounted) {
        print('Error al crear activo: $e');
        ToastService.error('Error al crear activo: ${e.toString()}');
      }
    }
  }

  // --- WIDGETS DE VISTA (buildCustomFields sin cambios) ---

  Widget _buildCustomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.customFields,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        if (_assetType!.fieldDefinitions.isEmpty)
          Text(AppLocalizations.of(context)!.noCustomFields),

        ..._assetType!.fieldDefinitions.map((fieldDef) {
          if (fieldDef.type == CustomFieldType.boolean) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CheckboxListTile(
                title: Text(fieldDef.name),
                subtitle: fieldDef.isRequired
                    ? Text(AppLocalizations.of(context)!.obligatory)
                    : null,
                value: _booleanFieldValues[fieldDef.id] ?? false,
                onChanged: (bool? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _booleanFieldValues[fieldDef.id!] = newValue;
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          }
          if (fieldDef.type == CustomFieldType.dropdown) {
            final values = _listFieldValues[fieldDef.id] ?? [];
            final selectedValue = _selectedListValues[fieldDef.id];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  labelText: fieldDef.name,
                  border: const OutlineInputBorder(),
                  helperText: fieldDef.isRequired ? 'Obligatorio' : null,
                ),
                items: values.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedListValues[fieldDef.id!] = newValue;
                  });
                },
                validator: (value) {
                  if (fieldDef.isRequired && value == null) {
                    return 'Este campo es obligatorio.';
                  }
                  return null;
                },
              ),
            );
          }

          final controller = _customControllers[fieldDef.id];
          if (controller == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: controller,
              keyboardType: fieldDef.type.keyboardType,
              inputFormatters: AssetFormUtils.getInputFormatters(fieldDef.type),
              decoration: InputDecoration(
                labelText: fieldDef.name,
                hintText: AssetFormUtils.getHintText(fieldDef.type),
                border: const OutlineInputBorder(),
                filled: _highlightedFields.contains(fieldDef.name),
                fillColor: Colors.green.withOpacity(0.1),
                helperText: fieldDef.isRequired ? 'Obligatorio' : null,
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

  @override
  Widget build(BuildContext context) {
    // Escuchar al proveedor para reconstrucción en caso de recarga de datos
    context.watch<ContainerProvider>();
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;
    if (_assetType == null || _containerId == null || _assetTypeId == null) {
      // Intenta inicializar de nuevo si el assetType es nulo (puede ser la primera carga)
      if (_assetType == null) {
        _initializeForm();
      }
      return Scaffold(
        appBar: AppBar(title: Text('Crear Activo')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final theme = Theme.of(context); // 🎨 Tu tema personalizado
    // 🔑 Se envuelve la vista en un Scaffold para ser una pantalla completa
    return Scaffold(
      appBar: AppBar(title: Text('Crear Activo: ${_assetType!.name}')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: aiEnabled
                            ? AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _isMagicLoading
                                    ? ElevatedButton.icon(
                                        key: const ValueKey('loading'),
                                        onPressed:
                                            null, // Deshabilitado mientras carga
                                        icon: const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        label: const Text('Analizando web...'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber.shade50,
                                          disabledBackgroundColor:
                                              Colors.amber.shade50,
                                        ),
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
                                          backgroundColor:
                                              Colors.amber.shade100,
                                          foregroundColor:
                                              Colors.amber.shade900,
                                          side: BorderSide(
                                            color: Colors.amber.shade300,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      // --- CAMPOS COMUNES ---
                      const Text(
                        'Datos Comunes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),

                      // 🔑 NUEVO: Selector de Ubicación
                      LocationDropdownField(
                        availableLocations: _availableLocations,
                        selectedLocationId: _selectedLocationId,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocationId = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Activo',
                          border: OutlineInputBorder(),
                          filled: _highlightedFields.contains('name'),
                          fillColor: Colors.green.withOpacity(0.1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor introduce un nombre.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción (Opcional)',
                          filled: _highlightedFields.contains('description'),
                          fillColor: Colors.green.withOpacity(0.1),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Barras (Opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code_scanner),
                          helperText:
                              'Escanée o introduzca el código del producto',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
                              color: theme.secondaryHeaderColor,
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
                      const SizedBox(height: 16),

                      // 🔑 NUEVA: Campo de Stock Mínimo (solo si no es seriado)
                      if (!_assetType!.isSerialized)
                        TextFormField(
                          controller: _minStockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock Mínimo',
                            border: OutlineInputBorder(),
                            helperText:
                                'Cantidad mínima recomendada del artículo',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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

                      // --- SECCIÓN DE IMÁGENES ---
                      ImagePreviewSection(
                        imageUrls: _imagePreviewUrls,
                        onAddImage: _addImage,
                        onRemoveImage: _removeImage,
                      ),
                      const SizedBox(height: 30),

                      // --- CAMPOS CUSTOM (Dinámicos) ---
                      _buildCustomFields(),
                    ],
                  ),
                ),
              ),

              // --- BOTÓN DE GUARDAR ---
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: _saveAsset,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar Activo',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
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
