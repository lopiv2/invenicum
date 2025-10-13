import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/services/toast_service.dart';

class DataListCreateScreen extends StatefulWidget {
  final String containerId;

  const DataListCreateScreen({
    super.key,
    required this.containerId,
  });

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
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ToastService.error('La lista debe tener al menos un elemento');
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

      ToastService.success('Lista personalizada creada con éxito');
      context.go('/container/${widget.containerId}/datalists');
    } catch (e) {
      if (!mounted) return;
      ToastService.error('Error al crear la lista: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TÍTULO ---
            Text(
              'Nueva Lista Personalizada',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
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
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Lista',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor introduce un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Sección de elementos
                    const Text(
                      'Elementos de la Lista',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Agregar nuevo elemento
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newItemController,
                            decoration: const InputDecoration(
                              labelText: 'Nuevo Elemento',
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) => _addItem(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lista de elementos
                    if (_items.isEmpty)
                      const Text(
                        'Agrega elementos a la lista',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    else
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
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
                  onPressed: () => context
                      .go('/container/${widget.containerId}/datalists'),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _saveList,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Lista'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}