import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/expiring_loan.dart';

class ExpiringLoansWidget extends StatelessWidget {
  final List<ExpiringLoan>? loans;

  const ExpiringLoansWidget({super.key, this.loans});

  @override
  Widget build(BuildContext context) {
    final items = loans ?? [];
    final bool hasLoans = items.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Color base según el estado de urgencia
    final Color stateColor = hasLoans ? Colors.orangeAccent : Colors.greenAccent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: stateColor.withValues(alpha: 0.08),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: stateColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
                  (hasLoans 
                      ? Colors.orange.withValues(alpha: 0.1) 
                      : Colors.green.withValues(alpha: 0.05)),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera con Badge de estado
                Row(
                  children: [
                    _buildHeaderIcon(hasLoans, stateColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "DEVOLUCIONES",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Para hoy",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasLoans) _buildCountBadge(items.length) else _buildSafeBadge(),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Contenido dinámico
                if (hasLoans)
                  ...items.map((loan) => _buildLoanItem(loan, isDark))
                else
                  _buildEmptyState(isDark),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.3), blurRadius: 8)
        ],
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildSafeBadge() {
    return const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 24);
  }

  Widget _buildLoanItem(ExpiringLoan loan, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
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
                  "Responsable: ${loan.borrowerName}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all_rounded, size: 16, color: Colors.greenAccent.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          const Text(
            "Todo al día por aquí",
            style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}