import 'package:invenicum/widgets/ui/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
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

List<LabelSize> labelSizesOf(AppLocalizations l10n) => [
  LabelSize(l10n.labelSizeSmall, 25, 15, "S"),
  LabelSize(l10n.labelSizeMedium, 50, 30, "M"),
  LabelSize(l10n.labelSizeLarge, 75, 50, "L"),
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
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () => showPreview(context, item),
        icon: const Icon(Icons.qr_code_2_rounded),
        label: Text(l10n.printLabelButton),
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
  LabelSize? _selectedSize;
  bool _isPrinting = false;

  Future<void> _handlePrint() async {
    final provider = context.read<InventoryItemProvider>();
    final l10n = AppLocalizations.of(context)!;
    final size = _selectedSize ?? labelSizesOf(l10n)[1];
    setState(() => _isPrinting = true);
    try {
      await provider.printLabel(
        widget.item.id.toString(),
        width: size.width,
        height: size.height,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPrinting = false);
      ToastService.error(l10n.errorWithMessage(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sizes = labelSizesOf(l10n);
    final selected = _selectedSize ?? sizes[1];
    return AlertDialog(
      title: Text(l10n.configurePrintTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<LabelSize>(
              initialValue: selected,
              decoration: InputDecoration(
                labelText: l10n.labelSizeField,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: sizes.map((size) {
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
              widthMm: selected.width,
              heightMm: selected.height,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPrinting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton.icon(
          onPressed: _isPrinting ? null : _handlePrint,
          icon: _isPrinting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: AppLoadingIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print_rounded),
          label: Text(
            _isPrinting ? l10n.generatingLabel : l10n.printButton,
          ),
        ),
      ],
    );
  }
}
