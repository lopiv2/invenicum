import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/models/list_data.dart';
import 'package:invenicum/models/location.dart';
import 'package:invenicum/providers/location_provider.dart';
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
import 'package:invenicum/screens/loans_screen.dart';
import 'package:invenicum/screens/location_create_screen.dart';
import 'package:invenicum/screens/location_edit_screen.dart';
import 'package:invenicum/screens/locations_screen.dart';
import 'package:invenicum/screens/login_screen.dart';
import 'package:invenicum/services/api_service.dart';
import 'package:invenicum/services/dashboard_service.dart';
import 'package:invenicum/widgets/main_layout.dart';
import 'package:provider/provider.dart';

final _apiService =
    ApiService(); // Asumiendo que ApiService es una clase existente
final _dashboardService = DashboardService(_apiService);

final router = GoRouter(
  initialLocation: '/login',
  // ... (redirect logic remains the same)
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      // MainLayout envuelve la ruta actual (child)
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              DashboardScreen(dashboardService: _dashboardService),
        ),

        // --- RUTAS DE GESTIÓN DE INVENTARIO ---

        // 1. Vista de Grid de Tipos de Activo (RUTA BASE / PADRE)
        GoRoute(
          path: '/container/:containerId/asset-types',
          builder: (context, state) {
            final containerId = state.pathParameters['containerId']!;
            return AssetTypeGridScreen(containerId: containerId);
          },
          routes: [
            // 1a. RUTA DE CREACIÓN DE TIPO DE ACTIVO (ANIDADA)
            // Path final: /container/:containerId/asset-types/new
            GoRoute(
              path: 'new',
              builder: (context, state) {
                final containerId = state.pathParameters['containerId']!;
                return AssetTypeCreateScreen(containerId: containerId);
              },
            ),
            // 🔑 1b. NUEVA RUTA DE EDICIÓN DE TIPO DE ACTIVO (ANIDADA)
            // Path final: /container/:containerId/asset-types/:assetTypeId/edit
            GoRoute(
              path: ':assetTypeId/edit', // Captura el ID del AssetType
              builder: (context, state) {
                final containerId = state.pathParameters['containerId']!;
                final assetTypeId = state.pathParameters['assetTypeId']!;

                // Asegúrate de haber importado AssetTypeEditScreen
                return AssetTypeEditScreen(
                  containerId: containerId,
                  assetTypeId: assetTypeId,
                );
              },
            ),
          ],
        ),

        // 2. Vista de Lista de Activos Individuales (RUTA COMPLETA)
        // La ruta se declara con el path ABSOLUTO para evitar problemas de resolución de anidación.
        // Path final: /container/:containerId/asset-types/:assetTypeId/assets
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
            // 2a. Ruta para CREAR un nuevo activo (ANIDADA)
            // Path final: /container/:containerId/asset-types/:assetTypeId/assets/new
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
            // 🔑 2b. RUTA para IMPORTAR CSV (ANIDADA)
            // Path final: .../assets/import-csv
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
              path: ':assetItemId/edit', // <-- Captura el ID del ítem
              builder: (context, state) {
                final containerId = state.pathParameters['containerId']!;
                final assetTypeId = state.pathParameters['assetTypeId']!;
                final assetItemId =
                    state.pathParameters['assetItemId']!; // <-- Nuevo ID

                // Recuperamos el objeto InventoryItem que se pasó con `extra`
                final InventoryItem? initialItem =
                    state.extra as InventoryItem?;

                // 💡 Aquí debes usar tu pantalla de edición
                return AssetEditScreen(
                  containerId: containerId,
                  assetTypeId: assetTypeId,
                  assetItemId: assetItemId,
                  initialItem:
                      initialItem, // Pasamos el ítem para pre-rellenar el formulario
                );
              },
            ),
          ],
        ),

        // 3. Vista de Listas Personalizadas
        GoRoute(
          path: '/container/:containerId/datalists',
          builder: (context, state) {
            final containerId = state.pathParameters['containerId']!;
            return DataListGridScreen(containerId: containerId);
          },
          routes: [
            // Ruta para crear nueva lista personalizada
            GoRoute(
              path: 'new',
              builder: (context, state) {
                final containerId = state.pathParameters['containerId']!;
                return DataListCreateScreen(containerId: containerId);
              },
            ),
            // Ruta para editar lista personalizada
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

        // 4. Vista de Categorías (Mantenidas)
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

        // --- RUTAS DE GESTIÓN DE INVENTARIO ---

        // 🔑 5. NUEVA RUTA DE GESTIÓN DE UBICACIONES (LOCATIONS) 📍
        GoRoute(
          path: '/container/:containerId/locations',
          builder: (context, state) {
            final containerId = state.pathParameters['containerId']!;
            // ASUME que tienes un widget llamado LocationsScreen que acepta containerId
            print('Navegando a LocationsScreen para Container ID: $containerId');
            return LocationsScreen(containerId: containerId);
            
          },
          routes: [
            GoRoute(
              // Ruta para crear una nueva ubicación
              path: 'new',
              builder: (context, state) {
                final containerId = state.pathParameters['containerId']!;
                return LocationCreateScreen(containerId: containerId);
              },
            ),
            GoRoute(
              // La ruta completa será: /container/:containerId/locations/:locationId/edit
              path: ':locationId/edit',
              builder: (context, state) {
                final containerId = state.pathParameters['containerId']!;
                final locationId = int.parse(
                  state.pathParameters['locationId']!,
                );

                // 1. Obtener el LocationProvider
                final locationProvider = context.read<LocationProvider>();

                // 2. Buscar la ubicación específica por ID en el Provider
                // Esto asume que el LocationsScreen ya cargó la lista 'locations'.
                final Location
                locationToEdit = locationProvider.locations.firstWhere(
                  (loc) => loc.id == locationId,
                  // Manejo de error si el ID no existe (puedes redirigir a una pantalla de error)
                  orElse: () {
                    // Mostrar un error y redirigir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ubicación no encontrada.')),
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

        // 🔑 6. NUEVA RUTA DE GESTIÓN DE PRÉSTAMOS (LOANS) 📑
        GoRoute(
          path: '/container/:containerId/loans',
          builder: (context, state) {
            final containerId = state.pathParameters['containerId']!;
            // ASUME que tienes un widget llamado LoansScreen que acepta containerId
            return LoansScreen(containerId: containerId);
          },
          // Puedes añadir rutas anidadas para Préstamos aquí (ej. /loans/new, /loans/:loanId)
        ),
      ],
    ),
  ],
);
