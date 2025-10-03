import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';

import '../models/asset_type_model.dart';
import '../models/inventory_item.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';

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

  // Mapa para los controladores de campos custom
  final Map<int, TextEditingController> _customControllers = {};

  // NUEVO: Estado para gestionar las URLs de las imágenes
  final List<String> _imageUrls = [];
  
  AssetType? _assetType;
  int? _containerId;
  int? _assetTypeId;

  @override
  void initState() {
    super.initState();
    _containerId = int.tryParse(widget.containerId);
    _assetTypeId = int.tryParse(widget.assetTypeId);

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
        status: '',
      ),
    );

    final assetType = container.assetTypes.firstWhere(
      (at) => at.id == _assetTypeId,
      orElse: () => AssetType(id: -1, name: '', fieldDefinitions: []),
    );

    setState(() {
      _assetType = assetType;
      // Inicializa los controladores para cada campo custom
      for (var field in assetType.fieldDefinitions) {
        // Usamos field.id como clave; asumimos que no es nulo en un modelo AssetType válido
        _customControllers[field.id!] = TextEditingController(); 
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // --- LÓGICA DE GESTIÓN DE IMÁGENES (Simulación) ---

  /// Muestra un diálogo para simular la subida y captura de la URL de la imagen.
  void _addImage() {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Imagen (URL de prueba)'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'Introduce la URL o ruta de la imagen',
              labelText: 'URL de Imagen',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  setState(() {
                    _imageUrls.add(url);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  void _removeImage(String url) {
    setState(() {
      _imageUrls.remove(url);
    });
  }

  // --- LÓGICA DE GUARDADO ---

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate() || _assetType == null) {
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();

    // 1. Recoger los valores custom
    final Map<String, dynamic> customFieldValues = {};
    for (var fieldDef in _assetType!.fieldDefinitions) {
      final controller = _customControllers[fieldDef.id];
      if (controller != null && controller.text.isNotEmpty) {
        // En un entorno real, aquí se haría la validación de tipo (int, double, bool)
        customFieldValues[fieldDef.id.toString()] = controller.text;
      }
    }

    // 2. Crear el nuevo objeto InventoryItem
    // NOTA: El modelo InventoryItem actual de Flutter no incluye una lista de URLs de imágenes
    // directamente. En un entorno real, pasarías la lista de URLs al método del Provider/Service,
    // y este se encargaría de crear los modelos InventoryItemImage en el backend.
    
    final newItem = InventoryItem(
      id: 0,
      containerId: _containerId!,
      assetTypeId: _assetTypeId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      customFieldValues: customFieldValues,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // Aquí el InventoryItem debería incluir un campo para las imágenes,
      // pero como tu modelo Flutter no lo tiene, lo pasamos aparte:
    );

    // 3. Llamar al proveedor para guardar (se debe extender el provider para aceptar las URLs)
    try {
      // 🛑 NOTA IMPORTANTE: Si `createInventoryItem` solo acepta `InventoryItem`,
      // tendrás que modificar `InventoryItemProvider` para aceptar las URLs.
      // Por ahora, asumimos una nueva función para simular esto:
      await itemProvider.createInventoryItem(
        newItem,
        imageUrls: _imageUrls, // Pasamos las URLs para que el servicio las maneje
      ); 

      // 4. Navegar de vuelta al listado
      if (mounted) {
        ToastService.success('Activo creado con éxito!');
        context.go(
          '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al crear activo: ${e.toString()}');
      }
    }
  }

  // --- WIDGET DE IMÁGENES ---

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imágenes del Activo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        
        // Botón para añadir imagen
        ElevatedButton.icon(
          onPressed: _addImage,
          icon: const Icon(Icons.image),
          label: const Text('Añadir Imagen'),
        ),
        const SizedBox(height: 10),

        // Previsualización de imágenes (Grid)
        if (_imageUrls.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _imageUrls.map((url) {
              return Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Muestra un placeholder si la URL no es una imagen válida
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image, size: 40, color: Colors.red),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  url.substring(0, 10) + '...',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                      onPressed: () => _removeImage(url),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white70,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(30, 30),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('No hay imágenes añadidas.'),
          ),
      ],
    );
  }

  // --- WIDGET PRINCIPAL (BUILD) ---

  @override
  Widget build(BuildContext context) {
    if (_assetType == null) {
      context.watch<ContainerProvider>();
      if (_containerId == null || _assetTypeId == null) {
        return const Center(child: Text('IDs no válidos.'));
      }
      _initializeForm();
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TÍTULO ---
            Text(
              'Crear Activo: ${_assetType!.name}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CAMPOS COMUNES ---
                    const Text(
                      'Datos Comunes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Activo',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    // --- SECCIÓN DE IMÁGENES ---
                    _buildImageSection(),
                    const SizedBox(height: 30),

                    // --- CAMPOS CUSTOM (DINÁMICOS) ---
                    const Text(
                      'Campos Personalizados',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    if (_assetType!.fieldDefinitions.isEmpty)
                      const Text('Este tipo de activo no tiene campos personalizados.'),

                    ..._assetType!.fieldDefinitions.map((fieldDef) {
                      final controller = _customControllers[fieldDef.id];
                      if (controller == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
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
                ),
              ),
            ),

            // --- BOTÓN DE GUARDAR ---
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _saveAsset,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Guardar Activo',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
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
}