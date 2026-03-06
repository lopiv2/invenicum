import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/expiring_loan.dart';
// Importa tus traducciones
import 'package:invenicum/l10n/app_localizations.dart';

class ExpiringLoansWidget extends StatelessWidget {
  final List<ExpiringLoan>? loans;

  const ExpiringLoansWidget({super.key, this.loans});

  @override
  Widget build(BuildContext context) {
    final items = loans ?? [];
    final bool hasLoans = items.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Color base según el estado: Naranja para advertencia, Azul para estado ok corporativo
    final Color stateColor = hasLoans ? Colors.orangeAccent : Colors.blueAccent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(24), // Aumentado para consistencia
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: stateColor.withValues(alpha: 0.15),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.grey.shade900 : Colors.white).withValues(alpha: 0.85),
                  (isDark ? Colors.black : Colors.blue.shade50).withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera
                Row(
                  children: [
                    _buildHeaderIcon(hasLoans, stateColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.returnsLabel.toUpperCase(), // 👈 Traducción: DEVOLUCIONES
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            l10n.forToday, // 👈 Traducción: Para hoy
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.blueGrey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasLoans) 
                      _buildCountBadge(items.length) 
                    else 
                      _buildSafeBadge(l10n.allUpToDateStatus), // 👈 Traducción opcional
                  ],
                ),
                
                if (hasLoans) const SizedBox(height: 20),
                
                // Contenido dinámico
                if (hasLoans)
                  ...items.map((loan) => _buildLoanItem(loan, isDark, l10n))
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildEmptyState(isDark, l10n),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(bool hasLoans, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        hasLoans ? Icons.alarm_on_rounded : Icons.calendar_today_rounded,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(8), // Cambiado a 8 para look más pro
        boxShadow: [
          BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.3), blurRadius: 8)
        ],
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }

  Widget _buildSafeBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.check_circle_rounded, color: Colors.blueAccent, size: 18),
    );
  }

  Widget _buildLoanItem(ExpiringLoan loan, bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.blue.shade100).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.orangeAccent.withValues(alpha: 0.15),
            child: const Icon(Icons.person_rounded, size: 16, color: Colors.orangeAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "${l10n.responsibleLabel}: ${loan.borrowerName}", // 👈 Traducción: Responsable
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "x${loan.quantity}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.done_all_rounded, size: 16, color: Colors.blueAccent.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(
          l10n.allUpToDateStatus, // 👈 Traducción: Todo al día por aquí
          style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}