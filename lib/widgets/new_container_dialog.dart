// lib/widgets/sidebar/new_container_dialog.dart

import 'package:flutter/material.dart';

class NewContainerDialog extends StatefulWidget {
  const NewContainerDialog({super.key});

  @override
  State<NewContainerDialog> createState() => _NewContainerDialogState();
}

class _NewContainerDialogState extends State<NewContainerDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isCollection = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Nuevo Contenedor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            SwitchListTile(
              title: const Text('¿Es una colección?'),
              value: _isCollection,
              onChanged: (val) => setState(() => _isCollection = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'description': _descController.text.trim(),
                'isCollection': _isCollection,
              });
            }
          },
          child: const Text('Crear Contenedor'),
        ),
      ],
    );
  }
}