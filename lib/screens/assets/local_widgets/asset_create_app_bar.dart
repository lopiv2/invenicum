import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Widget para el AppBar personalizado de la pantalla de crear activo
class AssetCreateAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String assetTypeName;

  const AssetCreateAppBarWidget({
    super.key,
    required this.assetTypeName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surfaceContainerLowest,
      surfaceTintColor: colorScheme.primary,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.newAssetLabel,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              assetTypeName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
