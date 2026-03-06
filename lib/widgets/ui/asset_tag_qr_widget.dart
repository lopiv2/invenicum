import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BentoPrintTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onPrint;
  final bool isPrinting;
  final bool showButton;
  final double widthMm;
  final double heightMm;

  const BentoPrintTile({
    super.key,
    required this.item,
    this.onPrint,
    this.isPrinting = false,
    this.showButton = true,
    this.widthMm = 50, // Valores por defecto
    this.heightMm = 30,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Ajustamos el diseño visual basándonos en si es una etiqueta pequeña o grande
    final isSmall = widthMm < 40;

    final labelContent = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          8,
        ), // Bordes más rectos para simular papel
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ), // Guía de corte
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(
            data: 'invenicum://asset/${item.id}',
            version: QrVersions.auto,
            size: isSmall
                ? 50.0
                : 80.0, // El QR se encoge en etiquetas pequeñas
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "ID: #${item.id}",
                  style: TextStyle(
                    fontSize: isSmall ? 8 : 10,
                    color: Colors.grey.shade700,
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        // 3. Texto dinámico basado en los mm seleccionados
        "${widthMm.toInt()}x${heightMm.toInt()}mm ${widthMm > 60 ? 'Large' : 'Standard'}",
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isPrinting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("IMPRIMIR AHORA"),
      ),
    );
  }
}
