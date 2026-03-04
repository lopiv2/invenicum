import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BentoPrintTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onPrint;
  final bool isPrinting;
  final bool showButton;

  const BentoPrintTile({
    super.key,
    required this.item,
    this.onPrint,
    this.isPrinting = false,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Definimos la tarjeta con un diseño que NO dependa de Expanded
    final labelContent = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        // Usamos crossAxisAlignment para que no intente medir alturas infinitas
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(
            data: 'invenicum://asset/${item.id}',
            version: QrVersions.auto,
            size: 80.0,
          ),
          const SizedBox(width: 12),
          // IMPORTANTE: En lugar de Flexible/Expanded puro, usamos un SizedBox 
          // o limitamos el ancho del texto para ayudar al motor de renderizado
          SizedBox(
            width: 180, // Ancho fijo para el área de texto
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "ID: #${item.id}",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                _buildSizeBadge(),
              ],
            ),
          ),
        ],
      ),
    );

    if (!showButton) return labelContent;

    return BentoBoxWidget(
      width: 350,
      title: "Etiqueta de Inventario",
      icon: Icons.print_outlined,
      child: Column(
        children: [
          labelContent,
          const SizedBox(height: 16),
          _buildPrintButton(context),
        ],
      ),
    );
  }

  Widget _buildSizeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "50x30mm Standard",
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPrinting ? null : onPrint,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isPrinting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text("IMPRIMIR AHORA"),
      ),
    );
  }
}