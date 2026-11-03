import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../providers/preferences_provider.dart';

class PriceDisplayWidget extends StatelessWidget {
  final dynamic value; // Puede recibir String o double
  final TextStyle? style;
  final Color? color;
  final double fontSize;

  const PriceDisplayWidget({
    super.key,
    required this.value,
    this.style,
    this.color = Colors.green,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesProvider>();
    final l10n = AppLocalizations.of(context)!;

    // 1. Convert the value from DB (USD) to a number
    final double dbValue = double.tryParse(value?.toString() ?? '0') ?? 0.0;

    // 2. Convert to local currency per preferences
    final double localPrice = preferences.convertPrice(dbValue);

    // 3. Format the text
    final String formattedPrice = preferences.formatPrice(localPrice);
    final String originalUsdText = preferences.formatPrice(
      dbValue,
      currencyCode: AppCurrencies.usd,
    );

    return Tooltip(
      message: l10n.originalPriceTooltip(originalUsdText),
      child: Text(
        formattedPrice,
        style:
            style ??
            TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
