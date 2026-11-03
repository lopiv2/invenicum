import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/service_l10n.dart';
import 'package:invenicum/data/models/store_plugin_model.dart';
import 'package:invenicum/data/models/user_data_model.dart';
import 'package:invenicum/data/services/plugin_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class PluginProvider extends ChangeNotifier {
  final PluginService _service;
  UserData? _currentUser;

  PluginProvider(this._service);

  /// Localizations resolved from the global navigator context.
  /// Null only when the app tree is not built yet (in which case
  /// toasts could not be displayed anyway).
  AppLocalizations? get _l10n => serviceL10n();

  List<StorePlugin> _installed = [];
  List<StorePlugin> _community = [];
  bool _isLoading = false;

  // --- GETTERS ---
  List<StorePlugin> get installed => _installed;
  List<StorePlugin> get community => _community;
  bool get isLoading => _isLoading;

  List<StorePlugin> get installedFromStore =>
      _installed.where((p) => !p.isMine).toList();
  List<StorePlugin> get myCreatedPlugins =>
      _installed.where((p) => p.isMine).toList();
  List<StorePlugin> get activeInstalled =>
      _installed.where((p) => p.isActive).toList();

  // --- LÓGICA DE TIENDA Y ESTADO ---

  /// Compara un plugin de la comunidad con los instalados localmente (Recuperado)
  String getStorePluginStatus(
    AppLocalizations l10n,
    String id,
    String? version,
  ) {
    final localPlugin = _installed.firstWhere(
      (p) => p.id == id,
      orElse: () => StorePlugin(
        id: '',
        name: '',
        author: '',
        version: '',
        description: '',
        slot: '',
      ),
    );

    if (localPlugin.id.isEmpty) return l10n.pluginStatusInstall;

    // Si las versiones no coinciden, permite actualizar
    if (version != null && localPlugin.version != version) {
      return l10n.pluginStatusUpdate;
    }

    return l10n.pluginStatusInstalled;
  }

  // --- ACCIONES CORE ---

  Future<void> refresh({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    if (!force) notifyListeners();

    try {
      // Usamos el handle de github del usuario para la identidad global
      final String? githubUser = _currentUser?.githubHandle;

      final nuevosInstaladosRaw = await _service.getMyPlugins();
      final nuevosComunidadRaw = await _service.getCommunityPlugins();

      _installed = nuevosInstaladosRaw
          .map(
            (p) => StorePlugin.fromJson(
              p,
              currentUserGithub: githubUser,
              l10n: _l10n,
            ),
          )
          .toList();

      final idsVistos = <String>{};
      _community = nuevosComunidadRaw
          .map(
            (p) => StorePlugin.fromJson(
              p,
              currentUserGithub: githubUser,
              l10n: _l10n,
            ),
          )
          .where((p) => idsVistos.add(p.id))
          .toList();

      debugPrint(
        "✅ Sincronizado: ${_installed.length} instalados, ${_community.length} en comunidad",
      );
    } catch (e) {
      debugPrint("❌ Error refrescando plugins: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// CASO A: El usuario es el autor y quiere cambiar el nombre/UI/metadatos (EDITAR)
  Future<void> editMyPluginMetadata(StorePlugin plugin) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Definimos qué campos enviamos al backend (limpieza para Joi)
      final Map<String, dynamic> data = {
        "name": plugin.name,
        "description": plugin.description,
        "slot": plugin.slot,
        "ui": plugin.ui,
        "version": plugin.version,
        "isPublic": plugin.isPublic,
      };

      // El backend recibirá esto y gestionará el PR si el autor no coincide
      await _service.updatePlugin(plugin.id, data);

      await refresh(force: true);
      final l10n0 = _l10n;
      if (l10n0 != null) ToastService.success(l10n0.pluginChangesSent);
    } catch (e) {
      final l10n1 = _l10n;
      if (l10n1 != null) ToastService.error(l10n1.pluginEditError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// CASO B: El usuario pulsa el botón naranja "Actualizar" del Market (ACTUALIZAR VERSIÓN)
  /// No importa si no es el autor, porque lo que hace es una "re-instalación"
  Future<void> updateFromStore(StorePlugin plugin) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Al usar el método install (POST /install), el backend hace un upsert
      // en la tabla UserPlugin y actualiza la relación del usuario con la nueva versión.
      final Map<String, dynamic> updateData = plugin.toJson();
      updateData['version'] = plugin.latestVersion; // Forzamos la nueva versión

      await _service.installPlugin(updateData);
      // 2. Actualización OPTIMISTA:
      // Buscamos el plugin en nuestra lista local y le subimos la versión ya mismo
      final index = _installed.indexWhere((p) => p.id == plugin.id);
      if (index != -1) {
        _installed[index] = plugin.copyWith(
          version: plugin.latestVersion,
          hasUpdate: false, // Ya no hay actualización pendiente
        );
        notifyListeners(); // 🚀 La UI se actualiza AQUÍ instantáneamente
      }

      await refresh(force: true);
      final l10n2 = _l10n;
      if (l10n2 != null) {
        ToastService.success(
          l10n2.pluginUpdatedToVersion(plugin.latestVersion),
        );
      }
    } catch (e) {
      final l10n3 = _l10n;
      if (l10n3 != null) ToastService.error(l10n3.pluginUpdateDownloadFailed);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> install(StorePlugin plugin) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.installPlugin(plugin.toJson());
      await Future.delayed(const Duration(milliseconds: 800));
      _installed = [];
      await refresh(force: true);
      final l10n4 = _l10n;
      if (l10n4 != null) {
        ToastService.success(l10n4.pluginInstalledWithName(plugin.name));
      }
    } catch (e) {
      final l10n5 = _l10n;
      if (l10n5 != null) ToastService.error(l10n5.pluginInstallFailed);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Desinstala un plugin (Recuperado)
  Future<void> uninstall(String pluginId) async {
    try {
      await _service.uninstallPlugin(pluginId);
      await refresh(force: true);
      final l10n6 = _l10n;
      if (l10n6 != null) ToastService.success(l10n6.pluginUninstalled);
    } catch (e) {
      final l10n7 = _l10n;
      if (l10n7 != null) ToastService.error(l10n7.pluginUninstallError);
    }
  }

  Future<void> togglePluginStatus(String id, bool status) async {
    final index = _installed.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final original = _installed[index];
    _installed[index] = original.copyWith(
      isActive: status,
      version: '',
      hasUpdate: false,
    );
    notifyListeners();

    try {
      await _service.toggleUserPlugin(id, status);
      final l10n8 = _l10n;
      if (l10n8 != null) {
        ToastService.success(
          status ? l10n8.pluginActivated : l10n8.pluginDeactivated,
        );
      }
    } catch (e) {
      _installed[index] = original;
      notifyListeners();
      final l10n9 = _l10n;
      if (l10n9 != null) ToastService.error(l10n9.pluginStatusChangeError);
    }
  }

  // --- CRUD AUTOR ---

  Future<void> savePlugin(Map<String, dynamic> data) async {
    try {
      if (data['id'] == null || data['id'].toString().isEmpty) {
        data['id'] = data['name'].toString().toLowerCase().replaceAll(' ', '_');
      }
      await _service.createPlugin(data);
      await refresh(force: true);
      final l10n10 = _l10n;
      if (l10n10 != null) ToastService.success(l10n10.pluginSaved);
    } catch (e) {
      final l10n11 = _l10n;
      if (l10n11 != null) ToastService.error(l10n11.pluginSaveError);
    }
  }

  Future<void> deletePlugin(String id, {bool deleteFromGitHub = false}) async {
    try {
      await _service.deletePlugin(id, deleteFromGitHub);
      await refresh(force: true);
      final l10n12 = _l10n;
      if (l10n12 != null) ToastService.success(l10n12.pluginDeletedGlobally);
    } catch (e) {
      final l10n13 = _l10n;
      if (l10n13 != null) ToastService.error(l10n13.pluginDeleteFailed);
    }
  }

  // --- UTILIDADES ---

  void updateCurrentUser(UserData user) {
    _currentUser = user;
    notifyListeners();
    // No refrescamos automáticamente aquí para evitar bucles,
    // lo llamamos desde el init de la app o login
  }

  Map<String, dynamic> getProcessedUi(Map<String, dynamic> ui) {
    if (_currentUser == null) return ui;
    try {
      String raw = jsonEncode(ui);
      raw = raw.replaceAll('{{userName}}', _currentUser!.name);
      return jsonDecode(raw);
    } catch (e) {
      return ui;
    }
  }

  Future<Map<String, dynamic>> downloadPluginStac(String url) async {
    return await _service.downloadPluginStac(url);
  }

  Future<void> loadCommunity() => refresh(force: true);
}
