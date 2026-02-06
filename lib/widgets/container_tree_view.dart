import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/loan_provider.dart';
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
      final loanProvider = context.read<LoanProvider>();
      for (var container in initialContainers) {
        _loadDataForContainer(container.id);
        // Cargar préstamos para cada contenedor
        loanProvider.fetchLoans(container.id);
      }
    });
  }

  // Genera la estructura de nodos usando la lista actualizada.
  TreeNode<dynamic> _buildTreeRoot(List<ContainerNode> containers) {
    final root = TreeNode.root();
    final loanProvider = context.watch<LoanProvider>();

    for (var container in containers) {
      final containerNode = TreeNode(
        key: container.id.toString(),
        data: container.name,
      );

      final assetTypesNode = TreeNode(
        key: "${container.id}_assettypes",
        data:
            "${AppLocalizations.of(context)!.assetTypes} (${container.assetTypes.length})",
      );
      containerNode.add(assetTypesNode);

      // ✅ El valor de locationsCount se actualiza automáticamente
      // cuando el Provider llama a notifyListeners().
      final locationsNode = TreeNode(
        key: "${container.id}_locations",
        data:
            "${AppLocalizations.of(context)!.locations} (${container.locations.length})",
      );
      containerNode.add(locationsNode);

      // ✅ Contar préstamos del contenedor actual
      final loansCount = loanProvider.loans.length;
      final loansNode = TreeNode(
        key: "${container.id}_loans",
        data: "${AppLocalizations.of(context)!.loans} ($loansCount)",
      );
      containerNode.add(loansNode);

      final datalistsNode = TreeNode(
        key: "${container.id}_datalists",
        data:
            "${AppLocalizations.of(context)!.datalists} (${container.dataLists.length})",
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
    final theme = Theme.of(context);

    ContainerNode? container;
    if (isContainer) {
      final containerIdInt = int.tryParse(node.key.toString());
      // 🚩 PROTECCIÓN EXTRA: Validar que el ID no sea nulo y exista en la lista actual
      if (containerIdInt == null) return const SizedBox.shrink();

      final index = containers.indexWhere((c) => c.id == containerIdInt);

      // Si el contenedor ya no está en la lista (por borrado o filtro),
      // abortamos el renderizado de este nodo inmediatamente.
      if (index == -1) return const SizedBox.shrink();

      container = containers[index];
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
                ? theme.colorScheme.primary
                : isSection
                ? theme.colorScheme.secondary
                : theme.hintColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.data.toString(),
              style: TextStyle(
                fontSize: isContainer ? 14 : 12,
                fontWeight: isSection ? FontWeight.bold : FontWeight.normal,
                color: isContainer
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    return Consumer<ContainerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.containers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final containers =
            provider.containers; // La lista siempre estará actualizada.

        // 1. Construir el árbol con la lista actualizada
        final root = _buildTreeRoot(containers);

        // Muestra un indicador de carga si es necesario
        if (containers.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return TreeView.simple(
          key: ValueKey('tree_total_${containers.length}'),
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
          indentation: Indentation(
            style: IndentStyle.roundJoint,
            width: 24,
            color: theme.dividerColor,
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
          title: Text(AppLocalizations.of(context)!.renameContainer),
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
                  return AppLocalizations.of(context)!.nameCannotBeEmpty;
                }
                if (value.trim() == container.name) {
                  return AppLocalizations.of(context)!.nameSameAsCurrent;
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(AppLocalizations.of(context)!.rename),
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
        ToastService.success(
          AppLocalizations.of(context)!.containerRenamed(newName),
        );
      } catch (e) {
        if (!context.mounted) return;
        ToastService.error(
          AppLocalizations.of(context)!.errorRenaming(e.toString()),
        );
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
        PopupMenuItem<ContainerAction>(
          value: ContainerAction.rename,
          child: Text(AppLocalizations.of(context)!.rename),
        ),
        PopupMenuItem<ContainerAction>(
          value: ContainerAction.delete,
          child: Text(AppLocalizations.of(context)!.delete),
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
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeletion),
          content: Text(
            AppLocalizations.of(
              context,
            )!.confirmDeleteContainer(container.name),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(color: theme.colorScheme.error),
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
        ToastService.success(
          AppLocalizations.of(context)!.containerDeleted(container.name),
        );
      } catch (e) {
        if (!context.mounted) return;
        ToastService.error(
          AppLocalizations.of(context)!.errorDeletingContainer(e.toString()),
        );
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
