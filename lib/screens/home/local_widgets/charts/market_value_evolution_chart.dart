import 'package:invenicum/widgets/ui/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/inventory_ownership_utils.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/widgets/ui/icon_badge.dart';
import 'package:provider/provider.dart';

import 'chart_main_container.dart';
import 'glass_ui_elements.dart';
import 'market_value_chart_content.dart';

class MarketValueEvolutionChart extends StatefulWidget {
  const MarketValueEvolutionChart({super.key});

  @override
  State<MarketValueEvolutionChart> createState() =>
      _MarketValueEvolutionChartState();
}

class _MarketValueEvolutionChartState
    extends State<MarketValueEvolutionChart> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InventoryItemProvider>();
      provider.loadAllItemsGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer3<
      InventoryItemProvider,
      PreferencesProvider,
      ContainerProvider
    >(
      builder: (
        context,
        inventoryProvider,
        preferences,
        containerProvider,
        child,
      ) {
        final allItems = inventoryProvider.allDownloadedItems;

        if (inventoryProvider.isLoading && allItems.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(child: AppLoadingIndicator()),
          );
        }

        /// Only owned items
        final ownedItems = InventoryOwnershipUtils.filterOwnedItems(
          allItems,
          containerProvider.containers,
        );

        /// Available years based on owned items
        final availableYears = _getAvailableYears(ownedItems);

        /// VALIDATION OF ACTIVE YEAR
        int effectiveYear = _selectedYear;

        if (!availableYears.contains(effectiveYear)) {
          effectiveYear = availableYears.isNotEmpty
              ? availableYears.first
              : DateTime.now().year;
        }

        /// Monthly data only from owned items
        final rawMonthlyData = _calculateMonthlyValue(
          ownedItems,
          effectiveYear,
        );

        IconData? trendIcon;
        Color? trendColor;
        String? percentageText;

        final now = DateTime.now();

        final int currentMonth =
            (effectiveYear == now.year) ? now.month : 12;

        if (currentMonth > 1) {
          final double currentVal = rawMonthlyData[currentMonth] ?? 0;
          final double previousVal =
              rawMonthlyData[currentMonth - 1] ?? 0;

          if (previousVal > 0) {
            final double change =
                ((currentVal - previousVal) / previousVal) * 100;

            if (change.abs() > 0.1) {
              percentageText =
                  "${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%";

              trendIcon = change > 0
                  ? Icons.trending_up
                  : Icons.trending_down;

              trendColor = change > 0
                  ? Colors.greenAccent
                  : Colors.redAccent;
            }
          }
        } else if (currentMonth == 1 && effectiveYear > 2000) {
          /// January vs December of previous year
          final pastYearData = _calculateMonthlyValue(
            ownedItems,
            effectiveYear - 1,
          );

          final double decVal = pastYearData[12] ?? 0;
          final double janVal = rawMonthlyData[1] ?? 0;

          if (decVal > 0) {
            final double change = ((janVal - decVal) / decVal) * 100;

            if (change.abs() > 0.1) {
              percentageText =
                  "${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%";

              trendIcon = change > 0
                  ? Icons.trending_up
                  : Icons.trending_down;

              trendColor = change > 0
                  ? Colors.greenAccent
                  : Colors.redAccent;
            }
          }
        }

        /// COIN EXCHANGE
        final Map<int, double> convertedData =
            rawMonthlyData.map((month, usdValue) {
          return MapEntry(
            month,
            preferences.convertPrice(usdValue),
          );
        });

        return GlassMainContainer(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
                trendIcon,
                trendColor,
                percentageText,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  GlassDropdown<int>(
                    value: effectiveYear,
                    items: availableYears.map((y) {
                      return DropdownMenuItem<int>(
                        value: y,
                        child: Text(
                          '$y',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),

                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedYear = v);
                      }
                    },
                  ),

                  const Spacer(),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: MarketValueLineChartContent(
                  selectedYear: effectiveYear,
                  monthlyValues: convertedData,
                  isDark: isDark,
                  currencySymbol: preferences.getSymbolForCurrency(
                    preferences.selectedCurrency,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calculates the accumulated value month by month
  Map<int, double> _calculateMonthlyValue(
    List<InventoryItem> items,
    int year,
  ) {
    final Map<int, double> monthlyIncrements = {};

    for (int i = 1; i <= 12; i++) {
      monthlyIncrements[i] = 0.0;
    }

    double baseValue = 0.0;

    for (final item in items) {
      final double val = item.marketValue;
      final int qty = item.quantity;

      final double totalItemValue = val * qty;

      final date = item.createdAt;

      if (date == null) continue;

      if (date.year < year) {
        baseValue += totalItemValue;
      } else if (date.year == year) {
        monthlyIncrements[date.month] =
            (monthlyIncrements[date.month] ?? 0) +
            totalItemValue;
      }
    }

    final Map<int, double> cumulativeData = {};

    double runningTotal = baseValue;

    for (int i = 1; i <= 12; i++) {
      runningTotal += monthlyIncrements[i]!;
      cumulativeData[i] = runningTotal;
    }

    return cumulativeData;
  }

  /// Available years based on owned items
  List<int> _getAvailableYears(List<InventoryItem> items) {
    final currentYear = DateTime.now().year;

    final Set<int> yearsSet = items
        .map((i) => i.createdAt?.year)
        .whereType<int>()
        .toSet();

    yearsSet.add(currentYear);
    yearsSet.add(_selectedYear);

    final result = yearsSet.toList()
      ..sort((a, b) => b.compareTo(a));

    return result;
  }

  Widget _buildHeader(
    BuildContext context,
    IconData? icon,
    Color? color,
    String? text,
  ) {
    return Row(
      children: [
        const IconBadge(
          icon: Icons.show_chart_rounded,
          color: Colors.green,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            AppLocalizations.of(context)!
                .marketValueEvolution
                .toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
        ),

        if (text != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),

            decoration: BoxDecoration(
              color: color!.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 14,
                ),

                const SizedBox(width: 4),

                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}