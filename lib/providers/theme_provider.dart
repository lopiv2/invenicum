import 'package:flutter/material.dart';
import 'package:invenicum/data/services/theme_service.dart';
import '../data/models/custom_theme_model.dart';
import '../core/utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService;

  // Flag to prevent multiple unnecessary loads from ProxyProvider
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ThemeProvider(this._themeService);

  CustomTheme get brandTheme => AppThemes.brand;
  List<CustomTheme> get predefinedThemes => AppThemes.predefined;
  List<CustomTheme> _userThemes = [];
  List<CustomTheme> get userThemes => _userThemes;

  String? _fontFamily;
  double _getDelta(String? fontFamily) => AppFonts.getDelta(fontFamily);

  CustomTheme _currentTheme = AppThemes.brand;
  CustomTheme get currentTheme => _currentTheme;

  void setFontFamily(String? fontFamily) {
    _fontFamily = fontFamily == 'Default' ? null : fontFamily;
    notifyListeners();
  }

  // 2. Dynamic ThemeData generation
  ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  TextStyle? _adjustSize(
    TextStyle? style,
    double delta, [
    double fallback = 14,
  ]) {
    return style?.copyWith(fontSize: (style.fontSize ?? fallback) + delta);
  }

  // Private method to avoid code duplication
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

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge:  _adjustSize(base.textTheme.displayLarge,  delta, 57),
      displayMedium: _adjustSize(base.textTheme.displayMedium, delta, 45),
      displaySmall:  _adjustSize(base.textTheme.displaySmall,  delta, 36),
      headlineLarge: _adjustSize(base.textTheme.headlineLarge, delta, 32),
      headlineMedium:_adjustSize(base.textTheme.headlineMedium,delta, 28),
      headlineSmall: _adjustSize(base.textTheme.headlineSmall, delta, 24),
      titleLarge:    _adjustSize(base.textTheme.titleLarge,    delta, 22),
      titleMedium:   _adjustSize(base.textTheme.titleMedium,   delta, 16),
      titleSmall:    _adjustSize(base.textTheme.titleSmall,    delta, 14),
      bodyLarge:     _adjustSize(base.textTheme.bodyLarge,     delta, 16),
      bodyMedium:    _adjustSize(base.textTheme.bodyMedium,    delta, 14),
      bodySmall:     _adjustSize(base.textTheme.bodySmall,     delta, 12),
      labelLarge:    _adjustSize(base.textTheme.labelLarge,    delta, 14),
      labelMedium:   _adjustSize(base.textTheme.labelMedium,   delta, 12),
      labelSmall:    _adjustSize(base.textTheme.labelSmall,    delta, 11),
    ),
  );
}

  void setInitializing() {
    _isInitialized = true;
  }

  Future<void> loadUserThemes() async {
    try {
      _userThemes = await _themeService.getCustomThemes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando temas: $e');
    }
  }

  Future<void> deleteThemeFromLibrary(String themeId) async {
    try {
      await _themeService.deleteCustomTheme(themeId);
      // We filter the local list so it disappears from the UI immediately
      _userThemes.removeWhere((t) => t.id == themeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar tema: $e');
    }
  }

  // Initialice the theme based on the user's saved configuration (called by ProxyProvider)
  void initializeTheme(String? hexColor, String? brightnessStr) async {
    if (hexColor == null || hexColor.isEmpty) {
      _isInitialized = true;
      return;
    }

    final colorValue = int.parse(hexColor.replaceFirst('#', '0xFF'));
    final brightness = brightnessStr == 'dark'
        ? Brightness.dark
        : Brightness.light;

    // 1. First load custom themes from the DB
    await loadUserThemes();

    // 2. Create a list with ALL possible themes for searching
    final allPossibleThemes = [
      AppThemes.brand,
      ...AppThemes.predefined,
      ..._userThemes, // Themes loaded from the DB
    ];

    try {
      // 3. Check if color and brightness match any named theme
      _currentTheme = allPossibleThemes.firstWhere(
        (t) =>
            t.primaryColor.toARGB32() == colorValue &&
            t.brightness == brightness,
      );
    } catch (_) {
      // 4. If it truly doesn't exist anywhere, it remains as Custom
      _currentTheme = CustomTheme(
        id: 'custom_db',
        name: 'Custom',
        primaryColor: Color(colorValue),
        brightness: brightness,
      );
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Changes the theme locally and persists it in the linked DB table
  Future<void> setTheme(CustomTheme theme) async {
    _currentTheme = theme; // Change the object in memory
    _isInitialized = true;

    notifyListeners(); // 🚩 This is what makes Flutter repaint the App

    try {
      // This updates the UserThemeConfig table in the backend
      final String hexColor =
          '#${theme.primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      await _themeService.updateUserTheme(
        hexColor: hexColor,
        brightness: theme.brightness == Brightness.dark ? 'dark' : 'light',
      );
    } catch (e) {
      debugPrint('Error persistiendo preferencia: $e');
    }
  }

  Future<void> saveThemeToLibrary(CustomTheme theme) async {
    try {
      // 1. Save to the library (the table of saved themes)
      await _themeService.createCustomTheme(theme);

      // 2. IMPORTANT: We also set it as the current theme
      // This will call setTheme() which updates UserThemeConfig and triggers notifyListeners()
      Future.delayed(Duration.zero).then((_) async => await setTheme(theme));
    } catch (e) {
      debugPrint('Error en saveThemeToLibrary: $e');
      rethrow;
    }
  }

  // lib/providers/theme_provider.dart

  Future<void> initializeThemeFromConfig(
    Color color,
    Brightness brightness,
  ) async {
    // 1. Load themes from the user's library
    await loadUserThemes();

    // 2. Put all themes in a bag for searching
    final allPossibleThemes = [
      AppThemes.brand,
      ...AppThemes.predefined,
      ..._userThemes, // These are the ones we just loaded from the DB
    ];

    try {
      // 3. Find the theme that matches color and brightness
      _currentTheme = allPossibleThemes.firstWhere(
        (t) =>
            t.primaryColor.toARGB32() == color.toARGB32() &&
            t.brightness == brightness,
      );
    } catch (_) {
      // 4. If it doesn't exist, leave it as Custom
      _currentTheme = CustomTheme(
        id: 'db_theme',
        name: 'Custom',
        primaryColor: color,
        brightness: brightness,
      );
    }

    _isInitialized = true;
    notifyListeners();
  }
}
