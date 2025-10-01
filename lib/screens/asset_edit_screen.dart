import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';
import '../models/inventory_item.dart';
import '../models/container_node.dart';
import '../models/asset_type_model.dart';
import '../providers/container_provider.dart';
import '../providers/inventory_item_provider.dart';

// Definición del Widget de la Pantalla de Edición
class AssetEditScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;
  final String assetItemId;
  final InventoryItem? initialItem; // Item que se pasa como 'extra'

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

  // 1. Controller para el campo de nombre fijo
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  // 2. Mapa de controllers para campos dinámicos (Clave: FieldDefinition.id)
  late Map<int, TextEditingController> _dynamicControllers;

  // El AssetType que define la estructura de campos
  AssetType? _assetType;

  @override
  void initState() {
    super.initState();

    // Inicializar el controller del nombre con el valor existente
    _nameController = TextEditingController(
      text: widget.initialItem?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialItem?.description ?? '',
    );
    _dynamicControllers = {};

    // 💡 La inicialización del AssetType y los campos dinámicos
    // debe esperar al `didChangeDependencies` para acceder al Provider.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_assetType == null) {
      _initializeDynamicFields();
    }
  }

  // Método para obtener el AssetType y crear los controladores dinámicos
  void _initializeDynamicFields() {
    final containerProvider = context.read<ContainerProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) return;

    // Buscar el Container y el AssetType
    final container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);

    final assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
      (at) => at?.id == atIdInt,
      orElse: () => null,
    );

    if (assetType != null) {
      setState(() {
        _assetType = assetType;

        // Inicializar controllers dinámicos, pre-rellenando con los valores del ítem
        for (var fieldDef in assetType.fieldDefinitions) {
          final initialValue =
              widget.initialItem?.customFieldValues[fieldDef.id.toString()] ??
              '';
          _dynamicControllers[fieldDef.id ?? 0] = TextEditingController(
            text: initialValue.toString(),
          );
        }
      });
    }
  }

  // --- LÓGICA DE EDICIÓN Y GUARDADO ---
  void _saveAsset() async {
    if (!_formKey.currentState!.validate() || widget.initialItem == null) {
      return;
    }

    final itemProvider = context.read<InventoryItemProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    if (cIdInt == null || atIdInt == null) return;

    // 1. Crear el mapa de valores actualizados para campos personalizados
    final Map<String, dynamic> updatedCustomValues = {};
    _dynamicControllers.forEach((fieldId, controller) {
      updatedCustomValues[fieldId.toString()] = controller.text;
    });

    // 2. Crear el objeto InventoryItem actualizado
    final updatedItem = InventoryItem(
      id: widget.initialItem!.id,
      containerId: cIdInt,
      assetTypeId: atIdInt,
      name: _nameController.text,
      description: _descriptionController.text,
      customFieldValues: updatedCustomValues,
    );

    // 3. Llamar al Provider para actualizar el ítem
    await itemProvider.updateInventoryItem(updatedItem, atIdInt);

    // 4. Navegar de vuelta a la lista y mostrar confirmación
    if (mounted) {
      context.go(
        '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets',
      );
      ToastService.success('Activo "${updatedItem.name}" actualizado correctamente.');
    }
  }
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget.initialItem == null || _assetType == null) {
      // Manejo de estado: si el ítem no se encontró o el AssetType no se cargó
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Activo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // El nombre se extrae del initialItem
    final assetName = widget.initialItem!.name;

    return Scaffold(
      appBar: AppBar(title: Text('Editar Activo: $assetName')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. CAMPO DE NOMBRE FIJO ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Activo',
                  border: OutlineInputBorder(),
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Activo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                'Campos Personalizados de ${_assetType!.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: 20),

              // --- 2. CAMPOS DINÁMICOS ---
              ..._assetType!.fieldDefinitions.map((fieldDef) {
                final controller = _dynamicControllers[fieldDef.id]!;

                // Nota: La validación y el tipo de widget (Text, Number, Date, etc.)
                // deberían basarse en fieldDef.fieldType. Aquí usamos un Text genérico.
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: fieldDef
                          .name, // Usar el nombre de la definición del campo
                      hintText: 'Tipo: ${fieldDef.type}',
                      border: const OutlineInputBorder(),
                    ),
                    // Ejemplo de validación simple
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),

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

  @override
  void dispose() {
    _nameController.dispose();
    // Liberar los controllers dinámicos
    _dynamicControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
