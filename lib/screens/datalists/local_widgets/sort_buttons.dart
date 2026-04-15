import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class SortButtons extends StatelessWidget {
  final List<String> items;
  final VoidCallback onChanged;

  const SortButtons({
    super.key,
    required this.items,
    required this.onChanged,
  });

  void _sortAscending() {
    AppUtils.sortAscending(items);
  }

  void _sortDescending() {
    AppUtils.sortDescending(items);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            _sortAscending();
            onChanged();
          },
          icon: const Icon(Icons.sort),
          label: Text(l10n.sortAsc),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            _sortDescending();
            onChanged();
          },
          icon: Transform.flip(
            flipY: true,
            child: const Icon(Icons.sort),
          ),
          label: Text(l10n.sortDesc),
        ),
      ],
    );
  }
}
