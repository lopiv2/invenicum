import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';

class CurrencyDropdownWidget extends StatelessWidget {
  final VoidCallback? onCurrencyChanged;

  // Tamaño para el símbolo o icono de la moneda
  static const double _iconSize = 22.0;

  const CurrencyDropdownWidget({
    super.key,
    this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos la moneda actual desde tu PreferencesProvider
    final preferences = context.watch<PreferencesProvider>();
    final currentCurrency = preferences.selectedCurrency; // Asegúrate de tener este getter

    return PopupMenuButton<String>(
      onSelected: (String currencyCode) async {
        await _changeCurrency(context, currencyCode);
        onCurrencyChanged?.call();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildMenuItem(context, 'EUR', '€', 'Euro'),
        _buildMenuItem(context, 'USD', '\$', 'Dollar'),
        _buildMenuItem(context, 'GBP', '£', 'Pound'),
        _buildMenuItem(context, 'JPY', '¥', 'Yen'),
        _buildMenuItem(context, 'MXN', 'Mex\$', 'Peso Mexicano'),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                _getSymbolForCurrency(currentCurrency),
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentCurrency,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              symbol, 
              style: const TextStyle(
                fontSize: _iconSize, 
                fontWeight: FontWeight.bold,
                color: Colors.grey
              )
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  String _getSymbolForCurrency(String currencyCode) {
    switch (currencyCode) {
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'USD':
      default: return '\$';
    }
  }

  Future<void> _changeCurrency(BuildContext context, String currencyCode) async {
    try {
      // Necesitaremos crear este método 'setCurrency' en tu PreferencesProvider
      await context.read<PreferencesProvider>().setCurrency(currencyCode);
      
      // Asumiendo que añades esta clave a tu l10n
      final l10n = AppLocalizations.of(context)!;
      ToastService.success("Moneda cambiada a $currencyCode"); 
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ToastService.error("Error al cambiar moneda: ${e.toString()}");
    }
  }
}