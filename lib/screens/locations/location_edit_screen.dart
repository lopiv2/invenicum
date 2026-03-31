// lib/screens/locations/location_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prevención de auto-parenting: No puedes ser tu propio padre
    if (_selectedParentId == widget.location.id) {
      ToastService.error(l10n.locationCannotBeItsOwnParent);
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
        ToastService.success(
          l10n.locationUpdatedSuccessfully(updatedLocation?.name ?? ''),
        );
        // Volver a la pantalla anterior
        context.pop();
      }
    } catch (e) {
      // Mostrar error
      if (mounted) {
        ToastService.error(l10n.errorUpdatingLocation(e.toString()));
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
    final l10n = AppLocalizations.of(context)!;
    // 🔑 OBTENER UBICACIONES EXISTENTES DEL PROVIDER PARA EL DROPDOWN
    final locationProvider = context.watch<LocationProvider>();
    final allLocations = locationProvider.locations;
    // Filtramos la lista para que la ubicación actual no se pueda seleccionar como su propio padre.
    final parentOptions = allLocations.where((loc) => loc.id != widget.location.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editLocationTitle(widget.location.name)),
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
                decoration: InputDecoration(
                  labelText: l10n.locationNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Campo Descripción ---
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // --- Campo Ubicación Padre (Dropdown) ---
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: l10n.parentLocationLabel,
                  border: const OutlineInputBorder(),
                ),
                value: _selectedParentId,
                hint: Text(l10n.noParentRootLocation),
                items: [
                  // Opción para no tener padre (Raíz)
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(l10n.noneRootScheme),
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
                  _isSaving ? l10n.savingLabel : l10n.updateLocationLabel,
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