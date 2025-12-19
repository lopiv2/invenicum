import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/services/toast_service.dart';
import '../models/container_node.dart';
import '../providers/container_provider.dart';

enum ContainerAction { rename, delete }

class ContainerTreeView extends StatefulWidget {
  // Definición de callbacks
  final Function(ContainerNode, String? subSection) onContainerTap;
  final Future<void> Function(int containerId) onDeleteContainer;
  final Future<void> Function(int containerId, String newName)
  onRenameContainer;

  const ContainerTreeView({
    super.key,
    required this.onContainerTap,
    required this.onDeleteContainer,
    required this.onRenameContainer,
  });

  @override
  State<ContainerTreeView> createState() => _ContainerTreeViewState();
}

class _ContainerTreeViewState extends State<ContainerTreeView> {
  // --- Lógica Asíncrona para Cargar Sub-datos ---
  Future<void> _loadDataForContainer(int containerId) async {
    try {
      // Usa context.read() porque NO debe provocar un rebuild. El rebuild lo hace el Consumer.
      await context.read<ContainerProvider>().loadDataLists(containerId);
    } catch (e) {
      print('Error cargando listas para contenedor $containerId: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Disparamos la carga de conteos (asíncrona) para todos los contenedores al inicio.
    Future.microtask(() {
      final initialContainers = context.read<ContainerProvider>().containers;
      for (var container in initialContainers) {
        _loadDataForContainer(container.id);
      }
    });
  }

  // Genera la estructura de nodos usando la lista actualizada.
  TreeNode<dynamic> _buildTreeRoot(List<ContainerNode> containers) {
    final root = TreeNode.root();

    for (var container in containers) {
      final containerNode = TreeNode(
        key: container.id.toString(),
        data: container.name,
      );

      final assetTypesNode = TreeNode(
        key: "${container.id}_assettypes",
        data: "Tipos de activos (${container.assetTypes.length})",
      );
      containerNode.add(assetTypesNode);

      // ✅ El valor de locationsCount se actualiza automáticamente
      // cuando el Provider llama a notifyListeners().
      final locationsNode = TreeNode(
        key: "${container.id}_locations",
        data: "Ubicaciones (${container.locations.length})",
      );
      containerNode.add(locationsNode);

      final loansNode = TreeNode(
        key: "${container.id}_loans",
        data: "Préstamos / Historial",
      );
      containerNode.add(loansNode);

      final datalistsNode = TreeNode(
        key: "${container.id}_datalists",
        data: "Listas Personalizadas (${container.dataLists.length})",
      );
      containerNode.add(datalistsNode);

      root.add(containerNode);
    }

    return root;
  }

  // Renderiza el contenido de cada nodo y maneja el menú contextual.
  Widget _itemBuilder(
    BuildContext context,
    TreeNode node,
    List<ContainerNode> containers,
  ) {
    final isContainer = node.level == 1;
    final isSection = node.level == 2;
    final isClickable = isContainer || isSection;

    ContainerNode? container;
    if (isContainer) {
      final containerIdInt = int.tryParse(node.key.toString());
      if (containerIdInt != null) {
        try {
          // Usa la lista inyectada para obtener el objeto ContainerNode correcto.
          container = containers.firstWhere((c) => c.id == containerIdInt);
        } catch (_) {}
      }
    }

    // Contenido visual del nodo (Icono y Texto)
    final nodeContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(
            _getIconForNode(node, container),
            size: isContainer ? 20 : 16,
            color: isContainer
                ? Theme.of(context).primaryColor
                : isSection
                ? Colors.blueGrey
                : Colors.grey,
          ),
          const SizedBox(width: 8),
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

    Widget finalWidget = nodeContent;

    // Manejo de Menú Contextual para Contenedores (clic derecho)
    if (isContainer && container != null) {
      finalWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onSecondaryTapDown: (details) =>
              _showContextMenu(context, details.globalPosition, container!),
          child: nodeContent,
        ),
      );
    } else {
      // Cursor de mouse para secciones clicables
      finalWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: nodeContent,
      );
    }

