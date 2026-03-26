import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TopLoanedBarChartContent extends StatelessWidget {
  final Map<String, int> topItems;
  final bool isDark;

  const TopLoanedBarChartContent({
    super.key,
    required this.topItems,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final itemNames = topItems.keys.toList();
    final itemCounts = topItems.values.toList();
    final maxCount = itemCounts.isEmpty
        ? 1
        : itemCounts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxCount * 1.4).toDouble(),
          barTouchData: _buildBarTouchData(itemNames, isDark),
          titlesData: _buildTitlesData(itemNames, isDark),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxCount / 4).clamp(1, 100).toDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.05,
              ),
              strokeWidth: 1,
              dashArray: [5, 5], // Líneas punteadas para un look más técnico
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
              left: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          barGroups: _buildBarGroups(itemCounts, isDark, colorScheme),
        ),
      ),
    );
  }
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
                color: Colors.white.withValues(alpha: 0.8),
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

List<BarChartGroupData> _buildBarGroups(
  List<int> counts,
  bool isDark,
  ColorScheme colorScheme,
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
            colors: [
              _getBarColor(i, colorScheme).withValues(alpha: 0.4),
              _getBarColor(i, colorScheme),
            ],
          ),
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          // Pequeña "gorra" brillante al final de la barra
          rodStackItems: [
            BarChartRodStackItem(
              counts[i].toDouble() - 0.2,
              counts[i].toDouble(),
              Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ],
    );
  });
}

Color _getBarColor(int index, ColorScheme colorScheme) {
  return [
    colorScheme.primary,
    colorScheme.secondary,
    colorScheme.surfaceBright,
    colorScheme.primaryContainer,
  ][index % 4];
}
