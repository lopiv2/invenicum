// widgets/asset_search_bar.dart

import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool isListView;
  final VoidCallback onToggleView;

  const AssetSearchBar({
    super.key,
    required this.searchController,
    required this.isListView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 🔑 Acceso a traducciones

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: l10n.globalSearch, // 🔑 Traducido
                hintText: l10n.searchInAllColumns, // 🔑 Traducido
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
              ),
            ),
          ),
        ),
        // Botón de alternar vista
        IconButton(
          icon: Icon(
            isListView ? Icons.grid_view : Icons.list,
            size: 30,
          ),
          tooltip: isListView ? l10n.showAsGrid : l10n.showAsList, // 🔑 Traducido
          onPressed: onToggleView,
        ),
      ],
    );
  }
}