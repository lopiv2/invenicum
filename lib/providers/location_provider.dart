// lib/providers/location_provider.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/data/services/location_service.dart';
import 'package:provider/provider.dart';

/// A Provider (ChangeNotifier) for managing Location state.
/// Uses LocationService for API communication.
class LocationProvider with ChangeNotifier {
  final LocationService _locationService;

  // State
  List<Location> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Constructor that receives the service via dependency injection
  LocationProvider(this._locationService);

  // Getters to access state
  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- CRUD and Fetch Methods ---

  /// Loads all locations for a specific container.
  /// @param containerId The container ID.
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
        debugPrint('Error loading locations: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new location and adds it to the local list.
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
      // If creation was successful, add it to local state and notify.
      return newLocation;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow; // Rethrow so the widget can handle specific errors (e.g., validation)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates a location and refreshes the local list.
  Future<Location?> updateLocation({
    required BuildContext context, // 🔑 Added BuildContext
    required int containerId, // 🔑 Added containerId for synchronization
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

      // 1. Update the local list
      final index = _locations.indexWhere((loc) => loc.id == locationId);
      if (index != -1) {
        _locations[index] = updatedLocation;
      }

      // 2. Notify ContainerProvider about the possible change in structure/count
      final containerProvider = context.read<ContainerProvider>();
      await containerProvider.loadDataLists(
        containerId,
      ); // Syncs the locations

      return updatedLocation;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a location and removes it from the local list.
  Future<void> deleteLocation(
    int locationId, {
    required int
    containerId, // 🔑 Add containerId to know which container to update
    required BuildContext context, // 🔑 Add BuildContext
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _locationService.deleteLocation(locationId);

      // Remove from local list
      _locations.removeWhere((loc) => loc.id == locationId);

      // 🔑 KEY STEP: Notify ContainerProvider about the change
      final containerProvider = context.read<ContainerProvider>();

      // Call the existing method that reloads the container's locations.
      await containerProvider.loadDataLists(
        containerId,
      ); // This updates the 'locations' list of the ContainerNode and its length.
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the location state (useful when switching containers or logging out).
  void clearState() {
    _locations = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
