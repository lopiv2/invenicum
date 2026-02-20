import 'package:invenicum/models/expiring_loan.dart';
import 'package:invenicum/models/top_loaned_items.dart';

/// Define la estructura de los datos que esperamos del endpoint de estadísticas.
class DashboardStats {
  final int totalContainers;
  final int totalItems;
  final int totalAssets;
  final int itemsPending;
  final int itemsLowStock;
  final double totalValue;
  final List<TopLoanedItem> topLoanedItems;
  final List<ExpiringLoan> loansExpiringToday;

  DashboardStats({
    required this.totalContainers,
    required this.totalItems,
    required this.totalAssets,
    required this.itemsPending,
    required this.itemsLowStock,
    required this.totalValue,
    required this.topLoanedItems,
    required this.loansExpiringToday,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalAssets: json['totalAssets'] as int? ?? 0,
      totalContainers: json['totalContainers'] as int? ?? 0,
      totalItems: json['totalItems'] as int? ?? 0,
      itemsPending: json['itemsPending'] as int? ?? 0,
      itemsLowStock: json['itemsLowStock'] as int? ?? 0,
      // Manejamos el valor económico asegurando que sea double
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      topLoanedItems:
          (json['topLoanedItems'] as List?)
              ?.map((item) => TopLoanedItem.fromJson(item))
              .toList() ??
          [],
      // 🚀 Mapeo de préstamos que vencen hoy
      loansExpiringToday:
          (json['loansExpiringToday'] as List?)
              ?.map((item) => ExpiringLoan.fromJson(item))
              .toList() ??
          [],
    );
  }
}
