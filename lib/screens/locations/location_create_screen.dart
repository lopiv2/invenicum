// lib/screens/locations/location_create_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
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

  // --- Save logic (integration with Provider) ---
  void _saveLocation() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final locationProvider = context.read<LocationProvider>();
      final containerProvider = context.read<ContainerProvider>();

        // CALL TO THE REAL SERVICE VIA THE PROVIDER
      final newLocation = await locationProvider.createLocation(
        containerId: int.parse(widget.containerId),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        parentId: _selectedParentId,
        context: context,
      );
      await containerProvider.loadDataLists(int.parse(widget.containerId));

      // Show success
      if (mounted) {
        ToastService.success(
          l10n.locationCreatedSuccessfully(newLocation?.name ?? ''),
        );
        // Return to the previous screen
        context.pop();
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ToastService.error(l10n.errorCreatingLocation(e.toString()));
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
    // 🔑 WE USE context.watch to obtain the list of available locations
    final locationProvider = context.watch<LocationProvider>();
    final allLocations = locationProvider.locations;
    final isLoading = locationProvider.isLoading;

    // If it's loading and the list is empty, show a loading indicator
    if (isLoading && allLocations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.createNewLocationTitle),
          backgroundColor: Colors.teal,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Filter locations to exclude the one being created (if this were an edit)
    // and ensure we only show locations that belong to the current container (assuming LocationsScreen already filtered them).
    // Here we use the list as-is, assuming the provider only contains locations for the given containerId.

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createNewLocationTitle),
        backgroundColor: Colors.teal,
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
                  hintText: l10n.locationNameHint,
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
                  hintText: l10n.locationDescriptionHint,
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
                // 🔑 We use the 'allLocations' list obtained from the Provider
                items: [
                  // Option for having no parent (Root)
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(l10n.noneRootScheme),
                  ),
                  // List of existing locations
                  ...allLocations.map((loc) {
                    return DropdownMenuItem<int>(
                      value: loc.id,
                      child: Text(loc.name),
                    );
                  })
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
                  _isSaving ? l10n.savingLabel : l10n.saveLocationLabel,
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
