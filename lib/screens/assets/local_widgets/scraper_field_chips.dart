import 'package:flutter/material.dart';
import 'package:invenicum/data/models/scraper.dart';

/// Selectable chips for the fields a scraper will extract.
///
/// Tapping a chip toggles its exclusion: excluded fields are shown in red
/// and are not sent to the backend when the scrape runs.
class ScraperFieldChips extends StatelessWidget {
  final List<ScraperField> fields;
  final Set<int> excludedFieldIds;
  final ValueChanged<int> onToggleField;

  const ScraperFieldChips({
    super.key,
    required this.fields,
    required this.excludedFieldIds,
    required this.onToggleField,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final field in fields)
          Builder(
            builder: (context) {
              final excluded = excludedFieldIds.contains(field.id);
              return InputChip(
                label: Text(field.name, style: theme.textTheme.labelSmall),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                showCheckmark: false,
                avatar: Icon(
                  excluded ? Icons.block : Icons.download_outlined,
                  size: 14,
                  color: excluded
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                backgroundColor: excluded
                    ? theme.colorScheme.errorContainer
                    : null,
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: excluded ? theme.colorScheme.onErrorContainer : null,
                ),
                onPressed: () => onToggleField(field.id),
              );
            },
          ),
      ],
    );
  }
}
