import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:invenicum/core/utils/common_functions.dart';

class MarketValueLineChartContent extends StatelessWidget {
  final Map<int, double> monthlyValues; // Mes (1-12) -> Valor Total
  final bool isDark;
  final String currencySymbol;

  const MarketValueLineChartContent({
    super.key,
    required this.monthlyValues,
    required this.isDark,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).languageCode;
    // Encontrar el valor máximo para escalar el eje Y
    double maxValue = monthlyValues.values.isEmpty
        ? 100
        : monthlyValues.values.reduce((a, b) => a > b ? a : b);

    // Añadimos un margen superior del 20% al valor máximo
    maxValue = maxValue == 0 ? 100 : maxValue * 1.2;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primaryColor =
        colorScheme.primary; // Color de la línea principal

    // Un degradado que va del color primario (arriba) a casi transparente (abajo)
    final LinearGradient belowBarGradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.2), // Suave arriba
        primaryColor.withValues(alpha: 0.01), // Casi invisible abajo
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final Color lightPrimary = Theme.of(context).colorScheme.primaryContainer;
    return SizedBox(
      height: 320,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            handleBuiltInTouches:
                true, // Habilita el comportamiento por defecto
            touchTooltipData: LineTouchTooltipData(
              // Fondo del tooltip (un gris oscuro/claro translúcido tipo cristal)
              // Distancia entre el punto y el tooltip
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              // Esta función define QUÉ texto se muestra y CÓMO se ve
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  // 'touchedSpot.y' es el valor numérico del punto
                  final double value = touchedSpot.y;

                  // 1. FORMATO DE CURRENCY Y DOS DECIMALES
                  final String formattedValue =
                      '$currencySymbol ${value.toStringAsFixed(2)}';

                  // 2. ESTILO DEL TEXTO (COLOR Y FORMATO)
                  return LineTooltipItem(
                    // Puedes poner solo el valor, o "$monthName\n$formattedValue"
                    formattedValue,
                    TextStyle(
                      color:
                          lightPrimary, // <--- OTRO COLOR (el morado de la gráfica)
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
            // Opcional: Círculo indicador que aparece sobre el punto tocado
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((spotIndex) {
                    return TouchedSpotIndicatorData(
                      FlLine(color: lightPrimary, strokeWidth: 2),
                      FlDotData(
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 6,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: lightPrimary,
                            ),
                      ),
                    );
                  }).toList();
                },
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: _buildTitlesData(locale),
          borderData: FlBorderData(show: false),
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: maxValue,
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: true,

              // --- CAMBIO 1: COLOR DE LA LÍNEA ---
              // Si quieres un degradado dinámico (ej: de primario a secundario)
              gradient: LinearGradient(
                colors: [primaryColor, colorScheme.secondary],
              ),

              // Si prefieres UN SOLO COLOR sólido de tu tema:
              // color: primaryColor,
              // ------------------------------------
              barWidth: 4,
              isStrokeCapRound: true,

              // --- CAMBIO 2: COLOR DE LOS PUNTOS ---
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: primaryColor, // Usamos el color primario del tema
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
              // ------------------------------------

              // --- CAMBIO 3: COLOR DEL ÁREA INFERIOR ---
              belowBarData: BarAreaData(
                show: true,
                gradient:
                    belowBarGradient, // Usamos el degradado que definimos arriba
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return List.generate(12, (index) {
      final month = index + 1;
      return FlSpot(month.toDouble(), monthlyValues[month] ?? 0.0);
    });
  }

  FlTitlesData _buildTitlesData(String locale) {
    return FlTitlesData(
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 60,
          getTitlesWidget: (value, meta) {
            // Aplicamos la misma lógica que tu PriceDisplayWidget:
            // 1. Símbolo de moneda
            // 2. Valor con 2 decimales fijos
            final String formattedValue =
                '$currencySymbol ${value.toStringAsFixed(2)}';

            return SideTitleWidget(
              meta: meta,
              child: Text(
                formattedValue,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final int monthIndex = value.toInt();
            if (monthIndex < 1 || monthIndex > 12) return const SizedBox();
            final String label = AppUtils.getLocalizedMonth(
              monthIndex,
              locale,
              short: false,
            );
            return SideTitleWidget(
              meta: meta,
              space: 8, // Espacio entre el punto y el texto
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
