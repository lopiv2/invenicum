import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:stac/stac.dart';
import 'package:invenicum/l10n/app_localizations.dart';

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
  late TextEditingController _versionController;
  late bool _isPublic;
  String? _jsonError;
  late String _selectedSlot;

  void _validateJson(String value) {
    setState(() {
      try {
        jsonDecode(value);
        _jsonError = null; // JSON válido
      } catch (e) {
        // Extraemos solo el mensaje relevante del error de formato
        _jsonError = "Format error: ${e.toString().split(':').last}";
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotFormatInvalidJson),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plugin?['name'] ?? '');
    _isPublic = widget.plugin?['isPublic'] ?? false;

    String initialVersion = widget.plugin?['version']?.toString() ?? '1.0.0';
    _versionController = TextEditingController(text: initialVersion);

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
          title: Text(AppLocalizations.of(context)!.previewLabel),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child:
                  Stac.fromJson(jsonMap, ctx) ??
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.unrecognizedStacStructure,
                    ),
                  ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.closeLabelUpper),
            ),
          ],
        ),
      );
    } catch (e) {
      ToastService.error(AppLocalizations.of(context)!.jsonErrorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.plugin == null ? l10n.createPluginTitle : l10n.editPluginTitle),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.orange),
            tooltip: l10n.stacDocumentation,
            onPressed: () => AppUtils.launchUrlWeb(Environment.stacDocsUrl),
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
                decoration: InputDecoration(labelText: l10n.name),
                validator: (v) => v!.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versionController,
                enabled:
                    widget.plugin != null, // 💡 Solo editable en modo EDICIÓN
                decoration: InputDecoration(
                  labelText: l10n.versionLabel,
                  helperText: widget.plugin == null
                      ? l10n.firstVersionHint
                      : l10n.incrementVersionHint,
                  prefixIcon: const Icon(Icons.numbers),
                  // Si está deshabilitado, le damos un aspecto visual distinto
                  filled: widget.plugin == null,
                  fillColor: widget.plugin == null ? Colors.grey[200] : null,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.requiredField;
                  // Validación básica de formato SemVer (x.x.x)
                  final RegExp versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
                  if (!versionRegex.hasMatch(v))
                    return l10n.invalidVersionFormat;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.makePublicLabel),
                subtitle: Text(
                  _isPublic
                      ? l10n.pluginPublicDescription
                      : l10n.pluginPrivateDescription,
                ),
                value: _isPublic,
                activeThumbColor: Colors.blue,
                secondary: Icon(
                  _isPublic ? Icons.public : Icons.public_off,
                  color: _isPublic ? Colors.blue : Colors.grey,
                ),
                onChanged: (bool value) async {
                  // Si intenta marcarlo como público
                  if (value == true) {
                    final authProvider = context.read<AuthProvider>();

                    // Usamos el getter que creamos antes
                    if (!authProvider.isGitHubLinked) {
                      // 1. Informamos al usuario por qué no puede
                      bool? goToProfile = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.requiresGithubTitle),
                          content: Text(
                            l10n.requiresGithubDescription,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.goToProfileUpper),
                            ),
                          ],
                        ),
                      );

                      // 2. Si aceptó ir al perfil, navegamos
                      if (goToProfile == true) {
                        if (mounted) {
                          Navigator.pop(
                            context,
                          ); // Cerramos el editor de plugin
                          context.pushNamed(RouteNames.myProfile);
                        }
                      }
                      return; // Detenemos el cambio del switch
                    }
                  }

                  // Si ya estaba conectado o está desactivando el público, procedemos normal
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSlot,
                decoration: InputDecoration(
                  labelText: l10n.slotLocationLabel,
                  border: const OutlineInputBorder(),
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
                    tooltip: l10n.formatJson,
                  ),
                  border: const OutlineInputBorder(),
                  labelText: l10n.stacJsonInterfaceLabel,
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
                    return l10n.fixJsonBeforeSave;
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
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                if (widget.plugin != null) 'id': widget.plugin!['id'],
                'name': _nameController.text,
                'slot': _selectedSlot,
                'isPublic': _isPublic,
                'version': _versionController.text,
                'ui': jsonDecode(_uiController.text),
              });
            }
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
