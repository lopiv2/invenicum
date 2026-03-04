import 'package:flutter/material.dart';
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
    
    // 1. Convertir el valor de la DB (USD) a número
    final double dbValue = double.tryParse(value?.toString() ?? '0') ?? 0.0;
    
    // 2. Convertir a moneda local según preferencias
    final double localPrice = preferences.convertPrice(dbValue);
    
    // 3. Formatear el texto
    final String formattedPrice = 
        '${preferences.getSymbolForCurrency(preferences.selectedCurrency)} ${localPrice.toStringAsFixed(2)}';

    return Tooltip(
      message: 'Original: \$${dbValue.toStringAsFixed(2)} USD',
      child: Text(
        formattedPrice,
        style: style ?? TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}