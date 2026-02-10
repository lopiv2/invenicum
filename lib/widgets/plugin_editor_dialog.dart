import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/utils/common_functions.dart';
import 'package:invenicum/utils/constants.dart';
import 'package:stac/stac.dart';

class PluginEditorDialog extends StatefulWidget {
  final Map<String, dynamic>? plugin;

  const PluginEditorDialog({super.key, this.plugin});

  @override
  State<PluginEditorDialog> createState() => _PluginEditorDialogState();
}

class _PluginEditorDialogState extends State<PluginEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _uiController;
  String? _jsonError;
  late String _selectedSlot;

  void _validateJson(String value) {
    setState(() {
      try {
        jsonDecode(value);
        _jsonError = null; // JSON válido
      } catch (e) {
        // Extraemos solo el mensaje relevante del error de formato
        _jsonError = "Error de formato: ${e.toString().split(':').last}";
      }
    });
  }

  void _formatJson() {
    try {
      final object = jsonDecode(_uiController.text);
      final prettyString = const JsonEncoder.withIndent('  ').convert(object);
      setState(() {
        _uiController.text = prettyString;
        _jsonError = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se puede formatear un JSON inválido")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plugin?['name'] ?? '');

    // Usamos las constantes para el valor inicial
    final initialSlot = widget.plugin?['slot'] ?? AppSlots.dashboardTop;

    _selectedSlot = AppSlots.allSlots.contains(initialSlot)
        ? initialSlot
        : AppSlots.allSlots.first;

    final uiJson = widget.plugin?['ui'] != null
        ? const JsonEncoder.withIndent('  ').convert(widget.plugin!['ui'])
        : '{\n  "type": "container",\n  "child": {\n    "type": "text",\n    "data": "Nuevo Plugin"\n  }\n}';
    _uiController = TextEditingController(text: uiJson);
  }

  void _openPreview() {
    try {
      final jsonMap = jsonDecode(_uiController.text);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Vista Previa"),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child:
                  Stac.fromJson(jsonMap, ctx) ??
                  const Center(child: Text("Estructura Stac no reconocida")),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CERRAR"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error en el JSON")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.plugin == null ? "Crear Plugin" : "Editar Plugin"),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.orange),
            tooltip: "Documentación de Stac",
            onPressed: () => AppUtils.launchWebUrl(Environment.stacDocsUrl),
          ),
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: _openPreview,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSlot,
                decoration: const InputDecoration(
                  labelText: "Ubicación (Slot)",
                  border: OutlineInputBorder(),
                ),
                // Usamos la lista de la clase AppSlots
                items: AppSlots.allSlots.map((String slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Text(
                      AppSlots.getName(context, slot),
                    ), // Nombre amigable desde constantes
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSlot = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _uiController,
                maxLines: 10,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.blueGrey,
                ),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.format_indent_increase),
                    onPressed: _formatJson,
                    tooltip: "Formatear JSON",
                  ),
                  border: const OutlineInputBorder(),
                  labelText: "JSON Stac (Interfaz)",
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: _jsonError == null
                      ? Colors.grey[50]
                      : Colors.red[50],
                  // Mostramos el error en tiempo real aquí
                  errorText: _jsonError,
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                onChanged: _validateJson, // 💡 Validación en tiempo real
                validator: (v) {
                  try {
                    jsonDecode(v!);
                    return null;
                  } catch (e) {
                    return "Corrige el JSON antes de guardar";
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCELAR"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                if (widget.plugin != null) 'id': widget.plugin!['id'],
                'name': _nameController.text,
                'slot': _selectedSlot,
                'ui': jsonDecode(_uiController.text),
              });
            }
          },
          child: const Text("GUARDAR"),
        ),
      ],
    );
  }
}
