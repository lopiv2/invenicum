import 'package:flutter/material.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/services/dashboard_service.dart';
import 'package:invenicum/widgets/stat_card.dart';
import 'package:invenicum/widgets/low_stock_card.dart';
import 'package:invenicum/widgets/top_loaned_items_chart.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.dashboardService});

  final DashboardService dashboardService; // 🔑 Inyección del servicio

  // Simulación de una función que obtiene datos asíncronos (como si fuera una API)
  Future<DashboardStats> _fetchStats() {
    return dashboardService.getGlobalStats();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Usamos SingleChildScrollView por si la pantalla es pequeña
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // FutureBuilder para manejar el estado de carga de los datos
          FutureBuilder<DashboardStats>(
            future: _fetchStats(), // Llama a la función que simula la API
            builder: (context, snapshot) {
              // 1. Mostrar Error
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error al cargar datos: ${snapshot.error}'),
                );
              }

              // 2. Mostrar Carga (Loading)
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 3. Mostrar Datos (Done)
              if (snapshot.hasData) {
                final stats = snapshot.data!;
                // 🔑 Accedemos directamente a las propiedades del objeto Stats
                final totalContainers = stats.totalContainers;
                final totalItems = stats.totalItems;
                final totalAssets = stats.totalAssets;

                return Consumer<LoanProvider>(
                  builder: (context, loanProvider, child) {
                    final activeLoans = loanProvider.activeLoans.length;
                    final returnedLoans = loanProvider.returnedLoans.length;

                    return GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 4
                          : 2, // 2 o 3 columnas según el tamaño de la pantalla
                      crossAxisSpacing: 120,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                      shrinkWrap:
                          true, // Importante para que GridView funcione dentro de Column/SingleChildScrollView
                      physics:
                          const NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
                      children: [
                        // Widget para Contenedores Totales
                        StatCard(
                          title: 'Contenedores',
                          count: totalContainers,
                          icon: Icons.inventory_2_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        StatCard(
                          title: 'Tipos de Activos',
                          count: totalAssets,
                          icon: Icons.type_specimen,
                          color: Colors.orange.shade600,
                        ),
                        // Widget para Items/Activos Totales
                        StatCard(
                          title: 'Activos',
                          count: totalItems,
                          icon: Icons.devices_other_outlined,
                          color: Colors.green.shade600,
                        ),
                        // Widget para Préstamos Totales
                        StatCard(
                          title: 'Préstamos vigentes',
                          count: activeLoans,
                          icon: Icons.compare_arrows,
                          color: Colors.red.shade600,
                        ),
                        StatCard(
                          title: 'Préstamos devueltos',
                          count: returnedLoans,
                          icon: Icons.compare_arrows,
                          color: Colors.blue.shade600,
                        ),

                        // Puedes añadir más contadores aquí si es necesario
                      ],
                    );
                  },
                );
              }

              // 4. Caso por defecto (o cuando no hay datos)
              return const Center(
                child: Text('No se encontraron estadísticas.'),
              );
            },
          ),

          const SizedBox(height: 24),

          // Widget de Stock Bajo
          const LowStockCard(),

          const SizedBox(height: 24),

          // Widget de Productos Más Prestados
          const TopLoanedItemsChart(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}