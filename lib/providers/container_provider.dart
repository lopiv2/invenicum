// providers/container_provider.dart

import 'package:flutter/foundation.dart';
import 'package:invenicum/services/container_service.dart';
import '../models/container_model.dart';

class ContainerProvider with ChangeNotifier {
  // Renombramos la variable a _containerService para mayor claridad.
  final ContainerService _containerService;

  ContainerProvider(this._containerService); // Recibe el ContainerService

  // 1. La variable de estado privada que almacena los datos
  List<ContainerNode> _containers = [];
  bool _isLoading = false;

  // 2. Getters públicos
  List<ContainerNode> get containers => _containers;
  bool get isLoading => _isLoading;

  // --- Lógica de Obtener Contenedores ---
  Future<void> loadContainers() async {
  _isLoading = true;
  notifyListeners(); // 1. Muestra la carga

  try {
    final loadedContainers = await _containerService.getContainers();
    _containers = loadedContainers;
  } catch (e) {
    print('Error al cargar contenedores: $e');
  } finally {
    _isLoading = false;
    notifyListeners(); // 2. Oculta la carga y muestra la lista (ya sea nueva o la antigua si falló).
  }
}

  // --- Lógica de Crear Contenedor ---
  Future<ContainerNode?> createNewContainer(
    String name,
    String? description,
  ) async {
    try {
      final newContainer = await _containerService.createContainer(name, description);
      await loadContainers();

      return newContainer;
    } catch (e) {
      print('Error al crear contenedor: $e');
      // Es vital que si el try falla, el error se propague para que el Sidebar lo maneje.
      rethrow; 
    }
  }
}
