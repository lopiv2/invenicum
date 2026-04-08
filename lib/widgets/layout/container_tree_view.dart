import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/loan_provider.dart';
import '../../data/models/container_node.dart';
import '../../providers/container_provider.dart';

enum ContainerAction { rename, delete }

class ContainerTreeView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<ContainerProvider, LoanProvider>(
      builder: (context, containerProvider, loanProvider, _) {
        final containers = containerProvider.containers;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: containers.length,
          itemBuilder: (context, index) {
            final container = containers[index];

            return Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ListTileTheme(
                horizontalTitleGap: 10,
                child: ExpansionTile(
                  key: PageStorageKey('container_${container.id}'),
                  leading: Icon(
                    container.isCollection
                        ? Icons.collections_outlined
                        : Icons.inventory_2_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onSecondaryTapDown: kIsWeb
                              ? null
                              : (details) => _showContextMenu(
                                  context,
                                  details.globalPosition,
                                  container,
                                ),
                          child: Text(
                            container.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuButton<ContainerAction>(
                        tooltip: '',
                        onSelected: (result) =>
                            _handleContextAction(context, container, result),
                        itemBuilder: (context) =>
                            _buildContextMenuItems(context),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_horiz,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.only(left: 10),
                  children: [
                    _buildSubItem(
                      context,
                      icon: Icons.category_outlined,
                      label:
                          "${AppLocalizations.of(context)!.assetTypes} (${container.assetTypes.length})",
                      onTap: () => context.goNamed(
                        RouteNames.assetTypes,
                        pathParameters: {
                          'containerId': container.id.toString(),
                        },
                      ),
                    ),
                    _buildSubItem(
                      context,
                      icon: Icons.place_outlined,
                      label:
                          "${AppLocalizations.of(context)!.locations} (${container.locations.length})",
                      onTap: () => context.goNamed(
                        RouteNames.locations,
                        pathParameters: {
                          'containerId': container.id.toString(),
                        },
                      ),
                    ),
                    _buildSubItem(
                      context,
                      icon: Icons.handshake_outlined,
                      label:
                          "${AppLocalizations.of(context)!.loans} (${loanProvider.loans.length})",
                      onTap: () => context.goNamed(
                        RouteNames.loans,
                        pathParameters: {
                          'containerId': container.id.toString(),
                        },
                      ),
                    ),
                    _buildSubItem(
                      context,
                      icon: Icons.list_alt,
                      label:
                          "${AppLocalizations.of(context)!.datalists} (${container.dataLists.length})",
                      onTap: () => context.goNamed(
                        RouteNames.dataLists,
                        pathParameters: {
                          'containerId': container.id.toString(),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, size: 16, color: theme.colorScheme.secondary),
      title: Text(label, style: theme.textTheme.bodySmall),
      onTap: onTap,
    );
  }

  // --- CONTEXT MENU LOGIC ---
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
      items: _buildContextMenuItems(context),
    ).then((result) => _handleContextAction(context, container, result));
  }

  List<PopupMenuEntry<ContainerAction>> _buildContextMenuItems(
    BuildContext context,
  ) {
    return [
      PopupMenuItem(
        value: ContainerAction.rename,
        child: Text(AppLocalizations.of(context)!.rename),
      ),
      PopupMenuItem(
        value: ContainerAction.delete,
        child: Text(AppLocalizations.of(context)!.delete),
      ),
    ];
  }

  void _handleContextAction(
    BuildContext context,
    ContainerNode container,
    ContainerAction? result,
  ) {
    if (result == ContainerAction.rename) {
      _showRenameDialog(context, container);
    }
    if (result == ContainerAction.delete) {
      _showDeleteConfirmationDialog(context, container);
    }
  }

  // --- DIALOGS (REUSING YOUR LOGIC) ---
  Future<void> _showRenameDialog(
    BuildContext context,
    ContainerNode container,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: container.name);
    final formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameContainer),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            validator: (v) =>
                (v == null || v.isEmpty)
                    ? l10n.fieldRequiredWithName(l10n.containerName)
                    : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.rename),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onRenameContainer(container.id, controller.text.trim());
    }
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    ContainerNode container,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.confirmDeleteContainer(container.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onDeleteContainer(container.id);
    }
  }
}
