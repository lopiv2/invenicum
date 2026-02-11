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
    final localPlugin = _installed.firstWhere(
      (p) => p['id'].toString() == id.toString(),
      orElse: () => {},
    );

    if (localPlugin.isEmpty) return "Instalar";

    // Si el plugin de la comunidad tiene una versión distinta a la que tengo
    if (version != null && localPlugin['version'] != version) {
      return "Actualizar";
    }

    return "Instalado";
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
      
      await refresh(); // Actualiza las listas localmente
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

  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.initSdk(userName: _currentUser?.name);

      // Traemos las dos listas del backend
      _installed = await _service.getMyPlugins();
      _community = await _service.getCommunityPlugins();
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
      if (pluginData.containsKey('id') && pluginData['id'] != null) {
        await _service.updatePlugin(pluginData);
      } else {
        await _service.createPlugin(pluginData);
      }
      await refresh();
      ToastService.success("Guardado correctamente");
    } catch (e) {
      ToastService.error("Error al guardar");
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

  Future<void> deletePlugin(String pluginId) async {
    try {
      await _service.deletePlugin(pluginId);
      await refresh();
      ToastService.success("Eliminado globalmente");
    } catch (e) {
      ToastService.error("No se pudo eliminar");
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