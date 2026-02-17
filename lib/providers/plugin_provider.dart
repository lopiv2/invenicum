import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:invenicum/models/user_data_model.dart';
import 'package:invenicum/services/plugin_service.dart';
import 'package:invenicum/services/toast_service.dart';

class PluginProvider extends ChangeNotifier {
  final PluginService _service;
  UserData? _currentUser;

  PluginProvider(this._service);

  List<Map<String, dynamic>> _installed = [];
  List<Map<String, dynamic>> _community = [];

  bool _isLoading = false;

  // Getters
  List<Map<String, dynamic>> get installed => _installed;
  List<Map<String, dynamic>> get community => _community;
  bool get isLoading => _isLoading;

  // 📥 Solo los que instalé de la comunidad (No son míos)
  List<Map<String, dynamic>> get installedFromStore =>
      _installed.where((p) => p['isMine'] == false).toList();

  List<Map<String, dynamic>> get myCreatedPlugins =>
      _installed.where((p) => p['isMine'] == true).toList();

  List<Map<String, dynamic>> get activeInstalled =>
      _installed.where((p) => p['isActive'] ?? true).toList();

  // --- LÓGICA DE TIENDA Y COMUNIDAD (UNIFICADA) ---

  /// Ya no necesitas refreshStore() separado, ahora todo viene en refresh()
  /// Pero si quieres un método específico para la pestaña comunidad:
  Future<void> loadCommunity() async {
    try {
      _community = await _service.getCommunityPlugins();
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando comunidad: $e");
    }
  }

  /// Compara un plugin de la comunidad con los instalados localmente
  String getStorePluginStatus(String id, String? version) {
    // Buscamos si el ID de la comunidad existe en nuestra lista de instalados
    final localPlugin = _installed.firstWhere(
      (p) => p['id'].toString() == id.toString(),
      orElse: () => {},
    );

    if (localPlugin.isEmpty) return "Instalar";

    // Opcional: Si quieres manejar actualizaciones de versión
    if (version != null && localPlugin['version'] != version) {
      return "Actualizar";
    }

    return "Instalado";
  }

  Future<Map<String, dynamic>> downloadPluginStac(String url) async {
    return await _service.downloadPluginStac(url);
  }

  /// 🚩 ANTES: installFromStore (Descargaba de GitHub)
  /// 🚩 AHORA: Simplemente llama al backend con el objeto del plugin
  Future<void> install(Map<String, dynamic> plugin) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Le mandamos el objeto completo.
      // El backend decidirá si es oficial (GitHub) o de la DB local.
      await _service.installPlugin(plugin);
      await Future.delayed(const Duration(seconds: 1));
      await refresh(force: true); // Actualiza las listas localmente
      ToastService.success("${plugin['name']} instalado");
    } catch (e) {
      debugPrint("❌ Error instalando: $e");
      ToastService.error("Fallo al instalar el plugin");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- GESTIÓN DE ESTADO Y DATOS ---

  Future<void> togglePluginStatus(String id, bool status) async {
    final index = _installed.indexWhere((p) => p['id'].toString() == id);
    if (index == -1) return;

    final originalStatus = _installed[index]['isActive'];
    _installed[index]['isActive'] = status;
    notifyListeners();

    try {
      await _service.toggleUserPlugin(id, status);
      ToastService.success(status ? "Plugin activado" : "Plugin desactivado");
    } catch (e) {
      _installed[index]['isActive'] = originalStatus;
      notifyListeners();
      ToastService.error("Error al cambiar estado");
    }
  }

  Future<void> refresh({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;

    // Solo notificamos al inicio si no es un refresh forzado por otra acción
    if (!force) notifyListeners();

    try {
      await _service.initSdk(userName: _currentUser?.name);

      final nuevosInstalados = await _service.getMyPlugins();
      final nuevosComunidad = await _service.getCommunityPlugins();

      // 1. Actualizamos instalados (contiene tanto comunidad como propios)
      _installed = nuevosInstalados;

      // 2. 🚩 FILTRO DE UNICIDAD PARA COMUNIDAD
      // Esto permite presencia dual: si el plugin está en instalados,
      // sigue apareciendo en comunidad pero solo UNA vez.
      final idsVistos = <String>{};
      _community = nuevosComunidad.where((p) {
        final id = p['id'].toString();
        return idsVistos.add(id);
      }).toList();

      debugPrint(
        "✅ Sincronizado: Total=${_installed.length}, Mios=${myCreatedPlugins.length}, Tienda=${_community.length}",
      );
    } catch (e) {
      debugPrint("Error refrescando plugins: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CRUD PARA AUTORES ---

  Future<void> savePlugin(Map<String, dynamic> pluginData) async {
    try {
      // Si no tiene ID, es una creación nueva
      if (pluginData['id'] == null || pluginData['id'].toString().isEmpty) {
        // Generamos un ID amigable o dejamos que el back lo haga
        pluginData['id'] = pluginData['name']
            .toString()
            .toLowerCase()
            .replaceAll(' ', '_');
      }

      await _service.createPlugin(pluginData);
      await refresh(force: true);
      ToastService.success("¡Plugin creado y guardado!");
    } catch (e) {
      ToastService.error("Error al crear el plugin");
    }
  }

  Future<void> uninstall(String pluginId) async {
    try {
      await _service.uninstallPlugin(pluginId);
      await refresh();
      ToastService.success("Plugin desinstalado");
    } catch (e) {
      ToastService.error("Error al desinstalar");
    }
  }

  Future<void> deletePlugin(
    String pluginId, {
    bool deleteFromGitHub = false,
  }) async {
    try {
      // 1. Pasamos el flag al servicio (necesitarás actualizar el servicio también)
      await _service.deletePlugin(pluginId, deleteFromGitHub);

      // 2. Refrescamos la lista local
      await refresh();

      // 3. Feedback personalizado
      if (deleteFromGitHub) {
        ToastService.success("Eliminado de la base de datos y de GitHub");
      } else {
        ToastService.success("Eliminado globalmente");
      }
    } catch (e) {
      ToastService.error("No se pudo eliminar");
      debugPrint("Error al eliminar plugin: $e");
    }
  }

  // --- UTILIDADES ---

  void updateCurrentUser(UserData user) {
    _currentUser = user;
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
}
