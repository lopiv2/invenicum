import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphview/GraphView.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/location.dart';
import 'package:invenicum/providers/location_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/core/utils/location_graph_builder.dart';
import 'package:invenicum/screens/locations/local_widgets/location_card_content.dart';
import 'package:provider/provider.dart';

class LocationsScreen extends StatefulWidget {
  final String containerId;
  const LocationsScreen({super.key, required this.containerId});
  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> with TickerProviderStateMixin {
  final GraphViewController _controller = GraphViewController();
  List<Location> _lastLocations = [];
  int? _selectedLocationId;

  Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  late final algorithm = TidierTreeLayoutAlgorithm(
    builder,
    TreeEdgeRenderer(builder),
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadLocations());
  }

  Location? get _selectedLocation {
    if (_selectedLocationId == null) return null;
    try {
      return _lastLocations.firstWhere((loc) => loc.id == _selectedLocationId);
    } catch (e) {
      return null;
    }
  }

  void _addLocation() {
    context.go('/container/${widget.containerId}/locations/new');
  }

  void _editLocation(int locationId) {
    context.go('/container/${widget.containerId}/locations/$locationId/edit');
  }

  void _deleteLocation(int locationId, String locationName) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.confirmDeleteLocationMessage(locationName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _performDeletion(locationId);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeletion(int locationId) async {
    final provider = context.read<LocationProvider>();
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.deleteLocation(locationId, containerId: int.parse(widget.containerId), context: context);
      if (mounted) {
        ToastService.success(l10n.deleteSuccess);
        _loadLocations();
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(l10n.deleteError(e.toString()));
      }
    }
  }

  Future<void> _loadLocations() async {
    final locationProvider = context.read<LocationProvider>();
    final int containerIdInt = int.parse(widget.containerId);
    print('Loading locations for container: $containerIdInt');
    await locationProvider.fetchLocations(containerIdInt);
    if (mounted) {
      final locations = locationProvider.locations;
      print('Loaded ${locations.length} locations');
      _updateGraph(locations);
    }
  }

  void _updateGraph(List<Location> newLocations) {
    bool listChanged = newLocations.length != _lastLocations.length;
    if (!listChanged && newLocations.isNotEmpty) {
      final currentIds = newLocations.map((loc) => loc.id).toSet();
      final lastIds = _lastLocations.map((loc) => loc.id).toSet();
      if (!currentIds.containsAll(lastIds)) listChanged = true;
    }

    if (listChanged || (_lastLocations.isEmpty && newLocations.isNotEmpty)) {
      setState(() {
        _lastLocations = List.from(newLocations);
        graph = buildLocationGraph(newLocations);
        print('Graph updated with ${newLocations.length} locations');
      });
      
      // Centrar la vista después de que se renderice el grafo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          try {
            _controller.zoomToFit();
            print('Graph centered and fitted');
          } catch (e) {
            print('Error fitting graph: $e');
          }
        });
      });
    } else if (newLocations.isEmpty && _lastLocations.isNotEmpty) {
      setState(() {
        _lastLocations = [];
        graph = Graph()..isTree = true;
        print('Graph cleared');
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locations = context.watch<LocationProvider>().locations;
    _updateGraph(locations);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationProvider = context.watch<LocationProvider>();
    final isLoading = locationProvider.isLoading;
    final errorMessage = locationProvider.errorMessage;
    final locations = locationProvider.locations;
    final theme = Theme.of(context);
    
    final Map<int, Location> locationMap = { for (var loc in locations) loc.id: loc };

    if (isLoading && locations.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(l10n.locationsScheme)),
        body: Center(child: Text(l10n.errorLoadingLocations(errorMessage), style: const TextStyle(color: Colors.red))),
      );
    }

    if (locations.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.locationsScheme),
          actions: [
            IconButton(icon: const Icon(Icons.add_location_alt), onPressed: _addLocation, tooltip: l10n.addNewLocation),
          ],
        ),
        body: Center(child: Text(l10n.noLocationsMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.locationsScheme),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: isLoading ? null : _loadLocations, tooltip: l10n.reloadLocations),
          IconButton(icon: const Icon(Icons.center_focus_strong), onPressed: () => _controller.animateToNode(ValueKey(1)), tooltip: l10n.centerView),
          IconButton(icon: const Icon(Icons.zoom_in), onPressed: _controller.zoomToFit, tooltip: l10n.zoomToFit),
          IconButton(icon: const Icon(Icons.add_location_alt), onPressed: _addLocation, tooltip: l10n.addNewLocation),
        ],
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: GraphView.builder(
              controller: _controller,
              graph: graph,
              algorithm: algorithm,
              centerGraph: true,
              builder: (Node node) => _locationNodeBuilder(node, locationMap),
            ),
          ),
          if (_selectedLocation != null) _buildActionPanel(l10n),
        ],
      ),
    );
  }

  Widget _buildActionPanel(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.selectedLocationLabel(_selectedLocation!.name),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _editLocation(_selectedLocationId!),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(l10n.edit),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _deleteLocation(_selectedLocationId!, _selectedLocation!.name),
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(l10n.delete),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationNodeBuilder(Node node, Map<int, Location> locationMap) {
    final locationId = node.key!.value as int;
    final location = locationMap[locationId];
    if (location == null) {
      print('Location not found for ID: $locationId');
      return const SizedBox(width: 160, height: 80);
    }
    print('Building node for location: ${location.name}');

    return SizedBox(
      width: 160,
      height: 80,
      child: LocationCardContent(
        location: location,
        onTap: () => setState(() => _selectedLocationId = (_selectedLocationId == locationId ? null : locationId)),
        isSelected: location.id == _selectedLocationId,
      ),
    );
  }
}