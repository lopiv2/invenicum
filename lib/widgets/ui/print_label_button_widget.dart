import 'package:flutter/material.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/widgets/ui/asset_tag_qr_widget.dart';
import 'package:provider/provider.dart';

class LabelSize {
  final String name;
  final double width;
  final double height;
  final String code;

  LabelSize(this.name, this.width, this.height, this.code);
}

// Definimos los tamaños disponibles
final List<LabelSize> labelSizes = [
  LabelSize("Pequeña (S) - 25x15mm", 25, 15, "S"),
  LabelSize("Estándar (M) - 50x30mm", 50, 30, "M"),
  LabelSize("Grande (L) - 75x50mm", 75, 50, "L"),
];

class PrintLabelButton extends StatelessWidget {
  final InventoryItem item;
  final bool fullWidth;

  const PrintLabelButton({
    super.key,
    required this.item,
    this.fullWidth = true,
  });

  // 💡 HACEMOS ESTA FUNCIÓN ESTÁTICA Y PÚBLICA
  static void showPreview(BuildContext context, InventoryItem item) {
    // Tamaño inicial por defecto (M)
    LabelSize selectedSize = labelSizes[1];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        // 👈 Crucial para actualizar el diálogo
        builder: (context, setDialogState) {
          return Consumer<InventoryItemProvider>(
            builder: (context, provider, _) => AlertDialog(
              title: const Text("Configurar Impresión"),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- SELECTOR DE TAMAÑO ---
                    DropdownButtonFormField<LabelSize>(
                      value: selectedSize,
                      decoration: const InputDecoration(
                        labelText: "Tamaño de etiqueta",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: labelSizes.map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text(size.name),
                        );
                      }).toList(),
                      onChanged: (newSize) {
                        if (newSize != null) {
                          // 👈 Actualizamos el estado interno del diálogo
                          setDialogState(() => selectedSize = newSize);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- VISTA PREVIA ACTUALIZADA ---
                    BentoPrintTile(
                      item: item,
                      showButton: false,
                      widthMm: selectedSize.width, // Le pasamos el ancho
                      heightMm: selectedSize.height, // Le pasamos el alto
                    ),
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
                          // 💡 Enviamos las medidas reales al provider
                          await provider.printLabel(
                            item.id.toString(),
                            width: selectedSize.width,
                            height: selectedSize.height,
                          );
                          if (context.mounted) Navigator.pop(dialogContext);
                        },
                  icon: provider.isPrinting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print_rounded),
                  label: Text(
                    provider.isPrinting ? "Generando..." : "IMPRIMIR",
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () =>
            showPreview(context, item), // Llamamos a la función estática
        // ... (mismo estilo que ya tenías)
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text("IMPRIMIR ETIQUETA"),
      ),
    );
  }
}
