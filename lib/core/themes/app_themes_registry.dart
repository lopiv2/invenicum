// lib/core/themes/app_themes_registry.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// SINGLE SOURCE OF TRUTH para todos los temas de la app.
//
// Para añadir un nuevo tema:
//   1. Añadir una entrada en _definitions (abajo)
//   2. Añadir el paletteId a VALID_PALETTE_IDS en el backend (preferences.js)
//   3. Añadir la entrada correspondiente en theme_name_localizer.dart (switch)
//   4. Nada más.
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/cga_palette.dart';
import 'package:invenicum/core/utils/retro/ega_palette.dart';
import 'package:invenicum/core/utils/retro/retro_effects.dart';
import 'package:invenicum/core/utils/retro/retro_theme.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';

// ─── Entrada de registro ──────────────────────────────────────────────────────
//
// Cada tema vive en un único objeto _ThemeEntry.
// Los getters de AppThemesRegistry derivan todo lo demás desde aquí.

class _ThemeEntry {
  final String id;

  /// Display name (fallback cuando no hay traducción disponible).
  final String name;

  /// ARB localization key (ej. 'themeBrand', 'themeEmerald').
  /// null si el tema no tiene traducción en ARB.
  final String? nameKey;

  final Color primaryColor;
  final Brightness brightness;

  /// Solo temas retro rellenan estos dos campos.
  final RetroTheme? retroTheme;
  final String? paletteId;

  /// Efectos visuales asociados. Por defecto ninguno.
  /// Los temas estándar (Material) siempre llevan RetroEffects.none.
  final RetroEffects effects;

  /// ARB localization key para texto adicional (notes) que se muestra
  /// en el tooltip junto al nombre localizado. null si no tiene.
  final String? notesKey;

  const _ThemeEntry({
    required this.id,
    required this.name,
    this.nameKey,
    required this.primaryColor,
    this.brightness = Brightness.light,
    this.retroTheme,
    this.paletteId,
    this.effects = RetroEffects.none,
    this.notesKey,
  }) : assert(
          (retroTheme == null) == (paletteId == null),
          'retroTheme y paletteId deben definirse juntos o ninguno',
        );

  bool get isRetro => paletteId != null;

  CustomTheme toCustomTheme() => CustomTheme(
        id: id,
        name: name,
        primaryColor: primaryColor,
        brightness: brightness,
        paletteId: paletteId,
      );
}

// ─── Registro central ─────────────────────────────────────────────────────────

class AppThemesRegistry {
  AppThemesRegistry._();

  // ══════════════════════════════════════════════════════════════════════════
  // 👇 ÚNICO LUGAR DONDE SE DEFINEN LOS TEMAS
  // ══════════════════════════════════════════════════════════════════════════

