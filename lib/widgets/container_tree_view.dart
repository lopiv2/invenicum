import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/services/toast_service.dart';
import '../models/container_node.dart';
import '../providers/container_provider.dart';

enum ContainerAction { rename, delete }

class ContainerTreeView extends StatefulWidget {
  final List<ContainerNode> containers;
  final Function(ContainerNode, String? subSection) onContainerTap;
  final Future<void> Function(int containerId) onDeleteContainer;
  final Future<void> Function(int containerId, String newName)
  onRenameContainer;

  const ContainerTreeView({
    super.key,
    required this.containers,
    required this.onContainerTap,
    required this.onDeleteContainer,
    required this.onRenameContainer,
  });

  @override
  State<ContainerTreeView> createState() => _ContainerTreeViewState();
}

class _ContainerTreeViewState extends State<ContainerTreeView> {
  Future<void> _loadDataForContainer(int containerId) async {
    try {
      await context.read<ContainerProvider>().loadDataLists(containerId);
    } catch (e) {
      print('Error cargando listas para contenedor $containerId: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Cargar las listas para todos los contenedores al inicio
    for (var container in widget.containers) {
      _loadDataForContainer(container.id);
    }
  }

  // --- Construcción del Árbol (Sin cambios) ---
  TreeNode<dynamic> _buildTreeRoot() {
    final root = TreeNode.root();

    for (var container in widget.containers) {
      final containerNode = TreeNode(
        key: container.id.toString(),
        data: container.name,
      );

      final assetTypesNode = TreeNode(
        key: "${container.id}_assettypes",
        data: "Tipos de activos (${container.assetTypes.length})",
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
  void _handleMenuAction(
    BuildContext context,
    ContainerAction action,
    ContainerNode container,
  ) {
    switch (action) {
      case ContainerAction.delete:
        _showDeleteConfirmationDialog(context, container);
        break;
      case ContainerAction.rename:
        _showRenameDialog(context, container);
        break;
    }
  }

  // --- NUEVA FUNCIÓN: Diálogo para Renombrar ---
  Future<void> _showRenameDialog(
    BuildContext context,
    ContainerNode container,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: container.name,
    );
    final formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Renombrar Contenedor'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nuevo nombre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                if (value.trim() == container.name) {
                  return 'El nombre es el mismo que el actual';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                // Permite enviar al presionar Enter si es válido
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Renombrar'),
            ),
          ],
        );
      },
    );

    // 3. Manejo de la Lógica de Renombrar
    if (confirmed == true) {
      final newName = controller.text.trim();
      if (newName.isEmpty || newName == container.name) return;

      try {
        // Llama al callback proporcionado por el padre
        await widget.onRenameContainer(container.id, newName);

        if (!context.mounted) return;
        ToastService.success('Contenedor renombrado a "$newName".');
      } catch (e) {
        if (!context.mounted) return;
        ToastService.error('Error al renombrar: ${e.toString()}');
      }
    }
  }

  // --- Lógica para mostrar el menú contextual (NUEVO) ---
  void _showContextMenu(
    BuildContext context,
    Offset position,
    ContainerNode container,
  ) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;

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
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    ContainerNode container,
  ) async {
    // ... (El cuerpo de esta función se mantiene como está)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar el contenedor "${container.name}"? Esta acción es irreversible y eliminará todos sus activos y datos.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await widget.onDeleteContainer(container.id);
        if (!context.mounted) return;
        ToastService.success('Contenedor "${container.name}" eliminado.');
      } catch (e) {
        if (!context.mounted) return;
        ToastService.error('Error al eliminar: ${e.toString()}');
      }
    }
  }

  // --- Renderizado del Ítem (itemBuilder MODIFICADO) ---
  // --- Renderizado del Ítem (itemBuilder CORREGIDO) ---
  Widget _itemBuilder(BuildContext context, TreeNode node) {
    final isContainer = node.level == 1;
    final isSection = node.level == 2;
    final isClickable = isContainer || isSection;

    ContainerNode? container;
    if (isContainer) {
      final containerIdInt = int.tryParse(node.key.toString());
      if (containerIdInt != null) {
        try {
          container = widget.containers.firstWhere((c) => c.id == containerIdInt);
        } catch (_) {}
      }
    }

    // 1. Contenido visual del nodo (La estructura de iconos y texto)
    final nodeContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(
            isContainer
                ? Icons.folder_open
                : isSection
                ? Icons.list_alt
                : Icons.fiber_manual_record,
            size: isContainer
                ? 20
                : isSection
                ? 16
                : 8,
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
        ],
      ),
    );

    if (!isClickable) {
      return nodeContent;
    }

    // 2. Manejo de Menú Contextual para Contenedores (Clic Derecho)
    Widget finalWidget = nodeContent;

    if (isContainer && container != null) {
      // Si es un contenedor, lo envolvemos para detectar el clic derecho
      finalWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          // onSecondaryTapDown para el menú contextual
          onSecondaryTapDown: (details) =>
              _showContextMenu(context, details.globalPosition, container!),
          // No definimos onTap aquí, permitiendo que el TreeView.simple.onItemTap
          // gestione la expansión y la navegación del clic primario.
          child: nodeContent,
        ),
      );
    } else {
      // Si es una sección (Activos/Listas) o un nodo simple
      // No necesita GestureDetector, solo el cursor de mouse.
      finalWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: nodeContent,
      );
    }

    return finalWidget;
  }

  @override
  Widget build(BuildContext context) {
    final root = _buildTreeRoot();
    return TreeView.simple(
      tree: root,
      showRootNode: false,

      // onItemTap ahora manejará tanto la expansión (si es posible) como la navegación
      onItemTap: (node) {
        final isContainer = node.level == 1;
        final isSection = node.level == 2;
        final keyParts = node.key.toString().split('_');
        final containerIdStr = isContainer
            ? node.key.toString()
            : keyParts.first;
        final containerIdInt = int.tryParse(containerIdStr);

        if (containerIdInt == null) return;

        final container = widget.containers.firstWhere(
          (c) => c.id == containerIdInt,
          orElse: () =>
              throw Exception("Container not found with ID: $containerIdStr"),
        );

        // Lógica de Navegación del Negocio
        if (isSection) {
          switch (keyParts.last) {
            case 'assettypes':
              context.go('/container/$containerIdStr/asset-types');
              return;
            case 'datalists':
              context.go('/container/$containerIdStr/datalists');
              return;
          }
        }

        // Lógica de Negocio General: Tap en el contenedor
        if (isContainer) {
          widget.onContainerTap(container, null);
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
