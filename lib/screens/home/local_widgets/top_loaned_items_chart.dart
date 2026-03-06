import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/loan.dart';
import 'package:invenicum/providers/loan_provider.dart';
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

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(isDark ? 0.1 : 0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      // Usamos el color del tema pero con poquísima opacidad
                      color: (isDark ? Colors.blueAccent : Colors.black)
                          .withOpacity(0.12),
                      blurRadius: 40, // Un radio muy grande para que sea suave
                      spreadRadius:
                          -10, // "Encogemos" la sombra para que no se vea sucia
                      offset: const Offset(0, 20), // La desplazamos hacia abajo
                    ),
                    // Segunda sombra opcional para dar volumen lateral
                    BoxShadow(
                      color: Colors.white.withOpacity(isDark ? 0.05 : 0.5),
                      blurRadius: 10,
                      offset: const Offset(
                        -5,
                        -5,
                      ), // Sombra de luz en la esquina superior
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? Colors.black87 : Colors.white).withOpacity(
                        0.85,
                      ),
                      (isDark ? Colors.blueGrey.shade900 : Colors.blue.shade50)
                          .withOpacity(0.6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark),
                    const SizedBox(height: 20),
                    _buildFilters(availableYears, isDark),
                    const SizedBox(height: 32),
                    if (topItems.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      _buildChart(topItems, isDark),
                  ],
                ),
              ),
            ),
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

  Widget _buildFilters(List<int> years, bool isDark) {
    return Row(
      children: [
        _buildGlassDropdown<int>(
          value: _selectedYear,
          items: years
              .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
              .toList(),
          onChanged: (v) => setState(() => _selectedYear = v!),
        ),
        const SizedBox(width: 12),
        _buildGlassDropdown<int>(
          value: _selectedMonth,
          items: List.generate(12, (i) => i + 1)
              .map(
                (m) =>
                    DropdownMenuItem(value: m, child: Text(_getShortMonth(m))),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedMonth = v!),
        ),
      ],
    );
  }

  Widget _buildChart(Map<String, int> topItems, bool isDark) {
    final itemNames = topItems.keys.toList();
    final itemCounts = topItems.values.toList();
    final maxCount = itemCounts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 320, // Aumentamos un poco la altura para los títulos de eje
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxCount * 1.4)
              .toDouble(), // Más aire arriba para las etiquetas
          barTouchData: _buildBarTouchData(itemNames, isDark),
          titlesData: _buildTitlesData(itemNames, isDark),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxCount / 4).clamp(1, 100).toDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              strokeWidth: 1,
              dashArray: [5, 5], // Líneas punteadas para un look más técnico
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
              left: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
          ),
          barGroups: _buildBarGroups(itemCounts, maxCount, isDark),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<int> counts,
    int max,
    bool isDark,
  ) {
    return List.generate(counts.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: counts[i].toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [_getBarColor(i).withOpacity(0.4), _getBarColor(i)],
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            // Pequeña "gorra" brillante al final de la barra
            rodStackItems: [
              BarChartRodStackItem(
                counts[i].toDouble() - 0.2,
                counts[i].toDouble(),
                Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ],
      );
    });
  }

  // --- Helpers de Diseño ---

  Widget _buildGlassDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData(List<String> names, bool isDark) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) =>
            isDark ? Colors.indigoAccent : Colors.blueGrey.shade900,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${names[groupIndex]}\n',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: '${rod.toY.toInt()} préstamos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<String> names, bool isDark) {
    return FlTitlesData(
      show: true,
      // --- EJE VERTICAL (PRÉSTAMOS) ---
      leftTitles: AxisTitles(
        axisNameWidget: const Text(
          "CANTIDAD DE PRÉSTAMOS",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        axisNameSize: 20,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()}',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ),
      // --- EJE HORIZONTAL (ARTÍCULOS) ---
      bottomTitles: AxisTitles(
        axisNameWidget: const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "ARTÍCULOS MÁS SOLICITADOS",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        axisNameSize: 25,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 45, // Más espacio para la rotación
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= names.length) return const SizedBox();
            return SideTitleWidget(
              meta: meta,
              angle: -0.5, // Rotación diagonal elegante
              child: Text(
                _truncateName(names[value.toInt()]),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _truncateName(String name) {
    return name.length > 10 ? '${name.substring(0, 8)}..' : name;
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
            color: Colors.grey.withOpacity(0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  String _getShortMonth(int m) => [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ][m - 1];

  Color _getBarColor(int index) {
    return [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
    ][index % 4];
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
