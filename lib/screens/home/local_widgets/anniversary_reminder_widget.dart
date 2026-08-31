import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/core/utils/anniversary_helper.dart';
import 'package:invenicum/core/utils/retro/retro_theme_extension.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// Widget "Recuerdos" estilo Google Fotos.
///
/// - Busca items cuyo `createdAt` es aniversario hoy ±3 días (multianiversario)
/// - Si no hay coincidencias → `SizedBox.shrink()` (oculto)
/// - Estética polaroid + bento limpio, con sombra e inclinación sutil
/// - Dismissible 24h (SharedPreferences)
/// - Ubicado tras `dashboard_top` en el dashboard
class AnniversaryReminderWidget extends StatefulWidget {
  const AnniversaryReminderWidget({super.key});

  @override
  State<AnniversaryReminderWidget> createState() =>
      _AnniversaryReminderWidgetState();
}

class _AnniversaryReminderWidgetState extends State<AnniversaryReminderWidget> {
  // Dismiss diario: solo oculta el día natural actual, vuelve a salir mañana
  static const String _dismissKey = 'anniversary_dismissed_date';
  static const String _legacyDismissKey = 'anniversary_dismissed_at';
  bool _dismissed = false;
  bool _checkingDismiss = true;

  @override
  void initState() {
    super.initState();
    _loadDismissState();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadDismissState() async {
    final prefs = await SharedPreferences.getInstance();
    // Migración: borra el antiguo int de 24h para que hoy vuelva a salir
    if (prefs.containsKey(_legacyDismissKey)) {
      await prefs.remove(_legacyDismissKey);
    }
    // Limpia claves legacy con prefijo antiguo salvo la nueva
    for (final k in prefs.getKeys().where((k) => k.startsWith('anniversary_dismissed_')).toList()) {
      if (k != _dismissKey) await prefs.remove(k);
    }
    final todayKey = _todayKey();
    final dismissedDate = prefs.getString(_dismissKey);
    if (dismissedDate == todayKey) {
      if (mounted) setState(() => _dismissed = true);
    } else if (dismissedDate != null) {
      // Día distinto → expirado, limpiar para que hoy se muestre
      await prefs.remove(_dismissKey);
    }
    if (mounted) setState(() => _checkingDismiss = false);
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissKey, _todayKey());
    // Limpieza legacy
    if (prefs.containsKey(_legacyDismissKey)) {
      await prefs.remove(_legacyDismissKey);
    }
    for (final k in prefs.getKeys().where((k) => k.startsWith('anniversary_dismissed_')).toList()) {
      if (k != _dismissKey) await prefs.remove(k);
    }
    if (mounted) setState(() => _dismissed = true);
  }

