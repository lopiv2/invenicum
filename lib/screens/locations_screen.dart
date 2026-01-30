import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphview/GraphView.dart';
import 'package:invenicum/models/location.dart';
import 'package:invenicum/providers/location_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/utils/location_graph_builder.dart';
import 'package:invenicum/widgets/location_card_content.dart';
import 'package:provider/provider.dart';

class LocationsScreen extends StatefulWidget {
  final String containerId;
  const LocationsScreen({super.key, required this.containerId});
  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen>
    with TickerProviderStateMixin {
  GraphViewController _controller = GraphViewController();
  final Random r = Random();
  List<Location> _lastLocations = [];
  int nextNodeId = 1;

  // --- LÓGICA DE NAVEGACIÓN Y ACCIONES ---

  void _addLocation() {
    context.go('/container/${widget.containerId}/locations/new');
  }

  void _editLocation(int locationId) {
    context.go('/container/${widget.containerId}/locations/$locationId/edit');
  }

  void _deleteLocation(int locationId, String locationName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la ubicación "$locationName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _performDeletion(locationId);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeletion(int locationId) async {
    final provider = context.read<LocationProvider>();

    try {
      await provider.deleteLocation(locationId, containerId: int.parse(widget.containerId), context: context);

      if (mounted) {
        ToastService.success('Ubicación eliminada exitosamente.');
        _loadLocations();
      }
    } catch (e) {
      if (mounted) {
        ToastService.error('Error al eliminar la ubicación: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final isLoading = locationProvider.isLoading;
    final errorMessage = locationProvider.errorMessage;
    final locations = locationProvider.locations;
    final theme = Theme.of(context); // 🎨 Tu tema personalizado
    final Map<int, Location> locationMap = {
      for (var loc in locations) loc.id: loc,
    };
    // 1. Manejar el estado de Carga Inicial
    if (isLoading && locations.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent, // 👈 Deja ver el fondo del MainLayout
        body: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      );
    }
    // 2. Manejar el estado de Error
    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Esquema de Ubicaciones')),
        body: Center(
          child: Text(
            'Error al cargar ubicaciones: $errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    // 3. Manejar el estado Sin Datos
    if (locations.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Esquema de Ubicaciones'),
          backgroundColor: theme.colorScheme.surfaceContainer,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_location_alt),
              onPressed: _addLocation,
              tooltip: 'Añadir Nueva Ubicación',
            ),
          ],
        ),
        body: const Center(
          child: Text(
            'No hay ubicaciones creadas en este contenedor. ¡Añade la primera!',
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Esquema de Ubicaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadLocations,
            tooltip: 'Recargar Ubicaciones',
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _resetView,
            tooltip: 'Centrar Vista',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _controller.zoomToFit,
            tooltip: 'Acercar Vista',
          ),
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: _addLocation,
            tooltip: 'Añadir Nueva Ubicación',
          ),
        ],
      ),

      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (isLoading) const LinearProgressIndicator(),
          // Configuration controls
          Expanded(
            child: GraphView.builder(
              controller: _controller,
              graph: graph,
              algorithm: algorithm,
              centerGraph: true,
              initialNode: ValueKey(1),
              panAnimationDuration: Duration(milliseconds: 750),
              toggleAnimationDuration: Duration(milliseconds: 750),
              builder: (Node node) => InkWell(
                onTap: () => _selectNode(node, node.key!.value as int),
                child: _locationNodeBuilder(node, locationMap),
              ),
            ),
          ),
          if (_selectedLocation != null) _buildActionPanel(),
        ],
      ),
    );
  }

  Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  late final algorithm = TidierTreeLayoutAlgorithm(
    builder,
    TreeEdgeRenderer(builder),
  );
  int? _selectedLocationId;
  Location? get _selectedLocation {
    if (_selectedLocationId == null) return null;
    // Usamos firstWhere con orElse para devolver null si no lo encuentra.
    try {
      return _lastLocations.firstWhere((loc) => loc.id == _selectedLocationId);
    } catch (e) {
      // Si no se encuentra, devolvemos null (esto no debería pasar si la lógica es correcta, pero es seguro).
      return null;
    }
  }

  Widget _buildActionPanel() {
    if (_selectedLocation == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Seleccionado: ${_selectedLocation!.name}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              // Botón EDITAR
              ElevatedButton.icon(
                onPressed: () => _editLocation(_selectedLocationId!),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(width: 8),
              // Botón ELIMINAR
              ElevatedButton.icon(
                onPressed: () => _deleteLocation(
                  _selectedLocationId!,
                  _selectedLocation!.name,
                ),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationNodeBuilder(Node node, Map<int, Location> locationMap) {
    final locationId = node.key!.value as int;
    final Location? location = locationMap[locationId];

    if (location == null) return Container();
    final isCurrentlySelected = location.id == _selectedLocationId;

    return LocationCardContent(
      location: location,
      // 🔑 CLAVE: Pasamos la nueva función combinada
      onTap: () => _selectNode(node, locationId),
      isSelected:
          isCurrentlySelected, // Necesitas que LocationCardContent tenga esta prop.
    );
  }

  Future<void> _loadLocations() async {
    final locationProvider = context.read<LocationProvider>();
    final int containerIdInt = int.parse(widget.containerId);

    // Esto llamará a la API y luego notificará a los listeners (build y didChangeDependencies)
    await locationProvider.fetchLocations(containerIdInt);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locations = context.watch<LocationProvider>().locations;

    _updateGraph(locations);
  }

  void _updateGraph(List<Location> newLocations) {
    // Verificación simple de cambio de contenido por longitud o diferencia de objetos.
    // Usamos IDs para una comparación más precisa si fuera necesario, pero la longitud es rápida.
    bool listChanged = newLocations.length != _lastLocations.length;

    if (!listChanged) {
      // Si tienen la misma longitud, verificamos si alguna ubicación se movió o cambió.
      // Aquí simplificamos asumiendo que el proveedor solo notificará si hay un cambio real.
      // Si necesitas una verificación profunda, podrías comparar hashCodes o IDs.
      if (newLocations.isEmpty && _lastLocations.isEmpty) return;

      // Comparamos los IDs para una verificación más robusta que solo la longitud
      final currentIds = newLocations.map((loc) => loc.id).toSet();
      final lastIds = _lastLocations.map((loc) => loc.id).toSet();

      if (currentIds.length != lastIds.length ||
          !currentIds.containsAll(lastIds)) {
        listChanged = true;
      }
    }

    if (listChanged) {
      // Reconstruir el grafo solo si hubo un cambio real en los datos
      setState(() {
        _lastLocations = List.from(newLocations); // Clonamos la lista
        graph = buildLocationGraph(newLocations);
      });
    }
  }

  void _selectNode(Node node, int locationId) {
    setState(() {
      // Si el nodo actual ya está seleccionado, lo deseleccionamos (null o 0).
      // Si no está seleccionado, lo seleccionamos.
      if (_selectedLocationId == locationId) {
        _selectedLocationId = null;
      } else {
        _selectedLocationId = locationId;
      }
    });
  }

  void _resetView() {
    _controller.animateToNode(ValueKey(1));
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadLocations());
  }

  @override
  void didUpdateWidget(LocationsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el containerId cambió, recargar las ubicaciones del nuevo contenedor
    if (oldWidget.containerId != widget.containerId) {
      _selectedLocationId = null; // Limpiar selección anterior
      _loadLocations();
    }
  }
}
