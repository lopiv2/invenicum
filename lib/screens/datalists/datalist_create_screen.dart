import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class DataListCreateScreen extends StatefulWidget {
  final String containerId;

  const DataListCreateScreen({super.key, required this.containerId});

  @override
  State<DataListCreateScreen> createState() => _DataListCreateScreenState();
}

class _DataListCreateScreenState extends State<DataListCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _items = [];
  final _newItemController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  void _addItem() {
    final item = _newItemController.text.trim();
    if (item.isNotEmpty) {
      setState(() {
        _items.add(item);
        _newItemController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _saveList() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ToastService.error(l10n.dataListNeedsAtLeastOneElement);
      return;
    }

    try {
      final provider = context.read<ContainerProvider>();
      // TODO: Implementar la lógica de guardado en el provider
      await provider.createDataList(
        containerId: int.parse(widget.containerId),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        items: _items,
      );

      if (!mounted) return;

      ToastService.success(l10n.customDataListCreated);
      context.goNamed(
        RouteNames.dataLists,
        pathParameters: {'containerId': widget.containerId},
      );
    } catch (e) {
      if (!mounted) return;
      ToastService.error(l10n.errorCreatingDataList(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TÍTULO ---
            Text(
              l10n.newCustomDataListTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // --- FORMULARIO ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.dataListNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterAName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Sección de elementos
                    Text(
                      l10n.dataListElementsTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Agregar nuevo elemento
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newItemController,
                            decoration: InputDecoration(
                              labelText: l10n.newElementLabel,
                              border: const OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) => _addItem(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addLabel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lista de elementos
                    if (_items.isEmpty)
                      Text(
                        l10n.addElementsToListHint,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    else
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_items[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeItem(index),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- BOTONES DE ACCIÓN ---
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.goNamed(
                    RouteNames.dataLists,
                    pathParameters: {'containerId': widget.containerId},
                  ),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _saveList,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.saveListLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
