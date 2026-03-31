import 'package:flutter/material.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/screens/asset_types/local_widgets/condition_badge_widget.dart';
import 'package:invenicum/widgets/ui/print_label_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetMarketStatusWidget extends StatelessWidget {
  final InventoryItem item;
  final AppLocalizations l10n;

  const AssetMarketStatusWidget({
    super.key,
    required this.item,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preferencesProvider = context.watch<PreferencesProvider>();
    final integrationProv = context.watch<IntegrationProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();
    // --- LÓGICA DE TENDENCIA ---
    IconData? trendIcon;
    Color? trendColor;
    String? percentageText;
    final history = item.priceHistory ?? [];

    if (history.length >= 2) {
      final lastPrice = history.last.price;
      final previousPrice = history[history.length - 2].price;

      if (previousPrice > 0) {
        final change = ((lastPrice - previousPrice) / previousPrice) * 100;
        percentageText =
            "${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%";
        trendIcon = change > 0
            ? Icons.trending_up
            : (change < 0 ? Icons.trending_down : Icons.trending_flat);
        trendColor = change > 0
            ? Colors.green
            : (change < 0 ? Colors.red : Colors.orange);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(
          l10n.quantity,
          "${item.quantity} unidades",
          Icons.inventory_2_outlined,
          theme,
        ),
        _buildInfoRow(
          l10n.location,
          item.location?.name ?? "—",
          Icons.location_on_outlined,
          theme,
        ),
        _buildInfoRowCondition(
          l10n.condition,
          Icons.ballot_outlined,
          theme,
          ConditionBadgeWidget(condition: item.condition),
        ),

        _buildInfoRow(
          l10n.minStock,
          item.minStock.toString(),
          Icons.warning_amber_rounded,
          theme,
        ),

        const Divider(height: 32),

        if (item.marketValue > 0) ...[
          Text(
            l10n.currentMarketValueLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${preferencesProvider.convertPrice(item.marketValue).toStringAsFixed(2)} ${preferencesProvider.selectedCurrency}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (trendIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trendIcon, color: trendColor, size: 24),
                  Text(
                    percentageText!,
                    style: TextStyle(
                      color: trendColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Botón de Sincronización con UPC
        if (integrationProv.isLinked('upcitemdb'))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: itemProvider.isSyncing
                  ? null
                  : () async {
                      try {
                        await itemProvider.syncWithUPC(item.id);
                        ToastService.success(l10n.marketPriceObtained);
                      } catch (e) {
                        ToastService.error(l10n.errorNotBarCode);
                      }
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: itemProvider.isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync_rounded),
              label: Text(
                itemProvider.isSyncing
                    ? l10n.syncingLabel
                    : l10n.updatePriceLabel,
              ),
            ),
          ),
        const SizedBox(height: 10),
        PrintLabelButton(item: item),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoRowCondition(
    String label,
    IconData icon,
    ThemeData theme,
    Widget conditionBadge,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          conditionBadge,
        ],
      ),
    );
  }
}
