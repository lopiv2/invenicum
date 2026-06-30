import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/data/services/toast_service.dart';
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

  static void showPreview(BuildContext context, InventoryItem item) {
    showAppDialog(
      context: context,
      builder: (_) => _LabelPrintDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () => showPreview(context, item),
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text("IMPRIMIR ETIQUETA"),
      ),
    );
  }
}

class _LabelPrintDialog extends StatefulWidget {
  final InventoryItem item;
  const _LabelPrintDialog({required this.item});

  @override
  State<_LabelPrintDialog> createState() => _LabelPrintDialogState();
}

class _LabelPrintDialogState extends State<_LabelPrintDialog> {
  LabelSize _selectedSize = labelSizes[1];
  bool _isPrinting = false;

  Future<void> _handlePrint() async {
    final provider = context.read<InventoryItemProvider>();
    setState(() => _isPrinting = true);
    try {
      await provider.printLabel(
        widget.item.id.toString(),
        width: _selectedSize.width,
        height: _selectedSize.height,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPrinting = false);
      ToastService.error('Error al imprimir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configurar Impresión"),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<LabelSize>(
              initialValue: _selectedSize,
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
                  setState(() => _selectedSize = newSize);
                }
              },
            ),
            const SizedBox(height: 20),
            BentoPrintTile(
              item: widget.item,
              showButton: false,
              widthMm: _selectedSize.width,
              heightMm: _selectedSize.height,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPrinting ? null : () => Navigator.of(context).pop(),
          child: const Text("CANCELAR"),
        ),
        ElevatedButton.icon(
          onPressed: _isPrinting ? null : _handlePrint,
          icon: _isPrinting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print_rounded),
          label: Text(_isPrinting ? "Generando..." : "IMPRIMIR"),
        ),
      ],
    );
  }
}
