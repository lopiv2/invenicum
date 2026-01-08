// lib/screens/loans_screen.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:invenicum/models/loan.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';

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
        ToastService.error('Error al cargar préstamos: ${e.toString()}');
      }
    }
  }

  void _addLoan() {
    context.go('/container/${widget.containerId}/loans/new');
  }

  void _editLoan(int loanId) {
    context.go('/container/${widget.containerId}/loans/$loanId/edit');
  }

  Future<void> _returnLoan(Loan loan) async {
    final loanProvider = context.read<LoanProvider>();
    final containerIdInt = int.tryParse(widget.containerId);
    if (containerIdInt == null) return;

    try {
      await loanProvider.returnLoan(containerIdInt, loan.id);
      if (mounted) {
        ToastService.success('Objeto devuelto exitosamente');
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al devolver: ${e.toString()}');
      }
    }
  }

  void _deleteLoan(Loan loan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar este préstamo de "${loan.itemName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
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
                  ToastService.success('Préstamo eliminado exitosamente');
                }
              } catch (e) {
                if (mounted) {
                  ToastService.error('Error al eliminar: ${e.toString()}');
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();
    final isLoading = loanProvider.isLoading;
    final loans = _getFilteredLoans(loanProvider.loans);

    if (isLoading && loanProvider.loans.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Préstamos'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadLoans,
            tooltip: 'Recargar Préstamos',
          ),
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: _addLoan,
            tooltip: 'Nuevo Préstamo',
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
                const Text(
                  'Filtrar: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Activos', 'active'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Devueltos', 'returned'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Vencidos', 'overdue'),
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
                          ? 'No hay préstamos registrados'
                          : 'No hay préstamos con este estado',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      child: DataTable2(
                        columnSpacing: 16,
                        horizontalMargin: 0,
                        minWidth: 800,
                        columns: const [
                          DataColumn(label: Text('Objeto')),
                          DataColumn(label: Text('Prestatario')),
                          DataColumn(label: Text('Contacto')),
                          DataColumn(label: Text('Fecha Préstamo')),
                          DataColumn(label: Text('Fecha Devolución')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
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
                              return Colors.white;
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
                                  loan.actualReturnDate != null
                                      ? DateFormat.yMd(
                                          Localizations.localeOf(
                                            context,
                                          ).toString(),
                                        ).format(loan.actualReturnDate!)
                                      : '-',
                                ),
                              ),
                              DataCell(
                                Chip(
                                  label: Text(
                                    loan.isOverdue && loan.status == 'active'
                                        ? 'Vencido'
                                        : loan.status == 'active'
                                        ? 'Activo'
                                        : 'Devuelto',
                                  ),
                                  backgroundColor:
                                      loan.isOverdue && loan.status == 'active'
                                      ? Colors.red
                                      : loan.status == 'active'
                                      ? Colors.orange
                                      : Colors.green,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    if (loan.status == 'active')
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => _returnLoan(loan),
                                        tooltip: 'Marcar como devuelto',
                                      )
                                    else
                                      const SizedBox(width: 48),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _editLoan(loan.id),
                                      tooltip: 'Editar',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteLoan(loan),
                                      tooltip: 'Eliminar',
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
