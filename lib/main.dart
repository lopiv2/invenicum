import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/providers/location_provider.dart';
import 'package:invenicum/services/alert_service.dart';
import 'package:invenicum/services/asset_type_service.dart';
import 'package:invenicum/services/container_service.dart';
import 'package:invenicum/services/inventory_item_service.dart';
import 'package:invenicum/services/loan_service.dart';
import 'package:invenicum/services/location_service.dart';
import 'package:invenicum/services/voucher_service.dart';
import 'routing/app_router.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    BrowserContextMenu.disableContextMenu();
  }

  // 2. Crea el AuthProvider manualmente antes de lanzar la app
  final authProvider = AuthProvider();
  
  // 3. ESPERA a que se verifique la sesión persistente
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        // --- PROVEEDORES DE SERVICIO (SIN ESTADO) ---
        Provider(create: (_) => ApiService()),
        Provider(
            create: (context) => ContainerService(context.read<ApiService>())),
        Provider(
            create: (context) => LocationService(context.read<ApiService>())),
        Provider(
            create: (context) => AssetTypeService(context.read<ApiService>())),
        Provider(
            create: (context) =>
                InventoryItemService(context.read<ApiService>())),
        Provider(create: (context) => LoanService(context.read<ApiService>())),
        Provider(
            create: (context) => VoucherService(context.read<ApiService>())),
        Provider(create: (context) => AlertService(context.read<ApiService>())),

        // --- PROVEEDORES DE ESTADO (CON NOTIFIERS) ---

        // 1. AuthProvider es el principal y no depende de nadie
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),

        // 2. Los demás providers dependen de AuthProvider.
        // Se reconstruirán si AuthProvider notifica cambios.
        ChangeNotifierProxyProvider<AuthProvider, ContainerProvider>(
          create: (context) => ContainerProvider(
            context.read<ContainerService>(),
            context.read<AssetTypeService>(),
            context.read<LocationService>(),
          ),
          update: (context, auth, previousProvider) {
            // Cuando 'auth' cambia, podemos reaccionar aquí.
            // Por ejemplo, si el usuario inicia sesión, podríamos cargar datos.
            if (auth.isAuthenticated) {
              previousProvider?.loadContainers();
            }
            return previousProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, LocationProvider>(
          create: (context) =>
              LocationProvider(context.read<LocationService>()),
          update: (context, auth, previousProvider) {
            if (auth.isAuthenticated) {
              // Asumiendo que LocationProvider tiene un método similar
              // previousProvider?.loadLocations();
            }
            return previousProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, InventoryItemProvider>(
          create: (context) =>
              InventoryItemProvider(context.read<InventoryItemService>()),
          update: (context, auth, previousProvider) {
            // Lógica similar si es necesario
            return previousProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, LoanProvider>(
          create: (context) => LoanProvider(context.read<LoanService>()),
          update: (context, auth, previousProvider) {
            if (auth.isAuthenticated) {
              // previousProvider?.loadLoans();
            }
            return previousProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AlertProvider>(
          create: (context) => AlertProvider(context.read<AlertService>()),
          update: (context, auth, previousProvider) {
            if (auth.isAuthenticated) {
              // previousProvider?.loadAlerts();
            }
            return previousProvider!;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // El AuthProvider ahora es el mismo que se creó en main()
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp.router(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: FToastBuilder(),
      debugShowCheckedModeBanner: false,
      title: 'Invenicum',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Pasamos la instancia correcta al router
      routerConfig: createAppRouter(authProvider),
    );
  }
}


