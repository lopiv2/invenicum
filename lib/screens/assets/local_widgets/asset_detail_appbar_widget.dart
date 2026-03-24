import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final InventoryItem item;
  final String containerId;
  final String assetTypeId;
  final AppLocalizations l10n;
  final Function(int) onNavigateSibling;

  const AssetDetailAppBar({
    super.key,
    required this.item,
    required this.containerId,
    required this.assetTypeId,
    required this.l10n,
    required this.onNavigateSibling,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0, // Evita que cambie de color al hacer scroll
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.pop(),
      ),
      actions: [
        // Navegación entre hermanos
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
          onPressed: () => onNavigateSibling(-1),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 32),
          onPressed: () => onNavigateSibling(1),
        ),

        const SizedBox(width: 8),

        // Botón de Editar
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ActionChip(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            label: Text(
              l10n.edit,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            avatar: Icon(
              Icons.edit_note_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.goNamed(
              RouteNames.assetEdit,
              pathParameters: {
                'containerId': containerId,
                'assetTypeId': assetTypeId,
                'assetId': item.id.toString(),
              },
              extra: item,
            ),
          ),
        ),
      ],
    );
  }
}
