// lib/screens/loan_create_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/models/loan.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/services/inventory_item_service.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';

class LoanCreateScreen extends StatefulWidget {
  final String containerId;

  // Ya no recibimos loanId porque esta pantalla es solo para creación
  const LoanCreateScreen({super.key, required this.containerId});

  @override
  State<LoanCreateScreen> createState() => _LoanCreateScreenState();
}

class _LoanCreateScreenState extends State<LoanCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _borrowerNameController;
  late TextEditingController _borrowerEmailController;
  late TextEditingController _borrowerPhoneController;
  late TextEditingController _notesController;
  late TextEditingController _quantityController;

  int _currentStock = 0;
  InventoryItem? _selectedItem;
  DateTime? _expectedReturnDate;

  @override
  void initState() {
    super.initState();
    _borrowerNameController = TextEditingController();
    _borrowerEmailController = TextEditingController();
    _borrowerPhoneController = TextEditingController();
    _notesController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
  }

  Future<void> _selectReturnDate() async {
    final initialDate =
        _expectedReturnDate ?? DateTime.now().add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(), // No tiene sentido prestar hacia el pasado
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      final container = containerProvider.containers.firstWhere(
        (c) => c.id == containerIdInt,
        orElse: () => throw Exception('Contenedor no encontrado'),
      );

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
          debugPrint('Error cargando items de ${assetType.name}');
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
                          subtitle: Text('Disponible: ${item.quantity}'),
                          onTap: () {
                            setState(() {
                              _selectedItem = item;
                              _currentStock = item.quantity;
                              _quantityController.text = _currentStock > 0
                                  ? '1'
                                  : '0';
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
      if (_selectedItem == null) {
        ToastService.error('Debes seleccionar un objeto');
        return;
      }

      final containerIdInt = int.tryParse(widget.containerId);
      if (containerIdInt == null) return;

      final loanProvider = context.read<LoanProvider>();
      final authProvider = context.read<AuthProvider>();
      final int userId = authProvider.user?.id ?? 0;

      try {
        final loan = Loan(
          id: 0,
          quantity: int.tryParse(_quantityController.text) ?? 1,
          containerId: containerIdInt,
          inventoryItemId: _selectedItem!.id,
          itemName: _selectedItem!.name,
          borrowerName: _borrowerNameController.text,
          borrowerEmail: _borrowerEmailController.text,
          borrowerPhone: _borrowerPhoneController.text,
          loanDate: DateTime.now(),
          expectedReturnDate: _expectedReturnDate,
          notes: _notesController.text,
          status: 'active',
          userId: userId,
        );
        final alertProvider = Provider.of<AlertProvider>(
          context,
          listen: false,
        );
        // 1. Registramos el préstamo (el backend descuenta stock)
        await loanProvider.createLoan(
          containerIdInt,
          loan,
          alertProvider: alertProvider,
        );

        if (mounted) {
          ToastService.success('Préstamo registrado exitosamente');

          context.go('/container/${widget.containerId}/loans');
        }
      } catch (e) {
        if (mounted) {
          ToastService.error('Error al registrar préstamo: ${e.toString()}');
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
              'Registrar Nuevo Préstamo',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

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
                    onPressed: _selectItem,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            TextFormField(
              controller: _borrowerNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Prestatario',
                hintText: 'Ej: Juan Pérez',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
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

            TextFormField(
              controller: _borrowerEmailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _borrowerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

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

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas Adicionales',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saveLoan,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Registrar Préstamo',
                    style: TextStyle(fontSize: 16),
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
