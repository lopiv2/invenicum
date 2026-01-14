import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/models/list_data.dart';
import 'package:invenicum/models/location.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/location_provider.dart';
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
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/services/dashboard_service.dart';
import 'package:invenicum/widgets/main_layout.dart';
import 'package:provider/provider.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  final _apiService = ApiService();
  final _dashboardService = DashboardService(_apiService);

  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final bool isAuthenticated = authProvider.isAuthenticated;
      final bool isLoggingIn = state.matchedLocation == '/login';

      // Si está cargando el estado inicial (checkAuthStatus), no hacemos nada aún
      if (authProvider.isLoading) return null;

      // 1. Si NO está autenticado y NO está en el login -> Mandar a login
      if (!isAuthenticated && !isLoggingIn) return '/login';

      // 2. Si ESTÁ autenticado e intenta ir a login o a la raíz -> Mandar a dashboard
      if (isAuthenticated && (isLoggingIn || state.matchedLocation == '/')) {
        return '/dashboard';
      }

      // En cualquier otro caso (está en dashboard, configuración, etc.), permitir
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) =>
                DashboardScreen(dashboardService: _dashboardService),
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
          GoRoute(
            path: '/container/:containerId/asset-types',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              return AssetTypeGridScreen(containerId: containerId);
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  return AssetTypeCreateScreen(containerId: containerId);
                },
              ),
              GoRoute(
                path: ':assetTypeId/edit',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final assetTypeId = state.pathParameters['assetTypeId']!;
                  return AssetTypeEditScreen(
                    containerId: containerId,
                    assetTypeId: assetTypeId,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/container/:containerId/asset-types/:assetTypeId/assets',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              final assetTypeId = state.pathParameters['assetTypeId']!;
              return AssetListScreen(
                containerId: containerId,
                assetTypeId: assetTypeId,
              );
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final assetTypeId = state.pathParameters['assetTypeId']!;
                  return AssetCreateScreen(
                    containerId: containerId,
                    assetTypeId: assetTypeId,
                  );
                },
              ),
              GoRoute(
                path: 'import-csv',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final assetTypeId = state.pathParameters['assetTypeId']!;
                  return AssetImportScreen(
                    containerId: containerId,
                    assetTypeId: assetTypeId,
                  );
                },
              ),
              GoRoute(
                path: ':assetItemId/edit',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final assetTypeId = state.pathParameters['assetTypeId']!;
                  final assetItemId = state.pathParameters['assetItemId']!;
                  final InventoryItem? initialItem =
                      state.extra as InventoryItem?;
                  return AssetEditScreen(
                    containerId: containerId,
                    assetTypeId: assetTypeId,
                    assetItemId: assetItemId,
                    initialItem: initialItem,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/container/:containerId/datalists',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              return DataListGridScreen(containerId: containerId);
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  return DataListCreateScreen(containerId: containerId);
                },
              ),
              GoRoute(
                path: ':dataListId/edit',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final dataListId = state.pathParameters['dataListId']!;
                  final initialData = state.extra as ListData;
                  return DataListEditScreen(
                    containerId: containerId,
                    dataListId: dataListId,
                    initialData: initialData,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/container/:containerId/categories',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              return Center(
                child: Text(
                  'Gestión de Categorías para Contenedor ID: $containerId',
                ),
              );
            },
          ),
          GoRoute(
            path: '/container/:containerId/locations',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              print(
                'Navegando a LocationsScreen para Container ID: $containerId',
              );
              return LocationsScreen(containerId: containerId);
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  return LocationCreateScreen(containerId: containerId);
                },
              ),
              GoRoute(
                path: ':locationId/edit',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final locationId = int.parse(
                    state.pathParameters['locationId']!,
                  );
                  final locationProvider = context.read<LocationProvider>();
                  final Location
                  locationToEdit = locationProvider.locations.firstWhere(
                    (loc) => loc.id == locationId,
                    orElse: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ubicación no encontrada.'),
                        ),
                      );
                      throw Exception(
                        'Location ID $locationId not found in the Provider list.',
                      );
                    },
                  );
                  return LocationEditScreen(
                    containerId: containerId,
                    location: locationToEdit,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/container/:containerId/loans',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              return LoansScreen(containerId: containerId);
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  return LoanCreateScreen(containerId: containerId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
