import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/widgets/container_tree_view.dart';
import 'package:provider/provider.dart';

class SidebarTreeSection extends StatelessWidget {
  const SidebarTreeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContainerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.containers.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: provider.containers.isEmpty
                ? _buildEmptyState(context)
                : ContainerTreeView(
                    key: ValueKey(
                      'tree_v2_${provider.containers.length}_${provider.isLoading}',
                    ),
                    onDeleteContainer: provider.deleteContainer,
                    onRenameContainer: provider.renameContainer,
                    // 🚩 AQUÍ ESTABA EL ERROR: Agregamos el argumento faltante
                    onContainerTap: (container, subSection) {
                      // Por ahora vacío, o puedes implementar lógica de navegación aquí
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          AppLocalizations.of(context)!.createFirstContainer,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.6)),
        ),
      ),
    );
  }
}
