import 'package:graphview/GraphView.dart';
import 'package:invenicum/data/models/location.dart';

/// Construye un [Graph] a partir de una lista de ubicaciones.
///
/// Problema: [BuchheimWalkerConfiguration] / [TidierTreeLayoutAlgorithm]
/// solo procesa un árbol con una única raíz. Si hay varias ubicaciones sin
/// padre (múltiples raíces), el algoritmo ignora todas menos la primera.
///
/// Solución: se añade un **nodo raíz virtual** con id = -1 que conecta todas
/// las ubicaciones sin padre como hijos directos. El nodo virtual es invisible
/// en la UI — el builder en LocationsScreen devuelve SizedBox.shrink() para id=-1.
Graph buildLocationGraph(List<Location> locations) {
  final graph = Graph()..isTree = true;

  if (locations.isEmpty) return graph;

  // Identificamos las raíces reales (ubicaciones sin padre)
  final rootLocations = locations.where((loc) => loc.parentId == null).toList();

  // Mapa de id → Node para construir las aristas eficientemente
  final nodeMap = <int, Node>{};

  // Nodo raíz virtual — solo se añade si hay más de una raíz real
  // (con una sola raíz el grafo funciona sin él)
  final bool needsVirtualRoot = rootLocations.length > 1;
  Node? virtualRoot;

  if (needsVirtualRoot) {
    virtualRoot = Node.Id(-1);
    nodeMap[-1] = virtualRoot;
  }

  // Creamos todos los nodos
  for (final loc in locations) {
    nodeMap[loc.id] = Node.Id(loc.id);
  }

  // Construimos las aristas
  for (final loc in locations) {
    final childNode = nodeMap[loc.id]!;

    if (loc.parentId != null) {
      // Tiene padre real → conectamos padre → hijo
      final parentNode = nodeMap[loc.parentId];
      if (parentNode != null) {
        graph.addEdge(parentNode, childNode);
      } else {
        // Padre no encontrado en la lista (huérfano) — lo tratamos como raíz
        if (needsVirtualRoot) {
          graph.addEdge(virtualRoot!, childNode);
        } else {
          graph.addNode(childNode);
        }
      }
    } else {
      // Sin padre → es raíz real
      if (needsVirtualRoot) {
        // Conectamos al nodo virtual para unificar todos los árboles
        graph.addEdge(virtualRoot!, childNode);
      } else {
        // Única raíz — la añadimos directamente sin virtual
        graph.addNode(childNode);
      }
    }
  }

  return graph;
}