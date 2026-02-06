import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/screens/asset_detail_screen.dart';
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

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final bool isAuthenticated = authProvider.isAuthenticated;
      final bool isLoggingIn = state.matchedLocation == '/login';

      // 1. Mientras se verifica el token en disco, no redirigir
      if (authProvider.isLoading) return null;

      // 2. Si NO está autenticado y no va a login, forzar login
      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // 3. Si ESTÁ autenticado e intenta ir a login o raíz, mandar a dashboard
      if (isLoggingIn || state.matchedLocation == '/') {
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
