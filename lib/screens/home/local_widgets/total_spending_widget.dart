import 'package:flutter/material.dart';
import '../../../widgets/ui/price_display_widget.dart'; // Importamos el widget centralizado

class TotalSpendingWidget extends StatelessWidget {
  final double amount;
  final bool isLoading;

  const TotalSpendingWidget({
    super.key,
    required this.amount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  'Inversión Total Económica',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (isLoading)
              const SizedBox(
                height: 34,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else
              // 🔑 REUTILIZACIÓN: Usamos el widget centralizado
              FittedBox(
                fit: BoxFit.scaleDown,
                child: PriceDisplayWidget(
                  value: amount,
                  // Personalizamos el estilo para este Card específico
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
            const SizedBox(height: 4),
            Text(
              'Basado en precios de adquisición',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}