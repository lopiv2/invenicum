import 'dart:typed_data';
import 'package:file_picker/file_picker.dart'; // Restaurado FilePicker
import 'package:flutter/material.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:invenicum/data/services/voucher_service.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class DeliveryVoucherEditorScreen extends StatefulWidget {
  const DeliveryVoucherEditorScreen({super.key});

  @override
  State<DeliveryVoucherEditorScreen> createState() =>
      _DeliveryVoucherEditorScreenState();
}

class _DeliveryVoucherEditorScreenState
    extends State<DeliveryVoucherEditorScreen> {
  late TextEditingController _templateController;
  Uint8List? _logoBytes;
  bool _isLoading = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with your default text
    _templateController = TextEditingController(text: _getDefaultTemplate());
    // Load configuration from the DB on startup
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConfig());
  }

  // Your original default text
  String _getDefaultTemplate() {
    return '''Item: {itemName}
Quantity: {quantity}

Borrower: {borrowerName}
Email: {borrowerEmail}
Phone: {borrowerPhone}

Loan Date: {loanDate}
Expected Return Date: {expectedReturnDate}

Notes: {notes}

_________________________ | _________________________
Signature of Deliverer    | Signature of Receiver''




_________________________ | _________________________
Signature of Receiver     | Signature of Returner''';
  }

  // Initial load of data from the backend
  Future<void> _loadConfig() async {
    setState(() => _isInitialLoading = true);
    try {
      final service = context.read<VoucherService>();
      final config = await service.getVoucherConfig();

      if (config != null) {
        setState(() {
          if (config['template'] != null) {
            _templateController.text = config['template'];
          }
        });

        if (config['logoPath'] != null) {
          final bytes = await service.fetchImageBytes(config['logoPath']);
          if (bytes != null) {
            setState(() => _logoBytes = bytes);
          }
        }
      }
    } finally {
      setState(() => _isInitialLoading = false);
    }
  }

  // Pick image logic as you had it (using FilePicker)
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      final int sizeInBytes = result.files.first.size;
      final double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 1.0) {
        // Show error if file is larger than 1MB
        if (!mounted) return;
        ToastService.error(
          'El archivo es muy pesado (${sizeInMb.toStringAsFixed(2)} MB). El máximo es 1 MB.',
        );
        return;
      }

      setState(() {
        _logoBytes = result.files.first.bytes;
      });
    }
  }

  // Insert tags at the cursor position
  void _addFieldToTemplate(String tag) {
    final text = _templateController.text;
    final selection = _templateController.selection;
    final newText = text.replaceRange(selection.start, selection.end, tag);
    _templateController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + tag.length),
    );
  }

  // Save to the database
  Future<void> _saveTemplate() async {
    setState(() => _isLoading = true);
    try {
      await context.read<VoucherService>().saveVoucherTemplate(
        _templateController.text,
        _logoBytes,
      );
      ToastService.success(AppLocalizations.of(context)!.configurationSaved);
    } catch (e) {
      ToastService.error(AppLocalizations.of(context)!.errorSaving(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Generate the PDF for preview
  Future<Uint8List> _generatePreviewPdf() async {
    final doc = pw.Document();

    // Get localized strings using the Flutter BuildContext (not pw.Context)
    final l10n = AppLocalizations.of(context)!;
    final pdfTitle = l10n.deliveryVoucherTitle;

    // Format the ID as requested: V-000000
    final String voucherId = "V-${"124".padLeft(6, '0')}";

    String processedText = _templateController.text
        .replaceAll('{voucherId}', voucherId)
        .replaceAll('{itemName}', 'Example Item')
        .replaceAll('{quantity}', '1')
        .replaceAll('{borrowerName}', 'John Doe')
      .replaceAll('{borrowerEmail}', 'john.doe@example.com')
      .replaceAll('{borrowerPhone}', '+34 600 000 000')
        .replaceAll('{loanDate}', '10/01/2024');
    // Additional optional placeholders
    processedText = processedText
      .replaceAll('{expectedReturnDate}', '17/01/2024')
      .replaceAll('{notes}', 'Handle with care');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pwContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (_logoBytes != null)
                    pw.Image(pw.MemoryImage(_logoBytes!), width: 80)
                  else
                    pw.SizedBox(width: 80, height: 80),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        pdfTitle,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      pw.Text(
                        voucherId,
                        style: const pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(processedText, style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.configureDeliveryVoucher)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sección del Logo
            Card(
              child: ListTile(
                leading: _logoBytes != null
                    ? Image.memory(_logoBytes!, width: 50)
                    : const Icon(Icons.image),
                title: Text(AppLocalizations.of(context)!.logoVoucher),
                subtitle: Text(AppLocalizations.of(context)!.formatsPNG),
                trailing: ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(AppLocalizations.of(context)!.upload),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Chips de ayuda
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FieldChip(
                  label: '{voucherId}',
                  onTap: () => _addFieldToTemplate('{voucherId}'),
                ),
                _FieldChip(
                  label: '{itemName}',
                  onTap: () => _addFieldToTemplate('{itemName}'),
                ),
                _FieldChip(
                  label: '{quantity}',
                  onTap: () => _addFieldToTemplate('{quantity}'),
                ),
                _FieldChip(
                  label: '{borrowerName}',
                  onTap: () => _addFieldToTemplate('{borrowerName}'),
                ),
                _FieldChip(
                  label: '{borrowerEmail}',
                  onTap: () => _addFieldToTemplate('{borrowerEmail}'),
                ),
                _FieldChip(
                  label: '{borrowerPhone}',
                  onTap: () => _addFieldToTemplate('{borrowerPhone}'),
                ),
                _FieldChip(
                  label: '{expectedReturnDate}',
                  onTap: () => _addFieldToTemplate('{expectedReturnDate}'),
                ),
                _FieldChip(
                  label: '{notes}',
                  onTap: () => _addFieldToTemplate('{notes}'),
                ),
                _FieldChip(
                  label: '{loanDate}',
                  onTap: () => _addFieldToTemplate('{loanDate}'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Editor de texto
            TextField(
              controller: _templateController,
              maxLines: 15,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context)!.configureVoucherBody,
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(AppLocalizations.of(context)!.previewPDF),
                    onPressed: () async {
                      await Printing.layoutPdf(
                        onLayout: (format) async => await _generatePreviewPdf(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(AppLocalizations.of(context)!.saveConfiguration),
                    onPressed: _isLoading ? null : _saveTemplate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for the Chips (similar to yours)
class _FieldChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FieldChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
      onPressed: onTap,
    );
  }
}
