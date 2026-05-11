import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:invenicum/data/services/scraper_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// ============================================================================
/// SCRAPER TEST MIXIN
/// ============================================================================
///
/// Shared UI logic for testing a single scraper field ad-hoc.
/// Used by both ScraperCreateScreen and ScraperEditScreen.
///
/// The consuming State must implement:
///   - [scraperName]  → current name field value
///   - [scraperUrl]   → current URL field value
///   - [urlPattern]   → current pattern field value (nullable)
///
/// Usage:
///   class _MyState extends State<MyWidget> with ScraperTestMixin {
///     @override String get scraperName => _nameCtrl.text.trim();
///     @override String get scraperUrl  => _urlCtrl.text.trim();
///     @override String? get urlPattern => ...;
///   }
///
///   // In the button:
///   onPressed: () => testField(context, f),
///
/// ============================================================================

mixin ScraperTestMixin<T extends StatefulWidget> on State<T> {
  String get scraperName;
  String get scraperUrl;
  String? get urlPattern;

  Future<void> testField(BuildContext context, Map<String, dynamic> f) async {
    final l10n = AppLocalizations.of(context)!;
    final testUrlController = TextEditingController();

    // 1. Ask for test URL
    final testUrl = await showAppDialog<String>(
      context: context,
      title: 'Test field',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Introduce una URL que coincida con el patrón del scraper '
            'para probar el campo "${f['name']}".',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (urlPattern != null && urlPattern!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Patrón: $urlPattern',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          TextField(
            controller: testUrlController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'URL a probar',
              hintText: 'https://ejemplo.com/items/123',
              prefixIcon: Icon(Icons.link_outlined),
            ),
            keyboardType: TextInputType.url,
            onSubmitted: (_) =>
                Navigator.of(context).pop(testUrlController.text.trim()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(testUrlController.text.trim()),
          child: const Text('Probar'),
        ),
      ],
    );

    if (testUrl == null || testUrl.isEmpty) return;

    // 2. Show loading — capture navigator BEFORE the async gap
    //    so we always close exactly the dialog we opened,
    //    regardless of useRootNavigator settings.
    final navigator = Navigator.of(context, rootNavigator: false);
    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      title: '',
      body: const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    // 3. Call service
    try {
      final service = context.read<ScraperService>();
      final result = await service.testField(
        scraperName: scraperName.isEmpty ? null : scraperName,
        testUrl: testUrl,
        urlPattern: urlPattern,
        fieldName: f['name'] as String,
        fieldXpath: f['xpath'] as String,
        fieldOrder: (f['order'] as int?) ?? 0,
      );

      // Close loading using the same navigator we captured above
      if (mounted && navigator.canPop()) navigator.pop();

      final pretty = const JsonEncoder.withIndent('  ').convert(result);
      if (!mounted) return;

      await showAppDialog<void>(
        context: context,
        title: l10n.runResultTitle,
        body: SingleChildScrollView(child: SelectableText(pretty)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      );
    } catch (e) {
      if (mounted && navigator.canPop()) navigator.pop();
      if (!mounted) return;
      ToastService.error(l10n.runError(e.toString()));
    }
  }
}