    return finalWidget;
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 CONSUMER: Este widget escucha cualquier cambio en ContainerProvider
    return Consumer<ContainerProvider>(
      builder: (context, provider, child) {
        final containers =
            provider.containers; // La lista siempre estará actualizada.

        // 1. Construir el árbol con la lista actualizada
        final root = _buildTreeRoot(containers);

        // Muestra un indicador de carga si es necesario
        if (containers.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return TreeView.simple(
          tree: root,
          showRootNode: false,

          // 2. Lógica de Tap
          onItemTap: (node) {
            final isContainer = node.level == 1;
            final isSection = node.level == 2;
            final keyParts = node.key.toString().split('_');
            final containerIdStr = isContainer
                ? node.key.toString()
                : keyParts.first;
            final containerIdInt = int.tryParse(containerIdStr);

            if (containerIdInt == null) return;

            // Usamos la lista 'containers' del Consumer para encontrar el objeto
            final container = containers.firstWhere(
              (c) => c.id == containerIdInt,
              orElse: () => throw Exception(
                "Container not found with ID: $containerIdStr",
              ),
            );

            String? targetPath;

            // Lógica de Navegación del Negocio (GoRouter)
            if (isSection) {
              final sectionKey = keyParts.last;

              switch (sectionKey) {
                case 'assettypes':
                  targetPath = '/container/$containerIdStr/asset-types';
                  break;
                case 'datalists':
                  targetPath = '/container/$containerIdStr/datalists';
                  break;
                case 'locations':
                  // El print que ya tenías para depuración:
                  print('Navegando a ubicaciones para ID: $containerIdStr');
                  targetPath = '/container/$containerIdStr/locations';
                  break;
                case 'loans':
                  targetPath = '/container/$containerIdStr/loans';
                  break;
              }
            }

            if (targetPath != null) {
              // 🟢 CORRECCIÓN APLICADA: Envolver la navegación en Future.microtask.
              // Esto permite que el TreeView termine su manipulación de estado
              // (como animaciones o scrolling) antes de que el Widget sea destruido
              // por el cambio de ruta.
              Future.microtask(() {
                if (!context.mounted) return;
                context.go(targetPath!);
              });
              return;
            }

            // Lógica de Negocio General: Tap en el contenedor
            if (isContainer) {
              widget.onContainerTap(container, null);
            }
          },

          // 3. Builder del Ítem: Pasamos la lista 'containers'
          builder: (context, node) => _itemBuilder(context, node, containers),

          expansionBehavior: ExpansionBehavior.snapToTop,
          indentation: const Indentation(
            style: IndentStyle.roundJoint,
            width: 24,
            color: Color(0xFFE0E0E0),
          ),
        );
      },
    );
  }

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

    if (confirmed == true) {
      final newName = controller.text.trim();
      if (newName.isEmpty || newName == container.name) return;

      try {
        await widget.onRenameContainer(container.id, newName);

        if (!context.mounted) return;
        ToastService.success('Contenedor renombrado a "$newName".');
      } catch (e) {
        if (!context.mounted) return;
        ToastService.error('Error al renombrar: ${e.toString()}');
      }
    }
  }

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

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    ContainerNode container,
  ) async {
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

  IconData _getIconForNode(TreeNode node, ContainerNode? container) {
    final isContainer = node.level == 1;
    final isSection = node.level == 2;

    if (isContainer) {
      // Si es una colección, usar un icono de colección
      if (container != null && container.isCollection) {
        return Icons.collections_outlined;
      }
      return Icons.inventory_2_outlined;
    }

    if (isSection) {
      final keyParts = node.key.toString().split('_');

      switch (keyParts.last) {
        case 'assettypes':
          return Icons.category_outlined;
        case 'locations':
          return Icons.place_outlined;
        case 'loans':
          return Icons.handshake_outlined;
        case 'datalists':
          return Icons.list_alt;
        default:
          return Icons.folder_open;
      }
    }

    return Icons.fiber_manual_record;
  }
}
