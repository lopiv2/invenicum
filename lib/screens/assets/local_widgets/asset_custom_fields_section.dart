import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/widgets/ui/price_display_widget.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetCustomFieldsSection extends StatelessWidget {
  final List<CustomFieldDefinition> customFields;
  final Map<String, dynamic>? customFieldValues;

  const AssetCustomFieldsSection({
    Key? key,
    required this.customFields,
    required this.customFieldValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Filtramos campos con valores
    final displayedFields = customFields.where((fieldDef) {
      final value = customFieldValues?[fieldDef.id.toString()] ??
          customFieldValues?[fieldDef.id] ??
          customFieldValues?[fieldDef.name];
      return value != null && value.toString().isNotEmpty;
    }).toList();

    if (displayedFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(Icons.settings_suggest, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.customFields,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: displayedFields.length,
          itemBuilder: (context, index) {
            final fieldDef = displayedFields[index];
            final value = customFieldValues?[fieldDef.id.toString()] ??
                customFieldValues?[fieldDef.id] ??
                customFieldValues?[fieldDef.name];
            return _buildFieldCard(context, fieldDef, value);
          },
        ),
      ],
    );
  }

  Widget _buildFieldCard(
    BuildContext context,
    CustomFieldDefinition fieldDef,
    dynamic value,
  ) {
    final String displayValue = value?.toString() ?? '—';
    
    Widget valueWidget;
    
    if (fieldDef.type == CustomFieldType.boolean) {
      final isChecked = value == true;
      valueWidget = Tooltip(
        message: isChecked ? 'Verdadero' : 'Falso',
        child: Icon(
          isChecked ? Icons.check_circle : Icons.cancel,
          color: isChecked ? Colors.green.shade600 : Colors.red.shade600,
          size: 32,
        ),
      );
    } else if (fieldDef.type == CustomFieldType.url &&
        displayValue != '—' &&
        displayValue.isNotEmpty) {
      valueWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => AppUtils.launchUrlWeb(displayValue),
          child: Tooltip(
            message: 'Abrir enlace',
            child: Text(
              displayValue,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    } else if (fieldDef.type == CustomFieldType.price && value != null) {
      valueWidget = PriceDisplayWidget(value: value);
    } else {
      valueWidget = Tooltip(
        message: displayValue,
        child: Text(
          displayValue,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fieldDef.name,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          valueWidget,
        ],
      ),
    );
  }
}