  static const _definitions = <_ThemeEntry>[
    // ── Standard ──────────────────────────────────────────────────────────
    _ThemeEntry(id: 'brand',      name: 'Invenicum',       nameKey: 'themeBrand',      primaryColor: Color(0xFF1A237E)),
    _ThemeEntry(id: 'emerald',    name: 'Esmeralda',       nameKey: 'themeEmerald',    primaryColor: Colors.teal),
    _ThemeEntry(id: 'sunset',     name: 'Atardecer',       nameKey: 'themeSunset',     primaryColor: Colors.orange),
    _ThemeEntry(id: 'ocean',      name: 'Indian Ocean',    nameKey: 'oceanTheme',      primaryColor: Colors.blue),
    _ThemeEntry(id: 'lavender',   name: 'Lavanda Dulce',   nameKey: 'themeLavender',   primaryColor: Color(0xFFCE93D8)),
    _ThemeEntry(id: 'forest',     name: 'Bosque Profundo', nameKey: 'themeForest',     primaryColor: Color(0xFF1B5E20)),
    _ThemeEntry(id: 'cherry',     name: 'Cereza',          nameKey: 'themeCherry',     primaryColor: Colors.redAccent),
    _ThemeEntry(id: 'indigo',     name: 'Noche Eléctrica', nameKey: 'themeElectricNight', primaryColor: Colors.indigoAccent),
    _ThemeEntry(id: 'amber',      name: 'Oro Ámbar',       nameKey: 'themeAmberGold',  primaryColor: Colors.amber),
    _ThemeEntry(id: 'sakura',     name: 'Cherry Blossom',  nameKey: 'cherryBlossomTheme', primaryColor: Color(0xFFF48FB1)),
    _ThemeEntry(id: 'slate',      name: 'Pizarra Moderna', nameKey: 'themeModernSlate', primaryColor: Color(0xFF546E7A)),
    _ThemeEntry(id: 'cyberpunk',  name: 'Cyberpunk',       nameKey: 'themeCyberpunk',  primaryColor: Colors.pinkAccent,      brightness: Brightness.dark),
    _ThemeEntry(id: 'nordic',     name: 'Ártico Nord',     nameKey: 'themeNordicArctic', primaryColor: Color(0xFFB3E5FC)),
    _ThemeEntry(id: 'dark_mode',  name: 'Noche Profunda',  nameKey: 'themeDeepNight',  primaryColor: Colors.blueGrey,        brightness: Brightness.dark),

    // ── Retro ──────────────────────────────────────────────────────────────
    // Para añadir un retro nuevo: copiar una entrada, cambiar id/name/paletteId,
    // crear la constante RetroTheme y elegir el preset de efectos.
    _ThemeEntry(
      id: 'retro_cga',
      name: 'CGA (1981)',
      paletteId: 'cga',
      primaryColor: CGA.brightCyan,
      brightness: Brightness.dark,
      retroTheme: RetroTheme.cga,
      effects: RetroEffects.cga,
    ),
    _ThemeEntry(
      id: 'retro_ega',
      name: 'EGA (1984)',
      paletteId: 'ega',
      primaryColor: EGA.magenta,
      brightness: Brightness.dark,
      retroTheme: RetroTheme.ega,
      effects: RetroEffects.ega,
    ),
    _ThemeEntry(
      id: 'retro_scumm_crt',
      name: 'SCUMM-VM CRT',
      paletteId: 'scumm_crt',
      primaryColor: CGA.brightCyan,
      brightness: Brightness.dark,
      retroTheme: RetroTheme.scummCrt,
      effects: RetroEffects.scummCrt,
    ),
    _ThemeEntry(
      id: 'retro_pipboy3000',
      name: 'Pip-Boy 3000',
      paletteId: 'pipboy3000',
      primaryColor: Color(0xFF00FF41),
      brightness: Brightness.dark,
      retroTheme: RetroTheme.pipboy3000,
      effects: RetroEffects.pipboy3000,
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // Getters derivados — no tocar al añadir temas
  // ══════════════════════════════════════════════════════════════════════════

  /// Todos los temas como CustomTheme (para la UI del picker).
  static List<CustomTheme> get all =>
      _definitions.map((e) => e.toCustomTheme()).toList();

  /// Solo temas estándar (Material), excluyendo brand (se usa por separado).
  static List<CustomTheme> get standard => _definitions
      .where((e) => e.id != 'brand' && !e.isRetro)
      .map((e) => e.toCustomTheme())
      .toList();

  /// Solo temas retro.
  static List<CustomTheme> get retro => _definitions
      .where((e) => e.isRetro)
      .map((e) => e.toCustomTheme())
      .toList();

  /// El tema brand por defecto.
  static CustomTheme get brand =>
      _definitions.first.toCustomTheme(); // 'brand' es siempre el primero

  /// IDs de temas del sistema (no se pueden borrar).
  static Set<String> get systemIds =>
      _definitions.map((e) => e.id).toSet();

  /// Resuelve un paletteId a su RetroTheme. Devuelve null para temas normales.
  static RetroTheme? retroThemeForPaletteId(String? paletteId) {
    if (paletteId == null) return null;
    return _definitions
        .where((e) => e.paletteId == paletteId)
        .map((e) => e.retroTheme)
        .firstOrNull;
  }

  /// Resuelve un paletteId a sus efectos. Devuelve none para temas normales.
  static RetroEffects effectsForPaletteId(String? paletteId) {
    if (paletteId == null) return RetroEffects.none;
    return _definitions
        .where((e) => e.paletteId == paletteId)
        .map((e) => e.effects)
        .firstOrNull ?? RetroEffects.none;
  }

  /// Resuelve efectos por ID de tema.
  static RetroEffects effectsForId(String id) {
    return _definitions
        .where((e) => e.id == id)
        .map((e) => e.effects)
        .firstOrNull ?? RetroEffects.none;
  }

  /// ARB localization key para un theme ID, o null si no tiene.
  static String? nameKeyForId(String id) {
    return _definitions
        .where((e) => e.id == id)
        .map((e) => e.nameKey)
        .firstOrNull;
  }

  /// ARB localization key para las notes de un theme ID, o null si no tiene.
  static String? notesKeyForId(String id) {
    return _definitions
        .where((e) => e.id == id)
        .map((e) => e.notesKey)
        .firstOrNull;
  }

  /// Lista de paletteIds válidos para validación en backend/frontend.
  static List<String> get validPaletteIds => _definitions
      .where((e) => e.paletteId != null)
      .map((e) => e.paletteId!)
      .toList();

  /// Busca un CustomTheme por id.
  static CustomTheme? findById(String id) {
    try {
      return _definitions.firstWhere((e) => e.id == id).toCustomTheme();
    } catch (_) {
      return null;
    }
  }

  /// Busca por color + brightness + paletteId opcional (para _resolveAndApply).
  static CustomTheme? findByConfig({
    required Color color,
    required Brightness brightness,
    String? paletteId,
  }) {
    try {
      return _definitions.firstWhere((e) {
        final colorMatch = e.primaryColor.toARGB32() == color.toARGB32();
        final brightnessMatch = e.brightness == brightness;
        if (paletteId != null && paletteId.isNotEmpty) {
          return colorMatch && brightnessMatch && e.paletteId == paletteId;
        }
        return colorMatch && brightnessMatch;
      }).toCustomTheme();
    } catch (_) {
      return null;
    }
  }
}
