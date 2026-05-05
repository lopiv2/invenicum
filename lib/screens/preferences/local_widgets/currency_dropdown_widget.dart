import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';

class CurrencyDropdownWidget extends StatelessWidget {
  final VoidCallback? onCurrencyChanged;
  static const double _iconSize = 22.0;

  const CurrencyDropdownWidget({
    super.key,
    this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = context.watch<PreferencesProvider>();
    final currentCurrency = preferencesProvider.selectedCurrency;
    final currencyLabels = AppCurrencies.getLabels(context);

    return PopupMenuButton<String>(
      onSelected: (String currencyCode) async {
        await _changeCurrency(context, currencyCode);
        onCurrencyChanged?.call();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        for (final code in AppCurrencies.allCodes)
          _buildMenuItem(
            context,
            code,
            AppCurrencies.getSymbol(code),
            currencyLabels[code] ?? code,
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                preferencesProvider.getSymbolForCurrency(currentCurrency),
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentCurrency,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      BuildContext context, String value, String symbol, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              symbol, 
              style: const TextStyle(
                fontSize: _iconSize, 
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey
              )
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }


  Future<void> _changeCurrency(BuildContext context, String currencyCode) async {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    try {
      await context.read<PreferencesProvider>().setCurrency(currencyCode);
      await AppUtils.trackAndToast(context, 'CURRENCY_CHANGED');
      ToastService.success("${l10n.currency}: $currencyCode"); 
    } catch (e) {
      ToastService.error("Error: ${e.toString()}");
    }
  }
}