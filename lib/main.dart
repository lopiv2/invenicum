import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/services/plugin_service.dart';
import 'package:invenicum/services/veni_chatbot_service.dart';
import 'package:provider/provider.dart';

// Localizations & Routing
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:toastification/toastification.dart';
import 'routing/app_router.dart';

// Providers
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/providers/location_provider.dart';
import 'package:invenicum/providers/theme_provider.dart';
import 'package:invenicum/providers/dashboard_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';

// Services
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/services/alert_service.dart';
import 'package:invenicum/services/asset_type_service.dart';
import 'package:invenicum/services/container_service.dart';
import 'package:invenicum/services/inventory_item_service.dart';
import 'package:invenicum/services/loan_service.dart';
import 'package:invenicum/services/location_service.dart';
import 'package:invenicum/services/theme_service.dart';
import 'package:invenicum/services/voucher_service.dart';
import 'package:invenicum/services/dashboard_service.dart';
import 'package:invenicum/services/preferences_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    BrowserContextMenu.disableContextMenu();
  }

  // 1. Inicialización previa de Auth
  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        // --- SERVICIOS (Singletons) ---
        Provider(create: (_) => ApiService()),
        Provider(create: (c) => PluginService(c.read<ApiService>())),
        Provider(create: (c) => DashboardService(c.read<ApiService>())),
        Provider(create: (c) => ThemeService(c.read<ApiService>())),
        Provider(create: (c) => PreferencesService(c.read<ApiService>())),
        Provider(create: (c) => ContainerService(c.read<ApiService>())),
        Provider(create: (c) => LocationService(c.read<ApiService>())),
        Provider(create: (c) => AssetTypeService(c.read<ApiService>())),
        Provider(create: (c) => InventoryItemService(c.read<ApiService>())),
        Provider(create: (c) => LoanService(c.read<ApiService>())),
        Provider(create: (c) => VoucherService(c.read<ApiService>())),
        Provider(create: (c) => AlertService(c.read<ApiService>())),
        // --- PROVEEDORES DE ESTADO ---

        // Auth es la raíz de la lógica
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        ChangeNotifierProxyProvider<ApiService, ChatService>(
          create: (context) => ChatService(context.read<ApiService>()),
          update: (context, api, previous) {
            // Si ya existe una instancia, simplemente la devolvemos para que no se resetee el historial
            if (previous != null) return previous;
            return ChatService(api);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, PluginProvider>(
          create: (c) => PluginProvider(c.read<PluginService>()),
          update: (context, auth, prev) {
            if (auth.isAuthenticated && auth.user != null && !auth.isLoading) {
              // 1. Inyectamos el usuario actual en el Provider para el reemplazo de {{userName}}
              prev?.updateCurrentUser(auth.user!);

              // 2. Inicializamos el SDK de Stac con el nombre del usuario para el Parser
              if (prev != null && !prev.isLoading && prev.installed.isEmpty) {
                Future.microtask(() async {
                  final pluginService = context.read<PluginService>();

                  // Pasamos el nombre al initSdk para que el InvenicumSdkParser lo tenga
                  await pluginService.initSdk(userName: auth.user!.name);

                  await prev.refresh();
                });
              }
            }
            return prev!;
          },
        ),

        // --- Dashboard ---
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (context) =>
              DashboardProvider(context.read<DashboardService>()),
          update: (context, auth, previous) {
            if (!auth.isLoading && auth.isAuthenticated) {
              // 🚩 Solo disparamos si no tenemos estadísticas aún
              if (previous != null &&
                  previous.stats == null &&
                  !previous.isLoading) {
                Future.microtask(() => previous.fetchStats());
              }
            }
            return previous!;
          },
        ),

        // --- Items ---
        ChangeNotifierProxyProvider<AuthProvider, InventoryItemProvider>(
          create: (c) => InventoryItemProvider(c.read<InventoryItemService>()),
          update: (context, auth, prev) {
            if (!auth.isLoading && auth.isAuthenticated && auth.token != null) {
              // 🚩 Añadimos la misma lógica: solo si está vacío
              if (prev != null && !prev.isLoading) {
                Future.microtask(() => prev.loadAllItemsGlobal());
              }
            }
            return prev!;
          },
        ),

        // Theme: Sincronización con perfil de usuario
        ChangeNotifierProxyProvider<AuthProvider, ThemeProvider>(
          create: (c) => ThemeProvider(c.read<ThemeService>()),
          update: (context, auth, prev) {
            if (auth.isAuthenticated &&
                auth.user?.themeConfig != null &&
                !prev!.isInitialized) {
              final config = auth.user!.themeConfig!;
              prev.setInitializing();
              prev.initializeThemeFromConfig(
                config.theme.primaryColor,
                config.theme.brightness,
              );
            }
            return prev!;
          },
        ),

        // Preferences: Carga de idioma y preferencias del usuario
        ChangeNotifierProxyProvider<AuthProvider, PreferencesProvider>(
          create: (c) => PreferencesProvider(c.read<PreferencesService>()),
          update: (context, auth, prev) {
            if (auth.isAuthenticated &&
                auth.token != null &&
                !prev!.isInitialized) {
              Future.microtask(() => prev.loadPreferences());
            }
            return prev!;
          },
        ),

        // Contenedores: Carga inicial
        ChangeNotifierProxyProvider<AuthProvider, ContainerProvider>(
          create: (c) => ContainerProvider(
            c.read<ContainerService>(),
            c.read<AssetTypeService>(),
            c.read<LocationService>(),
          ),
          update: (context, auth, prev) {
            if (auth.isAuthenticated && auth.token != null && !auth.isLoading) {
              Future.microtask(() => prev?.loadContainers());
            }
            return prev!;
          },
        ),

        // Location, Loan, Alert (Siguiendo el mismo patrón si es necesario)
        ChangeNotifierProxyProvider<AuthProvider, LocationProvider>(
          create: (c) => LocationProvider(c.read<LocationService>()),
          update: (_, auth, prev) => prev!,
        ),
        ChangeNotifierProxyProvider<AuthProvider, LoanProvider>(
          create: (c) => LoanProvider(c.read<LoanService>()),
          update: (_, auth, prev) => prev!,
        ),
        ChangeNotifierProxyProvider<AuthProvider, AlertProvider>(
          create: (c) => AlertProvider(c.read<AlertService>()),
          update: (_, auth, prev) => prev!,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // 🚩 Cambiado a StatefulWidget
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter _router; // 🚩 Guardamos la instancia aquí

  @override
  void initState() {
    super.initState();
    // Lo creamos una sola vez al iniciar la App
    // Necesitamos el AuthProvider inicial
    final authProvider = context.read<AuthProvider>();
    _router = createAppRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos Auth y Theme
    //final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = context.watch<ThemeProvider>();
    final preferencesProvider = context.watch<PreferencesProvider>();

    return ToastificationWrapper(
      child: MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        locale: preferencesProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        title: 'Invenicum',
        theme: themeProvider.themeData,
        routerConfig: _router,
        builder: (context, child) {
    // Esto asegura que FToast tenga acceso al Overlay desde la raíz
    return FToastBuilder()(context, child);
  },
      ),
    );
  }
}
