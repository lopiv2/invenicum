import 'package:flutter/material.dart';
import 'package:invenicum/services/theme_service.dart';
import '../models/custom_theme_model.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService;

  // Flag para evitar múltiples cargas innecesarias desde el ProxyProvider
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ThemeProvider(this._themeService);

  // 1. Temas Predefinidos e Identidad de Marca
  static final CustomTheme brandTheme = CustomTheme(
    id: 'brand',
    name: 'Invenicum (Marca)',
    primaryColor: const Color(0xFF1A237E),
    brightness: Brightness.light,
  );

  static final List<CustomTheme> predefinedThemes = [
    CustomTheme(id: 'emerald', name: 'Esmeralda', primaryColor: Colors.teal),
    CustomTheme(id: 'sunset', name: 'Atardecer', primaryColor: Colors.orange),
    CustomTheme(id: 'ocean', name: 'Océano Índico', primaryColor: Colors.blue),
    CustomTheme(
      id: 'lavender',
      name: 'Lavanda Dulce',
      primaryColor: Colors.purple.shade300,
    ),
    CustomTheme(
      id: 'forest',
      name: 'Bosque Profundo',
      primaryColor: Colors.green.shade900,
    ),
    CustomTheme(id: 'cherry', name: 'Cereza', primaryColor: Colors.redAccent),
    CustomTheme(
      id: 'indigo',
      name: 'Noche Eléctrica',
      primaryColor: Colors.indigoAccent,
    ),
    CustomTheme(id: 'amber', name: 'Oro Ámbar', primaryColor: Colors.amber),
    CustomTheme(
      id: 'sakura',
      name: 'Flor de Cerezo',
      primaryColor: Colors.pink.shade200,
    ),
    CustomTheme(
      id: 'slate',
      name: 'Pizarra Moderna',
      primaryColor: Colors.blueGrey.shade700,
    ),
    CustomTheme(
      id: 'cyberpunk',
      name: 'Cyberpunk',
      primaryColor: Colors.pinkAccent,
      brightness: Brightness.dark,
    ),
    CustomTheme(
      id: 'nordic',
      name: 'Ártico Nord',
      primaryColor: Colors.lightBlue.shade100,
      brightness: Brightness.light,
    ),
    CustomTheme(
      id: 'dark_mode',
      name: 'Noche Profunda',
      primaryColor: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
  ];
  List<CustomTheme> _userThemes = [];
  List<CustomTheme> get userThemes => _userThemes;

  CustomTheme _currentTheme = brandTheme;
  CustomTheme get currentTheme => _currentTheme;

  // 2. Generación dinámica del ThemeData
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _currentTheme.primaryColor,
      brightness: _currentTheme.brightness,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }

  setInitializing() {
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
      // Filtramos la lista local para que desaparezca de la UI inmediatamente
      _userThemes.removeWhere((t) => t.id == themeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar tema: $e');
    }
  }

  /// Inicializa el tema desde los datos del usuario (llamado por el ProxyProvider)
  void initializeTheme(String? hexColor, String? brightnessStr) async {
    if (hexColor == null || hexColor.isEmpty) {
      _isInitialized = true;
      return;
    }

    final colorValue = int.parse(hexColor.replaceFirst('#', '0xFF'));
    final brightness = brightnessStr == 'dark'
        ? Brightness.dark
        : Brightness.light;

    // 1. Primero cargamos los temas personalizados de la DB
    await loadUserThemes();

    // 2. Creamos una lista con TODOS los temas posibles para buscar
    final allPossibleThemes = [
      brandTheme,
      ...predefinedThemes,
      ..._userThemes, // Temas cargados de la DB
    ];

    try {
      // 3. Buscamos si el color y brillo coinciden con alguno que tenga nombre
      _currentTheme = allPossibleThemes.firstWhere(
        (t) => t.primaryColor.value == colorValue && t.brightness == brightness,
      );
    } catch (_) {
      // 4. Si realmente no existe en ningún lado, queda como Personalizado
      _currentTheme = CustomTheme(
        id: 'custom_db',
        name: 'Personalizado',
        primaryColor: Color(colorValue),
        brightness: brightness,
      );
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Cambia el tema localmente y lo persiste en la tabla vinculada de la DB
  Future<void> setTheme(CustomTheme theme) async {
    _currentTheme = theme; // Cambiamos el objeto en memoria
    _isInitialized = true;

    notifyListeners(); // 🚩 Esto es lo que hace que Flutter repinte la App

    try {
      // Esto actualiza la tabla UserThemeConfig en el backend
      final String hexColor =
          '#${theme.primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
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
      // 1. Guardamos en la biblioteca (la tabla de temas guardados)
      await _themeService.createCustomTheme(theme);

      // 2. IMPORTANTE: También lo establecemos como tema actual
      // Esto llamará a setTheme() que actualiza UserThemeConfig y hace el notifyListeners()
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
    // 1. Cargamos los temas de la biblioteca del usuario
    await loadUserThemes();

    // 2. Metemos todos los temas en una bolsa para buscar
    final allPossibleThemes = [
      brandTheme,
      ...predefinedThemes,
      ..._userThemes, // Estos son los que acabamos de cargar de la DB
    ];

    try {
      // 3. Buscamos el tema que coincida en color y brillo
      _currentTheme = allPossibleThemes.firstWhere(
        (t) =>
            t.primaryColor.value == color.value && t.brightness == brightness,
      );
    } catch (_) {
      // 4. Si no existe, lo dejamos como personalizado
      _currentTheme = CustomTheme(
        id: 'db_theme',
        name: 'Personalizado',
        primaryColor: color,
        brightness: brightness,
      );
    }

    _isInitialized = true;
    notifyListeners();
  }
}