  Future<void> _clearDismissForDebug() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissKey);
    if (prefs.containsKey(_legacyDismissKey)) {
      await prefs.remove(_legacyDismissKey);
    }
    for (final k in prefs.getKeys().where((k) => k.startsWith('anniversary_dismissed_')).toList()) {
      await prefs.remove(k);
    }
    if (mounted) setState(() => _dismissed = false);
    // Forzar recarga
    if (mounted) {
      final provider = context.read<InventoryItemProvider>();
      await provider.loadAllItemsGlobal();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingDismiss || _dismissed) return const SizedBox.shrink();

    final isRetro = Theme.of(context).extension<RetroThemeExtension>()?.retro != null;

    return Consumer<InventoryItemProvider>(
      builder: (context, provider, _) {
        final all = provider.allDownloadedItems.isNotEmpty
            ? provider.allDownloadedItems
            : provider.allInventoryItems;

        // Trigger global load if cache empty and not already loading
        if (all.isEmpty && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) provider.loadAllItemsGlobal();
          });
          return const SizedBox.shrink();
        }
        if (all.isEmpty) return const SizedBox.shrink();

        final grouped = AnniversaryHelper.groupAnniversaries(
          all,
          customDateResolver: AnniversaryHelper.tryParseCustomAcquisitionDate,
        );
        // Debug diagnostics when no anniversary within window
        if (grouped.isEmpty) {
          // ignore: avoid_print
          debugPrint('[Anniversary] ${all.length} items checked, 0 anniversaries within ±${AnniversaryHelper.defaultToleranceDays}d. '
              'Sample: ${all.take(3).map((e) => '${e.name}:createdAt=${e.createdAt?.toIso8601String()} custom=${AnniversaryHelper.tryParseCustomAcquisitionDate(e)?.toIso8601String()} cf=${e.customFieldValues}').join(' | ')} '
              'Today:${DateTime.now().toIso8601String()}');
          // In debug builds show a faint placeholder to explain why hidden
          assert(() {
            // Only in debug, return hidden but log
            return true;
          }());
          return const SizedBox.shrink();
        }

        // Aplanar para carrusel, ordenado por años asc y luego fecha
        final sortedYears = grouped.keys.toList()..sort();
        final flat = <_AnniversaryEntry>[];
        for (final y in sortedYears) {
          for (final item in grouped[y]!) {
            flat.add(_AnniversaryEntry(item, y));
          }
        }
        // Limitar a 12 polaroids para no saturar
        final displayItems = flat.take(12).toList();
        final totalCount = flat.length;

        return isRetro
            ? _buildRetro(context, displayItems, totalCount, grouped)
            : _buildBentoPolaroid(context, displayItems, totalCount, grouped);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BENTO POLAROID (material)
  // ---------------------------------------------------------------------------

  Widget _buildBentoPolaroid(
    BuildContext context,
    List<_AnniversaryEntry> items,
    int totalCount,
    Map<int, List<InventoryItem>> grouped,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Header badge text multianiversario
    final yearsLabel = _buildYearsSummary(l10n, grouped);
    // Flavor friki estable 24h — fecha original (2025), no aniversario 2026
    final today = DateTime.now();
    final flavorYears = grouped.keys.reduce((a, b) => a < b ? a : b);
    final sampleForDate = grouped[flavorYears]!.first;
    final rawAcquisition = AnniversaryHelper.tryParseCustomAcquisitionDate(sampleForDate) ?? sampleForDate.createdAt!;
    final dateStr = _formatToday(rawAcquisition.toLocal(), l10n);
    final flavor = AnniversaryHelper.pickFlavor(l10n, flavorYears, totalCount, today, dateStr);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.10 : 0.9),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? const Color(0xFF1E1E1E) : Colors.white).withValues(alpha: 0.92),
                  (isDark ? const Color(0xFF121212) : const Color(0xFFF8F6F0)).withValues(alpha: 0.96),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — long-press to reset dismiss (debug)
                GestureDetector(
                  onLongPress: () async {
                    await _clearDismissForDebug();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.anniversaryDismissReset)),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const FaIcon(FontAwesomeIcons.cameraRetro, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.anniversaryTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                yearsLabel,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Dismiss
                        Tooltip(
                          message: l10n.anniversaryDismiss,
                          child: InkWell(
                            onTap: _dismiss,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded, size: 18, color: isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.anniversarySubtitle(totalCount),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.primary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.science_rounded, size: 12, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          flavor,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            height: 1.25,
                            color: isDark ? Colors.white70 : Colors.black87.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Carrusel Polaroid
                SizedBox(
                  height: 188,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final entry = items[index];
                      // Inclinación alterna -1.2, 0.9, -0.7...
                      final tilt = [ -0.015, 0.012, -0.009, 0.014, -0.011 ][index % 5];
                      return Transform.rotate(
                        angle: tilt,
                        child: _PolaroidCard(entry: entry),
                      );
                    },
                  ),
                ),

                // Footer chips multianiversario + action
                if (grouped.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: grouped.keys.map((y) {
                        final count = grouped[y]!.length;
                        final label = y == 1 ? l10n.anniversaryBadgeOneYear : l10n.anniversaryBadgeYears(y);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.9 : 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.18)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history_rounded, size: 13, color: theme.colorScheme.onPrimaryContainer),
                              const SizedBox(width: 4),
                              Text('$label · $count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: Row(
                    children: [
                      Text(
                        _formatToday(DateTime.now(), l10n),
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38, fontStyle: FontStyle.italic),
                      ),
                      const Spacer(),
                      if (totalCount > items.length)
                        Text(
                          '+${totalCount - items.length} ${l10n.anniversaryMore}',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RETRO MODE
  // ---------------------------------------------------------------------------

  Widget _buildRetro(
    BuildContext context,
    List<_AnniversaryEntry> items,
    int totalCount,
    Map<int, List<InventoryItem>> grouped,
  ) {
    final retro = Theme.of(context).extension<RetroThemeExtension>()!.retro!;
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final flavorYears = grouped.keys.reduce((a, b) => a < b ? a : b);
    final sampleForDate = grouped[flavorYears]!.first;
    final rawAcquisition = AnniversaryHelper.tryParseCustomAcquisitionDate(sampleForDate) ?? sampleForDate.createdAt!;
    final dateStr = _formatToday(rawAcquisition.toLocal(), l10n);
    final flavor = AnniversaryHelper.pickFlavor(l10n, flavorYears, totalCount, today, dateStr);
    return Container(
      decoration: BoxDecoration(
        color: retro.messageBox,
        border: Border.all(color: retro.border, width: 2),
        boxShadow: [
          BoxShadow(color: retro.border.withValues(alpha: 0.25), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: retro.titleBar,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Text('▓▒░ ', style: TextStyle(color: retro.border, fontFamily: 'monospace', fontSize: 10)),
                Expanded(child: Text(l10n.anniversaryTitle.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: retro.titleText, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                InkWell(onTap: _dismiss, child: Text('[X]', style: TextStyle(color: retro.titleText, fontFamily: 'monospace', fontSize: 11))),
              ],
            ),
          ),
          Container(height: 1, color: retro.border),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              l10n.anniversarySubtitle(totalCount),
              style: TextStyle(color: retro.messageText, fontFamily: 'monospace', fontSize: 11),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '> $flavor',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: retro.messageText.withValues(alpha: 0.85),
                fontFamily: 'monospace',
                fontSize: 9,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final e = items[i];
                return InkWell(
                  onTap: () => _openDetail(context, e.item),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(color: Colors.black, border: Border.all(color: retro.border)),
                    child: Column(
                      children: [
                        Expanded(child: _RetroImage(url: _anniversaryImageUrl(e.item))),
                        Container(
                          width: double.infinity,
                          color: retro.messageBox,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          child: Text(
                            e.item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: retro.messageText, fontFamily: 'monospace', fontSize: 9),
                          ),
                        ),
                        Container(
                          color: retro.border,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            e.yearsAgo == 1 ? '1Y' : '${e.yearsAgo}Y',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: retro.titleBar, fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: retro.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(_formatToday(DateTime.now(), l10n), style: TextStyle(color: retro.messageText.withValues(alpha: 0.6), fontFamily: 'monospace', fontSize: 9)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _buildYearsSummary(AppLocalizations l10n, Map<int, List<InventoryItem>> grouped) {
    if (grouped.length == 1) {
      final y = grouped.keys.first;
      final c = grouped[y]!.length;
      final badge = y == 1 ? l10n.anniversaryBadgeOneYear : l10n.anniversaryBadgeYears(y);
      return '$badge · $c ${c == 1 ? l10n.anniversaryItem : l10n.anniversaryItems}';
    }
    final parts = grouped.keys.toList()..sort();
    return '${parts.map((y) {
      final c = grouped[y]!.length;
      final badge = y == 1 ? '1a' : '${y}a';
      return '$badge:$c';
    }).join('  •  ')}  ·  ${l10n.anniversaryMemories}';
  }

  String _formatToday(DateTime now, AppLocalizations l10n) {
    try {
      final fmt = DateFormat.yMMMd(l10n.localeName);
      return fmt.format(now);
    } catch (_) {
      return '${now.day}/${now.month}/${now.year}';
    }
  }

  void _openDetail(BuildContext context, InventoryItem item) {
    context.goNamed(
      RouteNames.assetDetail,
      pathParameters: {
        'containerId': item.containerId.toString(),
        'assetTypeId': item.assetTypeId.toString(),
        'assetId': item.id.toString(),
      },
    );
  }
}

String _anniversaryImageUrl(InventoryItem item) {
  if (item.images.isEmpty) return '';
  final raw = item.images.first.url;
  if (raw.startsWith('http') || raw.startsWith('data:')) return raw;
  final clean = raw.startsWith('/') ? raw : '/$raw';
  return '${Environment.apiUrl}$clean';
}

class _AnniversaryEntry {
  final InventoryItem item;
  final int yearsAgo;
  _AnniversaryEntry(this.item, this.yearsAgo);
}

class _PolaroidCard extends StatelessWidget {
  final _AnniversaryEntry entry;
  const _PolaroidCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final url = _anniversaryImageUrl(entry.item);
    final yearsText = entry.yearsAgo == 1 ? l10n.anniversaryBadgeOneYear : l10n.anniversaryBadgeYears(entry.yearsAgo);

    return InkWell(
      onTap: () {
        context.goNamed(
          RouteNames.assetDetail,
          pathParameters: {
            'containerId': entry.item.containerId.toString(),
            'assetTypeId': entry.item.assetTypeId.toString(),
            'assetId': entry.item.id.toString(),
          },
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 132,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: Colors.black.withValues(alpha: 0.07), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tape effect superior
            Center(
              child: Container(
                width: 46,
                height: 12,
                transform: Matrix4.translationValues(0, -5, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
            // Imagen
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: url.isEmpty
                      ? Container(
                          color: const Color(0xFFF0EDE6),
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 28),
                        )
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(color: const Color(0xFFF0EDE6)),
                          errorWidget: (_, _, _) => Container(
                            color: const Color(0xFFF0EDE6),
                            child: const Icon(Icons.broken_image_outlined, color: Colors.black26),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Caption zona polaroid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                entry.item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2B2B),
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFCC80).withValues(alpha: 0.8)),
                ),
                child: Text(
                  yearsText,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4, color: Color(0xFF6D4C41)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RetroImage extends StatelessWidget {
  final String url;
  const _RetroImage({required this.url});
  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(color: Colors.black, child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 20));
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: Colors.black),
      errorWidget: (_, _, _) => Container(color: Colors.black, child: const Icon(Icons.broken_image, color: Colors.white24, size: 18)),
    );
  }
}
