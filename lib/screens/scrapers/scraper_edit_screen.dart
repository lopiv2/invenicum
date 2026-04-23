// lib/screens/scrapers/scraper_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/models/scraper.dart';
import 'dart:convert';

import 'package:invenicum/data/services/scraper_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/providers/scraper_provider.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class ScraperEditScreen extends StatefulWidget {
  final String containerId;
  final String scraperId;
  final Scraper initial;

  const ScraperEditScreen({
    super.key,
    required this.containerId,
    required this.scraperId,
    required this.initial,
  });

  @override
  State<ScraperEditScreen> createState() => _ScraperEditScreenState();
}

class _ScraperEditScreenState extends State<ScraperEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _patternController;
  final _fieldNameController = TextEditingController();
  final _fieldXpathController = TextEditingController();
  final List<Map<String, dynamic>> _fields = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial.name);
    _urlController = TextEditingController(text: widget.initial.url);
    _patternController = TextEditingController(
      text: widget.initial.urlPattern ?? '',
    );
    // initialize fields from widget.initial
    for (final f in widget.initial.fields) {
      _fields.add({
        'id': f.id,
        'name': f.name,
        'xpath': f.xpath,
        'order': f.order ?? _fields.length,
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _patternController.dispose();
    _fieldNameController.dispose();
    _fieldXpathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final provider = context.read<ScraperProvider>();
      await provider.updateScraper(
        containerId: int.parse(widget.containerId),
        scraperId: int.parse(widget.scraperId),
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        urlPattern: _patternController.text.trim().isEmpty
            ? null
            : _patternController.text.trim(),
        fields: _fields
            .map(
              (f) => {
                if (f.containsKey('id')) 'id': f['id'],
                'name': f['name'] ?? '',
                'xpath': f['xpath'] ?? '',
                'order': f['order'] ?? 0,
              },
            )
            .toList(),
      );
      if (!mounted) return;
      context.go('/container/${widget.containerId}/scrapers');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _addField() {
    final name = _fieldNameController.text.trim();
    final xpath = _fieldXpathController.text.trim();
    if (name.isEmpty || xpath.isEmpty) return;
    setState(() {
      _fields.add({'name': name, 'xpath': xpath, 'order': _fields.length});
      _fieldNameController.clear();
      _fieldXpathController.clear();
    });
  }

  void _editField(int index) async {
    final field = _fields[index];
    final nameController = TextEditingController(text: field['name']);
    final xpathController = TextEditingController(text: field['xpath']);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: xpathController,
                decoration: const InputDecoration(labelText: 'XPath'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      setState(() {
        _fields[index]['name'] = nameController.text.trim();
        _fields[index]['xpath'] = xpathController.text.trim();
      });
    }
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
      for (var i = 0; i < _fields.length; i++) {
        _fields[i]['order'] = i;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Scraper',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com/page',
                prefixIcon: const Icon(Icons.link_outlined),
              ),
              keyboardType: TextInputType.url,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _patternController,
              decoration: const InputDecoration(
                labelText: 'URL pattern (optional)',
                hintText: '/items/\\d+',
                prefixIcon: Icon(Icons.filter_alt_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text('Fields', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fieldNameController,
                    decoration: const InputDecoration(labelText: 'Field name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _fieldXpathController,
                    decoration: const InputDecoration(labelText: 'XPath'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_fields.isEmpty)
              const Text('No fields yet. Add one above.')
            else
              Flexible(
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _fields.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _fields.removeAt(oldIndex);
                      _fields.insert(newIndex, item);
                      for (var i = 0; i < _fields.length; i++)
                        _fields[i]['order'] = i;
                    });
                  },
                  itemBuilder: (context, index) {
                    final f = _fields[index];
                    final l10n = AppLocalizations.of(context)!;
                    return ListTile(
                      key: ValueKey('field_$index'),
                      title: Text(f['name'] ?? ''),
                      subtitle: Text(f['xpath'] ?? ''),
                      leading: const Icon(Icons.drag_indicator),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            tooltip: l10n.testScraper,
                            onPressed: () async {
                              // 1. Pedir URL de prueba
                              final testUrlController = TextEditingController();
                              final testUrl = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Test field'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Introduce una URL que coincida con el patrón del scraper para probar el campo "${f['name']}".',
                                        style: Theme.of(
                                          ctx,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 12),
                                      if (_patternController.text.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'Patrón: ${_patternController.text}',
                                            style: Theme.of(ctx)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    ctx,
                                                  ).colorScheme.outline,
                                                  fontFamily: 'monospace',
                                                ),
                                          ),
                                        ),
                                      TextField(
                                        controller: testUrlController,
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          labelText: 'URL a probar',
                                          hintText:
                                              'https://ejemplo.com/items/123',
                                          prefixIcon: Icon(Icons.link_outlined),
                                        ),
                                        keyboardType: TextInputType.url,
                                        onSubmitted: (_) => Navigator.of(
                                          ctx,
                                        ).pop(testUrlController.text.trim()),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(null),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(
                                        ctx,
                                      ).pop(testUrlController.text.trim()),
                                      child: const Text('Probar'),
                                    ),
                                  ],
                                ),
                              );

                              if (testUrl == null || testUrl.isEmpty) return;

                              // 2. Mostrar loading
                              BuildContext? loadingContext;
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) {
                                  loadingContext = ctx;
                                  return const AlertDialog(
                                    content: SizedBox(
                                      height: 80,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  );
                                },
                              );

                              // 3. Ejecutar test con la URL introducida
                              try {
                                final service = context.read<ScraperService>();
                                final result = await service.runAdHoc(
                                  name: _nameController.text,
                                  url:
                                      testUrl, // ← URL introducida por el usuario
                                  urlPattern: _patternController.text.isEmpty
                                      ? null
                                      : _patternController.text,
                                  fields: [
                                    // ← Solo el campo que se está probando
                                    {
                                      'name': f['name'],
                                      'xpath': f['xpath'],
                                      'order': f['order'],
                                    },
                                  ],
                                );
                                if (loadingContext != null &&
                                    Navigator.of(loadingContext!).canPop()) {
                                  Navigator.of(loadingContext!).pop();
                                }
                                final pretty = const JsonEncoder.withIndent(
                                  '  ',
                                ).convert(result);
                                if (!mounted) return;
                                await showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(l10n.runResultTitle),
                                    content: SingleChildScrollView(
                                      child: SelectableText(pretty),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: Text(l10n.ok),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                if (loadingContext != null &&
                                    Navigator.of(loadingContext!).canPop()) {
                                  Navigator.of(loadingContext!).pop();
                                }
                                if (!mounted) return;
                                ToastService.error(l10n.runError(e.toString()));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editField(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeField(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
