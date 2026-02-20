import 'package:flutter/material.dart';
import 'package:invenicum/models/expiring_loan.dart';

class ExpiringLoansWidget extends StatelessWidget {
  // Cambiamos a List<ExpiringLoan>? para aceptar nulos con seguridad
  final List<ExpiringLoan>? loans;

  const ExpiringLoansWidget({super.key, this.loans});

  @override
  Widget build(BuildContext context) {
    // Si es null, lo tratamos como lista vacía
    final items = loans ?? [];
    final bool hasLoans = items.isNotEmpty;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: hasLoans ? Colors.red.shade50 : Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              children: [
                Icon(
                  Icons.history_toggle_off, 
                  color: hasLoans ? Colors.red.shade700 : Colors.grey.shade600
                ),
                const SizedBox(width: 8),
                Text(
                  "Devoluciones para hoy",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: hasLoans ? Colors.red.shade900 : Colors.grey.shade800
                  ),
                ),
                const Spacer(),
                if (hasLoans)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      items.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                else
                  Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20),
              ],
            ),
          ),
          
          // Si hay préstamos, los listamos. Si no, mostramos un mensaje amigable.
          if (hasLoans)
            ...items.map((loan) => ListTile(
              dense: true,
              title: Text(
                "${loan.itemName} (x${loan.quantity})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Debe devolver: ${loan.borrowerName}"),
              leading: Icon(Icons.person_outline, size: 20, color: Colors.red.shade300),
            ))
          else
            const Padding(
              padding: EdgeInsets.only(bottom: 16, top: 4),
              child: Text(
                "No hay devoluciones pendientes para hoy",
                style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}