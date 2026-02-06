import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/services/dashboard_service.dart';
import 'package:invenicum/widgets/stat_card.dart';
import 'package:invenicum/widgets/low_stock_card.dart';
import 'package:invenicum/widgets/top_loaned_items_chart.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.dashboardService});

  final DashboardService dashboardService;

  Future<DashboardStats?> _fetchStats(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    
    if (auth.token == null || auth.isLoading) {
      debugPrint('[DashboardScreen] Esperando token... Petición abortada.');
      return null; 
    }

    try {
      return await dashboardService.getGlobalStats();
    } catch (e) {
      debugPrint('[DashboardScreen] Error en fetch: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboard,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          FutureBuilder<DashboardStats?>(
            future: _fetchStats(context), 
            builder: (context, snapshot) {
              
              if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(l10n.syncingSession),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('${l10n.errorLoadingData}: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasData) {
                final stats = snapshot.data!;
                
                return Consumer<LoanProvider>(
                  builder: (context, loanProvider, child) {
                    return GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
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
                );
              }

              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 24),
          const LowStockCard(),
          const SizedBox(height: 24),
          const TopLoanedItemsChart(),
        ],
      ),
    );
  }
}