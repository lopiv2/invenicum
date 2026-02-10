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

  List<Map<String, dynamic>> get installed => _installed;
  List<Map<String, dynamic>> get community => _community;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get activeInstalled =>
      _installed.where((p) => p['isActive'] ?? true).toList();

  /// Método para alternar el estado sin desinstalar
  Future<void> togglePluginStatus(String pluginId, bool status) async {
    try {
      // 1. Actualización local inmediata (Optimistic UI)
      final index = _installed.indexWhere((p) => p['id'] == pluginId);
      if (index == -1) return;

      // 2. Modificamos el dato
      _installed[index]['isActive'] = status;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      try {
        await _service.toggleUserPlugin(pluginId, status);

        ToastService.success(status ? "Plugin activado" : "Plugin desactivado");
      } catch (e) {
        // Si falla, revertimos y notificamos
        _installed[index]['isActive'] = !status;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error toggling plugin: $e");
      ToastService.error("No se pudo cambiar el estado del plugin");

      // Revertir cambio local si falla el servidor
      await refresh();
    }
  }

  void updateCurrentUser(UserData user) {
    _currentUser = user;
    // No llamamos a notifyListeners aquí para evitar bucles infinitos en el Proxy
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

  /// Carga inicial de datos llamando al servicio
  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.initSdk(userName: _currentUser?.name);

      // El backend ahora devuelve 'isActive' dentro del objeto del plugin en 'getMyPlugins'
      _installed = await _service.getMyPlugins();
      _community = await _service.getCommunityPlugins();
    } catch (e) {
      debugPrint("Error cargando plugins: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePlugin(Map<String, dynamic> pluginData) async {
    try {
      if (pluginData.containsKey('id')) {
        await _service.updatePlugin(pluginData);
      } else {
        await _service.createPlugin(pluginData);
      }
      // Tras guardar (especialmente si es edición del autor), refrescamos
      await refresh();
    } catch (e) {
      debugPrint("Error al guardar plugin: $e");
      ToastService.error("Error al guardar");
    }
  }

  Future<void> install(String pluginId) async {
    try {
      await _service.installPlugin(pluginId);
      // Tras instalar, el plugin viene con isActive: true por defecto de la DB
      await refresh();
      ToastService.success("Plugin instalado");
    } catch (e) {
      debugPrint("Error: $e");
      ToastService.error("Error al instalar");
    }
  }

  Future<void> uninstall(String pluginId) async {
    try {
      await _service.uninstallPlugin(pluginId);
      // Limpiamos localmente antes del refresh para feedback instantáneo
      _installed.removeWhere((p) => p['id'].toString() == pluginId);
      notifyListeners();

      await refresh();
      ToastService.success("Plugin desinstalado");
    } catch (e) {
      debugPrint("Error al desinstalar: $e");
      ToastService.error("Error al desinstalar");
    }
  }

  Future<void> deletePlugin(String pluginId) async {
    try {
      // 1. Llamada a la API para borrar de la DB
      await _service.deletePlugin(pluginId);

      // 2. Limpieza local instantánea:
      // Lo eliminamos de la lista de comunidad si estaba allí
      _community.removeWhere((p) => p['id'] == pluginId);

      // Lo eliminamos de la lista de instalados (por si el autor lo tenía puesto)
      _installed.removeWhere((p) => p['id'] == pluginId);

      // 3. Notificar a los widgets para que se reconstruyan sin el plugin
      notifyListeners();

      ToastService.success("Plugin eliminado globalmente");
    } catch (e) {
      debugPrint("Error al borrar: $e");
      ToastService.error("No se pudo eliminar el plugin");
    }
  }
}
