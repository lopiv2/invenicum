import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/dashboard_stats.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/data/services/dashboard_service.dart';
import 'package:invenicum/screens/home/local_widgets/charts/market_value_evolution_chart.dart';
import 'package:invenicum/screens/home/local_widgets/expiring_loan_widget.dart';
import 'package:invenicum/screens/home/local_widgets/location_value_heatmap.dart';
import 'package:invenicum/screens/home/local_widgets/low_stock_card.dart';
import 'package:invenicum/widgets/ui/stac_slot.dart';
import 'package:invenicum/widgets/ui/stat_card.dart';
import 'package:invenicum/screens/home/local_widgets/top_demanded_items_widget.dart';
import 'package:invenicum/screens/home/local_widgets/charts/top_loaned_items_chart.dart';
import 'package:invenicum/screens/home/local_widgets/total_market_value_widget.dart';
import 'package:invenicum/screens/home/local_widgets/total_spending_widget.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.dashboardService});

  final DashboardService dashboardService;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardStats?> _statsFuture;

  @override
  void initState() {
    super.initState();
    // 1. Iniciamos la carga de las estadísticas globales
    _statsFuture = widget.dashboardService.getGlobalStats();

    // 2. Cargamos los préstamos en el Provider DESPUÉS del primer frame
    // Esto evita el error de "setState() called during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LoanProvider>().fetchAllLoans();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryItemProvider>().loadTotalMarketValue();
      context.read<InventoryItemProvider>().loadAllItemsGlobal();
      if (context.read<ContainerProvider>().containers.isEmpty) {
        context.read<ContainerProvider>().loadContainers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              l10n.dashboard,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          const StacSlot(slotName: 'dashboard_top'),
          const SizedBox(height: 24),

          FutureBuilder<DashboardStats?>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final stats =
                  snapshot.data ??
                  DashboardStats(
                    totalContainers: 0,
                    totalItems: 0,
                    totalAssets: 0,
                    itemsPending: 0,
                    itemsLowStock: 0,
                    totalValue: 0,
                    topLoanedItems: const [],
                    loansExpiringToday: const [],
                  );

              return Column(
                children: [
                  if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.errorLoadingData,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),

                  // 1. Widget de Inversión - Responsive
                  if (screenWidth > 600)
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: TotalSpendingWidget(
                              amount: stats.totalValue,
                              isLoading: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer<InventoryItemProvider>(
                              builder: (context, itemProvider, child) {
                                return TotalMarketValueWidget(
                                  marketValue: itemProvider.totalMarketValue,
                                  isLoading: itemProvider.isMarketValueLoading,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        TotalSpendingWidget(
                          amount: stats.totalValue,
                          isLoading: false,
                        ),
                        const SizedBox(height: 12),
                        Consumer<InventoryItemProvider>(
                          builder: (context, itemProvider, child) {
                            return TotalMarketValueWidget(
                              marketValue: itemProvider.totalMarketValue,
                              isLoading: itemProvider.isMarketValueLoading,
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // 2. Grid de Estadísticas
                  Consumer<LoanProvider>(
                    builder: (context, loanProvider, child) {
                      return GridView.count(
                        crossAxisCount: screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2),
                        crossAxisSpacing: screenWidth > 600 ? 20 : 12,
                        mainAxisSpacing: screenWidth > 600 ? 12 : 8,
                        childAspectRatio: screenWidth > 900 ? 1.8 : (screenWidth > 600 ? 1.6 : 1.5),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            title: l10n.containers,
                            count: stats.totalContainers,
                            icon: Icons.inventory_2_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          StatCard(
                            title: l10n.totalAssets,
                            count: stats.totalAssets,
                            icon: Icons.type_specimen,
                            color: Colors.orange.shade600,
                          ),
                          StatCard(
                            title: l10n.assets,
                            count: stats.totalItems,
                            icon: Icons.devices_other_outlined,
                            color: Colors.green.shade600,
                          ),
                          StatCard(
                            title: l10n.activeLoans,
                            count: loanProvider.activeLoans.length,
                            icon: Icons.compare_arrows,
                            color: Colors.red.shade600,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  const LocationValueHeatmap(),

                  const SizedBox(height: 24),

                  // 3. SECCIÓN MIXTA: Más Demandados y Expiran Hoy
                  // Si la pantalla es ancha (> 900px), usamos Row. Si no, Column.
                  if (screenWidth > 900)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TopDemandedItemsWidget(
                            items: stats.topLoanedItems,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: ExpiringLoansWidget(
                            loans: stats.loansExpiringToday,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        TopDemandedItemsWidget(items: stats.topLoanedItems),
                        const SizedBox(height: 24),
                        ExpiringLoansWidget(loans: stats.loansExpiringToday),
                      ],
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const LowStockCard(),
          const SizedBox(height: 24),
          if (screenWidth > 600)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: TopLoanedItemsChart()),
                const SizedBox(width: 16),
                const Expanded(child: MarketValueEvolutionChart()),
              ],
            )
          else
            Column(
              children: [
                const TopLoanedItemsChart(),
                const SizedBox(height: 16),
                const MarketValueEvolutionChart(),
              ],
            ),
          const SizedBox(height: 32),
          const StacSlot(slotName: 'dashboard_bottom'),
        ],
      ),
    );
  }
}
