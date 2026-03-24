import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Importante para acceder al provider
import '../../data/models/price_history_point.dart';
import '../../providers/preferences_provider.dart'; // Asegúrate de que la ruta es correcta

class PriceHistoryChart extends StatelessWidget {
  final List<PriceHistoryPoint> history;

  const PriceHistoryChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // 🔑 Accedemos a las preferencias para convertir los precios
    final preferencesProvider = context.watch<PreferencesProvider>();
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No hay historial de precios disponible")),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Evolución del precio (${preferencesProvider.selectedCurrency})",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 6,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20,
              left: 10,
              top: 10,
              bottom: 10,
            ),
            child: LineChart(
              LineChartData(
                backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 
                  0.2,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _calculateInterval(),
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          value.toInt(),
                        );
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize:
                          50, // Aumentado un poco para que quepan símbolos como USD
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            // 🔑 Usamos el símbolo del provider en el eje Y
                            '${preferencesProvider.getSymbolForCurrency(preferencesProvider.selectedCurrency)}${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: history.map((point) {
                      return FlSpot(
                        point.createdAt.millisecondsSinceEpoch.toDouble(),
                        // 🔑 CONVERSIÓN CRÍTICA: Convertimos el precio del punto
                        preferencesProvider.convertPrice(point.price),
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                          theme.colorScheme.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => theme.colorScheme.surfaceVariant,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          barSpot.x.toInt(),
                        );
                        return LineTooltipItem(
                          '${DateFormat('dd MMM').format(date)}\n',
                          const TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              // 🔑 Tooltip con la moneda seleccionada
                              text:
                                  '${preferencesProvider.getSymbolForCurrency(preferencesProvider.selectedCurrency)}${barSpot.y.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateInterval() {
    if (history.length < 2) return 1;
    final first = history.first.createdAt.millisecondsSinceEpoch;
    final last = history.last.createdAt.millisecondsSinceEpoch;
    return (last - first) / 4;
  }
}
