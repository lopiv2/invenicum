// lib/screens/locations/location_create_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/location_provider.dart';

class LocationCreateScreen extends StatefulWidget {
  final String containerId;
  final int? initialParentId;

  const LocationCreateScreen({
    super.key,
    required this.containerId,
    this.initialParentId,
  });

  @override
  State<LocationCreateScreen> createState() => _LocationCreateScreenState();
}

class _LocationCreateScreenState extends State<LocationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedParentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedParentId = widget.initialParentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Lógica de Guardado (Integración con Provider) ---
  void _saveLocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final locationProvider = context.read<LocationProvider>();
      final containerProvider = context.read<ContainerProvider>();

      // LLAMADA AL SERVICE REAL A TRAVÉS DEL PROVIDER
      final newLocation = await locationProvider.createLocation(
        containerId: int.parse(widget.containerId),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        parentId: _selectedParentId, context: context,
      );
      await containerProvider.loadDataLists(int.parse(widget.containerId));

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ubicación "${newLocation?.name}" creada exitosamente.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        // Volver a la pantalla anterior
        context.pop();
      }
    } catch (e) {
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 USAMOS CONTEXT.WATCH para obtener la lista de ubicaciones disponibles
    final locationProvider = context.watch<LocationProvider>();
    final allLocations = locationProvider.locations;
    final isLoading = locationProvider.isLoading;

    // Si está cargando y la lista está vacía, mostramos un indicador
    if (isLoading && allLocations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Crear Nueva Ubicación'),
          backgroundColor: Colors.teal,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Filtramos las ubicaciones para excluir la que se está creando (si fuera una edición)
    // y asegurarnos que solo mostramos ubicaciones que pertenecen al contenedor actual (asumiendo que LocationsScreen ya filtró).
    // Aquí usamos la lista tal cual, asumiendo que el provider solo tiene las del containerId.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Ubicación'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Campo Nombre ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Ubicación',
                  hintText: 'Ej: Estantería B3, Sala de Servidores',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Campo Descripción ---
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Detalles de acceso, tipo de contenido, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // --- Campo Ubicación Padre (Dropdown) ---
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Ubicación Padre (Contiene a esta)',
                  border: OutlineInputBorder(),
                ),
                value: _selectedParentId,
                hint: const Text('Ningún padre (Ubicación Raíz)'),
                // 🔑 Usamos la lista 'allLocations' obtenida del Provider
                items: [
                  // Opción para no tener padre (Raíz)
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Ninguno (Raíz del Esquema)'),
                  ),
                  // Lista de ubicaciones existentes
                  ...allLocations.map((loc) {
                    return DropdownMenuItem<int>(
                      value: loc.id,
                      child: Text(loc.name),
                    );
                  }).toList(),
                ],
                onChanged: _isSaving
                    ? null // Deshabilitar si se está guardando
                    : (newValue) {
                        setState(() {
                          _selectedParentId = newValue;
                        });
                      },
              ),
              const SizedBox(height: 40),

              // --- Botón de Guardar ---
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveLocation,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Guardando...' : 'Guardar Ubicación',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
