import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/asset_template_model.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/screens/asset_detail_screen.dart';
import 'package:invenicum/screens/asset_template_detail_screen.dart';
import 'package:invenicum/screens/asset_template_editor_screen.dart';
import 'package:invenicum/screens/asset_templates_market_screen.dart';
import 'package:invenicum/screens/integrations_screen.dart';
import 'package:invenicum/screens/plugins_screen.dart';
import 'package:invenicum/screens/profile_screen.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/screens/achievements_screen.dart';
import 'package:provider/provider.dart';
// Models
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/models/list_data.dart';
import 'package:invenicum/models/location.dart';

// Providers
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/location_provider.dart';

// Screens
import 'package:invenicum/screens/alerts_screen.dart';
import 'package:invenicum/screens/asset_create_screen.dart';
import 'package:invenicum/screens/asset_edit_screen.dart';
import 'package:invenicum/screens/asset_import_screen.dart';
import 'package:invenicum/screens/asset_list_screen.dart';
import 'package:invenicum/screens/asset_type_create_screen.dart';
import 'package:invenicum/screens/asset_type_edit_screen.dart';
import 'package:invenicum/screens/asset_type_grid_screen.dart';
import 'package:invenicum/screens/dashboard_screen.dart';
import 'package:invenicum/screens/datalist_create_screen.dart';
import 'package:invenicum/screens/datalist_edit_screen.dart';
import 'package:invenicum/screens/datalist_grid_screen.dart';
import 'package:invenicum/screens/delivery_voucher_editor_screen.dart';
import 'package:invenicum/screens/loan_create_screen.dart';
import 'package:invenicum/screens/loans_screen.dart';
import 'package:invenicum/screens/location_create_screen.dart';
import 'package:invenicum/screens/location_edit_screen.dart';
import 'package:invenicum/screens/locations_screen.dart';
import 'package:invenicum/screens/login_screen.dart';
import 'package:invenicum/screens/preferences_screen.dart';

// Layout
import 'package:invenicum/widgets/main_layout.dart';

