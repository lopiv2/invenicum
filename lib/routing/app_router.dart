import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/screens/asset_type_create_screen.dart';
import 'package:invenicum/screens/asset_type_grid_screen.dart';
import 'package:invenicum/screens/dashboard_screen.dart';
import 'package:invenicum/screens/login_screen.dart';
import 'package:invenicum/widgets/main_layout.dart';

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
          builder: (context, state) => const DashboardScreen(),
        ),

        // --- RUTAS DE GESTIÓN DE INVENTARIO ---

        // 1. Vista de Grid de Tipos de Activo
        // Cuando se hace clic en 'Activos' en la Sidebar.
        GoRoute(
          path: '/container/:containerId/asset-types',
          builder: (context, state) {
            final containerId = state.pathParameters['containerId']!;
            return AssetTypeGridScreen(containerId: containerId);
          },
          routes: [
            // 1a. RUTA DE CREACIÓN DE TIPO DE ACTIVO
            // Path relativo a '/container/:containerId/asset-types'
            GoRoute(
              path:
                  'new', // Esto se resuelve a /container/:containerId/asset-types/new
              builder: (context, state) {
                final containerId = state.pathParameters['containerId']!;
                return AssetTypeCreateScreen(containerId: containerId);
              },
            ),
          ],
        ),

        // 2. Vista de Lista de Activos Individuales
        // Cuando se hace clic en un Tipo de Activo del grid (ej: 'Ordenadores').
        GoRoute(
          path: '/container/:containerId/asset-types/:assetTypeId/assets',
          builder: (context, state) {
            final containerId = state.pathParameters['containerId']!;
            final assetTypeId = state.pathParameters['assetTypeId']!;

            return Center(
              child: Text(
                'Activos de Tipo $assetTypeId en Contenedor $containerId',
              ),
            );

            // return AssetListScreen(containerId: containerId, assetTypeId: assetTypeId);
          },
        ),

        // 3. Vista de Listas Personalizadas
        GoRoute(
          path: '/container/:containerId/datalists',
          builder: (context, state) {
            final containerId = state.pathParameters['containerId']!;
            return Center(
              child: Text('Gestión de Listas para Contenedor ID: $containerId'),
            );
          },
        ),

        // 4. Vista de Categorías
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
      ],
    ),
  ],
);
