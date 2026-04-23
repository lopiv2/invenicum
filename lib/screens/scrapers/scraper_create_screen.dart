// lib/screens/scrapers/scraper_create_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:invenicum/data/services/scraper_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/providers/scraper_provider.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class ScraperCreateScreen extends StatefulWidget {
  final String containerId;
  const ScraperCreateScreen({super.key, required this.containerId});

  @override
  State<ScraperCreateScreen> createState() => _ScraperCreateScreenState();
}

class _ScraperCreateScreenState extends State<ScraperCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _patternController = TextEditingController();
  final _fieldNameController = TextEditingController();
  final _fieldXpathController = TextEditingController();

  final List<Map<String, dynamic>> _fields = [];

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
      await provider.createScraper(
        containerId: int.parse(widget.containerId),
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        urlPattern: _patternController.text.trim().isEmpty ? null : _patternController.text.trim(),
        fields: _fields.map((f) => {
          'name': f['name'] ?? '',
          'xpath': f['xpath'] ?? '',
          'order': f['order'] ?? 0,
        }).toList(),
      );
      if (!mounted) return;
      context.go('/container/${widget.containerId}/scrapers');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _addField() {
    final name = _fieldNameController.text.trim();
    final xpath = _fieldXpathController.text.trim();
    if (name.isEmpty || xpath.isEmpty) return;
    setState(() {
      _fields.add({
        'name': name,
        'xpath': xpath,
        'order': _fields.length,
      });
      _fieldNameController.clear();
      _fieldXpathController.clear();
    });
  }

  void _editField(int index) async {
    final field = _fields[index];
    final nameController = TextEditingController(text: field['name']);
    final xpathController = TextEditingController(text: field['xpath']);
    final result = await showDialog<bool>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Edit field'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: xpathController, decoration: const InputDecoration(labelText: 'XPath')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
        ],
      );
    });
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
            Text('New Scraper', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _patternController,
              decoration: const InputDecoration(
                labelText: 'URL pattern (optional)',
                hintText: '/items/\d+',
                prefixIcon: Icon(Icons.filter_alt_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text('Fields', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: _fieldNameController, decoration: const InputDecoration(labelText: 'Field name'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _fieldXpathController, decoration: const InputDecoration(labelText: 'XPath'))),
              const SizedBox(width: 12),
              FilledButton.icon(onPressed: _addField, icon: const Icon(Icons.add), label: const Text('Add')),
            ]),
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
                      for (var i = 0; i < _fields.length; i++) {
                        _fields[i]['order'] = i;
                      }
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
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          tooltip: l10n.testScraper,
                          onPressed: () async {
                            // Run ad-hoc test without saving using backend endpoint
                            final service = context.read<ScraperService>();
                            // show loading
                            showDialog<void>(context: context, barrierDismissible: false, builder: (ctx) => const AlertDialog(content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),),);
                            try {
                              final result = await service.runAdHoc(
                                name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
                                url: _urlController.text.trim(),
                                urlPattern: _patternController.text.trim().isEmpty ? null : _patternController.text.trim(),
                                fields: _fields.map((f) => {
                                  'name': f['name'] ?? '',
                                  'xpath': f['xpath'] ?? '',
                                  'order': f['order'] ?? 0,
                                }).toList(),
                              );
                              Navigator.of(context).pop();
                              final pretty = const JsonEncoder.withIndent('  ').convert(result);
                              await showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: Text(l10n.runResultTitle), content: SingleChildScrollView(child: Text(pretty)), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.ok))],),);
                            } catch (e) {
                              Navigator.of(context).pop();
                              ToastService.error(l10n.runError(e.toString()));
                            }
                          },
                        ),
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _editField(index)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeField(index)),
                      ]),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: () => context.pop(), child: const Text('Cancel')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
