import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/dashboard_stats.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/data/services/dashboard_service.dart';
import 'package:invenicum/screens/home/local_widgets/expiring_loan_widget.dart';
import 'package:invenicum/screens/home/local_widgets/low_stock_card.dart';
import 'package:invenicum/widgets/ui/stac_slot.dart';
import 'package:invenicum/widgets/ui/stat_card.dart';
import 'package:invenicum/screens/home/local_widgets/top_demanded_items_widget.dart';
import 'package:invenicum/screens/home/local_widgets/top_loaned_items_chart.dart';
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
      // También podrías cargar la inversión económica aquí
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

              if (snapshot.hasError || snapshot.data == null) {
                return Center(child: Text(l10n.errorLoadingData));
              }

              final stats = snapshot.data!;

              return Column(
                children: [
                  // 1. Widget de Inversión
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
                  ),
                  const SizedBox(height: 24),

                  // 2. Grid de Estadísticas
                  Consumer<LoanProvider>(
                    builder: (context, loanProvider, child) {
                      return GridView.count(
                        crossAxisCount: screenWidth > 600 ? 4 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.8,
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
          const TopLoanedItemsChart(),
          const SizedBox(height: 32),
          const StacSlot(slotName: 'dashboard_bottom'),
        ],
      ),
    );
  }
}
