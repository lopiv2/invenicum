import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/screens/datalists/local_widgets/draggable_drag_icon.dart';
import 'package:invenicum/screens/datalists/local_widgets/sort_buttons.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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

  void _moveItem(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
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
            // --- TÍTULO Y BOTONES ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.newCustomDataListTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton.icon(
                      onPressed: _saveList,
                      icon: const Icon(Icons.save),
                      label: Text(l10n.saveListLabel),
                    ),
                    SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () => context.goNamed(
                        RouteNames.dataLists,
                        pathParameters: {'containerId': widget.containerId},
                      ),
                      icon: const Icon(Icons.cancel),
                      label: Text(l10n.cancel),
                    ),
                  ],
                ),
              ],
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
                    SortButtons(
                      items: _items,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    // Elements list
                    if (_items.isEmpty)
                      Text(
                        l10n.addElementsToListHint,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    else
                      Card(
                        child: ReorderableListView(
                          buildDefaultDragHandles: false,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: _moveItem,
                          children: _items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return ListTile(
                              key: ValueKey('$item-$index'),
                              leading: DraggableDragIcon(
                                index: index,
                              ),
                              title: TextFormField(
                                initialValue: item,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  _items[index] = value;
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeItem(index),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

