import 'package:flutter/material.dart';

class TotalMarketValueWidget extends StatelessWidget {
  final double marketValue;
  final bool isLoading;

  const TotalMarketValueWidget({
    super.key,
    required this.marketValue,
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
            // Cambiamos a tonos azules/púrpuras para diferenciarlo de la inversión (verde)
            colors: [Colors.indigo.shade800, Colors.blue.shade600],
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
                Icon(Icons.trending_up, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  'Valor de Mercado Total',
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
              Text(
                '${marketValue.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
            const SizedBox(height: 4),
            Text(
              'Basado en precios de mercado actuales',
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