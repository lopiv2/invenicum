import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class MagicAiDialog extends StatefulWidget {
  const MagicAiDialog({super.key});

  @override
  State<MagicAiDialog> createState() => _MagicAiDialogState();
}

class _MagicAiDialogState extends State<MagicAiDialog> {
  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.magicAssistant,
            style: TextStyle(color: Colors.indigo.shade900),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.aiPasteUrlDescription,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _urlController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.productUrlLabel,
                hintText: 'https://www.amazon.es/...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleasePasteUrl;
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasAbsolutePath) {
                  return AppLocalizations.of(context)!.enterValidUrl;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Devolvemos la URL a la pantalla principal
              Navigator.pop(context, _urlController.text.trim());
            }
          },
          child: Text(AppLocalizations.of(context)!.startMagic),
        ),
      ],
    );
  }
}