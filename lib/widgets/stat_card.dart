// Definición del Widget Reutilizable para el Contador (StatCard)
import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        // 🔑 REDUCCIÓN CLAVE 1: Reducir el Padding vertical (simétrico a 12)
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // 🔑 ALINEACIÓN CLAVE: Center o Start para evitar que ocupe todo el espacio
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize:
              MainAxisSize.min, // Ocupa solo el espacio necesario verticalmente
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color), // Icono más pequeño
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // 🔑 REDUCCIÓN CLAVE 2: Reducir este espaciador
            const SizedBox(height: 4),

            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28, // Fuente ligeramente más pequeña
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            // 🔑 REDUCCIÓN CLAVE 3: Reducir o eliminar este espaciador
            // const SizedBox(height: 4), // Se elimina o se reduce mucho
            Text(
              l10n.totals,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
