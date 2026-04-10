// lib/screens/loans_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/l10n/app_localizations.dart'; // Asegúrate de que la ruta sea correcta
import 'package:invenicum/data/models/loan.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/data/services/voucher_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pluto_grid/pluto_grid.dart';
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
      // 🚀 Ahora el provider maneja la carga limpia
      await loanProvider.fetchLoans(containerIdInt);
      // Opcional: cargar estadísticas para resúmenes visuales
      await loanProvider.fetchStats(containerIdInt);
    } catch (e) {
      if (mounted) {
        ToastService.error('${context.l10n.errorLoadingData}: $e');
      }
    }
  }

  void _addLoan() {
    context.goNamed(
      RouteNames.loanCreate,
      pathParameters: {'containerId': widget.containerId.toString()},
    );
  }

  Future<void> _returnLoan(Loan loan) async {
    final loanProvider = context.read<LoanProvider>();
    final containerIdInt = int.tryParse(widget.containerId);
    if (containerIdInt == null) return;

    try {
      // 💡 El backend ahora se encarga de sumar el stock, el front solo espera el nuevo estado
      await loanProvider.returnLoan(containerIdInt, loan.id);
      if (mounted) {
        ToastService.success(context.l10n.configurationSaved);
      }
    } catch (e) {
      if (mounted) ToastService.error(e.toString());
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
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  List<Loan> _getFilteredLoans(LoanProvider provider) {
    switch (_filterStatus) {
      case 'active':
        return provider.activeLoans;
      case 'returned':
        return provider.returnedLoans;
      case 'overdue':
        return provider.overdueLoans; // 🚩 Usa .isOverdue del servidor
      default:
        return provider.loans;
    }
  }

  Future<void> _generateVoucher(Loan loan) async {
    final l10n = AppLocalizations.of(context)!;
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
                          l10n.deliveryVoucher,
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
    // 💡 Obtenemos la lista filtrada de forma eficiente
    final loans = _getFilteredLoans(loanProvider);
    final theme = Theme.of(context);

    if (isLoading && loanProvider.loans.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
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
            tooltip:
                l10n.reloadLoans, // Reutilizando recargar o crear una nueva
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
          if (loanProvider.currentStats != null)
            _buildQuickStats(loanProvider.currentStats!, l10n),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '${l10n.apply}: ',
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
          Expanded(
            child: loans.isEmpty
                ? Center(
                    child: Text(
                      l10n.noLoansFound,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: PlutoGrid(
                          columns: _buildPlutoColumns(l10n),
                          rows: _buildPlutoRows(loans),
                          rowColorCallback: (rowColorContext) {
                            final loan =
                                rowColorContext.row.cells['loan_object']!.value
                                    as Loan;
                            if (loan.status == 'returned') {
                              return Colors.green.shade50;
                            }
                            if (loan.isOverdue) {
                              return Colors.red.shade50;
                            }
                            return Colors.transparent;
                          },
                          configuration: PlutoGridConfiguration(
                            style: PlutoGridStyleConfig(
                              rowHeight: 80,
                              cellTextStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                          onLoaded: (event) {
                            event.stateManager.setShowColumnFilter(true);
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<PlutoColumn> _buildPlutoColumns(AppLocalizations l10n) {
    return [
      PlutoColumn(
        title: 'loan_object',
        field: 'loan_object',
        type: PlutoColumnType.text(),
        hide: true,
        enableFilterMenuItem: false,
        enableSorting: false,
      ),
      PlutoColumn(
        title: l10n.loanObject,
        field: 'itemName',
        type: PlutoColumnType.text(),
        width: 180,
      ),
      PlutoColumn(
        title: l10n.borrowerName,
        field: 'borrowerName',
        type: PlutoColumnType.text(),
        width: 170,
      ),
      PlutoColumn(
        title: l10n.alertInfo,
        field: 'contact',
        type: PlutoColumnType.text(),
        width: 210,
      ),
      PlutoColumn(
        title: l10n.quantity,
        field: 'quantity',
        type: PlutoColumnType.number(),
        width: 90,
      ),
      PlutoColumn(
        title: l10n.loanDate,
        field: 'loanDate',
        type: PlutoColumnType.text(),
        width: 120,
      ),
      PlutoColumn(
        title: l10n.dueDate,
        field: 'dueDate',
        type: PlutoColumnType.text(),
        width: 120,
      ),
      PlutoColumn(
        title: l10n.status,
        field: 'status',
        type: PlutoColumnType.text(),
        width: 130,
        renderer: (ctx) {
          final loan = ctx.row.cells['loan_object']!.value as Loan;
          return Center(child: _buildStatusBadge(loan, l10n));
        },
      ),
      PlutoColumn(
        title: l10n.apply,
        field: 'actions',
        type: PlutoColumnType.text(),
        width: 150,
        enableSorting: false,
        enableFilterMenuItem: false,
        renderer: (ctx) {
          final loan = ctx.row.cells['loan_object']!.value as Loan;
          return Center(child: _buildActions(loan, l10n));
        },
      ),
    ];
  }

  List<PlutoRow> _buildPlutoRows(List<Loan> loans) {
    return loans.map((loan) {
      final String contact = loan.borrowerEmail ?? loan.borrowerPhone ?? '-';
      final String dueDateText = loan.expectedReturnDate != null
          ? DateFormat.yMd().format(loan.expectedReturnDate!)
          : '-';

      return PlutoRow(
        cells: {
          'loan_object': PlutoCell(value: loan),
          'itemName': PlutoCell(value: loan.itemName),
          'borrowerName': PlutoCell(value: loan.borrowerName ?? '-'),
          'contact': PlutoCell(value: contact),
          'quantity': PlutoCell(value: loan.quantity),
          'loanDate': PlutoCell(value: DateFormat.yMd().format(loan.loanDate)),
          'dueDate': PlutoCell(value: dueDateText),
          'status': PlutoCell(value: loan.status),
          'actions': PlutoCell(value: ''),
        },
      );
    }).toList();
  }

  Widget _buildStatusBadge(Loan loan, AppLocalizations l10n) {
    String label = l10n.active;
    Color color = Colors.orange;

    if (loan.status == 'returned') {
      label = l10n.returned;
      color = Colors.green;
    } else if (loan.isOverdue) {
      label = l10n.overdue;
      color = Colors.red;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActions(Loan loan, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loan.status == 'active')
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => _returnLoan(loan),
            tooltip: l10n.returned,
          ),
        IconButton(
          icon: const Icon(Icons.print, color: Colors.teal),
          onPressed: () => _generateVoucher(loan),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteLoan(loan),
        ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(l10n.totalLabel, stats['totalLoans']),
          _statItem(l10n.actives, stats['activeLoans'], color: Colors.orange),
          _statItem(l10n.overdue, stats['overdueLoans'], color: Colors.red),
        ],
      ),
    );
  }

  Widget _statItem(String label, dynamic value, {Color? color}) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
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
