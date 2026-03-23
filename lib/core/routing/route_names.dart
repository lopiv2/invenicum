// lib/core/routing/route_names.dart
//
// Fuente de verdad única para los nombres de ruta de GoRouter.
// Usar siempre estas constantes en lugar de strings literales al navegar.
// Si renombras una ruta aquí, el compilador señalará todos los usos rotos.

abstract class RouteNames {
  // ── Autenticación (fuera del Shell) ───────────────────────────────────────
  static const login           = 'login';
  static const setup           = 'setup';

  // ── Perfil y cuenta ───────────────────────────────────────────────────────
  static const myProfile       = 'myProfile';

  // ── Navegación principal ──────────────────────────────────────────────────
  static const dashboard       = 'dashboard';
  static const alerts          = 'alerts';
  static const preferences     = 'preferences';    // path: /preferences
  static const reports         = 'reports';
  static const voucherEditor   = 'voucherEditor';
  static const achievements    = 'achievements';
  static const integrations    = 'integrations';

  // ── Templates ─────────────────────────────────────────────────────────────
  static const templates       = 'templates';
  static const templateCreate  = 'templateCreate'; // nested: templates/create
  static const templateDetail  = 'templateDetail'; // nested: templates/details/:templateId

  // ── Plugins ───────────────────────────────────────────────────────────────
  static const plugins         = 'plugins';        // path: /plugins-admin
  static const pluginDetail    = 'pluginDetail';   // path: /plugins/:pluginId

  // ── Asset Types ───────────────────────────────────────────────────────────
  static const assetTypes      = 'assetTypes';
  static const assetTypeCreate = 'assetTypeCreate';
  static const assetTypeEdit   = 'assetTypeEdit';

  // ── Assets (ítems de inventario) ──────────────────────────────────────────
  static const assetList       = 'assetList';
  static const assetCreate     = 'assetCreate';
  static const assetDetail     = 'assetDetail';
  static const assetEdit       = 'assetEdit';
  static const assetImport     = 'assetImport';

  // ── DataLists ─────────────────────────────────────────────────────────────
  static const dataLists       = 'dataLists';
  static const dataListCreate  = 'dataListCreate';
  static const dataListEdit    = 'dataListEdit';

  // ── Locations ─────────────────────────────────────────────────────────────
  static const locations       = 'locations';
  static const locationCreate  = 'locationCreate';
  static const locationEdit    = 'locationEdit';

  // ── Loans ─────────────────────────────────────────────────────────────────
  static const loans           = 'loans';
  static const loanCreate      = 'loanCreate';
}