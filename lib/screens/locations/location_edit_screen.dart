// lib/screens/locations/location_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/location_provider.dart';

class LocationEditScreen extends StatefulWidget {
  final Location location; // Existing location to edit
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
    // Initialize controllers with the location data
    _nameController = TextEditingController(text: widget.location.name);
    _descriptionController =
        TextEditingController(text: widget.location.description ?? '');
    
    // Initialize selected parent
    _selectedParentId = widget.location.parentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Edit logic (Integration with Provider) ---
  void _saveLocation() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prevent self-parenting: you cannot be your own parent
    if (_selectedParentId == widget.location.id) {
      ToastService.error(l10n.locationCannotBeItsOwnParent);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final locationProvider = context.read<LocationProvider>();

      // CALL TO THE REAL SERVICE TO UPDATE
      final updatedLocation = await locationProvider.updateLocation(
        locationId: widget.location.id,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        parentId: _selectedParentId, context: context, containerId: int.parse(widget.containerId),
      );

      // Show success
      if (mounted) {
        ToastService.success(
          l10n.locationUpdatedSuccessfully(updatedLocation?.name ?? ''),
        );
        context.pop();
      }
    } catch (e) {
      // Show error
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
    // FETCH EXISTING LOCATIONS FROM THE PROVIDER FOR THE DROPDOWN
    final locationProvider = context.watch<LocationProvider>();
    final allLocations = locationProvider.locations;
    // Filter the list so the current location cannot be selected as its own parent.
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
              // --- Name Field ---
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

              // --- Description Field ---
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // --- Parent Location Field (Dropdown) ---
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: l10n.parentLocationLabel,
                  border: const OutlineInputBorder(),
                ),
                initialValue: _selectedParentId,
                hint: Text(l10n.noParentRootLocation),
                items: [
                  // Option for having no parent (Root)
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(l10n.noneRootScheme),
                  ),
                  // List of existing locations (filtered)
                  ...parentOptions.map((loc) {
                    return DropdownMenuItem<int>(
                      value: loc.id,
                      child: Text(loc.name),
                    );
                  })
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

              // --- Save Button ---
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