import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:provider/provider.dart';
// Importa tus traducciones
import 'package:invenicum/l10n/app_localizations.dart';

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
      Provider.of<InventoryItemProvider>(context, listen: false).loadAllItemsGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Consumer<InventoryItemProvider>(
      builder: (context, itemProvider, child) {
        if (itemProvider.isLoading) return _buildLoadingState(isDark);

        final items = itemProvider.allInventoryItems;
        final lowStockItems = items.where((item) => item.quantity < item.minStock).toList();
        
        // Color de estado: Naranja si hay alertas, Azul si todo está ok
        final Color stateColor = lowStockItems.isNotEmpty ? Colors.orangeAccent : Colors.blueAccent;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? Colors.grey.shade900 : Colors.white).withValues(alpha: 0.85),
                      (isDark ? Colors.black : Colors.blue.shade50).withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(lowStockItems.length, l10n, stateColor, isDark),
                    const SizedBox(height: 24),
                    if (lowStockItems.isEmpty)
                      _buildEmptyState(l10n)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lowStockItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final item = lowStockItems[index];
                          return _buildStockItem(item, isDark, l10n);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int count, AppLocalizations l10n, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            count > 0 ? Icons.warning_amber_rounded : Icons.inventory_2_outlined, 
            color: color, 
            size: 20
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.inventoryLabel.toUpperCase(), // 👈 Traducción: INVENTARIO
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.5, 
                  color: Colors.grey
                ),
              ),
              Text(
                "${l10n.lowStockTitle} ($count)", // 👈 Traducción: Stock Bajo
                style: TextStyle(
                  fontSize: 17, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blueGrey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockItem(dynamic item, bool isDark, AppLocalizations l10n) {
    final double minStock = item.minStock.toDouble();
    final double quantity = item.quantity.toDouble();
    final double percentage = minStock > 0 ? (quantity / minStock).clamp(0.0, 1.0) : 0.0;
    
    // Rojo si es crítico (menos del 50% del mínimo), naranja si está cerca
    final Color itemColor = percentage < 0.5 ? Colors.redAccent : Colors.orangeAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${item.quantity}',
                    style: TextStyle(
                      color: itemColor, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 15
                    ),
                  ),
                  TextSpan(
                    text: ' / $minStock',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildProgressBar(percentage, itemColor, isDark),
      ],
    );
  }

  Widget _buildProgressBar(double value, Color color, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: 8,
              width: constraints.maxWidth * value,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3), 
                    blurRadius: 6, 
                    offset: const Offset(0, 2)
                  )
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.blueAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.optimalStockStatus, // 👈 Traducción: Stock en niveles óptimos
              style: const TextStyle(
                color: Colors.grey, 
                fontSize: 13, 
                fontStyle: FontStyle.italic
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}