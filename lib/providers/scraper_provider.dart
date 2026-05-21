// lib/providers/scraper_provider.dart
import 'package:flutter/material.dart';
import 'package:invenicum/data/models/scraper.dart';
import 'package:invenicum/data/services/scraper_service.dart';

class ScraperProvider extends ChangeNotifier {
  final ScraperService _service;

  bool isLoading = false;
  final Map<int, List<Scraper>> _cache = {};

  ScraperProvider(this._service);

  List<Scraper> scrapersForContainer(int containerId) {
    return _cache[containerId] ?? [];
  }

  Future<void> loadForContainer(int containerId) async {
    isLoading = true;
    notifyListeners();
    try {
      final list = await _service.getScrapers(containerId);
      _cache[containerId] = list;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Scraper> createScraper({
    required int containerId,
    required String name,
    required String url,
    String? urlPattern,
    List<Map<String, dynamic>>? fields,
  }) async {
    final s = await _service.createScraper(
      containerId: containerId,
      name: name,
      url: url,
      urlPattern: urlPattern,
      fields: fields,
    );
    _cache[containerId] = [ ...( _cache[containerId] ?? [] ), s ];
    notifyListeners();
    return s;
  }

  Future<Scraper> updateScraper({
    required int containerId,
    required int scraperId,
    required String name,
    required String url,
    String? urlPattern,
    List<Map<String, dynamic>>? fields,
  }) async {
    final updated = await _service.updateScraper(
      scraperId: scraperId,
      name: name,
      url: url,
      urlPattern: urlPattern,
      fields: fields,
    );
    final list = _cache[containerId] ?? [];
    _cache[containerId] = list.map((s) => s.id == updated.id ? updated : s).toList();
    notifyListeners();
    return updated;
  }

  Future<void> deleteScraper(int containerId, int scraperId) async {
    // Optimistic update: remove locally first so UI updates immediately
    final previous = List<Scraper>.from(_cache[containerId] ?? []);
    _cache[containerId] = previous.where((s) => s.id != scraperId).toList();
    notifyListeners();
    try {
      await _service.deleteScraper(scraperId);
    } catch (e) {
      // Revert on error and rethrow
      _cache[containerId] = previous;
      notifyListeners();
      rethrow;
    }
  }
}