// Services
import 'package:invenicum/services/dashboard_service.dart';
import 'package:stac/stac.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final loggingIn = state.matchedLocation == '/login';

      // 1. 🚩 CAPTURA DE CÓDIGO GITHUB (Nivel Global)
      // Buscamos el código tanto en GoRouter como en la URL de la ventana (antes del #)
      final uri = Uri.parse(html.window.location.href);
      final String? githubCode =
          state.uri.queryParameters['code'] ?? uri.queryParameters['code'];

      // Si detectamos un código y estamos logueados, forzamos ir a perfil para procesarlo
      if (githubCode != null &&
          authProvider.isAuthenticated &&
          state.matchedLocation != '/myprofile') {
        return '/myprofile?code=$githubCode';
      }

      if (!authProvider.isAuthenticated && !loggingIn) {
        return '/login';
      }

      if (authProvider.isAuthenticated && loggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Ruta de Login fuera del Shell
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Rutas Protegidas dentro del MainLayout
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/myprofile',
            builder: (context, state) {
              // 1. Intentamos obtener el código de GoRouter (por si acaso viniera después del #)
              String? code = state.uri.queryParameters['code'];

              // 2. 🚩 SI NO ESTÁ AHÍ, lo buscamos en la URL real del navegador (antes del #)
              if (code == null) {
                final Uri uri = Uri.parse(html.window.location.href);
                code = uri.queryParameters['code'];
              }

              if (code != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final authProvider = context.read<AuthProvider>();
                  final success = await authProvider.linkGitHubAccount(code!);

                  if (success) {
                    // 3. Limpieza total: Esto eliminará el ?code= de la barra de direcciones
                    html.window.history.replaceState(null, '', '/#/myprofile');

                    ToastService.success("GitHub vinculado correctamente");
                  }
                });
              }

              return const UserProfileScreen();
            },
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(
              dashboardService: context.read<DashboardService>(),
            ),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/preferences',
            builder: (context, state) => const PreferencesScreen(),
          ),
          GoRoute(
            path: '/delivery-voucher-editor',
            builder: (context, state) => const DeliveryVoucherEditorScreen(),
          ),

          // --- CONTENEDORES / ASSET TYPES ---
          GoRoute(
            path: '/container/:containerId/asset-types',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              return AssetTypeGridScreen(containerId: containerId);
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => AssetTypeCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                ),
              ),
              GoRoute(
                path: ':assetTypeId/edit',
                builder: (context, state) => AssetTypeEditScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/achievements',
            builder: (context, state) => const Scaffold(
              // Si quieres que tenga scroll propio y padding
              body: SingleChildScrollView(
                padding: EdgeInsets.all(40.0),
                child: AchievementsCardWidget(),
              ),
            ),
          ),
          // --- INTEGRACIONES ---
          GoRoute(
            path: '/integrations',
            builder: (context, state) => IntegrationsScreen(),
          ),
          // --- TEMPLATES ---
          GoRoute(
            path: '/templates',
            builder: (context, state) => const AssetTemplatesMarketScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  // 🛡️ Verificación robusta del objeto extra
                  final Object? extra = state.extra;
                  AssetTemplate? draft;

                  if (extra is AssetTemplate) {
                    draft = extra;
                  }

                  return AssetTemplateEditorScreen(initialDraft: draft);
                },
              ),
              GoRoute(
                path: 'details/:templateId',
                builder: (context, state) {
                  // Intentamos pillar el objeto del 'extra' por eficiencia
                  final AssetTemplate? templateFromExtra =
                      state.extra as AssetTemplate?;
                  final String templateId = state.pathParameters['templateId']!;

                  return AssetTemplateDetailScreen(
                    templateId: templateId,
                    initialTemplate: templateFromExtra,
                  );
                },
              ),
            ],
          ),
          // --- PLUGINS ---
          GoRoute(
            path: '/plugins-admin',
            builder: (context, state) => const PluginAdminScreen(),
          ),
          GoRoute(
            path: '/plugins/:pluginId',
            builder: (context, state) {
              final pluginId = state.pathParameters['pluginId']!;
              final provider = context.read<PluginProvider>();

              // Buscamos el plugin en la lista de instalados del provider
              final plugin = provider.installed.firstWhere(
                (p) => p['id'] == pluginId,
                orElse: () => <String, dynamic>{},
              );

              return Scaffold(
                appBar: AppBar(title: Text(plugin['name'] ?? 'Plugin')),
                body: plugin.isEmpty
                    ? const Center(child: Text("Plugin no encontrado"))
                    : Stac(routeName: plugin['ui']),
              );
            },
          ),

          // --- ASSETS (ITEMS) ---
          GoRoute(
            path: '/container/:containerId/asset-types/:assetTypeId/assets',
            builder: (context, state) => AssetListScreen(
              containerId: state.pathParameters['containerId']!,
              assetTypeId: state.pathParameters['assetTypeId']!,
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => AssetCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                ),
              ),
              GoRoute(
                path: 'import-csv',
                builder: (context, state) => AssetImportScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                ),
              ),
              GoRoute(
                path: ':assetId',
                builder: (context, state) => AssetDetailScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                  itemId: state.pathParameters['assetId']!,
                ),
              ),
              GoRoute(
                path: ':assetId/edit',
                builder: (context, state) {
                  final item = state.extra as InventoryItem?;
                  return AssetEditScreen(
                    containerId: state.pathParameters['containerId']!,
                    assetTypeId: state.pathParameters['assetTypeId']!,
                    assetItemId: state.pathParameters['assetId']!,
                    initialItem: item,
                  );
                },
              ),
            ],
          ),

          // --- DATALISTS ---
          GoRoute(
            path: '/container/:containerId/datalists',
            builder: (context, state) => DataListGridScreen(
              containerId: state.pathParameters['containerId']!,
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => DataListCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                ),
              ),
              GoRoute(
                path: ':dataListId/edit',
                builder: (context, state) {
                  final listData = state.extra as ListData?;
                  return DataListEditScreen(
                    containerId: state.pathParameters['containerId']!,
                    dataListId: state.pathParameters['dataListId']!,
                    initialData:
                        listData!, // La pantalla debe manejar si esto es null
                  );
                },
              ),
            ],
          ),

          // --- LOCATIONS ---
          GoRoute(
            path: '/container/:containerId/locations',
            builder: (context, state) => LocationsScreen(
              containerId: state.pathParameters['containerId']!,
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => LocationCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                ),
              ),
              GoRoute(
                path: ':locationId/edit',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final locationId = int.tryParse(
                    state.pathParameters['locationId'] ?? '',
                  );

                  // Intentar obtener del extra
                  Location? location = state.extra as Location?;

                  // Fallback: Si no hay extra (ej. refresh), buscar en el provider
                  if (location == null && locationId != null) {
                    final provider = context.read<LocationProvider>();
                    try {
                      location = provider.locations.firstWhere(
                        (l) => l.id == locationId,
                      );
                    } catch (_) {
                      // Si no está, la pantalla de edición deberá cargarla por ID o mostrar error
                    }
                  }

                  return LocationEditScreen(
                    containerId: containerId,
                    location:
                        location!, // Puede ser null, la pantalla debe validarlo
                  );
                },
              ),
            ],
          ),

          // --- LOANS ---
          GoRoute(
            path: '/container/:containerId/loans',
            builder: (context, state) =>
                LoansScreen(containerId: state.pathParameters['containerId']!),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => LoanCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    // Manejo de errores de ruta no encontrada
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página no encontrada: ${state.uri}')),
    ),
  );
}
