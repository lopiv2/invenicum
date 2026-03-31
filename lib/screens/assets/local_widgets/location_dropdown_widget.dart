// lib/widgets/location_dropdown_field.dart

import 'package:flutter/material.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/providers/location_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LocationDropdownField extends StatelessWidget {
  final List<Location> availableLocations;
  final int? selectedLocationId;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;
  // containerId necesario para crear la ubicación y recargar la lista
  final int? containerId;

  const LocationDropdownField({
    super.key,
    required this.availableLocations,
    required this.selectedLocationId,
    required this.onChanged,
    this.validator,
    this.containerId,
  });

  // Sentinel: valor especial que nunca coincide con un ID real de BD
  static const int _kCreateNew = -1;

  Future<void> _handleCreateNew(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    String? newName;
    int? selectedParentId;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        // StatefulBuilder para que el dropdown de padre pueda hacer setState
        // dentro del diálogo sin reconstruir todo el árbol exterior.
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(l10n.newLocationLabel),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.name,
                        hintText: l10n.newLocationHint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.pleaseEnterAName
                          : null,
                      onFieldSubmitted: (_) {
                        if (formKey.currentState!.validate()) {
                          newName = nameCtrl.text.trim();
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Selector de ubicación padre — usa las mismas ubicaciones
                    // que el dropdown principal (deduplicadas por id).
                    DropdownButtonFormField<int>(
                      value: selectedParentId,
                      decoration: InputDecoration(
                        labelText: l10n.parentLocationOptionalLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.account_tree_outlined, size: 18),
                      ),
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text(l10n.noneRootLabel),
                        ),
                        ...{ for (final loc in availableLocations) loc.id: loc }
                            .values
                            .map((loc) => DropdownMenuItem<int>(
                                  value: loc.id,
                                  child: Text(loc.name),
                                )),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => selectedParentId = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      newName = nameCtrl.text.trim();
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(l10n.create),
                ),
              ],
            );
          },
        );
      },
    );

    if (newName == null || containerId == null) return;

    try {
      final locationProvider = context.read<LocationProvider>();
      final containerProvider = context.read<ContainerProvider>();

      final created = await locationProvider.createLocation(
        containerId: containerId!,
        name: newName!,
        parentId: selectedParentId,
        context: context,
      );

      if (created != null) {
        // Añadimos la ubicación al ContainerNode en memoria ANTES de llamar
        // onChanged. Así cuando el dropdown se reconstruya con el nuevo value,
        // availableLocations ya la incluye y no hay crash por item faltante.
        containerProvider.addLocationToContainer(containerId!, created);
        onChanged(created.id);
        ToastService.success(l10n.locationCreatedShort(newName!));
      }
    } catch (e) {
      ToastService.error(l10n.errorCreatingLocation(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Deduplicamos la lista por id para evitar el assert de Flutter
    // "There should be exactly one item with value X".
    final uniqueLocations = { for (final loc in availableLocations) loc.id: loc }.values.toList();

    // Si el value seleccionado no existe aún en la lista (frame de transición
    // entre crear la ubicación y que el provider la propague), usamos null
    // para que el dropdown no crashee. El valor se restaura en el siguiente frame.
    final safeValue = uniqueLocations.any((l) => l.id == selectedLocationId)
        ? selectedLocationId
        : null;

    return DropdownButtonFormField<int>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: l10n.location,
        border: const OutlineInputBorder(),
        helperText: l10n.obligatory,
      ),
      items: [
        ...uniqueLocations.map((location) => DropdownMenuItem<int>(
              value: location.id,
              child: Text(location.name),
            )),
        // Opción fija al final para crear nueva ubicación
        DropdownMenuItem<int>(
          value: _kCreateNew,
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, size: 18, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                l10n.newLocationEllipsis,
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == _kCreateNew) {
          _handleCreateNew(context);
        } else {
          onChanged(value);
        }
      },
      validator: validator ??
          (value) {
            if (value == null || value == _kCreateNew) {
              return l10n.pleaseSelectLocation;
            }
            return null;
          },
    );
  }
}