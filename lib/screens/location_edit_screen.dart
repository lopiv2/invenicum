// lib/screens/locations/location_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/models/location.dart';
import 'package:invenicum/providers/location_provider.dart';

class LocationEditScreen extends StatefulWidget {
  final Location location; // Ubicación existente a editar
  final String containerId;

  const LocationEditScreen({
    super.key,
    required this.location,
    required this.containerId,
  });

  @override
  State<LocationEditScreen> createState() => _LocationEditScreenState();
}

class _LocationEditScreenState extends State<LocationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  int? _selectedParentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos de la ubicación
    _nameController = TextEditingController(text: widget.location.name);
    _descriptionController =
        TextEditingController(text: widget.location.description ?? '');
    
    // Inicializar padre seleccionado
    _selectedParentId = widget.location.parentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Lógica de Edición (Integración con Provider) ---
  void _saveLocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prevención de auto-parenting: No puedes ser tu propio padre
    if (_selectedParentId == widget.location.id) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Una ubicación no puede ser su propia padre.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final locationProvider = context.read<LocationProvider>();

      // LLAMADA AL SERVICE REAL PARA ACTUALIZAR
      final updatedLocation = await locationProvider.updateLocation(
        locationId: widget.location.id,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        parentId: _selectedParentId, context: context, containerId: int.parse(widget.containerId),
      );

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ubicación "${updatedLocation?.name}" actualizada.'),
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
            content: Text('Error al actualizar ubicación: ${e.toString()}'),
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
    // 🔑 OBTENER UBICACIONES EXISTENTES DEL PROVIDER PARA EL DROPDOWN
    final locationProvider = context.watch<LocationProvider>();
    final allLocations = locationProvider.locations;
    // Filtramos la lista para que la ubicación actual no se pueda seleccionar como su propio padre.
    final parentOptions = allLocations.where((loc) => loc.id != widget.location.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.location.name}'),
        backgroundColor: Colors.orange,
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
                items: [
                  // Opción para no tener padre (Raíz)
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Ninguno (Raíz del Esquema)'),
                  ),
                  // Lista de ubicaciones existentes (filtradas)
                  ...parentOptions.map((loc) {
                    return DropdownMenuItem<int>(
                      value: loc.id,
                      child: Text(loc.name),
                    );
                  }).toList(),
                ],
                onChanged: _isSaving
                    ? null
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
                  _isSaving ? 'Guardando...' : 'Actualizar Ubicación',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.orange,
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