import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Solo el contenido del formulario, sin AlertDialog wrapper.
/// El wrapper (AlertDialog o CGADialog) lo provee showAppDialog.
/// Los botones cancel/submit están aquí porque son los únicos
/// que tienen acceso directo al estado interno (_nameController, etc.).
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
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.pop(context);

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'isCollection': _isCollection,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Campos ──────────────────────────────────────────────────────────
        TextField(
          controller: _nameController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.name,
            prefixIcon: const Icon(Icons.label_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descController,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
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

        // ── Botones ─────────────────────────────────────────────────────────
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _cancel,
              child: Text(l10n.cancel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.createContainerButton),
            ),
          ],
        ),
      ],
    );
  }
}