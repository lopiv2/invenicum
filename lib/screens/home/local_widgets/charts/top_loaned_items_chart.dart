import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/loan.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/screens/home/local_widgets/charts/chart_main_container.dart';
import 'package:invenicum/screens/home/local_widgets/charts/top_loaned_bar_chart_widget.dart';
import 'package:invenicum/screens/home/local_widgets/charts/top_loaned_filters.dart';
import 'package:provider/provider.dart';

class TopLoanedItemsChart extends StatefulWidget {
  const TopLoanedItemsChart({super.key});

  @override
  State<TopLoanedItemsChart> createState() => _TopLoanedItemsChartState();
}

class _TopLoanedItemsChartState extends State<TopLoanedItemsChart> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lp = context.read<LoanProvider>();
      if (lp.loans.isEmpty) lp.fetchAllLoans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<LoanProvider>(
      builder: (context, loanProvider, child) {
        final availableYears = _getAvailableYears(loanProvider.loans);
        final topItems = _getTopLoanedItems(
          loanProvider.loans,
          _selectedYear,
          _selectedMonth,
        );

        return GlassMainContainer(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 20),
              TopLoanedFilters(
                selectedYear: _selectedYear,
                selectedMonth: _selectedMonth,
                years: availableYears,
                onYearChanged: (y) => setState(() => _selectedYear = y),
                onMonthChanged: (m) => setState(() => _selectedMonth = m),
              ),
              const SizedBox(height: 32),
              topItems.isEmpty
                  ? _buildEmptyState(isDark)
                  : TopLoanedBarChartContent(
                      topItems: topItems,
                      isDark: isDark,
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        _buildIconBadge(Icons.bar_chart_rounded, Colors.indigoAccent),
        const SizedBox(width: 12),
        Text(
          AppLocalizations.of(context)!.topLoanedItems.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'Sin actividad en este período',
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Map<String, int> _getTopLoanedItems(List<Loan> loans, int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final counts = <String, int>{};
    for (var l in loans.where(
      (l) => l.loanDate.isAfter(start) && l.loanDate.isBefore(end),
    )) {
      counts[l.itemName] = (counts[l.itemName] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(
      sorted.take(6),
    ); // Reducido a 6 para que se vea bien en móvil
  }

  List<int> _getAvailableYears(List<Loan> loans) {
    if (loans.isEmpty) return [DateTime.now().year];
    return (loans.map((l) => l.loanDate.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a)));
  }
}
