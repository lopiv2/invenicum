import 'package:flutter/material.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/widgets/ui/icon_badge.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'chart_main_container.dart';
import 'glass_ui_elements.dart';
import 'market_value_chart_content.dart';

class MarketValueEvolutionChart extends StatefulWidget {
  const MarketValueEvolutionChart({super.key});

  @override
  State<MarketValueEvolutionChart> createState() =>
      _MarketValueEvolutionChartState();
}

class _MarketValueEvolutionChartState extends State<MarketValueEvolutionChart> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    // Al entrar a la pantalla, nos aseguramos de pedir todos los items
    // para que la gráfica tenga datos reales de todo el inventario.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InventoryItemProvider>();
      provider.loadAllItemsGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<InventoryItemProvider, PreferencesProvider>(
      builder: (context, inventoryProvider, preferences, child) {
        final allItems = inventoryProvider.allDownloadedItems;

        if (inventoryProvider.isLoading && allItems.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 1. Obtenemos la lista de años
        final availableYears = _getAvailableYears(allItems);

        // 2. SEGURIDAD: Determinamos qué valor mostrar REALMENTE en el dropdown
        // No modificamos _selectedYear aquí (para no ensuciar el estado en el build),
        // simplemente calculamos el valor válido para el widget.
        int effectiveYear = _selectedYear;
        if (!availableYears.contains(effectiveYear)) {
          effectiveYear = availableYears.isNotEmpty
              ? availableYears.first
              : DateTime.now().year;
        }
        // 1. Calculamos los valores en la moneda base (USD)
        final rawMonthlyData = _calculateMonthlyValue(allItems, effectiveYear);

        // 2. CONVERSIÓN: Creamos un nuevo mapa con los valores convertidos
        final Map<int, double> convertedData = rawMonthlyData.map((
          month,
          usdValue,
        ) {
          return MapEntry(month, preferences.convertPrice(usdValue));
        });

        return GlassMainContainer(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Usamos un ConstrainedBox o simplemente dejamos que el Dropdown ocupe su sitio
                  // Asegúrate de que GlassDropdown NO tenga un Expanded interno como vimos antes.
                  GlassDropdown<int>(
                    value: effectiveYear, // Usamos el valor validado
                    items: availableYears.map((y) {
                      return DropdownMenuItem<int>(
                        value: y,
                        child: Text('$y', style: const TextStyle(fontSize: 13)),
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
                height: 220,
                child: MarketValueLineChartContent(
                  monthlyValues: convertedData,
                  isDark: isDark,
                  currencySymbol: preferences.getSymbolForCurrency(preferences.selectedCurrency),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calcula el valor acumulado mes a mes.
  /// IMPORTANTE: Considera (Valor de Mercado * Cantidad)
  Map<int, double> _calculateMonthlyValue(List<InventoryItem> items, int year) {
    final Map<int, double> monthlyIncrements = {};
    for (int i = 1; i <= 12; i++) monthlyIncrements[i] = 0.0;

    double baseValue = 0.0;

    for (var item in items) {
      // Tomamos marketValue, si es null usamos 0.0
      final double val = item.marketValue;
      final int qty = item.quantity;
      final double totalItemValue = val * qty;

      final date = item.createdAt;

      if (date!.year < year) {
        // Si el item es de años anteriores, se suma al valor inicial del 1 de Enero
        baseValue += totalItemValue;
      } else if (date.year == year) {
        // Si es del año actual, lo sumamos al mes correspondiente
        monthlyIncrements[date.month] =
            (monthlyIncrements[date.month] ?? 0) + totalItemValue;
      }
    }

    // Convertimos los incrementos mensuales en una línea acumulativa
    final Map<int, double> cumulativeData = {};
    double runningTotal = baseValue;

    for (int i = 1; i <= 12; i++) {
      runningTotal += monthlyIncrements[i]!;
      cumulativeData[i] = runningTotal;
    }

    return cumulativeData;
  }

  /// Extrae la lista de años únicos presentes en el inventario
  List<int> _getAvailableYears(List<InventoryItem> items) {
    final int currentYear = DateTime.now().year;

    // Extraemos los años, filtramos nulos por seguridad y convertimos a Set para unicidad
    final Set<int> yearsSet = items
        .map((i) => i.createdAt?.year)
        .whereType<int>()
        .toSet();

    // Siempre garantizamos que el año actual o el seleccionado estén disponibles
    yearsSet.add(currentYear);
    yearsSet.add(_selectedYear);

    final List<int> result = yearsSet.toList();
    result.sort((a, b) => b.compareTo(a)); // De más reciente a más antiguo
    return result;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const IconBadge(
          icon: Icons.show_chart_rounded,
          color: Colors.greenAccent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.marketValueEvolution.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
