// lib/screens/scrapers/scraper_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'dart:convert';

import 'package:invenicum/data/services/scraper_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/scraper_provider.dart';
import 'package:provider/provider.dart';

class ScraperGridScreen extends StatefulWidget {
  final String containerId;

  const ScraperGridScreen({super.key, required this.containerId});

  @override
  State<ScraperGridScreen> createState() => _ScraperGridScreenState();
}

class _ScraperGridScreenState extends State<ScraperGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScraperProvider>();
      provider.loadForContainer(int.parse(widget.containerId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScraperProvider>();
        final l10n = AppLocalizations.of(context)!;
        final scrapers = provider.scrapersForContainer(int.parse(widget.containerId));
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.scrapers, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  FilledButton.icon(
                    onPressed: () => context.goNamed(RouteNames.scraperCreate, pathParameters: {'containerId': widget.containerId}),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newScraperLabel),
              ),
            ],
          ),
          const SizedBox(height: 24),
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : scrapers.isEmpty
                        ? Center(child: Text(l10n.noScrapers))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: scrapers.length,
                        itemBuilder: (context, index) {
                          final s = scrapers[index];
                          return ListTile(
                            title: Text(s.name),
                            subtitle: Text(s.url),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        tooltip: l10n.editButtonLabel,
                                        onPressed: () => context.goNamed(
                                          RouteNames.scraperEdit,
                                          pathParameters: {'containerId': widget.containerId, 'scraperId': s.id.toString()},
                                          extra: s,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(l10n.confirmDeleteScraper),
                                              content: Text(l10n.confirmDeleteScraperMessage(s.name)),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
                                                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete)),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteScraper(int.parse(widget.containerId), s.id);
                                              ToastService.success(l10n.scraperDeletedSuccess);
                                            } catch (e) {
                                              ToastService.error(l10n.errorDeletingScraper(e.toString()));
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
