import 'package:flutter/material.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/assets/local_widgets/location_dropdown_widget.dart';
import 'common_form_field.dart';
import 'card_section_widget.dart';
import 'section_header_widget.dart';

/// Widget para la sección de datos principales del formulario
class MainDataSectionWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Location> availableLocations;
  final int? selectedLocationId;
  final ValueChanged<int?> onLocationChanged;
  final Set<String> highlightedFields;
  final int? containerId;

  const MainDataSectionWidget({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.availableLocations,
    required this.selectedLocationId,
    required this.onLocationChanged,
    this.highlightedFields = const {},
    this.containerId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CardSectionWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: l10n.mainDataTitle,
            icon: Icons.inventory_2_outlined,
          ),
          CommonFormField(
            controller: nameController,
            label: l10n.assetName,
            icon: Icons.label_outline,
            highlighted: highlightedFields.contains('name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterAName;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CommonFormField(
            controller: descriptionController,
            label: l10n.description,
            icon: Icons.notes_outlined,
            maxLines: 3,
            highlighted: highlightedFields.contains('description'),
          ),
          const SizedBox(height: 16),
          LocationDropdownField(
            availableLocations: availableLocations,
            selectedLocationId: selectedLocationId,
            onChanged: onLocationChanged,
            containerId: containerId,
          ),
        ],
      ),
    );
  }
}
