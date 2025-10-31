// lib/widgets/location_dropdown_field.dart

import 'package:flutter/material.dart';
import 'package:invenicum/models/location.dart';

class LocationDropdownField extends StatelessWidget {
  final List<Location> availableLocations;
  final int? selectedLocationId;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;

  const LocationDropdownField({
    super.key,
    required this.availableLocations,
    required this.selectedLocationId,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedLocationId,
      decoration: const InputDecoration(
        labelText: 'Ubicación',
        border: OutlineInputBorder(),
        helperText: 'Obligatorio',
      ),
      items: availableLocations.map((location) {
        return DropdownMenuItem<int>(
          value: location.id,
          child: Text(location.name),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value == null) {
              return 'Por favor, selecciona una ubicación.';
            }
            return null;
          },
    );
  }
}