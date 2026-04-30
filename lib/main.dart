import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/services/asset_print_service.dart';
import 'package:invenicum/providers/achievement_provider.dart';
import 'package:invenicum/providers/first_run_provider.dart'; // 🆕
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/providers/template_provider.dart';
import 'package:invenicum/data/services/achievements_service.dart';
import 'package:invenicum/data/services/integrations_service.dart';
import 'package:invenicum/data/services/plugin_service.dart';
import 'package:invenicum/data/services/template_service.dart';
import 'package:invenicum/data/services/veni_chatbot_service.dart';
import 'package:provider/provider.dart';

// Localizations & Routing
import 'package:invenicum/l10n/app_localizations.dart';
import 'core/routing/app_router.dart';

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
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/data/services/alert_service.dart';
import 'package:invenicum/data/services/asset_type_service.dart';
import 'package:invenicum/data/services/container_service.dart';
import 'package:invenicum/data/services/inventory_item_service.dart';
import 'package:invenicum/data/services/loan_service.dart';
import 'package:invenicum/data/services/location_service.dart';
import 'package:invenicum/data/services/theme_service.dart';
import 'package:invenicum/data/services/voucher_service.dart';
import 'package:invenicum/data/services/dashboard_service.dart';
import 'package:invenicum/data/services/preferences_service.dart';
import 'package:invenicum/data/services/report_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Servicios base que deben estar listos antes del primer frame ────────
  final apiService = ApiService();
  await apiService.initializeToken(); // carga el JWT del disco a memoria

  // ── 2. Comprobación de primer uso (una sola petición al backend) ───────────
  // Se hace ANTES del runApp para que el router ya tenga el resultado
  // en su primer redirect y no haya ningún flash de pantalla incorrecta.
  final firstRunProvider = FirstRunProvider(apiService);
  await firstRunProvider.check();

  // ── 3. AuthProvider (sin cambios respecto a tu código original) ───────────
  // tokenAlreadyInitialized: true porque ya llamamos apiService.initializeToken()
  // arriba. Así AuthProvider no lo repite y _initialize() solo emite
  // un notifyListeners() al terminar, evitando evaluaciones del redirect
  // con estado a medias que causaban el loop setup→login→setup.
  final authProvider = AuthProvider(tokenAlreadyInitialized: true);

  runApp(
    MultiProvider(
      providers: [
        // --- SERVICIOS (Singletons) ---
        // 🆕 Usamos .value para exponer la instancia ya creada arriba
        Provider<ApiService>.value(value: apiService),
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
        Provider(create: (c) => IntegrationService(c.read<ApiService>())),
        Provider(create: (c) => TemplateService(c.read<ApiService>())),
        Provider(create: (c) => AchievementService(c.read<ApiService>())),
        Provider(create: (c) => ReportService(c.read<ApiService>())),
        Provider(create: (c) => AssetPrintService(c.read<ApiService>())),

        // --- PROVEEDORES DE ESTADO ---

        // 🆕 FirstRunProvider: expuesto para que el router y la pantalla de
        // setup puedan llamar a .check() de nuevo tras crear el primer usuario.
        ChangeNotifierProvider<FirstRunProvider>.value(value: firstRunProvider),

        // Auth es la raíz de la lógica de sesión
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        ChangeNotifierProxyProvider<ApiService, ChatService>(
          create: (context) => ChatService(context.read<ApiService>()),
          update: (context, api, previous) {
            if (previous != null) return previous;
            return ChatService(api);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, PluginProvider>(
          create: (c) => PluginProvider(c.read<PluginService>()),
          update: (context, auth, prev) {
            if (auth.isAuthenticated && auth.user != null && !auth.isLoading) {
              prev?.updateCurrentUser(auth.user!);
              if (prev != null && !prev.isLoading && prev.installed.isEmpty) {
                Future.microtask(() async {
                  final pluginService = context.read<PluginService>();
                  await pluginService.initSdk(userName: auth.user!.name);
                  await prev.refresh();
                });
              }
            }
            return prev!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, IntegrationProvider>(
          create: (c) => IntegrationProvider(c.read<IntegrationService>()),
          update: (context, auth, prev) {
            if (auth.isAuthenticated && auth.token != null && !auth.isLoading) {
              if (prev != null && prev.statuses.isEmpty && !prev.isLoading) {
                Future.microtask(() => prev.loadStatuses());
              }
            }
            return prev!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TemplateProvider>(
          create: (context) =>
              TemplateProvider(context.read<TemplateService>()),
          update: (context, auth, previous) {
            if (auth.isAuthenticated && auth.token != null && !auth.isLoading) {
              if (previous != null &&
                  previous.marketTemplates.isEmpty &&
                  !previous.isLoading) {
                Future.microtask(() {
                  previous.fetchMarketTemplates();
                });
              }
            }
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (context) =>
              DashboardProvider(context.read<DashboardService>()),
          update: (context, auth, previous) {
            // 🚩 Añadida comprobación de token y estado de carga
            if (auth.isAuthenticated && auth.token != null && !auth.isLoading) {
              if (previous != null &&
                  previous.stats == null &&
                  !previous.isLoading) {
                Future.microtask(() => previous.fetchStats());
              }
            }
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, InventoryItemProvider>(
          create: (c) => InventoryItemProvider(
            c.read<InventoryItemService>(),
            c.read<AssetPrintService>(),
          ),
          update: (context, auth, prev) {
            if (!auth.isLoading && auth.isAuthenticated && auth.token != null) {
              if (prev != null && !prev.isLoading) {
                Future.microtask(() => prev.loadAllItemsGlobal());
              }
            }
            return prev!;
          },
        ),
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
        ChangeNotifierProxyProvider<AuthProvider, ContainerProvider>(
          create: (c) => ContainerProvider(
            c.read<ContainerService>(),
            c.read<AssetTypeService>(),
            c.read<LocationService>(),
          ),
          update: (context, auth, prev) {
            // 🚩 Ahora solo pide contenedores si el token es válido
            if (auth.isAuthenticated && auth.token != null && !auth.isLoading) {
              if (prev != null && !prev.isLoading && prev.containers.isEmpty) {
                Future.microtask(() => prev.loadContainers());
              }
            }
            return prev!;
          },
        ),
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
        ChangeNotifierProxyProvider<AuthProvider, AchievementProvider>(
          create: (c) => AchievementProvider(c.read<AchievementService>()),
          update: (context, auth, prev) {
            // 🚩 Protección añadida
            if (auth.isAuthenticated && auth.token != null && !auth.isLoading) {
              if (prev != null &&
                  prev.achievements.isEmpty &&
                  !prev.isLoading) {
                Future.microtask(() => prev.fetchAchievements(context));
              }
            }
            return prev!;
          },
        ),
      ],
      child: MyApp(
        authProvider: authProvider,
        firstRunProvider: firstRunProvider,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  final FirstRunProvider firstRunProvider; // 🆕

  const MyApp({
    super.key,
    required this.authProvider,
    required this.firstRunProvider,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    // 🆕 Pasamos ambos providers al router
    _router = createAppRouter(widget.authProvider, widget.firstRunProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final preferencesProvider = context.watch<PreferencesProvider>();
    // Determinamos el modo de tema
    ThemeMode currentMode;
    if (preferencesProvider.useSystemTheme) {
      currentMode = ThemeMode.system;
    } else {
      currentMode = preferencesProvider.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
    }

    return MaterialApp.router(
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
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: currentMode,
      routerConfig: _router,
      builder: (context, child) {
        return FToastBuilder()(context, child);
      },
    );
  }
}
