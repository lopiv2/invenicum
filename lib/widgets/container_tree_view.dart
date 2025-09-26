// lib/widgets/container_tree_view.dart

import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:go_router/go_router.dart';
import '../models/container_node.dart';

class ContainerTreeView extends StatelessWidget {
  final List<ContainerNode> containers;
  final Function(ContainerNode, String? subSection) onContainerTap;

  const ContainerTreeView({
    super.key,
    required this.containers,
    required this.onContainerTap,
  });

  // --- Construcción del Árbol (Sin cambios) ---
  TreeNode<dynamic> _buildTreeRoot() {
    final root = TreeNode.root();
    
    for (var container in containers) {
      final containerNode = TreeNode(
        key: container.id.toString(), 
        data: container.name,
      );
      
      // Nodo de la sección 'Activos'
      final assetTypesNode = TreeNode(
        key: "${container.id}_assettypes",
        data: "Activos (${container.assetTypes.length})", 
      );
      containerNode.add(assetTypesNode);

      // Nodo de la sección 'Listas Personalizadas' 
      final datalistsNode = TreeNode(
        key: "${container.id}_datalists",
        data: "Listas Personalizadas (${container.dataLists.length})",
      );
      containerNode.add(datalistsNode);
      
      root.add(containerNode);
    }
    
    return root;
  }

  // --- Renderizado del Ítem (itemBuilder) ---
  Widget _itemBuilder(BuildContext context, TreeNode node) {
    final isContainer = node.level == 1;
    final isSection = node.level == 2;
    // Solo queremos el cursor de mano en elementos clickables (Contenedores y Secciones)
    final isClickable = isContainer || isSection;
    
    final nodeContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Icono de expansión
          if (node.children.isNotEmpty)
            Icon(
              node.isExpanded ? Icons.expand_more : Icons.chevron_right,
              size: 20,
              color: Colors.grey,
            )
          else
            const SizedBox(width: 24),
            
          // Icono del nodo
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
          
          // Texto del nodo
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

    // Si el nodo es clickeable, lo envolvemos en MouseRegion
    if (isClickable) {
      return MouseRegion(
        // Cursor de mano (SystemMouseCursors.click)
        cursor: SystemMouseCursors.click,
        child: nodeContent,
      );
    }
    
    return nodeContent;
  }

  // --- Manejo del Tap (onItemTap - Sin cambios) ---
  @override
  Widget build(BuildContext context) {
    return TreeView.simple(
      tree: _buildTreeRoot(),
      showRootNode: false,
      
      onItemTap: (node) {
        final isContainer = node.level == 1;
        final isSection = node.level == 2;
        final keyParts = node.key.toString().split('_');
        final containerIdStr = isContainer ? node.key.toString() : keyParts.first;
        final containerIdInt = int.tryParse(containerIdStr);

        if (containerIdInt == null) return; 

        // Buscar el contenedor
        final container = containers.firstWhere(
          (c) => c.id == containerIdInt, 
          orElse: () => throw Exception("Container not found with ID: $containerIdStr")
        );

        // Lógica de Navegación del Negocio (Sección Activos)
        if (isSection && keyParts.last == 'assettypes') {
          context.go('/container/$containerIdStr/asset-types');
          return;
        } 
        
        // Lógica de Negocio General
        if (isContainer || isSection) {
          onContainerTap(container, isSection ? keyParts.last : null);
        }
      },
      
      builder: (context, node) => _itemBuilder(context, node),
      
      expansionBehavior: ExpansionBehavior.snapToTop, 
      indentation: const Indentation(
        style: IndentStyle.roundJoint,
        width: 24,
        color: Color(0xFFE0E0E0),
      ),
    );
  }
}