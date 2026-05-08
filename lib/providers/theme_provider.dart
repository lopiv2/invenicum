import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_theme.dart';
import 'package:invenicum/data/services/theme_service.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';
import 'package:invenicum/core/utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService;

  ThemeProvider(this._themeService);

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  CustomTheme _currentTheme = AppThemes.brand;
  CustomTheme get currentTheme => _currentTheme;

  List<CustomTheme> _userThemes = [];
  List<CustomTheme> get userThemes => _userThemes;

  String? _fontFamily;

  // ─────────────────────────────────────────────
  // RETRO
  //
  // A theme is "retro" if its paletteId maps to a known RetroTheme.
  // No separate enum needed — the paletteId string IS the discriminator.
  // ─────────────────────────────────────────────

  /// Returns the [RetroTheme] for the active theme, or null for normal themes.
  RetroTheme? get activeRetroTheme => _retroThemeForPaletteId(
        _currentTheme.paletteId,
      );

  bool get isRetroMode => activeRetroTheme != null;

  /// Central mapping from paletteId → RetroTheme.
  /// Add future palettes (vga, amiga…) here only.
  static RetroTheme? _retroThemeForPaletteId(String? paletteId) =>
      switch (paletteId) {
        'cga' => RetroTheme.cga,
        'ega' => RetroTheme.ega,
        _     => null,
      };

  // ─────────────────────────────────────────────
  // FONT
  // ─────────────────────────────────────────────

  void setFontFamily(String? fontFamily) {
    _fontFamily = fontFamily == 'Default' ? null : fontFamily;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // THEMES
  // ─────────────────────────────────────────────

  ThemeData get lightTheme => isRetroMode
      ? activeRetroTheme!.toThemeData()
      : _buildTheme(Brightness.light);

  ThemeData get darkTheme => isRetroMode
      ? activeRetroTheme!.toThemeData()
      : _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _currentTheme.primaryColor,
      brightness: brightness,
      appBarTheme: const AppBarTheme(centerTitle: true),
      fontFamily: _fontFamily,
    );

    final delta = AppFonts.getDelta(_fontFamily);
    if (delta == 0) return base;

    TextStyle? adjust(TextStyle? style, double fallback) {
      if (style == null) return null;
      return style.copyWith(fontSize: (style.fontSize ?? fallback) + delta);
    }

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge:  adjust(base.textTheme.displayLarge,  57),
        displayMedium: adjust(base.textTheme.displayMedium, 45),
        displaySmall:  adjust(base.textTheme.displaySmall,  36),
        headlineLarge: adjust(base.textTheme.headlineLarge, 32),
        headlineMedium:adjust(base.textTheme.headlineMedium,28),
        headlineSmall: adjust(base.textTheme.headlineSmall, 24),
        titleLarge:    adjust(base.textTheme.titleLarge,    22),
        titleMedium:   adjust(base.textTheme.titleMedium,   16),
        titleSmall:    adjust(base.textTheme.titleSmall,    14),
        bodyLarge:     adjust(base.textTheme.bodyLarge,     16),
        bodyMedium:    adjust(base.textTheme.bodyMedium,    14),
        bodySmall:     adjust(base.textTheme.bodySmall,     12),
        labelLarge:    adjust(base.textTheme.labelLarge,    14),
        labelMedium:   adjust(base.textTheme.labelMedium,   12),
        labelSmall:    adjust(base.textTheme.labelSmall,    11),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LOAD USER THEMES
  // ─────────────────────────────────────────────

  Future<void> loadUserThemes() async {
    try {
      _userThemes = await _themeService.getCustomThemes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading themes: $e');
    }
  }

  // ─────────────────────────────────────────────
  // INITIALIZE FROM BACKEND USER CONFIG
  //
  // The backend only stores hexColor + brightness.
  // We match against the predefined list first; if no match is found
  // we create an anonymous CustomTheme.
  // Retro themes ARE in the predefined list and will be matched by color,
  // so their paletteId will be restored correctly.
  // ─────────────────────────────────────────────

  Future<void> initializeTheme(
    String? hexColor,
    String? brightnessStr,
  ) async {
    if (hexColor == null || hexColor.isEmpty) {
      _isInitialized = true;
      return;
    }

    final color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    final brightness =
        brightnessStr == 'dark' ? Brightness.dark : Brightness.light;

    await _resolveAndApply(color: color, brightness: brightness);

    _isInitialized = true;
    notifyListeners();
  }

  void initializeFromUserConfig({
    required Color color,
    required Brightness brightness,
  }) async {
    await _resolveAndApply(color: color, brightness: brightness);
    _isInitialized = true;
    notifyListeners();
  }

  /// Matches [color]+[brightness] against all known themes (predefined + user).
  /// Falls back to an anonymous CustomTheme if no match is found.
  Future<void> _resolveAndApply({
    required Color color,
    required Brightness brightness,
  }) async {
    await loadUserThemes();

    final candidates = [...AppThemes.all, ..._userThemes];

    try {
      _currentTheme = candidates.firstWhere(
        (t) =>
            t.primaryColor.toARGB32() == color.toARGB32() &&
            t.brightness == brightness,
      );
    } catch (_) {
      // No predefined match — anonymous Material theme, no paletteId.
      _currentTheme = CustomTheme(
        id: 'custom',
        name: 'Custom',
        primaryColor: color,
        brightness: brightness,
      );
    }
  }

  // ─────────────────────────────────────────────
  // SET THEME
  // ─────────────────────────────────────────────

  Future<void> setTheme(CustomTheme theme) async {
    _currentTheme = theme;
    _isInitialized = true;
    notifyListeners();

    try {
      await _themeService.updateUserTheme(
        hexColor: theme.hexColor,
        brightness: theme.brightnessStr,
      );
    } catch (e) {
      debugPrint('Error persisting theme: $e');
    }
  }

  Future<void> saveThemeToLibrary(CustomTheme theme) async {
    try {
      await _themeService.createCustomTheme(theme);
      await setTheme(theme);
    } catch (e) {
      debugPrint('Error in saveThemeToLibrary: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  Future<void> deleteThemeFromLibrary(String themeId) async {
    try {
      await _themeService.deleteCustomTheme(themeId);
      _userThemes.removeWhere((t) => t.id == themeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting theme: $e');
    }
  }
}