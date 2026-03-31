import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetDetailTitleHeader extends StatelessWidget {
  const AssetDetailTitleHeader({
    super.key,
    required this.item,
    required this.theme,
  });

  final InventoryItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          if (item.barcode != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n.skuBarcodeLabel}: ${item.barcode}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
