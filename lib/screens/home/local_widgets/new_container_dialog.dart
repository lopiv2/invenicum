// lib/widgets/sidebar/new_container_dialog.dart

import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.newContainerDialog),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.descriptionField,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.isCollectionQuestion),
              value: _isCollection,
              onChanged: (val) => setState(() => _isCollection = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
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
          child: Text(l10n.createContainerButton),
        ),
      ],
    );
  }
}