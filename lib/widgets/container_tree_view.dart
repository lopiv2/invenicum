import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import '../models/container_model.dart';

class ContainerTreeView extends StatelessWidget {
  final List<ContainerNode> containers;
  final Function(ContainerNode, String? subSection) onContainerTap;

  const ContainerTreeView({
    super.key,
    required this.containers,
    required this.onContainerTap,
  });

  // Aseguramos que la función devuelve el tipo genérico correcto
  TreeNode<dynamic> _buildTreeRoot() {
    final root = TreeNode.root();
    
    for (var container in containers) {
      final containerNode = TreeNode(
        key: container.id,
        data: container.name,
      );
      
      // Nodo de la sección 'Activos'
      final elementsNode = TreeNode(
        key: "${container.id}_elements",
        data: "Activos (${container.elements.length})",
      );
      for (int i = 0; i < container.elements.length; i++) {
        elementsNode.add(
          TreeNode(
            key: "${container.id}_element_$i",
            data: container.elements[i],
          ),
        );
      }
      containerNode.add(elementsNode);

      // Nodo de la sección 'Listas Personalizadas'  
      final datalistsNode = TreeNode(
        key: "${container.id}_datalists",
        data: "Listas Personalizadas (${container.dataLists.length})",
      );
      for (int i = 0; i < container.dataLists.length; i++) {
        datalistsNode.add(
          TreeNode(
            key: "${container.id}_datalist_$i",
            data: container.dataLists[i],
          ),
        );
      }
      containerNode.add(datalistsNode);
      root.add(containerNode);
    }
    
    return root;
  }

  // Define el diseño visual del nodo
  Widget _itemBuilder(BuildContext context, TreeNode node) {
    final isContainer = node.level == 1;
    final isSection = node.level == 2;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Icono para expandir/colapsar (solo visible si tiene hijos)
          if (node.children.isNotEmpty)
            Icon(
              node.isExpanded
                ? Icons.expand_more 
                : Icons.chevron_right,
              size: 20,
              color: Colors.grey,
            )
          else
            // Espacio de relleno si no hay icono de expansión (para alineación)
            const SizedBox(width: 24),
            
          Icon(
            isContainer 
              ? Icons.folder_open 
              : isSection 
                ? Icons.list_alt 
                : Icons.fiber_manual_record,
            size: isContainer ? 20 : isSection ? 16 : 8,
            color: isContainer 
              ? Theme.of(context).primaryColor
              : isSection 
                ? Colors.grey[700]
                : Colors.grey,
          ),
          const SizedBox(width: 8),
          // Usamos toString() para manejar diferentes tipos de datos
          Text(
            node.data.toString(), 
            style: TextStyle(
              fontSize: isContainer ? 14 : 12,
              fontWeight: isSection ? FontWeight.bold : FontWeight.normal,
              color: isContainer 
                ? Theme.of(context).primaryColor 
                : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TreeView.simple(
      tree: _buildTreeRoot(),
      showRootNode: false,
      // Usamos 'onItemTap' para la lógica y la expansión
      onItemTap: (node) {
        final isContainer = node.level == 1;
        final isSection = node.level == 2;
        
        // 1. Lógica de negocio
        if (isContainer || isSection) {
          final containerId = isContainer ? node.key : node.key.split('_').first;
          // Esto puede fallar si no existe, mejor usar firstWhere con un valor por defecto
          final container = containers.firstWhere((c) => c.id == containerId, 
            orElse: () => throw Exception("Container not found with ID: $containerId")
          );
          
          onContainerTap(container, isSection ? node.key.split('_').last : null);
        } 
      },
      // Usamos 'itemBuilder' para el diseño
      builder: (context, node) => _itemBuilder(context, node),
      
      // Configuraciones de visualización
      expansionBehavior: ExpansionBehavior.none, // o .collapseOthers si prefieres
      indentation: Indentation(
        style: IndentStyle.roundJoint,
        width: 24,
        color: Colors.grey.shade300,
      ),
    );
  }
}