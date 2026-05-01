import 'package:flutter/material.dart';
import 'package:invenicum/screens/home/first_run_screen.dart';
import 'package:web/web.dart' as html;
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/models/asset_template_model.dart';
import 'package:invenicum/data/models/store_plugin_model.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/screens/assets/asset_detail_screen.dart';
import 'package:invenicum/screens/templates/asset_template_detail_screen.dart';
import 'package:invenicum/screens/templates/asset_template_editor_screen.dart';
import 'package:invenicum/screens/templates/asset_templates_market_screen.dart';
import 'package:invenicum/screens/integrations/integrations_screen.dart';
import 'package:invenicum/screens/plugins/plugins_screen.dart';
import 'package:invenicum/screens/home/profile_screen.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/screens/achievements/achievements_screen.dart';
import 'package:provider/provider.dart';
// Models
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'package:invenicum/data/models/location.dart';

// Providers
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/first_run_provider.dart'; // 🆕
import 'package:invenicum/providers/location_provider.dart';

// Screens
import 'package:invenicum/screens/alerts/alerts_screen.dart';
import 'package:invenicum/screens/assets/asset_create_screen.dart';
import 'package:invenicum/screens/assets/asset_edit_screen.dart';
import 'package:invenicum/screens/assets/asset_import_screen.dart';
import 'package:invenicum/screens/assets/asset_list_screen.dart';
import 'package:invenicum/screens/asset_types/asset_type_create_screen.dart';
import 'package:invenicum/screens/asset_types/asset_type_edit_screen.dart';
import 'package:invenicum/screens/asset_types/asset_type_grid_screen.dart';
import 'package:invenicum/screens/home/dashboard_screen.dart';
import 'package:invenicum/screens/datalists/datalist_create_screen.dart';
import 'package:invenicum/screens/datalists/datalist_edit_screen.dart';
import 'package:invenicum/screens/datalists/datalist_grid_screen.dart';
import 'package:invenicum/screens/preferences/delivery_voucher_editor_screen.dart';
import 'package:invenicum/screens/loans/loan_create_screen.dart';
import 'package:invenicum/screens/loans/loans_screen.dart';
import 'package:invenicum/screens/locations/location_create_screen.dart';
import 'package:invenicum/screens/locations/location_edit_screen.dart';
import 'package:invenicum/screens/locations/locations_screen.dart';
import 'package:invenicum/screens/home/login_screen.dart';
import 'package:invenicum/screens/preferences/preferences_screen.dart';
import 'package:invenicum/screens/reports/reports_screen.dart';
import 'package:invenicum/l10n/app_localizations.dart';

// Layout
import 'package:invenicum/widgets/layout/main_layout.dart';
import 'package:invenicum/core/routing/route_names.dart';

