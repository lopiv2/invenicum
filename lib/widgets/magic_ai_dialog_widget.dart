import 'package:flutter/material.dart';

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
            'Asistente Mágico IA',
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
            const Text(
              'Pega el enlace del producto y la IA extraerá automáticamente la información para rellenar los campos.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _urlController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'URL del producto',
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
                  return 'Por favor, pega una URL';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasAbsolutePath) {
                  return 'Introduce una URL válida';
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
          child: const Text('Cancelar'),
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
          child: const Text('Empezar Magia'),
        ),
      ],
    );
  }
}