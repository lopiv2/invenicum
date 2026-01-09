// lib/screens/loan_create_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/models/loan.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/services/inventory_item_service.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';

class LoanCreateScreen extends StatefulWidget {
  final String containerId;
  final int? loanId;

  const LoanCreateScreen({super.key, required this.containerId, this.loanId});

  @override
  State<LoanCreateScreen> createState() => _LoanCreateScreenState();
}

class _LoanCreateScreenState extends State<LoanCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _borrowerNameController;
  late TextEditingController _borrowerEmailController;
  late TextEditingController _borrowerPhoneController;
  late TextEditingController _notesController;
  late TextEditingController _quantityController; // Añadir esto
  int _currentStock = 0; // Para validar que no presten más de lo que hay

  InventoryItem? _selectedItem;
  DateTime? _expectedReturnDate;
  Loan? _editingLoan;

  @override
  void initState() {
    super.initState();
    _borrowerNameController = TextEditingController();
    _borrowerEmailController = TextEditingController();
    _borrowerPhoneController = TextEditingController();
    _notesController = TextEditingController();
    _quantityController = TextEditingController(text: '1');

    if (widget.loanId != null) {
      _loadLoanForEditing();
    }
  }

  @override
  void didUpdateWidget(LoanCreateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el loanId cambió, recargar el préstamo
    if (oldWidget.loanId != widget.loanId && widget.loanId != null) {
      _loadLoanForEditing();
    }
  }

  void _loadLoanForEditing() {
    final loanProvider = context.read<LoanProvider>();
    final loan = loanProvider.loans.firstWhere(
      (l) => l.id == widget.loanId,
      orElse: () => Loan(
        id: 0,
        containerId: 0,
        inventoryItemId: 0,
        itemName: '',
        quantity: 1,
        borrowerName: '',
        borrowerEmail: '',
        borrowerPhone: '',
        loanDate: DateTime.now(),
        status: 'active',
      ),
    );

    if (loan.id != 0) {
      _editingLoan = loan;
      _borrowerNameController.text = loan.borrowerName ?? '';
      _borrowerEmailController.text = loan.borrowerEmail ?? '';
      _borrowerPhoneController.text = loan.borrowerPhone ?? '';
      _notesController.text = loan.notes ?? '';
      _quantityController.text = loan.quantity.toString();
      // Asegurar que siempre se carga la fecha del préstamo actual desde el provider
      _expectedReturnDate = loan.expectedReturnDate;

      // Cargar el item seleccionado
      final itemProvider = context.read<InventoryItemProvider>();
      _selectedItem = itemProvider.inventoryItems.firstWhere(
        (item) => item.id == loan.inventoryItemId,
        orElse: () => InventoryItem(
          id: 0,
          name: loan.itemName,
          assetTypeId: 0,
          locationId: 0,
          containerId: 0,
        ),
      );
    }
  }

  Future<void> _selectReturnDate() async {
    final initialDate =
        _expectedReturnDate ?? DateTime.now().add(Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expectedReturnDate = picked;
      });
    }
  }

  void _selectItem() async {
    final containerProvider = context.read<ContainerProvider>();
    final containerIdInt = int.parse(widget.containerId);

    try {
      // Obtener el contenedor
      final container = containerProvider.containers.firstWhere(
        (c) => c.id == containerIdInt,
        orElse: () => throw Exception('Container not found'),
      );

      // Obtener todos los items de todos los tipos de activo del contenedor
      final allItems = <InventoryItem>[];
      final apiService = context.read<ApiService>();
      final inventoryItemService = InventoryItemService(apiService);

      for (final assetType in container.assetTypes) {
        try {
          final response = await inventoryItemService.fetchInventoryItems(
            containerId: containerIdInt,
            assetTypeId: assetType.id,
          );
          allItems.addAll(response.items);
        } catch (e) {
          // Continuar con el siguiente tipo de activo si hay error
          if (mounted) {
            ToastService.error('Error cargando items de ${assetType.name}');
          }
        }
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Seleccionar Objeto'),
            content: SizedBox(
              width: double.maxFinite,
              child: allItems.isEmpty
                  ? const Center(child: Text('No hay objetos disponibles'))
                  : ListView.builder(
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        final item = allItems[index];
                        return ListTile(
                          title: Text(item.name),
                          onTap: () {
                            setState(() {
                              _selectedItem = item;
                            });
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al seleccionar objeto: ${e.toString()}');
      }
    }
  }

  void _saveLoan() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItem == null && _editingLoan == null) {
        ToastService.error('Debes seleccionar un objeto');
        return;
      }

      final containerIdInt = int.tryParse(widget.containerId);
      if (containerIdInt == null) return;

      final loanProvider = context.read<LoanProvider>();

      try {
        final loan = Loan(
          id: _editingLoan?.id ?? 0,
          quantity: int.tryParse(_quantityController.text) ?? 1,
          containerId: containerIdInt,
          inventoryItemId: _editingLoan?.inventoryItemId ?? _selectedItem!.id,
          itemName: _editingLoan?.itemName ?? _selectedItem!.name,
          borrowerName: _borrowerNameController.text,
          borrowerEmail: _borrowerEmailController.text,
          borrowerPhone: _borrowerPhoneController.text,
          loanDate: _editingLoan?.loanDate ?? DateTime.now(),
          expectedReturnDate: _expectedReturnDate,
          notes: _notesController.text,
          status: _editingLoan?.status ?? 'active',
        );

        if (_editingLoan != null) {
          await loanProvider.updateLoan(containerIdInt, loan);
          if (mounted) {
            ToastService.success('Préstamo actualizado exitosamente');
            // Recargar todos los préstamos para asegurar que tenemos la versión actual del servidor
            await loanProvider.fetchLoans(containerIdInt);
            // Después de recargar, actualizar el estado local con los datos frescos
            if (mounted) {
              setState(() {
                _loadLoanForEditing();
              });
              // Esperar un poco para que el setState se complete antes de navegar
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        } else {
          await loanProvider.createLoan(containerIdInt, loan);
          if (mounted) {
            ToastService.success('Préstamo creado exitosamente');
          }
        }

        if (mounted) {
          context.go('/container/${widget.containerId}/loans');
        }
      } catch (e) {
        if (mounted) {
          ToastService.error('Error al guardar préstamo: ${e.toString()}');
        }
      }
    }
  }

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _borrowerEmailController.dispose();
    _borrowerPhoneController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingLoan != null
                  ? 'Editar Préstamo'
                  : 'Registrar Nuevo Préstamo',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Seleccionar Objeto
            Text(
              'Objeto a Prestar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedItem?.name ?? 'Selecciona un objeto',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedItem != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _editingLoan == null ? _selectItem : null,
                    child: Text(
                      _editingLoan != null ? 'No editable' : 'Seleccionar',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Nombre del Prestatario
            TextFormField(
              controller: _borrowerNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Prestatario',
                hintText: 'Ej: Juan Pérez',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad a prestar (Disponible: $_currentStock)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Ingresa una cantidad';
                final n = int.tryParse(value);
                if (n == null || n <= 0) return 'Cantidad no válida';
                if (n > _currentStock) return 'No hay suficiente stock';
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Email
            TextFormField(
              controller: _borrowerEmailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                hintText: 'juan@example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Correo inválido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Teléfono
            TextFormField(
              controller: _borrowerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                hintText: '+34 123 456 789',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Fecha de Devolución Esperada
            GestureDetector(
              onTap: _selectReturnDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _expectedReturnDate != null
                          ? 'Devolución esperada: ${_expectedReturnDate!.toLocal().toString().split(' ')[0]}'
                          : 'Selecciona fecha de devolución',
                      style: TextStyle(
                        fontSize: 16,
                        color: _expectedReturnDate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas Adicionales',
                hintText: 'Ej: Producto en buen estado',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // Botones
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saveLoan,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _editingLoan != null ? 'Actualizar' : 'Registrar Préstamo',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
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