// Services
import 'package:invenicum/data/services/dashboard_service.dart';
import 'package:stac/stac.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Also receives [firstRunProvider] so the router can
/// listen to it and react when the check finishes.
GoRouter createAppRouter(
  AuthProvider authProvider,
  FirstRunProvider firstRunProvider, // 🆕
) {
  return GoRouter(
    // 🆕 We listen to both providers: when either one notifies a change,
    // GoRouter re-evaluates the redirect automatically.
    refreshListenable: Listenable.merge([authProvider, firstRunProvider]),
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final firstRunProvider = context.read<FirstRunProvider>(); // 🆕

      // ── 1. WAIT UNTIL BOTH CHECKS FINISH ──────────────────────────────────
      // While AuthProvider is loading the token from disk OR
      // FirstRunProvider still doesn't know whether users exist, do nothing.
      if (authProvider.isLoading || firstRunProvider.isChecking) return null;

      // ── 2. FIRST RUN: redirect to setup before anything else ───────────────
      // If the backend says there are no users, send to setup
      // regardless of whether there is a token or not.
      final isSetupRoute = state.matchedLocation == '/setup';
      if (firstRunProvider.isFirstRun) {
        // Avoid loop: if we're already on /setup, do not redirect.
        return isSetupRoute ? null : '/setup';
      }

      // From here on, the backend has users -> normal flow.

      final isAuthenticated = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      // ── 3. GITHUB LOGIC ───────────────────────────────────────────────────
      final uri = Uri.parse(html.window.location.href);
      final String? githubCode =
          state.uri.queryParameters['code'] ?? uri.queryParameters['code'];
      if (githubCode != null &&
          isAuthenticated &&
          state.matchedLocation != '/myprofile') {
        return '/myprofile?code=$githubCode';
      }

      // ── 4. ROUTE PROTECTION ───────────────────────────────────────────────
      // Public routes that should never be stored as redirectTo destination.
      // /setup is included because after markAsComplete() the router re-evaluates
      // with matchedLocation='/setup' and isAuthenticated=false - without this
      // guard it would generate redirectTo=/setup and send the user back
      // to the wizard right after logging in.
      final isPublicRoute = isLoggingIn || isSetupRoute;

      if (!isAuthenticated && !isPublicRoute) {
        final fromLocation = state.uri.toString();
        return '/login?redirectTo=${Uri.encodeComponent(fromLocation)}';
      }

      // If already logged in and going to login, send to dashboard (or QR)
      if (isAuthenticated && isLoggingIn) {
        final redirectTo = state.uri.queryParameters['redirectTo'];
        return redirectTo ?? '/dashboard';
      }

      return null;
    },
    routes: [
      // ── Public routes (outside Shell) ────────────────────────────────────
      GoRoute(name: RouteNames.login, path: '/login', builder: (context, state) => const LoginScreen()),

      // 🆕 First-run setup screen
      GoRoute(
        name: RouteNames.setup,
        path: '/setup',
        builder: (context, state) => const FirstRunSetupScreen(),
      ),

      // ── Protected routes inside MainLayout ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            name: RouteNames.myProfile,
            path: '/myprofile',
            builder: (context, state) {
              String? code = state.uri.queryParameters['code'];
              if (code == null) {
                final Uri uri = Uri.parse(html.window.location.href);
                code = uri.queryParameters['code'];
              }

              if (code != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final authProvider = context.read<AuthProvider>();
                  final success = await authProvider.linkGitHubAccount(code!);
                  if (success) {
                    html.window.history.replaceState(null, '', '/#/myprofile');
                    ToastService.success("GitHub vinculado correctamente");
                  }
                });
              }

              return const UserProfileScreen();
            },
          ),
          GoRoute(
            name: RouteNames.dashboard,
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(
              dashboardService: context.read<DashboardService>(),
            ),
          ),
          GoRoute(
            name: RouteNames.alerts,
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            name: RouteNames.preferences,
            path: '/preferences',
            builder: (context, state) => const PreferencesScreen(),
          ),
          GoRoute(
            name: RouteNames.reports,
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            name: RouteNames.voucherEditor,
            path: '/delivery-voucher-editor',
            builder: (context, state) => const DeliveryVoucherEditorScreen(),
          ),

          // --- CONTAINERS / ASSET TYPES ---
          GoRoute(
            name: RouteNames.assetTypes,
            path: '/container/:containerId/asset-types',
            builder: (context, state) {
              final containerId = state.pathParameters['containerId']!;
              return AssetTypeGridScreen(containerId: containerId);
            },
            routes: [
              GoRoute(
                name: RouteNames.assetTypeCreate,
                path: 'new',
                builder: (context, state) => AssetTypeCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                ),
              ),
              GoRoute(
                name: RouteNames.assetTypeEdit,
                path: ':assetTypeId/edit',
                builder: (context, state) => AssetTypeEditScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            name: RouteNames.achievements,
            path: '/achievements',
            builder: (context, state) => const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(40.0),
                child: AchievementsCardWidget(),
              ),
            ),
          ),
          GoRoute(
            name: RouteNames.integrations,
            path: '/integrations',
            builder: (context, state) => IntegrationsScreen(),
          ),
          GoRoute(
            name: RouteNames.templates,
            path: '/templates',
            builder: (context, state) => const AssetTemplatesMarketScreen(),
            routes: [
              GoRoute(
                name: RouteNames.templateCreate,
                path: 'create',
                builder: (context, state) {
                  final Object? extra = state.extra;
                  AssetTemplate? draft;
                  if (extra is AssetTemplate) {
                    draft = extra;
                  }
                  return AssetTemplateEditorScreen(initialDraft: draft);
                },
              ),
              GoRoute(
                name: RouteNames.templateDetail,
                path: 'details/:templateId',
                builder: (context, state) {
                  final AssetTemplate? templateFromExtra =
                      state.extra as AssetTemplate?;
                  final String templateId =
                      state.pathParameters['templateId']!;
                  return AssetTemplateDetailScreen(
                    templateId: templateId,
                    initialTemplate: templateFromExtra,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: RouteNames.plugins,
            path: '/plugins-admin',
            builder: (context, state) => const PluginAdminScreen(),
          ),
          GoRoute(
            name: RouteNames.pluginDetail,
            path: '/plugins/:pluginId',
            builder: (context, state) {
              final pluginId = state.pathParameters['pluginId']!;
              final provider = context.watch<PluginProvider>();
              final plugin = provider.installed.firstWhere(
                (p) => p.id == pluginId,
                orElse: () => StorePlugin(
                  id: '',
                  name: '',
                  author: '',
                  version: '',
                  description: '',
                  slot: '',
                ),
              );
              final processedUi = provider.getProcessedUi(plugin.ui!);
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(
                appBar: AppBar(title: Text(plugin.name)),
                body: Stac.fromJson(processedUi, context) ??
                    Center(child: Text(l10n.pluginLoadError)),
              );
            },
          ),

          // --- ASSETS (ITEMS) ---
          GoRoute(
            name: RouteNames.assetList,
            path: '/container/:containerId/asset-types/:assetTypeId/assets',
            builder: (context, state) => AssetListScreen(
              containerId: state.pathParameters['containerId']!,
              assetTypeId: state.pathParameters['assetTypeId']!,
            ),
            routes: [
              GoRoute(
                name: RouteNames.assetCreate,
                path: 'new',
                builder: (context, state) => AssetCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                ),
              ),
              GoRoute(
                name: RouteNames.assetImport,
                path: 'import-csv',
                builder: (context, state) => AssetImportScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                ),
              ),
              GoRoute(
                name: RouteNames.assetDetail,
                path: ':assetId',
                builder: (context, state) => AssetDetailScreen(
                  containerId: state.pathParameters['containerId']!,
                  assetTypeId: state.pathParameters['assetTypeId']!,
                  itemId: state.pathParameters['assetId']!,
                ),
              ),
              GoRoute(
                name: RouteNames.assetEdit,
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
            name: RouteNames.dataLists,
            path: '/container/:containerId/datalists',
            builder: (context, state) => DataListGridScreen(
              containerId: state.pathParameters['containerId']!,
            ),
            routes: [
              GoRoute(
                name: RouteNames.dataListCreate,
                path: 'new',
                builder: (context, state) => DataListCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                ),
              ),
              GoRoute(
                name: RouteNames.dataListEdit,
                path: ':dataListId/edit',
                builder: (context, state) {
                  final listData = state.extra as ListData?;
                  return DataListEditScreen(
                    containerId: state.pathParameters['containerId']!,
                    dataListId: state.pathParameters['dataListId']!,
                    initialData: listData!,
                  );
                },
              ),
            ],
          ),

          // --- LOCATIONS ---
          GoRoute(
            name: RouteNames.locations,
            path: '/container/:containerId/locations',
            builder: (context, state) => LocationsScreen(
              containerId: state.pathParameters['containerId']!,
            ),
            routes: [
              GoRoute(
                name: RouteNames.locationCreate,
                path: 'new',
                builder: (context, state) => LocationCreateScreen(
                  containerId: state.pathParameters['containerId']!,
                ),
              ),
              GoRoute(
                name: RouteNames.locationEdit,
                path: ':locationId/edit',
                builder: (context, state) {
                  final containerId = state.pathParameters['containerId']!;
                  final locationId = int.tryParse(
                    state.pathParameters['locationId'] ?? '',
                  );
                  Location? location = state.extra as Location?;
                  if (location == null && locationId != null) {
                    final provider = context.read<LocationProvider>();
                    try {
                      location =
                          provider.locations.firstWhere((l) => l.id == locationId);
                    } catch (_) {}
                  }
                  return LocationEditScreen(
                    containerId: containerId,
                    location: location!,
                  );
                },
              ),
            ],
          ),

          // --- LOANS ---
          GoRoute(
            name: RouteNames.loans,
            path: '/container/:containerId/loans',
            builder: (context, state) => LoansScreen(
              containerId: state.pathParameters['containerId']!,
            ),
            routes: [
              GoRoute(
                name: RouteNames.loanCreate,
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
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(child: Text(l10n.pageNotFoundUri(state.uri.toString()))),
      );
    },
  );
}