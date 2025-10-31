// lib/providers/location_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:invenicum/models/location.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/services/location_service.dart';
import 'package:provider/provider.dart';

/// Un Provider (ChangeNotifier) para manejar el estado de las Ubicaciones.
/// Utiliza LocationService para la comunicación con la API.
class LocationProvider with ChangeNotifier {
  final LocationService _locationService;

  // Estado
  List<Location> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Constructor que recibe el servicio mediante inyección de dependencia
  LocationProvider(this._locationService);

  // Getters para acceder al estado
  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Métodos de CRUD y Fetch ---

  /**
   * Carga todas las ubicaciones de un contenedor específico.
   * @param containerId El ID del contenedor.
   */
  Future<void> fetchLocations(int containerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedLocations = await _locationService.getLocations(containerId);
      _locations = loadedLocations;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (kDebugMode) {
        print('Error al cargar ubicaciones: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Crea una nueva ubicación y la añade a la lista local.
   */
  Future<Location?> createLocation({
    required BuildContext context,
    required int containerId,
    required String name,
    String? description,
    int? parentId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newLocation = await _locationService.createLocation(
        containerId: containerId,
        name: name,
        description: description,
        parentId: parentId,
      );
      await fetchLocations(containerId);
      final containerProvider = context.read<ContainerProvider>();
      await containerProvider.loadDataLists(containerId);
      // Si la creación fue exitosa, la añadimos al estado local y notificamos.
      return newLocation;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow; // Relanzar para que el widget pueda manejar errores específicos (ej. validación)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Actualiza una ubicación y refresca la lista local.
   */
  Future<Location?> updateLocation({
    required BuildContext context, // 🔑 Añadido BuildContext
    required int containerId, // 🔑 Añadido containerId para la sincronización
    required int locationId,
    required String name,
    String? description,
    int? parentId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedLocation = await _locationService.updateLocation(
        locationId: locationId,
        name: name,
        description: description ?? '',
        parentId: parentId,
      );

      // 1. Actualizar la lista local
      final index = _locations.indexWhere((loc) => loc.id == locationId);
      if (index != -1) {
        _locations[index] = updatedLocation;
      }

      // 2. Notificar al ContainerProvider sobre el posible cambio en la estructura/conteo
      final containerProvider = context.read<ContainerProvider>();
      await containerProvider.loadDataLists(
        containerId,
      ); // Sincroniza las ubicaciones

      return updatedLocation;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Elimina una ubicación y la remueve de la lista local.
   */
  Future<void> deleteLocation(
    int locationId, {
    required int
    containerId, // 🔑 Añadir containerId para saber qué contenedor actualizar
    required BuildContext context, // 🔑 Añadir BuildContext
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _locationService.deleteLocation(locationId);

      // Remover de la lista local
      _locations.removeWhere((loc) => loc.id == locationId);

      // 🔑 PASO CLAVE: Notificar al ContainerProvider sobre el cambio
      final containerProvider = context.read<ContainerProvider>();

      // Llamamos al método que ya existe y que recarga las ubicaciones del contenedor.
      await containerProvider.loadDataLists(
        containerId,
      ); // Esto actualiza la lista 'locations' del ContainerNode y su length.
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Limpia el estado de las ubicaciones (útil al cambiar de contenedor o cerrar sesión).
   */
  void clearState() {
    _locations = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
