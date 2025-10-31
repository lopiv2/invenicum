// lib/utils/location_graph_builder.dart

import 'package:graphview/GraphView.dart';
import 'package:invenicum/models/location.dart';

// ❌ Se eliminan las listas de mock globales (mockLocations y locationMap)

/**
 * Construye un objeto Graph (de graphview) a partir de la lista de objetos Location.
 * Esta función es pura: solo usa los datos proporcionados en 'locations'.
 * * @param locations La lista de ubicaciones cargadas desde la API.
 * @returns El objeto Graph listo para ser renderizado por GraphView.
 */
Graph buildLocationGraph(List<Location> locations) {
  // Inicializamos el grafo como un árbol para usar el algoritmo TidierTreeLayoutAlgorithm.
  final graph = Graph()..isTree = true;
  
  // Mapeamos los ID de las ubicaciones a sus nodos graphview para facilitar la creación de aristas.
  final nodeMap = <int, Node>{};

  // 1. Crear Nodos
  for (var loc in locations) {
    // Usamos el ID de la ubicación como el ID del nodo.
    final node = Node.Id(loc.id);
    
    // Almacenamos el nodo creado en el mapa usando el ID de la ubicación como clave.
    nodeMap[loc.id] = node;
    
    // Añadimos el nodo al grafo.
    graph.addNode(node);
  }

  // 2. Crear Aristas (Relaciones Padre-Hijo)
  for (var loc in locations) {
    // Si la ubicación tiene un padre Y el nodo padre existe en nuestro mapa (fue cargado).
    if (loc.parentId != null && nodeMap.containsKey(loc.parentId)) {
      final parentNode = nodeMap[loc.parentId]!;
      final childNode = nodeMap[loc.id]!;
      
      // La arista va del padre al hijo.
      graph.addEdge(parentNode, childNode);
    }
  }
  
  return graph;
}