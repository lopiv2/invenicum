import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/widgets/ui/price_display_widget.dart';
import 'package:provider/provider.dart';

class LocationValueHeatmap extends StatelessWidget {
  const LocationValueHeatmap({super.key, this.maxRows = 8, this.maxSlices = 6});

  final int maxRows;
  final int maxSlices;

  @override
  Widget build(BuildContext context) {
    return Consumer2<InventoryItemProvider, ContainerProvider>(
      builder: (context, itemProvider, containerProvider, _) {
        final allItems = itemProvider.allDownloadedItems;
        final locationIndex = _buildLocationIndex(containerProvider.containers);
        final cells = _buildCells(allItems, locationIndex);

        return _LocationValueDonutCard(
          cells: cells.take(maxRows).toList(),
          maxSlices: maxSlices,
          isLoading: itemProvider.isLoading && allItems.isEmpty,
          unassignedCount: allItems
              .where((item) => item.locationId == null)
              .length,
          unassignedValue: allItems
              .where((item) => item.locationId == null)
              .fold<double>(0, (sum, item) => sum + _resolveItemValue(item)),
        );
      },
    );
  }

  Map<String, _LocationMeta> _buildLocationIndex(
    List<ContainerNode> containers,
  ) {
    final index = <String, _LocationMeta>{};

    for (final container in containers) {
      void visit(Location location, String parentPath) {
        final path = parentPath.isEmpty
            ? location.name
            : '$parentPath > ${location.name}';
        final key = '${container.id}-${location.id}';
        index[key] = _LocationMeta(
          containerName: container.name,
          locationName: location.name,
          locationPath: path,
        );

        for (final child in location.children ?? const <Location>[]) {
          visit(child, path);
        }
      }

      for (final location in container.locations) {
        visit(location, '');
      }
    }

    return index;
  }

  List<_HeatmapCellData> _buildCells(
    List<InventoryItem> items,
    Map<String, _LocationMeta> locationIndex,
  ) {
    final grouped = <String, _HeatmapCellData>{};

    for (final item in items) {
      if (item.locationId == null) continue;

      final key = '${item.containerId}-${item.locationId}';
      final meta =
          locationIndex[key] ??
          _LocationMeta(
            containerName: 'Contenedor ${item.containerId}',
            locationName: 'Ubicación ${item.locationId}',
            locationPath: 'Ubicación ${item.locationId}',
          );

      final value = _resolveItemValue(item);
      final quantity = item.quantity > 0 ? item.quantity : 1;

      grouped.update(
        key,
        (current) => current.copyWith(
          totalValue: current.totalValue + value,
          totalQuantity: current.totalQuantity + quantity,
          totalEntries: current.totalEntries + 1,
        ),
        ifAbsent: () => _HeatmapCellData(
          key: key,
          containerName: meta.containerName,
          locationName: meta.locationName,
          locationPath: meta.locationPath,
          totalValue: value,
          totalQuantity: quantity,
          totalEntries: 1,
        ),
      );
    }

    final cells = grouped.values.toList()
      ..sort((a, b) {
        final valueCompare = b.totalValue.compareTo(a.totalValue);
        if (valueCompare != 0) return valueCompare;
        return b.totalQuantity.compareTo(a.totalQuantity);
      });

    return cells;
  }

  static double _resolveItemValue(InventoryItem item) {
    if (item.totalMarketValue > 0) return item.totalMarketValue;
    if (item.marketValue > 0) return item.marketValue * item.quantity;
    return 0;
  }
}

class _LocationValueDonutCard extends StatelessWidget {
  const _LocationValueDonutCard({
    required this.cells,
    required this.maxSlices,
    required this.isLoading,
    required this.unassignedCount,
    required this.unassignedValue,
  });

