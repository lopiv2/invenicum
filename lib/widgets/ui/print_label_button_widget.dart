import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/widgets/ui/asset_tag_qr_widget.dart';
import 'package:provider/provider.dart';

class PrintLabelButton extends StatelessWidget {
  final InventoryItem item;
  final bool fullWidth;

  const PrintLabelButton({super.key, required this.item, this.fullWidth = true});

  // 💡 HACEMOS ESTA FUNCIÓN ESTÁTICA Y PÚBLICA
  static void showPreview(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer<InventoryItemProvider>( // Usamos Consumer aquí
        builder: (context, provider, _) => AlertDialog(
          title: const Text("Vista Previa"),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "La etiqueta física se generará con este formato.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                BentoPrintTile(item: item, showButton: false),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton.icon(
              onPressed: provider.isPrinting
                  ? null
                  : () async {
                      await provider.printLabel(item.id.toString());
                      if (context.mounted) Navigator.pop(dialogContext);
                    },
              icon: provider.isPrinting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print_rounded),
              label: Text(provider.isPrinting ? "Cargando..." : "IMPRIMIR"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () => showPreview(context, item), // Llamamos a la función estática
        // ... (mismo estilo que ya tenías)
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text("IMPRIMIR ETIQUETA"),
      ),
    );
  }
}