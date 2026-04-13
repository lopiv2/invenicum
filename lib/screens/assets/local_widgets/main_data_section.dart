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
  final List<String> nameSuggestions;
  final FocusNode? nameAutocompleteFocusNode;

  const MainDataSectionWidget({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.availableLocations,
    required this.selectedLocationId,
    required this.onLocationChanged,
    this.highlightedFields = const {},
    this.containerId,
    this.nameSuggestions = const [],
    this.nameAutocompleteFocusNode,
  });

  Iterable<String> _filterSuggestions(TextEditingValue value) {
    final query = value.text.trim().toLowerCase();
    final options = nameSuggestions;
    if (options.isEmpty) return const <String>[];
    if (query.isEmpty) return options.take(8);
    return options
        .where((option) => option.toLowerCase().contains(query))
        .take(8);
  }

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
          nameSuggestions.isEmpty
              ? CommonFormField(
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
                )
              : RawAutocomplete<String>(
                  textEditingController: nameController,
                  focusNode: nameAutocompleteFocusNode,
                  optionsBuilder: _filterSuggestions,
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 220,
                            minWidth: 260,
                            maxWidth: 520,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(option),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (selection) {
                    nameController
                      ..text = selection
                      ..selection = TextSelection.collapsed(
                        offset: selection.length,
                      );
                  },
                  fieldViewBuilder:
                      (context, textController, focusNode, onFieldSubmitted) {
                        return CommonFormField(
                          controller: textController,
                          focusNode: focusNode,
                          onFieldSubmitted: (_) => onFieldSubmitted(),
                          label: l10n.assetName,
                          icon: Icons.label_outline,
                          highlighted: highlightedFields.contains('name'),
                          suffixIcon: const Icon(
                            Icons.history_outlined,
                            size: 18,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterAName;
                            }
                            return null;
                          },
                        );
                      },
                ),
          const SizedBox(height: 16),
          CommonFormField(
            controller: descriptionController,
            label: l10n.description,
            icon: Icons.notes_outlined,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 8,
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
