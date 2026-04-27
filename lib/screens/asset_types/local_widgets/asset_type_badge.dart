import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetTypeBadge extends StatelessWidget {
  final bool isCollection;

  const AssetTypeBadge({
    super.key,
    required this.isCollection,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos l10n y theme directamente desde el contexto del widget
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final color = isCollection ? Colors.lightGreen : theme.primaryColor;
    final textColor = isCollection ? Colors.green[800] : theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // Nota: withValues es para Flutter 3.27+. 
        // Si usas una versión anterior, cambia a color.withOpacity(0.15)
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCollection ? Icons.auto_awesome_motion : Icons.inventory_2,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            (isCollection ? l10n.collectionLabel : l10n.inventoryLabel).toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}