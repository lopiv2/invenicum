import 'package:flutter/material.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/widgets/new_container_dialog.dart';
import 'package:invenicum/widgets/sidebar_shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';

class SidebarContainerHeader extends StatelessWidget {
  const SidebarContainerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ContainerProvider>();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.containers.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            // Ahora usamos los nombres sin guion bajo
            AddIconButton(
              isLoading: provider.isLoading,
              onTap: () => _showNewContainerDialog(context),
            ),
            ActionIconButton(
              icon: Icons.refresh_rounded,
              onTap: provider.isLoading
                  ? null
                  : () => context.read<ContainerProvider>().loadContainers(),
            ),
          ],
        ),
      ),
    );
  }

  // Mueve aquí la lógica del diálogo para que el componente sea autónomo
  Future<void> _showNewContainerDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          const NewContainerDialog(), // Usamos el nuevo widget
    );

    if (result != null) {
      final provider = context.read<ContainerProvider>();
      try {
        await provider.createNewContainer(
          result['name'],
          result['description'].isEmpty ? null : result['description'],
          isCollection: result['isCollection'],
        );
        ToastService.success('Contenedor creado');
      } catch (e) {
        ToastService.error('Error: $e');
      }
    }
  }
}
