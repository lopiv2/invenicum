import 'package:flutter/material.dart';
import 'package:invenicum/models/asset_template_model.dart';
import '../services/template_service.dart';

class TemplateProvider with ChangeNotifier {
  final TemplateService _service;

  List<AssetTemplate> _marketTemplates = [];
  List<AssetTemplate> _userLibrary = [];
  bool _isLoading = false;
  String? _errorMessage;

  TemplateProvider(this._service);

  // Getters
  List<AssetTemplate> get marketTemplates => _marketTemplates;
  List<AssetTemplate> get userLibrary => _userLibrary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. Cargar plantillas del Marketplace
  Future<void> fetchMarketTemplates() async {
    _setLoading(true);
    try {
      // El service ahora devolverá una lista ya mapeada por AssetTemplate.fromJson
      _marketTemplates = await _service.getMarketTemplates();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 2. HIDRATACIÓN: Obtener detalle completo
  Future<AssetTemplate> getTemplateById(String id) async {
    try {
      // El DTO del backend garantiza que aquí vengan los 'fields' y 'created_at'
      final templateCompleto = await _service.getTemplateById(id);

      // Actualizamos la lista local para que la UI se refresque con los datos completos
      final index = _marketTemplates.indexWhere((t) => t.id == id);
      if (index != -1) {
        _marketTemplates[index] = templateCompleto;
        notifyListeners();
      }

      return templateCompleto;
    } catch (e) {
      debugPrint("❌ Error obteniendo detalle: $e");
      rethrow;
    }
  }

  // 3. Publicar en el Market (GitHub PR)
  Future<bool> publishTemplateToMarket(AssetTemplate template) async {
    _setLoading(true);
    try {
      // El backend ahora devuelve el objeto creado procesado por el DTO
      final AssetTemplate newTemplate = await _service.publishTemplate(template);

      // En lugar de recargar todo el market, podemos insertarlo localmente
      // para dar una sensación de velocidad (Optimistic Update)
      _marketTemplates.insert(0, newTemplate);
      
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 4. Cargar biblioteca personal
  Future<void> fetchUserLibrary() async {
    _setLoading(true);
    try {
      _userLibrary = await _service.getUserLibrary();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 5. Guardar/Instalar plantilla del market
  Future<bool> saveTemplateToLibrary(AssetTemplate template) async {
    try {
      // Enviamos el objeto. El backend hará el upsert en la DB y el vínculo UserTemplate
      await _service.saveTemplateToUser(template);
      
      // Refrescamos la biblioteca para que aparezca la nueva
      await fetchUserLibrary(); 
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}