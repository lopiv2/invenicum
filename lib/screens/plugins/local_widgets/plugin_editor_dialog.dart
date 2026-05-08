import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
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

  void _close([dynamic result]) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(result);
  }

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

      showAppDialog(
        context: context,

        title: AppLocalizations.of(context)!.previewLabel,

        body: Container(
          constraints: const BoxConstraints(maxWidth: 400),

          width: MediaQuery.of(context).size.width * 0.8,

          child: SingleChildScrollView(
            child:
                Stac.fromJson(jsonMap, context) ??
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.unrecognizedStacStructure,
                  ),
                ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => _close(),

            child: Text(AppLocalizations.of(context)!.closeLabelUpper),
          ),
        ],
      );
    } catch (e) {
      ToastService.error(AppLocalizations.of(context)!.jsonErrorGeneric);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ───────────────── HEADER ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.plugin == null
                        ? l10n.createPluginTitle
                        : l10n.editPluginTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.orange),
                  tooltip: l10n.stacDocumentation,
                  onPressed: () =>
                      AppUtils.launchUrlWeb(Environment.stacDocsUrl),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  onPressed: _openPreview,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ───────────────── NAME ─────────────────
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.name),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),

            const SizedBox(height: 16),

            // ───────────────── VERSION ─────────────────
            TextFormField(
              controller: _versionController,
              enabled: widget.plugin != null,
              decoration: InputDecoration(
                labelText: l10n.versionLabel,
                helperText: widget.plugin == null
                    ? l10n.firstVersionHint
                    : l10n.incrementVersionHint,
                prefixIcon: const Icon(Icons.numbers),
                filled: widget.plugin == null,
                fillColor: widget.plugin == null ? Colors.grey[200] : null,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.requiredField;
                final RegExp versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
                if (!versionRegex.hasMatch(v)) {
                  return l10n.invalidVersionFormat;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ───────────────── PUBLIC SWITCH ─────────────────
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
              onChanged: (value) async {
                if (value == true) {
                  final authProvider = context.read<AuthProvider>();

                  if (!authProvider.isGitHubLinked) {
                    final goToProfile = await showAppDialog<bool>(
                      context: context,
                      title: l10n.requiresGithubTitle,
                      body: Text(l10n.requiresGithubDescription),
                      actions: [
                        TextButton(
                          onPressed: () => _close(false),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () => _close(true),
                          child: Text(l10n.goToProfileUpper),
                        ),
                      ],
                    );

                    if (goToProfile == true && mounted) {
                      Navigator.pop(context);
                      context.pushNamed(RouteNames.myProfile);
                    }
                    return;
                  }
                }

                setState(() => _isPublic = value);
              },
            ),

            const SizedBox(height: 16),

            // ───────────────── SLOT ─────────────────
            DropdownButtonFormField<String>(
              value: _selectedSlot,
              decoration: InputDecoration(
                labelText: l10n.slotLocationLabel,
                border: const OutlineInputBorder(),
              ),
              items: AppSlots.allSlots.map((slot) {
                return DropdownMenuItem(
                  value: slot,
                  child: Text(AppSlots.getName(context, slot)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSlot = value!);
              },
            ),

            const SizedBox(height: 16),

            // ───────────────── JSON ─────────────────
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
                ),
                border: const OutlineInputBorder(),
                labelText: l10n.stacJsonInterfaceLabel,
                filled: true,
                fillColor: _jsonError == null
                    ? Colors.grey[50]
                    : Colors.red[50],
                errorText: _jsonError,
              ),
              onChanged: _validateJson,
              validator: (v) {
                try {
                  jsonDecode(v!);
                  return null;
                } catch (_) {
                  return l10n.fixJsonBeforeSave;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
