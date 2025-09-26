import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:go_router/go_router.dart';
import '../models/container_node.dart';

enum ContainerAction { rename, delete }

class ContainerTreeView extends StatelessWidget {
  final List<ContainerNode> containers;
  final Function(ContainerNode, String? subSection) onContainerTap;
  final Future<void> Function(int containerId) onDeleteContainer; 
  // TODO: Añadir callback para Renombrar si es necesario

  const ContainerTreeView({
    super.key,
    required this.containers,
    required this.onContainerTap,
    required this.onDeleteContainer, 
  });

  // --- Construcción del Árbol (Sin cambios) ---
  TreeNode<dynamic> _buildTreeRoot() {
    final root = TreeNode.root();
    
    for (var container in containers) {
      final containerNode = TreeNode(
        key: container.id.toString(), 
        data: container.name,
      );
      
      final assetTypesNode = TreeNode(
        key: "${container.id}_assettypes",
        data: "Activos (${container.assetTypes.length})", 
      );
      containerNode.add(assetTypesNode);

      final datalistsNode = TreeNode(
        key: "${container.id}_datalists",
        data: "Listas Personalizadas (${container.dataLists.length})",
      );
      containerNode.add(datalistsNode);
      
      root.add(containerNode);
    }
    
    return root;
  }
  
  // --- Lógica de Manejo de Acciones (NUEVO) ---
  void _handleMenuAction(BuildContext context, ContainerAction action, ContainerNode container) {
    switch (action) {
      case ContainerAction.delete:
        _showDeleteConfirmationDialog(context, container);
        break;
      case ContainerAction.rename:
        // TODO: Implementar el diálogo para Renombrar
        print('Renombrar contenedor ${container.name}');
        break;
    }
  }

  // --- Lógica para mostrar el menú contextual (NUEVO) ---
  void _showContextMenu(BuildContext context, Offset position, ContainerNode container) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    
    showMenu<ContainerAction>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), 
        Offset.zero & overlay.size,   
      ),
      items: <PopupMenuEntry<ContainerAction>>[
        const PopupMenuItem<ContainerAction>(
          value: ContainerAction.rename,
          child: Text('Renombrar'),
        ),
        const PopupMenuItem<ContainerAction>(
          value: ContainerAction.delete,
          child: Text('Eliminar'),
        ),
      ],
    ).then((result) {
      if (result != null) {
        _handleMenuAction(context, result, container);
      }
    });
  }

  // --- Diálogo de Confirmación (SIN CAMBIOS ESTRUCTURALES) ---
  Future<void> _showDeleteConfirmationDialog(BuildContext context, ContainerNode container) async {
    // ... (El cuerpo de esta función se mantiene como está)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el contenedor "${container.name}"? Esta acción es irreversible y eliminará todos sus activos y datos.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await onDeleteContainer(container.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contenedor "${container.name}" eliminado.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    }
  }


  // --- Renderizado del Ítem (itemBuilder MODIFICADO) ---
  Widget _itemBuilder(BuildContext context, TreeNode node) {
    final isContainer = node.level == 1;
    final isSection = node.level == 2;
    final isClickable = isContainer || isSection;
    
    // Buscar el objeto ContainerNode si es un contenedor
    ContainerNode? container;
    if (isContainer) {
      final containerIdInt = int.tryParse(node.key.toString());
      if (containerIdInt != null) {
        try {
          // Acceder a la lista 'containers' de la clase StatelessWidget
          container = containers.firstWhere((c) => c.id == containerIdInt);
        } catch (_) {}
      }
    }

    // 1. Contenido visual del nodo (SIN BOTÓN DE BORRAR)
    final nodeContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), 
      child: Row(
        children: [
          // 1. Icono de expansión
          /*if (node.children.isNotEmpty)
            Icon(
              node.isExpanded ? Icons.expand_more : Icons.chevron_right,
              size: 20,
              color: Colors.grey,
            )
          else
            const SizedBox(width: 24),*/
            
          // 2. Icono del nodo
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
          
          // 3. Texto del nodo
          Expanded(
            child: Text(
              node.data.toString(), 
              style: TextStyle(
                fontSize: isContainer ? 14 : 12,
                fontWeight: isSection ? FontWeight.bold : FontWeight.normal,
                color: isContainer 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[900],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // *** ELIMINAMOS EL ICONBUTTON DE BORRAR ***
        ],
      ),
    );

    // 2. Manejo de Clicks y Menú Contextual
    if (!isClickable) {
      return nodeContent;
    }
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // Clic Izquierdo: Expande/Colapsa y navega. 
        // Usamos el onTap para simular la expansión (menos confiable sin controller)
        onTap: () {
          // Llama al onItemTap, que se encarga de la expansión si el TreeView lo soporta
          // Y luego maneja la navegación.
          //TreeView.of(context)!.onItemTap.call(node);
        },
        
        // Clic Secundario (Botón Derecho): Muestra el menú contextual
        onSecondaryTapDown: isContainer && container != null
          ? (details) => _showContextMenu(context, details.globalPosition, container!)
          : null,
          
        child: nodeContent,
      ),
    );
  }

  // --- Manejo del Tap (onItemTap - Se mantiene la lógica de navegación) ---
  @override
  Widget build(BuildContext context) {
    return TreeView.simple(
      tree: _buildTreeRoot(),
      showRootNode: false,
      
      // onItemTap ahora manejará tanto la expansión (si es posible) como la navegación
      onItemTap: (node) {
        final isContainer = node.level == 1;
        final isSection = node.level == 2;
        final keyParts = node.key.toString().split('_');
        final containerIdStr = isContainer ? node.key.toString() : keyParts.first;
        final containerIdInt = int.tryParse(containerIdStr);

        if (containerIdInt == null) return; 

        final container = containers.firstWhere(
          (c) => c.id == containerIdInt, 
          orElse: () => throw Exception("Container not found with ID: $containerIdStr")
        );

        // Lógica de Navegación del Negocio
        if (isSection && keyParts.last == 'assettypes') {
          context.go('/container/$containerIdStr/asset-types');
          return;
        } 
        
        // Lógica de Negocio General: Tap en el contenedor o sección general
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