import 'package:flutter/material.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:provider/provider.dart';

class LowStockCard extends StatefulWidget {
  const LowStockCard({super.key});

  @override
  State<LowStockCard> createState() => _LowStockCardState();
}

class _LowStockCardState extends State<LowStockCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InventoryItemProvider>(
        context,
        listen: false,
      );
      // Llamamos al método que acabamos de arreglar
      provider.loadAllItemsGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryItemProvider>(
      builder: (context, itemProvider, child) {
        // 2. Si el provider está cargando, mostramos un indicador
        if (itemProvider.isLoading && itemProvider.inventoryItems.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final lowStockItems = itemProvider.inventoryItems
            .where((item) => item.quantity < (item.minStock))
            .toList();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Importante para evitar errores de scroll
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade600,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Stock Bajo (${lowStockItems.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (lowStockItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        '✅ Todo el stock está en niveles óptimos',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  // 3. Limitamos el tamaño del ListView para que no rompa el Dashboard
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lowStockItems.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      final item = lowStockItems[index];
                      final double minStock = item.minStock.toDouble();
                      final double quantity = item.quantity.toDouble();

                      // Evitar división por cero
                      final stockPercentage = minStock > 0
                          ? (quantity / minStock * 100).clamp(0.0, 100.0)
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${item.quantity}/$minStock',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: stockPercentage < 50
                                        ? Colors.red.shade600
                                        : Colors.orange.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: stockPercentage / 100,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  stockPercentage < 50
                                      ? Colors.red.shade600
                                      : Colors.orange.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
