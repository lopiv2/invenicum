// lib/screens/loan_create_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/data/models/loan.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/data/services/inventory_item_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LoanCreateScreen extends StatefulWidget {
  final String containerId;

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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expectedReturnDate = picked;
      });
    }
  }

  void _selectItem() async {
    final l10n = AppLocalizations.of(context)!;
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
          debugPrint('Error loading items for ${assetType.name}');
        }
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.selectObjectTitle),
            content: SizedBox(
              width: double.maxFinite,
              child: allItems.isEmpty
                  ? Center(child: Text(l10n.noObjectsAvailable))
                  : ListView.builder(
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        final item = allItems[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            l10n.availableQuantity(item.quantity),
                          ),
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
        ToastService.error(l10n.errorSelectingObject(e.toString()));
      }
    }
  }

  void _saveLoan() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_selectedItem == null) {
        ToastService.error(l10n.mustSelectAnObject);
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
        await loanProvider.createLoan(
          containerIdInt,
          loan,
          alertProvider: alertProvider,
        );

        if (mounted) {
          ToastService.success(l10n.loanRegisteredSuccessfully);

          context.goNamed(
            RouteNames.loans,
            pathParameters: {'containerId': widget.containerId.toString()},
          );
        }
      } catch (e) {
        if (mounted) {
          ToastService.error(l10n.errorRegisteringLoan(e.toString()));
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.registerNewLoan,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Text(
              l10n.loanObject,
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
                      _selectedItem?.name ?? l10n.selectAnObject,
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
                    child: Text(l10n.selectLabel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            TextFormField(
              controller: _borrowerNameController,
              decoration: InputDecoration(
                labelText: l10n.borrowerName,
                hintText: l10n.borrowerNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? l10n.borrowerNameRequired
                  : null,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: l10n.loanQuantityAvailable(_currentStock),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return l10n.enterQuantity;
                final n = int.tryParse(value);
                if (n == null || n <= 0) return l10n.invalidQuantity;
                if (n > _currentStock) return l10n.notEnoughStock;
                return null;
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _borrowerEmailController,
              decoration: InputDecoration(
                labelText: l10n.borrowerEmail,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return l10n.invalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _borrowerPhoneController,
              decoration: InputDecoration(
                labelText: l10n.borrowerPhone,
                border: const OutlineInputBorder(),
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
                          ? l10n.expectedReturnDateLabel(
                              _expectedReturnDate!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                            )
                          : l10n.selectReturnDate,
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
              decoration: InputDecoration(
                labelText: l10n.additionalNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saveLoan,
                  icon: const Icon(Icons.save),
                  label: Text(
                    l10n.registerLoanLabel,
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
                  label: Text(l10n.cancel, style: const TextStyle(fontSize: 16)),
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
