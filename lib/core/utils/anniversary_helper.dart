import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Helper para calcular aniversarios de creación de [InventoryItem].
///
/// Lógica:
/// - Un item es "aniversario" si su `createdAt` cae dentro de `toleranceDays`
///   alrededor del día de hoy, pero hace N años (N >= 1).
/// - Soporta multianiversario (1,2,3... años) agrupado por [yearsAgo].
/// - Tolera el 29 de febrero (mapea a 28 feb en años no bisiestos).
class AnniversaryHelper {
  static const int defaultToleranceDays = 3;
  static const int maxYearsBack = 20;

  /// Agrupa items por `yearsAgo` donde el aniversario está a <= [toleranceDays]
  /// de [today]. Devuelve mapa ordenable (key = yearsAgo).
  /// Si `customDateResolver` se provee, se probará también esa fecha como
  /// fecha de adquisición (ej. campo custom tipo `date`).
  static Map<int, List<InventoryItem>> groupAnniversaries(
    List<InventoryItem> items, {
    DateTime? today,
    int toleranceDays = defaultToleranceDays,
    int maxYears = maxYearsBack,
    DateTime? Function(InventoryItem)? customDateResolver,
  }) {
    final now = _normalizeToday(today ?? DateTime.now());
    final Map<int, List<InventoryItem>> grouped = {};

    for (final item in items) {
      // 1) Fecha principal: createdAt (siempre) — probamos tanto UTC date como local
      //    para evitar desfase de zona horaria (ej. 2025-08-31T22:00Z → 2025-09-01 local)
      // 2) Si hay resolver custom (ej. campo fecha adquisición) y da fecha distinta, se prioriza la que dé match
      final candidates = <DateTime>[];
      if (item.createdAt != null) {
        final c = item.createdAt!;
        candidates.add(c.toLocal());
        // También probar la fecha UTC tal cual (sin conversión) por si el backend guarda a medianoche UTC
        final utcDay = DateTime(c.year, c.month, c.day);
        if (!candidates.any((d) => d.year == utcDay.year && d.month == utcDay.month && d.day == utcDay.day)) {
          candidates.add(utcDay);
        }
      }
      if (customDateResolver != null) {
        final custom = customDateResolver(item);
        if (custom != null) {
          // Evitar duplicado si es mismo día que ya tenemos
          final already = candidates.any((cand) => cand.year == custom.year && cand.month == custom.month && cand.day == custom.day);
          if (!already) candidates.add(custom);
        }
      }
      if (candidates.isEmpty) continue;

      int? bestYearsAgo;
      for (final cand in candidates) {
        final y = _findMatchingYearsAgo(
          cand,
          now,
          toleranceDays: toleranceDays,
          maxYears: maxYears,
        );
        if (y != null) {
          bestYearsAgo = y;
          break; // Prioriza createdAt, luego custom
        }
      }
      if (bestYearsAgo == null) continue;
      grouped.putIfAbsent(bestYearsAgo, () => []).add(item);
    }

    // Ordenar items dentro de cada grupo por fecha original
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final da = a.createdAt!;
        final db = b.createdAt!;
        return da.compareTo(db);
      });
    }
    return grouped;
  }

  /// Lista plana de items de aniversario (todos los años), ordenada por
  /// proximidad al aniversario y luego por años desc.
  static List<InventoryItem> getAnniversaryItems(
    List<InventoryItem> items, {
    DateTime? today,
    int toleranceDays = defaultToleranceDays,
    int maxYears = maxYearsBack,
    DateTime? Function(InventoryItem)? customDateResolver,
  }) {
    final grouped = groupAnniversaries(
      items,
      today: today,
      toleranceDays: toleranceDays,
      maxYears: maxYears,
      customDateResolver: customDateResolver,
    );
    final flat = grouped.entries
        .expand((e) => e.value.map((item) => _ScoredItem(item, e.key)))
        .toList()
      ..sort((a, b) {
        // Prioriza aniversarios más cercanos al día exacto
        final scoreA = _anniversaryDistanceDays(a.item.createdAt!, today ?? DateTime.now(), a.yearsAgo);
        final scoreB = _anniversaryDistanceDays(b.item.createdAt!, today ?? DateTime.now(), b.yearsAgo);
        final cmp = scoreA.compareTo(scoreB);
        if (cmp != 0) return cmp;
        return a.yearsAgo.compareTo(b.yearsAgo);
      });
    return flat.map((e) => e.item).toList();
  }

  /// Calcula cuántos años hace que se creó el item si su aniversario
  /// está dentro de la tolerancia. Null si no aplica.
  static int? findYearsAgoForItem(
    InventoryItem item, {
    DateTime? today,
    int toleranceDays = defaultToleranceDays,
    DateTime? Function(InventoryItem)? customDateResolver,
  }) {
    final candidates = <DateTime>[];
    if (item.createdAt != null) {
      final c = item.createdAt!;
      candidates.add(c.toLocal());
      final utcDay = DateTime(c.year, c.month, c.day);
      if (!candidates.any((d) => d.year == utcDay.year && d.month == utcDay.month && d.day == utcDay.day)) {
        candidates.add(utcDay);
      }
    }
    if (customDateResolver != null) {
      final c = customDateResolver(item);
      if (c != null) {
        final already = candidates.any((cand) => cand.year == c.year && cand.month == c.month && cand.day == c.day);
        if (!already) candidates.add(c);
      }
    }
    if (candidates.isEmpty) return null;
    final now = _normalizeToday(today ?? DateTime.now());
    for (final cand in candidates) {
      final y = _findMatchingYearsAgo(cand, now, toleranceDays: toleranceDays);
      if (y != null) return y;
    }
    return null;
  }

  /// Intenta extraer una fecha de adquisición de los customFields tipo date.
  /// Prueba `DateTime.tryParse` y formatos `dd/MM/yyyy`, `MM-dd-yyyy`, `yyyy-MM-dd`.
  static DateTime? tryParseCustomAcquisitionDate(InventoryItem item) {
    final vals = item.customFieldValues;
    if (vals == null || vals.isEmpty) return null;
    for (final v in vals.values) {
      final dt = _parseLooseDate(v);
      if (dt != null) return dt;
    }
    return null;
  }

  static DateTime? _parseLooseDate(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    // ISO directo
    var dt = DateTime.tryParse(s);
    if (dt != null) return dt;
    // dd/MM/yyyy or dd-MM-yyyy
    final partsSlash = s.split(RegExp(r'[/\-]'));
    if (partsSlash.length == 3) {
      // Intentar dd/MM/yyyy
      final a = int.tryParse(partsSlash[0]);
      final b = int.tryParse(partsSlash[1]);
      final c = int.tryParse(partsSlash[2]);
      if (a != null && b != null && c != null) {
        // Si año tiene 4 dígitos al final → dd/MM/yyyy
        if (partsSlash[2].length == 4) {
          dt = DateTime.tryParse('${c.toString().padLeft(4,'0')}-${b.toString().padLeft(2,'0')}-${a.toString().padLeft(2,'0')}');
          if (dt != null) return dt;
        }
        // Si año al inicio → yyyy-MM-dd ya probado, pero por si viene con /
        if (partsSlash[0].length == 4) {
          dt = DateTime.tryParse('${a.toString().padLeft(4,'0')}-${b.toString().padLeft(2,'0')}-${c.toString().padLeft(2,'0')}');
          if (dt != null) return dt;
        }
      }
    }
    return null;
  }

  /// Días de distancia entre la fecha de aniversario ((created + yearsAgo)
  /// y hoy. 0 = aniversario exacto.
  static int anniversaryOffsetDays(
    InventoryItem item, {
    DateTime? today,
  }) {
    final created = item.createdAt;
    if (created == null) return 999;
    final now = _normalizeToday(today ?? DateTime.now());
    final yearsAgo = _findMatchingYearsAgo(
      created.toLocal(),
      now,
      toleranceDays: 999,
    );
    if (yearsAgo == null) return 999;
    return _anniversaryDistanceDays(created.toLocal(), now, yearsAgo);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  static DateTime _normalizeToday(DateTime d) => DateTime(d.year, d.month, d.day);

  static int? _findMatchingYearsAgo(
    DateTime created,
    DateTime today, {
    required int toleranceDays,
    int maxYears = maxYearsBack,
  }) {
    // Rango a probar: aniversarios cuyo año esté cerca de today (±1)
    // Pero para no iterar 20*items, probamos solo candidatos cercanos.
    // Si diffYears está fuera de [1, maxYears+1], no hay match cercano
    // salvo que el item sea muy antiguo y su aniversario caiga cerca por
    // coincidencia de MM-DD (ej. 5 años). Por eso iteramos todos los yearsAgo
    // posibles hasta maxYears — es barato (20 iteraciones por item).
    for (int yearsAgo = 1; yearsAgo <= maxYears; yearsAgo++) {
      if (created.year + yearsAgo > today.year + 1) break;
      if (created.year + yearsAgo < today.year - 1) continue;
      final anniversary = _anniversaryForYearsAgo(created, yearsAgo);
      final diffDays = (anniversary.difference(today).inDays).abs();
      if (diffDays <= toleranceDays) return yearsAgo;
    }
    // Fallback exhaustivo por si diffYears es muy grande pero MM-DD coincide
    // (ej. item de hace 8 años con mismo día). La loop anterior ya cubre,
    // pero por si maxYears > diffYears+1 permitimos buscar todos.
    for (int yearsAgo = 1; yearsAgo <= maxYears; yearsAgo++) {
      final anniversary = _anniversaryForYearsAgo(created, yearsAgo);
      // Solo considerar aniversarios cuyo año esté cerca de today (±1)
      if ((anniversary.year - today.year).abs() > 1) continue;
      final diffDays = (anniversary.difference(today).inDays).abs();
      if (diffDays <= toleranceDays) return yearsAgo;
    }
    return null;
  }

  static DateTime _anniversaryForYearsAgo(DateTime created, int yearsAgo) {
    final y = created.year + yearsAgo;
    final m = created.month;
    final d = created.day;
    if (m == 2 && d == 29 && !_isLeapYear(y)) {
      return DateTime(y, 2, 28);
    }
    return DateTime(y, m, d);
  }

  static int _anniversaryDistanceDays(
    DateTime created,
    DateTime today,
    int yearsAgo,
  ) {
    final ann = _anniversaryForYearsAgo(created.toLocal(), yearsAgo);
    final t = _normalizeToday(today);
    return (ann.difference(t).inDays).abs();
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  /// Fecha de aniversario para display (ej. "20 may 2024")
  static DateTime anniversaryDate(InventoryItem item, int yearsAgo) {
    final c = item.createdAt!.toLocal();
    return _anniversaryForYearsAgo(c, yearsAgo);
  }

  /// Frase friki estable 24h para el widget.
  /// Usa `today.day+month+year` como semilla para que no cambie en cada rebuild.
  static String pickFlavor(
    AppLocalizations l10n,
    int yearsAgo,
    int count,
    DateTime today,
    String dateStr,
  ) {
    final idx = (yearsAgo * 31 + count * 7 + today.day + today.month * 13 + today.year) % 6;
    switch (idx) {
      case 0:
        return l10n.anniversaryFlavor1(yearsAgo, count, dateStr);
      case 1:
        return l10n.anniversaryFlavor2(yearsAgo, count, dateStr);
      case 2:
        return l10n.anniversaryFlavor3(yearsAgo, count, dateStr);
      case 3:
        return l10n.anniversaryFlavor4(yearsAgo, count, dateStr);
      case 4:
        return l10n.anniversaryFlavor5(yearsAgo, count, dateStr);
      default:
        return l10n.anniversaryFlavor6(yearsAgo, count, dateStr);
    }
  }
}

class _ScoredItem {
  final InventoryItem item;
  final int yearsAgo;
  _ScoredItem(this.item, this.yearsAgo);
}
