import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/widgets/layout/container_tree_view.dart';
import 'package:provider/provider.dart';

class SidebarTreeSection extends StatefulWidget {
  const SidebarTreeSection({super.key});

  @override
  State<SidebarTreeSection> createState() => _SidebarTreeSectionState();
}

class _SidebarTreeSectionState extends State<SidebarTreeSection> {
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
                    // 🔑 MEJORA: La key ahora incluye la suma de listas y préstamos
                    // Si cualquiera de esos números cambia, el TreeView se refresca sí o sí.
                    key: ValueKey(
                      'tree_v3_${provider.containers.length}_${_getTotalItemsCount(provider)}'
                    ),
                    onDeleteContainer: provider.deleteContainer,
                    onRenameContainer: provider.renameContainer,
                    onContainerTap: (container, subSection) {
                      // Navegación lógica opcional
                    },
                  ),
          ),
        );
      },
    );
  }

  // Función auxiliar para forzar el refresco de la Key
  int _getTotalItemsCount(ContainerProvider provider) {
    return provider.containers.fold(0, (sum, c) => sum + c.dataLists.length);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          AppLocalizations.of(context)!.createFirstContainer,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}