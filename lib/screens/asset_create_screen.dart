import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/container_node.dart';
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

  AssetType? _assetType;
  int? _containerId;
  int? _assetTypeId;

  @override
  void initState() {
    super.initState();
    _containerId = int.tryParse(widget.containerId);
    _assetTypeId = int.tryParse(widget.assetTypeId);
    
    // Programamos la inicialización después del primer frame para usar context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    if (_containerId == null || _assetTypeId == null) return;

    // Obtenemos el tipo de activo de forma no reactiva
    final containerProvider = context.read<ContainerProvider>();
    final container = containerProvider.containers
 .firstWhere((c) => c.id == _containerId, orElse: () => ContainerNode(id: -1, name: '', description: '', assetTypes: [], dataLists: [], status: '')); // Proporcionar un valor predeterminado

    if (container != null) {
      final assetType = container.assetTypes
 .firstWhere((at) => at.id == _assetTypeId, orElse: () => AssetType(id: -1, name: '', fieldDefinitions: [])); // Proporcionar un valor predeterminado

      if (assetType != null) {
        setState(() {
          _assetType = assetType;
          // Inicializa los controladores para cada campo custom
          for (var field in assetType.fieldDefinitions) {
            _customControllers[field.id ?? 0] = TextEditingController();
          }
        });
      }
    }
  }
  
  // Limpia los controladores cuando el widget es desechado
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Lógica para guardar el nuevo activo
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
    final newItem = InventoryItem(
      // El ID será generado por la DB/API
      id: 0, 
      containerId: _containerId!,
      assetTypeId: _assetTypeId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      customFieldValues: customFieldValues,
      // Los campos de fecha se establecerán en la API
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 3. Llamar al proveedor para guardar (simulado o real)
    try {
      await itemProvider.createInventoryItem(newItem);
      
      // 4. Navegar de vuelta al listado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activo creado con éxito!')),
        );
        // Regresa a la lista de activos
        context.go('/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear activo: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_assetType == null) {
      // Usamos el watch para que si el provider carga los contenedores tarde, 
      // la pantalla intente inicializarse de nuevo.
      context.watch<ContainerProvider>(); 
      if (_containerId == null || _assetTypeId == null) {
        return const Center(child: Text('IDs no válidos.'));
      }
      // Reintentamos la inicialización si el tipo de activo aún no está cargado
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CAMPOS COMUNES ---
                    const Text('Datos Comunes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre del Activo', border: OutlineInputBorder()),
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
                      decoration: const InputDecoration(labelText: 'Descripción (Opcional)', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    // --- CAMPOS CUSTOM (DINÁMICOS) ---
                    const Text('Campos Personalizados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                label: const Text('Guardar Activo', style: TextStyle(fontSize: 16)),
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
      // case 'boolean': // Los booleanos se manejarían con Checkbox/Switch, no con TextFormField
      default:
        return TextInputType.text;
    }
  }
}