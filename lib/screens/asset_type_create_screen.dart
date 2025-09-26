// lib/screens/asset_type_create_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/widgets/custom_field_editor.dart';
import 'package:provider/provider.dart';
import '../models/list_data.dart'; // Necesitas el modelo de Lista de Datos
import '../providers/container_provider.dart'; // Para obtener Listas de Datos disponibles

class AssetTypeCreateScreen extends StatefulWidget {
  final String containerId;

  const AssetTypeCreateScreen({super.key, required this.containerId});

  @override
  State<AssetTypeCreateScreen> createState() => _AssetTypeCreateScreenState();
}

class _AssetTypeCreateScreenState extends State<AssetTypeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController =
      TextEditingController(); // Nuevo controlador para la URL de la imagen

  List<CustomFieldDefinition> _fieldDefinitions = [];
  List<ListData> _availableDataLists = [];
  bool _isLoadingLists = true;

  // Estado para la URL de la imagen que se muestra en la vista previa
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadDataLists();
    // Escuchar cambios en el controlador de la URL para actualizar la vista previa
    _imageUrlController.addListener(_updateImagePreview);
  }

  // Actualiza el estado de _currentImageUrl para la vista previa
  void _updateImagePreview() {
    setState(() {
      final url = _imageUrlController.text;
      // Una validación simple para asegurarse de que es una URL "razonable"
      if (Uri.tryParse(url)?.hasAbsolutePath == true) {
        _currentImageUrl = url;
      } else {
        _currentImageUrl = null; // Limpiar si no es una URL válida
      }
    });
  }

  // Carga las listas de datos disponibles del contenedor
  void _loadDataLists() {
    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.tryParse(widget.containerId);

    if (containerIdInt != null) {
      final container = containerProvider.containers.firstWhere(
        (c) => c.id == containerIdInt,
        orElse: () => throw Exception("Container not found"),
      );
      setState(() {
        _availableDataLists = container.dataLists;
        _isLoadingLists = false;
      });
    } else {
      setState(() {
        _isLoadingLists = false;
      });
    }
  }

  void _addNewField() {
    setState(() {
      _fieldDefinitions.add(
        CustomFieldDefinition(
          id: 0,
          name: 'Nuevo Campo ${_fieldDefinitions.length + 1}',
          type: CustomFieldType.text,
          isRequired: false,
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      _fieldDefinitions.removeAt(index);
    });
  }

  void _saveAssetType() async {
    if (_formKey.currentState!.validate()) {
      final containerProvider = context.read<ContainerProvider>();
      final containerIdInt = int.tryParse(widget.containerId);
      if (containerIdInt == null) return;

      final newTypeName = _nameController.text;
      final newImageUrl =
          _currentImageUrl; // Usamos la URL validada para el AssetType

      try {
        await containerProvider.addNewAssetTypeToContainer(
          containerId: containerIdInt,
          name: newTypeName,
          imageUrl: newImageUrl,
          fieldDefinitions:
              _fieldDefinitions, // Pasamos la lista de definiciones
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tipo de Activo "${newTypeName}" creado exitosamente en el servidor.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/container/${widget.containerId}/asset-types');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al crear el Tipo de Activo: ${e.toString()}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.removeListener(_updateImagePreview); // Quitar listener
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Nuevo Tipo de Activo',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- Campo de Nombre ---
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Tipo de Activo',
                hintText: 'Ej: Ordenador Portátil, Sustancia Química',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // --- Sección de Imagen (URL y Previsualización) ---
            Text(
              'Imagen del Tipo de Activo (URL)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de la Imagen',
                      hintText: 'Ej: https://ejemplo.com/mi_imagen.png',
                      border: OutlineInputBorder(),
                    ),
                    // No es estrictamente necesario validar aquí si la URL existe,
                    // ya que Image.network manejará los errores visualmente.
                    // Podrías añadir un validador de formato de URL si lo deseas.
                  ),
                ),
                const SizedBox(width: 20),
                // --- Vista Previa de la Imagen ---
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:
                      _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(
                            _currentImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Previsualización',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- Editor de Campos Dinámicos ---
            Text(
              'Definición de Campos Personalizados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),

            _isLoadingLists
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _fieldDefinitions.length,
                    itemBuilder: (context, index) {
                      final field = _fieldDefinitions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CustomFieldEditor(
                          field: field,
                          availableDataLists: _availableDataLists,
                          onDelete: () => _removeField(index),
                          onUpdate: (updatedField) {
                            setState(() {
                              _fieldDefinitions[index] = updatedField;
                            });
                          },
                        ),
                      );
                    },
                  ),

            TextButton.icon(
              onPressed: _addNewField,
              icon: const Icon(Icons.add_box),
              label: const Text('Añadir Nuevo Campo'),
            ),
            const SizedBox(height: 40),

            // --- Botón de Guardar ---
            ElevatedButton.icon(
              onPressed: _saveAssetType,
              icon: const Icon(Icons.save),
              label: const Text(
                'Crear Tipo de Activo',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
