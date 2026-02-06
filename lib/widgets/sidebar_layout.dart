import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/widgets/container_tree_view.dart';

class SidebarLayout extends StatefulWidget {
  const SidebarLayout({super.key});

  @override
  State<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Selectores precisos para rendimiento
    final containers = context.select<ContainerProvider, List>(
      (p) => p.containers,
    );
    final isLoading = context.select<ContainerProvider, bool>(
      (p) => p.isLoading,
    );
    final containerProvider = context.read<ContainerProvider>();

    // Obtener la ruta actual para marcar el item seleccionado
    final String location = GoRouterState.of(context).uri.toString();

    return Container(
      width: 260,
      decoration: BoxDecoration(
        // OPCIÓN A: Color Sólido Suave (Estilo moderno/limpio)
        //color: colorScheme.surfaceContainerLow, // Un tono ligeramente distinto al fondo principal

        // OPCIÓN B: Si prefieres un degradado sutil, descomenta esto:
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surface, colorScheme.primary.withOpacity(0.05)],
        ),

        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ACCESOS DIRECTOS ---
            _SidebarNavButton(
              icon: Icons.dashboard_customize_outlined,
              title: AppLocalizations.of(context)!.dashboard,
              selected: location == '/dashboard',
              onTap: () => context.go('/dashboard'),
            ),

            const SizedBox(height: 6),

            // --- SECCIÓN DE CONTENEDORES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.containers.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  _AddIconButton(
                    isLoading: isLoading,
                    onTap: () => _showNewContainerDialog(context),
                  ),
                  _ActionIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: isLoading ? null : containerProvider.loadContainers,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: isLoading && containers.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : containers.isEmpty
                    ? _buildEmptyState()
                    : ContainerTreeView(
                        // Key dinámica para evitar RangeError al borrar
                        key: ValueKey('tree_sidebar_${containers.length}'),
                        onDeleteContainer: _handleDeleteContainer,
                        onRenameContainer: _handleRenameContainer,
                        onContainerTap: (container, subSection) {
                          // Navegación handled dentro del TreeView o aquí
                        },
                      ),
              ),
            ),

            // --- FOOTER (Preferencias / Alertas) ---
            const Divider(height: 1),
            SizedBox(

              child: Column(
                children: [
                  _SidebarNavButton(
                    icon: Icons.notifications_none_rounded,
                    title: AppLocalizations.of(context)!.alerts,
                    selected: location == '/alerts',
                    onTap: () => context.go('/alerts'),
                    compact: true,
                  ),
                  _SidebarNavButton(
                    icon: Icons.settings_outlined,
                    title: AppLocalizations.of(context)!.preferences,
                    selected: location == '/preferences',
                    onTap: () => context.go('/preferences'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          AppLocalizations.of(context)!.createFirstContainer,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE ACCIONES ---

  Future<void> _handleDeleteContainer(int containerId) async {
    await context.read<ContainerProvider>().deleteContainer(containerId);
  }

  Future<void> _handleRenameContainer(int containerId, String newName) async {
    await context.read<ContainerProvider>().renameContainer(
      containerId,
      newName,
    );
  }

  Future<void> _showNewContainerDialog(BuildContext context) async {
    final containerProvider = context.read<ContainerProvider>();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isCollection = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Nuevo Contenedor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej: Almacén Principal',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('¿Es una colección?'),
                  subtitle: const Text('Habilita vistas de exposición y valor'),
                  value: isCollection,
                  onChanged: (val) => setDialogState(() => isCollection = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context, {
                    'name': nameController.text.trim(),
                    'description': descController.text.trim(),
                    'isCollection': isCollection,
                  });
                }
              },
              child: const Text('Crear Contenedor'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        await containerProvider.createNewContainer(
          result['name'],
          result['description'].isEmpty ? null : result['description'],
          isCollection: result['isCollection'],
        );
        if (mounted) ToastService.success('Contenedor creado');
      } catch (e) {
        if (mounted) ToastService.error('Error: $e');
      }
    }
  }
}

// --- COMPONENTES ATÓMICOS MODERNOS ---

class _SidebarNavButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _SidebarNavButton({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 1 : 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryFixedDim : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected ? [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddIconButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AddIconButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
      onPressed: isLoading ? null : onTap,
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      onPressed: onTap,
    );
  }
}
