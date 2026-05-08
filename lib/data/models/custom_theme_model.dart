import 'package:flutter/material.dart';

// ─── Palette ID constants ─────────────────────────────────────────────────────
//
// Retro themes are just CustomThemes with a well-known paletteId.
// Nothing else distinguishes them from a regular theme at the model level.
// The ThemeProvider is responsible for building the correct ThemeData
// depending on whether a paletteId maps to a retro renderer.
//
// Convention:
//   null / ''         → Material theme (uses primaryColor + brightness)
//   'cga'             → CGA retro renderer
//   'ega'             → EGA retro renderer
//   (future) 'vga'    → VGA retro renderer
//
// paletteId is NEVER sent to the backend. It is derived from the theme id
// at read-time so the DB schema stays clean.

class CustomTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Brightness brightness;

  /// Optional palette identifier for special renderers (retro, etc.).
  /// Derived from [id] at construction time – never persisted separately.
  final String? paletteId;

  const CustomTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    this.brightness = Brightness.light,
    this.paletteId,
  });

  /// Whether this theme uses a non-Material palette renderer.
  bool get hasCustomPalette => paletteId != null && paletteId!.isNotEmpty;

  /// Convenience: true when the palette is one of the known retro renderers.
  bool get isRetro => paletteId == 'cga' || paletteId == 'ega';

  CustomTheme copyWith({
    String? id,
    String? name,
    Color? primaryColor,
    Brightness? brightness,
    String? paletteId,
  }) {
    return CustomTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      brightness: brightness ?? this.brightness,
      paletteId: paletteId ?? this.paletteId,
    );
  }

  // ─── Serialization helpers ─────────────────────────────────────────────────

  /// Hex string ready to send to the backend (e.g. '#1A237E').
  String get hexColor =>
      '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  /// Brightness string for the backend ('light' | 'dark').
  String get brightnessStr => brightness == Brightness.dark ? 'dark' : 'light';
}