  final List<_HeatmapCellData> cells;
  final int maxSlices;
  final bool isLoading;
  final int unassignedCount;
  final double unassignedValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = _buildSections(cells, maxSlices);
    final totalValue = cells.fold<double>(
      0,
      (sum, cell) => sum + cell.totalValue,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.surface, const Color(0xFFF7F0E6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribución de valor por ubicación',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'El donut muestra cómo se reparte el valor de mercado entre las ubicaciones con más peso.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LegendPill(
                    label: '${cells.length} ubicaciones',
                    color: const Color(0xFFCF7A32),
                  ),
                  _LegendPill(
                    color: const Color(0xFF245C4A),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total '),
                        PriceDisplayWidget(
                          value: totalValue,
                          color: Colors.white,
                          fontSize: 12,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unassignedCount > 0)
                    _LegendPill(
                      color: const Color(0xFF245C4A),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$unassignedCount sin ubicación · '),
                          PriceDisplayWidget(
                            value: unassignedValue,
                            color: Colors.white,
                            fontSize: 12,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (cells.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noLocationValueData,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _DonutChartPanel(
                          sections: sections,
                          totalValue: totalValue,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: _LocationRankingList(cells: cells),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _DonutChartPanel(
                      sections: sections,
                      totalValue: totalValue,
                    ),
                    const SizedBox(height: 20),
                    _LocationRankingList(cells: cells),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  List<_ChartSectionData> _buildSections(
    List<_HeatmapCellData> cells,
    int maxSlices,
  ) {
    const palette = <Color>[
      Color(0xFFCF7A32),
      Color(0xFF2E6F95),
      Color(0xFF5E8C61),
      Color(0xFF7B4B94),
      Color(0xFFB24C63),
      Color(0xFF246A73),
    ];

    final top = cells.take(maxSlices).toList();
    final sections = <_ChartSectionData>[];

    for (var index = 0; index < top.length; index++) {
      sections.add(
        _ChartSectionData(
          cell: top[index],
          color: palette[index % palette.length],
        ),
      );
    }

    if (cells.length > maxSlices) {
      final remaining = cells.skip(maxSlices).toList();
      final otherValue = remaining.fold<double>(
        0,
        (sum, cell) => sum + cell.totalValue,
      );
      final otherQuantity = remaining.fold<int>(
        0,
        (sum, cell) => sum + cell.totalQuantity,
      );
      final otherEntries = remaining.fold<int>(
        0,
        (sum, cell) => sum + cell.totalEntries,
      );
      sections.add(
        _ChartSectionData(
          cell: _HeatmapCellData(
            key: 'others',
            containerName: 'Resto de ubicaciones',
            locationName: 'Otras ubicaciones',
            locationPath: '${remaining.length} ubicaciones adicionales',
            totalValue: otherValue,
            totalQuantity: otherQuantity,
            totalEntries: otherEntries,
          ),
          color: const Color(0xFF8B949E),
        ),
      );
    }

    return sections;
  }
}

class _DonutChartPanel extends StatefulWidget {
  const _DonutChartPanel({required this.sections, required this.totalValue});

  final List<_ChartSectionData> sections;
  final double totalValue;

  @override
  State<_DonutChartPanel> createState() => _DonutChartPanelState();
}

class _DonutChartPanelState extends State<_DonutChartPanel> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlighted =
        touchedIndex >= 0 && touchedIndex < widget.sections.length
        ? widget.sections[touchedIndex]
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response?.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              response!.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    centerSpaceRadius: 74,
                    sectionsSpace: 3,
                    startDegreeOffset: -90,
                    sections: [
                      for (
                        var index = 0;
                        index < widget.sections.length;
                        index++
                      )
                        _buildPieSection(
                          widget.sections[index],
                          index == touchedIndex,
                          widget.totalValue,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      highlighted?.cell.locationName ?? 'Valor total',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    PriceDisplayWidget(
                      value: highlighted?.cell.totalValue ?? widget.totalValue,
                      color: theme.colorScheme.onSurface,
                      fontSize: 26,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (highlighted != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_percent(highlighted.cell.totalValue, widget.totalValue).toStringAsFixed(1)}% del valor',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final section in widget.sections)
                _LegendPill(
                  label: section.cell.locationName,
                  color: section.color,
                ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(
    _ChartSectionData section,
    bool isSelected,
    double totalValue,
  ) {
    final percentage = _percent(section.cell.totalValue, totalValue);
    return PieChartSectionData(
      color: section.color,
      value: section.cell.totalValue <= 0 ? 0.0001 : section.cell.totalValue,
      radius: isSelected ? 98 : 88,
      title: percentage >= 8 ? '${percentage.toStringAsFixed(0)}%' : '',
      titleStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: isSelected ? 15 : 12,
      ),
    );
  }
}

class _LocationRankingList extends StatelessWidget {
  const _LocationRankingList({required this.cells});

  final List<_HeatmapCellData> cells;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalValue = cells.fold<double>(
      0,
      (sum, cell) => sum + cell.totalValue,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < cells.length; index++) ...[
            _RankingRow(
              rank: index + 1,
              cell: cells[index],
              percentage: _percent(cells[index].totalValue, totalValue),
            ),
            if (index != cells.length - 1)
              Divider(
                height: 20,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
          ],
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.cell,
    required this.percentage,
  });

  final int rank;
  final _HeatmapCellData cell;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$rank',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cell.locationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${cell.containerName} · ${cell.locationPath}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricBadge(label: '${cell.totalQuantity} uds'),
                  _MetricBadge(label: '${cell.totalEntries} registros'),
                  _MetricBadge(label: '${percentage.toStringAsFixed(1)}%'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PriceDisplayWidget(
          value: cell.totalValue,
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({this.label, required this.color, this.child});

  final String? label;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final textColor = color.computeLuminance() > 0.45
        ? Colors.black87
        : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        child: child ?? Text(label ?? ''),
      ),
    );
  }
}

class _LocationMeta {
  const _LocationMeta({
    required this.containerName,
    required this.locationName,
    required this.locationPath,
  });

  final String containerName;
  final String locationName;
  final String locationPath;
}

class _ChartSectionData {
  const _ChartSectionData({required this.cell, required this.color});

  final _HeatmapCellData cell;
  final Color color;
}

class _HeatmapCellData {
  const _HeatmapCellData({
    required this.key,
    required this.containerName,
    required this.locationName,
    required this.locationPath,
    required this.totalValue,
    required this.totalQuantity,
    required this.totalEntries,
  });

  final String key;
  final String containerName;
  final String locationName;
  final String locationPath;
  final double totalValue;
  final int totalQuantity;
  final int totalEntries;

  _HeatmapCellData copyWith({
    double? totalValue,
    int? totalQuantity,
    int? totalEntries,
  }) {
    return _HeatmapCellData(
      key: key,
      containerName: containerName,
      locationName: locationName,
      locationPath: locationPath,
      totalValue: totalValue ?? this.totalValue,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalEntries: totalEntries ?? this.totalEntries,
    );
  }
}

double _percent(double value, double total) {
  if (total <= 0) return 0;
  return (value / total) * 100;
}
