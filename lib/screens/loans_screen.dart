// lib/screens/loans_screen.dart

import 'dart:typed_data';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:invenicum/l10n/app_localizations.dart'; // Asegúrate de que la ruta sea correcta
import 'package:invenicum/models/loan.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/services/voucher_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

// Extensión útil para acceder rápido a las traducciones
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

class LoansScreen extends StatefulWidget {
  final String containerId;

  const LoansScreen({super.key, required this.containerId});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  String _filterStatus = 'all'; // all, active, returned, overdue

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadLoans());
  }

  @override
  void didUpdateWidget(LoansScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.containerId != widget.containerId) {
      _loadLoans();
    }
  }

  Future<void> _loadLoans() async {
    final containerIdInt = int.tryParse(widget.containerId);
    if (containerIdInt == null) return;

    final loanProvider = context.read<LoanProvider>();
    try {
      await loanProvider.fetchLoans(containerIdInt);
    } catch (e) {
      if (mounted) {
        // Usando clave de error genérica o específica si existiera
        ToastService.error('${context.l10n.errorLoadingData}: ${e.toString()}');
      }
    }
  }

  void _addLoan() {
    context.go('/container/${widget.containerId}/loans/new');
  }

  Future<void> _returnLoan(Loan loan) async {
    final loanProvider = context.read<LoanProvider>();
    final containerIdInt = int.tryParse(widget.containerId);
    if (containerIdInt == null) return;

    try {
      await loanProvider.returnLoan(containerIdInt, loan.id);
      if (mounted) {
        ToastService.success(context.l10n.configurationSaved); // O una clave específica de éxito
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(e.toString());
      }
    }
  }

  void _deleteLoan(Loan loan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.confirmDeletion),
        content: Text(
          '${context.l10n.confirmDeleteAlertMessage} (${loan.itemName})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final loanProvider = context.read<LoanProvider>();
              final containerIdInt = int.tryParse(widget.containerId);
              if (containerIdInt == null) return;

              try {
                await loanProvider.deleteLoan(containerIdInt, loan.id);
                if (mounted) {
                  ToastService.success(context.l10n.alertDeleted);
                }
              } catch (e) {
                if (mounted) {
                  ToastService.error(e.toString());
                }
              }
            },
            child: Text(context.l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Loan> _getFilteredLoans(List<Loan> loans) {
    switch (_filterStatus) {
      case 'active':
        return loans.where((l) => l.status == 'active').toList();
      case 'returned':
        return loans.where((l) => l.status == 'returned').toList();
      case 'overdue':
        return loans.where((l) => l.isOverdue).toList();
      default:
        return loans;
    }
  }

  Future<void> _generateVoucher(Loan loan) async {
    try {
      final voucherService = context.read<VoucherService>();
      final config = await voucherService.getVoucherConfig();

      if (config == null) {
        ToastService.error(context.l10n.errorNoVoucherTemplate);
        return;
      }

      final String template = config['template'] ?? "";
      final String? logoPath = config['logoPath'];
      Uint8List? logoBytes;

      if (logoPath != null) {
        logoBytes = await voucherService.fetchImageBytes(logoPath);
      }

      final String voucherIdStr = loan.formattedVoucherId;

      // Mapeo de datos usando las claves del template
      final String processedContent = template
          .replaceAll('{voucherId}', voucherIdStr)
          .replaceAll('{itemName}', loan.itemName)
          .replaceAll('{quantity}', loan.quantity.toString())
          .replaceAll('{borrowerName}', loan.borrowerName ?? 'N/A')
          .replaceAll('{borrowerEmail}', loan.borrowerEmail ?? 'N/A')
          .replaceAll('{borrowerPhone}', loan.borrowerPhone ?? 'N/A')
          .replaceAll(
            '{loanDate}',
            DateFormat('dd/MM/yyyy').format(loan.loanDate),
          )
          .replaceAll(
            '{expectedReturnDate}',
            loan.expectedReturnDate != null
                ? DateFormat('dd/MM/yyyy').format(loan.expectedReturnDate!)
                : 'N/A',
          )
          .replaceAll('{notes}', loan.notes ?? '');

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logoBytes != null)
                      pw.Image(pw.MemoryImage(logoBytes), width: 80),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'DELIVERY VOUCHER', // O usar una traducción específica para el PDF
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        pw.Text(
                          voucherIdStr,
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 20),
                pw.Text(
                  processedContent,
                  style: const pw.TextStyle(fontSize: 12, height: 1.5),
                ),
                pw.Spacer(),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) => doc.save(),
        name: 'Vale_${voucherIdStr}.pdf',
      );
    } catch (e) {
      ToastService.error("${context.l10n.errorGeneratingPDF}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loanProvider = context.watch<LoanProvider>();
    final isLoading = loanProvider.isLoading;
    final loans = _getFilteredLoans(loanProvider.loans);
    final theme = Theme.of(context);

    if (isLoading && loanProvider.loans.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.loanManagement),
        backgroundColor: theme.colorScheme.surfaceContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadLoans,
            tooltip: l10n.reloadLocations, // Reutilizando recargar o crear una nueva
          ),
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: _addLoan,
            tooltip: l10n.registerNewLoan,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '${l10n.apply}: ', // O una etiqueta "Filtrar"
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(l10n.all, 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip(l10n.active, 'active'),
                        const SizedBox(width: 8),
                        _buildFilterChip(l10n.returned, 'returned'),
                        const SizedBox(width: 8),
                        _buildFilterChip(l10n.overdue, 'overdue'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabla de préstamos
          Expanded(
            child: loans.isEmpty
                ? Center(
                    child: Text(
                      _filterStatus == 'all'
                          ? l10n.noLoansFound
                          : l10n.noLoansFound, // Podrías personalizar según filtro si quieres
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      child: DataTable2(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        minWidth: 800,
                        columns: [
                          DataColumn(label: Text(l10n.loanObject)),
                          DataColumn(label: Text(l10n.borrowerName)),
                          DataColumn(label: Text(l10n.alertInfo)), // "Contacto" o info
                          DataColumn(label: Text(l10n.loanDate)),
                          DataColumn(label: Text(l10n.dueDate)),
                          DataColumn(label: Text(l10n.status)),
                          DataColumn(
                            label: Text(l10n.apply), // "Acciones"
                            headingRowAlignment: MainAxisAlignment.center,
                          ),
                        ],
                        rows: loans.map((loan) {
                          return DataRow(
                            color: WidgetStateProperty.resolveWith((states) {
                              if (loan.isOverdue && loan.status == 'active') {
                                return Colors.red.shade50;
                              }
                              if (loan.status == 'returned') {
                                return Colors.green.shade50;
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(Text(loan.itemName)),
                              DataCell(Text(loan.borrowerName ?? '-')),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (loan.borrowerEmail != null)
                                      Text(
                                        loan.borrowerEmail!,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    if (loan.borrowerPhone != null)
                                      Text(
                                        loan.borrowerPhone!,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat.yMd(
                                    Localizations.localeOf(context).toString(),
                                  ).format(loan.loanDate),
                                ),
                              ),
                              DataCell(
                                Text(
                                  loan.expectedReturnDate != null
                                      ? DateFormat.yMd(
                                          Localizations.localeOf(context).toString(),
                                        ).format(loan.expectedReturnDate!)
                                      : '-',
                                ),
                              ),
                              DataCell(
                                Chip(
                                  label: Text(
                                    loan.isOverdue && loan.status == 'active'
                                        ? l10n.overdue
                                        : loan.status == 'active'
                                            ? l10n.active
                                            : l10n.returned,
                                  ),
                                  backgroundColor:
                                      loan.isOverdue && loan.status == 'active'
                                          ? Colors.red
                                          : loan.status == 'active'
                                              ? Colors.orange
                                              : Colors.green,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (loan.status == 'active')
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        onPressed: () => _returnLoan(loan),
                                        tooltip: l10n.returned,
                                      )
                                    else
                                      const SizedBox(width: 48),
                                    IconButton(
                                      icon: const Icon(Icons.print, color: Colors.teal),
                                      onPressed: () => _generateVoucher(loan),
                                      tooltip: l10n.generateVoucher,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteLoan(loan),
                                      tooltip: l10n.delete,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filterStatus == value,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
    );
  }
}