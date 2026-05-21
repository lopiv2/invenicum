// lib/screens/assets/local_widgets/scraper_import_widget.dart
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/scraper.dart';
import 'package:invenicum/data/services/scraper_service.dart';
import 'package:provider/provider.dart';

class ScraperImportWidget extends StatefulWidget {
  final int containerId;
  final void Function(Map<String, dynamic> results) onResults;

  const ScraperImportWidget({
    super.key,
    required this.containerId,
    required this.onResults,
  });

  @override
  State<ScraperImportWidget> createState() => _ScraperImportWidgetState();
}

class _ScraperImportWidgetState extends State<ScraperImportWidget> {
  final _urlController = TextEditingController();
  List<Scraper> _scrapers = [];
  Scraper? _selectedScraper;
  bool _loading = false;
  bool _loadingScrapers = true;

  @override
  void initState() {
    super.initState();
    _loadScrapers();
    _urlController.addListener(_autoSelectScraper);
  }

  @override
  void dispose() {
    _urlController.removeListener(_autoSelectScraper);
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadScrapers() async {
    try {
      final service = context.read<ScraperService>();
      final list = await service.getScrapers(widget.containerId);
      if (mounted)
        setState(() {
          _scrapers = list;
          _loadingScrapers = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingScrapers = false);
    }
  }

  void _autoSelectScraper() {
    final url = _urlController.text.trim();
    if (url.isEmpty || _scrapers.isEmpty) return;

    Scraper? match;

    // 1. Intentar con urlPattern (regex)
    for (final s in _scrapers) {
      if (s.urlPattern != null && s.urlPattern!.isNotEmpty) {
        try {
          final regex = RegExp(s.urlPattern!);
          if (regex.hasMatch(url)) {
            match = s;
            break;
          }
        } catch (_) {}
      }
    }

    // 2. Fallback: la URL empieza por la URL raíz del scraper
    if (match == null) {
      for (final s in _scrapers) {
        final root = s.url.endsWith('/') ? s.url : '${s.url}/';
        if (url.startsWith(root) || url.startsWith(s.url)) {
          match = s;
          break;
        }
      }
    }

    if (match != null && match != _selectedScraper) {
      setState(() => _selectedScraper = match);
    }
  }

  Future<void> _run() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || _selectedScraper == null) return;

    setState(() => _loading = true);
    try {
      final service = context.read<ScraperService>();
      final results = await service.runAdHoc(
        name: _selectedScraper!.name,
        url: url,
        urlPattern: _selectedScraper!.urlPattern,
        fields: _selectedScraper!.fields
            .map(
              (f) => {'name': f.name, 'xpath': f.xpath, 'order': f.order ?? 0},
            )
            .toList(),
      );
      widget.onResults(results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMatch = _selectedScraper != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // URL input
        TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: 'URL to scrape',
            hintText: 'https://example.com/item/123',
            prefixIcon: const Icon(Icons.link_outlined),
            suffixIcon: _urlController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _urlController.clear();
                      setState(() => _selectedScraper = null);
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),

        // Scraper selector
        if (_loadingScrapers)
          const LinearProgressIndicator()
        else if (_scrapers.isEmpty)
          Text(
            'No scrapers configured for this container.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Scraper>(
                  value: _selectedScraper,
                  decoration: InputDecoration(
                    labelText: 'Scraper',
                    prefixIcon: Icon(
                      hasMatch
                          ? Icons.check_circle_outline
                          : Icons.find_replace,
                      color: hasMatch
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                  items: _scrapers
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // ← clave
                            children: [
                              Flexible(
                                // ← Flexible en vez de Expanded
                                child: Text(
                                  s.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (s == _selectedScraper) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (s) => setState(() => _selectedScraper = s),
                  hint: const Text('Select scraper'),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed:
                    (_selectedScraper != null &&
                        _urlController.text.trim().isNotEmpty &&
                        !_loading)
                    ? _run
                    : null,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: const Text('Extract'),
              ),
            ],
          ),

        // Auto-match chip
        if (hasMatch)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  label: Text(
                    'Auto-detected: ${_selectedScraper!.name}',
                    style: theme.textTheme.labelSmall,
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                ...(_selectedScraper!.fields.map(
                  (f) => Chip(
                    label: Text(f.name, style: theme.textTheme.labelSmall),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )),
              ],
            ),
          ),
      ],
    );
  }
}
