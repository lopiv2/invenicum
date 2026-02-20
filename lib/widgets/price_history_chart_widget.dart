import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/price_history_point.dart'; // Asegúrate de importar tu modelo

class PriceHistoryChart extends StatelessWidget {
  final List<PriceHistoryPoint> history;

  const PriceHistoryChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No hay historial de precios disponible")),
      );
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Evolución del precio",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        AspectRatio(
          aspectRatio: 6,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 10, top: 10, bottom: 10),
            child: LineChart(
              LineChartData(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _calculateInterval(),
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '€${value.toInt()}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                        point.price,
                      );
                    }).toList(),
                    isCurved: true, // Líneas curvas para suavizar
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true, // Muestra los puntos
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: theme.colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true, // Sombreado debajo de la línea
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.primary.withOpacity(0.0),
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
                        final date = DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt());
                        return LineTooltipItem(
                          '${DateFormat('dd MMM').format(date)}\n',
                          const TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '€${barSpot.y.toStringAsFixed(2)}',
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
    return (last - first) / 4; // Divide el eje X en 4 partes
  }
}