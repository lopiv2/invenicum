// lib/data/models/scraper.dart


class ScraperField {
  final int id;
  final String name;
  final String xpath;
  final int? order;
  final int scraperId;

  ScraperField({
    required this.id,
    required this.name,
    required this.xpath,
    this.order,
    required this.scraperId,
  });

  factory ScraperField.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString();
      if (s.isEmpty || s == 'null') return null;
      return int.tryParse(s);
    }

    return ScraperField(
      id: tryParseInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      xpath: json['xpath'] ?? '',
      order: tryParseInt(json['order']),
      scraperId: tryParseInt(json['scraper_id']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'xpath': xpath,
      'order': order,
      'scraper_id': scraperId,
    };
  }
}

class Scraper {
  final int id;
  final String name;
  final String url;
  final String? urlPattern;
  final DateTime? createdAt;
  final List<ScraperField> fields;

  Scraper({
    required this.id,
    required this.name,
    required this.url,
    this.urlPattern,
    this.createdAt,
    this.fields = const [],
  });

  factory Scraper.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString();
      if (s.isEmpty || s == 'null') return null;
      return int.tryParse(s);
    }

    final List<dynamic>? fieldsJson = json['fields'] ?? json['scraper_fields'];
    final createdAtRaw = json['created_at'] ?? json['createdAt'];
    DateTime? createdAt;
    try {
      if (createdAtRaw != null) createdAt = DateTime.tryParse(createdAtRaw.toString());
    } catch (_) {
      createdAt = null;
    }

    return Scraper(
      id: tryParseInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      urlPattern: json['url_pattern'] ?? json['urlPattern'],
      createdAt: createdAt,
      fields: fieldsJson is List
          ? fieldsJson.where((e) => e is Map<String, dynamic>).map((e) => ScraperField.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'url_pattern': urlPattern,
      'created_at': createdAt?.toIso8601String(),
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }
}
