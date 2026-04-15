import 'package:graphview/GraphView.dart';
import 'package:invenicum/data/models/location.dart';

/// Builds a [Graph] from a list of locations.
///
/// Problem: [BuchheimWalkerConfiguration] / [TidierTreeLayoutAlgorithm]
/// only processes a tree with a single root. If there are multiple locations without
/// a parent (multiple roots), the algorithm ignores all but the first.
///
/// Solution: a **virtual root node** with id = -1 is added, connecting all
/// rootless locations as direct children. The virtual node is invisible
/// in the UI — the builder in LocationsScreen returns SizedBox.shrink() for
/// locations with id=-1.
Graph buildLocationGraph(List<Location> locations) {
  final graph = Graph()..isTree = true;

  if (locations.isEmpty) return graph;

  // We identify the real roots (locations without a parent)
  final rootLocations = locations.where((loc) => loc.parentId == null).toList();

  // Map of id → Node for efficient edge construction
  final nodeMap = <int, Node>{};

  // Virtual root node — only added if there is more than one real root
  // (with a single root, the graph works without it)
  final bool needsVirtualRoot = rootLocations.length > 1;
  Node? virtualRoot;

  if (needsVirtualRoot) {
    virtualRoot = Node.Id(-1);
    nodeMap[-1] = virtualRoot;
  }

  // Create all nodes
  for (final loc in locations) {
    nodeMap[loc.id] = Node.Id(loc.id);
  }

  // Build edges
  for (final loc in locations) {
    final childNode = nodeMap[loc.id]!;

    if (loc.parentId != null) {
      // Has a real parent → connect parent → child
      final parentNode = nodeMap[loc.parentId];
      if (parentNode != null) {
        graph.addEdge(parentNode, childNode);
      } else {
        // Parent not found in the list (orphan) — treat it as a root
        if (needsVirtualRoot) {
          graph.addEdge(virtualRoot!, childNode);
        } else {
          graph.addNode(childNode);
        }
      }
    } else {
      // No parent → it's a real root
      if (needsVirtualRoot) {
        // Connect to the virtual node to unify all trees
        graph.addEdge(virtualRoot!, childNode);
      } else {
        // Single root — add it directly without virtual
        graph.addNode(childNode);
      }
    }
  }

  return graph;
}