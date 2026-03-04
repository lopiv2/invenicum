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
      if (lp.loans.isEmpty) {
        lp.fetchAllLoans(); // Asegúrate de que este método existe en tu Provider
      }
    });
  }

  /// Obtiene los 10 productos más prestados del mes y año seleccionados
  Map<String, int> _getTopLoanedItems(List<Loan> loans, int year, int month) {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 1);

    // Filtrar préstamos del mes seleccionado
    final monthLoans = loans.where((loan) {
      return loan.loanDate.isAfter(monthStart) &&
          loan.loanDate.isBefore(monthEnd);
    }).toList();

    // Contar por nombre de artículo
    final itemCounts = <String, int>{};
    for (var loan in monthLoans) {
      itemCounts[loan.itemName] = (itemCounts[loan.itemName] ?? 0) + 1;
    }

    // Ordenar y tomar los top 10
    final sortedItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topItems = Map.fromEntries(sortedItems.take(10));

    return topItems;
  }

  List<int> _getAvailableYears(List<Loan> loans) {
    if (loans.isEmpty) return [DateTime.now().year];

    final years = loans.map((l) => l.loanDate.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProvider>(
      builder: (context, loanProvider, child) {
        final availableYears = _getAvailableYears(loanProvider.loans);
        final topItems = _getTopLoanedItems(
          loanProvider.loans,
          _selectedYear,
          _selectedMonth,
        );

        if (topItems.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.topLoanedItems,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedYear,
                          items: availableYears
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null && value != _selectedYear) {
                              setState(() {
                                _selectedYear = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedMonth,
                          items: List.generate(12, (index) => index + 1)
                              .map(
                                (month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(_getMonthName(month)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null && value != _selectedMonth) {
                              setState(() {
                                _selectedMonth = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No hay préstamos en ${_getMonthName(_selectedMonth)} de $_selectedYear',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final itemNames = topItems.keys.toList();
        final itemCounts = topItems.values.toList();
        final maxCount = itemCounts.reduce((a, b) => a > b ? a : b);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.topLoanedItems,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedYear,
                        items: availableYears
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text('Año: $year'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null && value != _selectedYear) {
                            setState(() {
                              _selectedYear = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedMonth,
                        items: List.generate(12, (index) => index + 1)
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(_getMonthName(month)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null && value != _selectedMonth) {
                            setState(() {
                              _selectedMonth = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      maxY: (maxCount * 1.2).toDouble(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey.shade900,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${itemNames[groupIndex]}\n${rod.toY.toStringAsFixed(0)} préstamos',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < itemNames.length) {
                                final name = itemNames[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: SizedBox(
                                    width: 100,
                                    child: Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 60,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                            reservedSize: 40,
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        horizontalInterval: (maxCount * 1.2) / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 0.8,
                          );
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          left: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      barGroups: List.generate(itemCounts.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: itemCounts[index].toDouble(),
                              color: _getBarColor(index),
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }

  Color _getBarColor(int index) {
    const colors = [
      Color(0xFF6366F1), // Indigo
      Color(0xFF8B5CF6), // Violet
      Color(0xFFEC4899), // Pink
      Color(0xFFF43F5E), // Rose
      Color(0xFFF97316), // Orange
      Color(0xFFFBBF24), // Amber
      Color(0xFF84CC16), // Lime
      Color(0xFF10B981), // Emerald
      Color(0xFF14B8A6), // Teal
      Color(0xFF0891B2), // Cyan
    ];
    return colors[index % colors.length];
  }
}
