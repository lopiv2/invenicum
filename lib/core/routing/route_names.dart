// lib/core/routing/route_names.dart
//
// Single source of truth for GoRouter route names.
// Always use these constants instead of literal strings when navigating.
// If you rename a route here, the compiler will flag all broken usages.

abstract class RouteNames {
  // ── Authentication (outside Shell) ───────────────────────────────────────
  static const login           = 'login';
  static const setup           = 'setup';

  // ── Profile and account ─────────────────────────────────────────────────
  static const myProfile       = 'myProfile';

  // ── Main navigation ─────────────────────────────────────────────────────
  static const dashboard       = 'dashboard';
  static const alerts          = 'alerts';
  static const preferences     = 'preferences';    // path: /preferences
  static const reports         = 'reports';
  static const voucherEditor   = 'voucherEditor';
  static const achievements    = 'achievements';
  static const integrations    = 'integrations';

  // ── Templates ────────────────────────────────────────────────────────────
  static const templates       = 'templates';
  static const templateCreate  = 'templateCreate'; // nested: templates/create
  static const templateDetail  = 'templateDetail'; // nested: templates/details/:templateId

  // ── Plugins ──────────────────────────────────────────────────────────────
  static const plugins         = 'plugins';        // path: /plugins-admin
  static const pluginDetail    = 'pluginDetail';   // path: /plugins/:pluginId

  // ── Asset Types ──────────────────────────────────────────────────────────
  static const assetTypes      = 'assetTypes';
  static const assetTypeCreate = 'assetTypeCreate';
  static const assetTypeEdit   = 'assetTypeEdit';

  // ── Assets (inventory items) ─────────────────────────────────────────────
  static const assetList       = 'assetList';
  static const assetCreate     = 'assetCreate';
  static const assetDetail     = 'assetDetail';
  static const assetEdit       = 'assetEdit';
  static const assetImport     = 'assetImport';

  // ── DataLists ────────────────────────────────────────────────────────────
  static const dataLists       = 'dataLists';
  static const dataListCreate  = 'dataListCreate';
  static const dataListEdit    = 'dataListEdit';

  // ── Locations ────────────────────────────────────────────────────────────
  static const locations       = 'locations';
  static const locationCreate  = 'locationCreate';
  static const locationEdit    = 'locationEdit';

  // ── Loans ────────────────────────────────────────────────────────────────
  static const loans           = 'loans';
  static const loanCreate      = 'loanCreate';
}