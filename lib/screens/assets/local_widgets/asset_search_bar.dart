// widgets/asset_search_bar.dart

import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool isListView;
  final VoidCallback onToggleView;
  final VoidCallback onToggleGallery;

  const AssetSearchBar({
    super.key,
    required this.searchController,
    required this.isListView,
    required this.onToggleView,
    required this.onToggleGallery,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.of(context).size.width < 920;

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: l10n.globalSearch,
                hintText: l10n.searchInAllColumns,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: onToggleView,
          icon: Icon(isListView ? Icons.grid_view_rounded : Icons.list_rounded),
          label: Text(
            isCompact
                ? 'Vista'
                : (isListView ? l10n.showAsGrid : l10n.showAsList),
          ),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          onPressed: onToggleGallery,
          icon: const Icon(Icons.play_circle_fill_rounded),
          label: const Text('3D'),
          style: FilledButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
