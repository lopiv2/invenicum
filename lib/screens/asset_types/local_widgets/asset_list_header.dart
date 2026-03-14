// widgets/asset_list_header.dart

import 'package:flutter/material.dart';
import '../../../data/models/asset_type_model.dart';

class AssetListHeader extends StatelessWidget {
  final AssetType assetType;
  final VoidCallback onGoToCreateAsset;
  final VoidCallback onShowCountFilterDialog;
  final VoidCallback onImportCSV;
  final String? selectedCountFieldId;

  const AssetListHeader({
    super.key,
    required this.assetType,
    required this.onGoToCreateAsset,
    required this.onShowCountFilterDialog,
    required this.onImportCSV,
    this.selectedCountFieldId,
  });

  @override
  Widget build(BuildContext context) {
    // Detectamos si el ancho es de móvil
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con estilo Bento
        Text(
          'Listado de Activos: "${assetType.name}"',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),

        // Usamos Wrap en lugar de Row para que los botones "salten" de línea si no caben
        Wrap(
          spacing: 8, // Espacio horizontal entre botones
          runSpacing: 8, // Espacio vertical entre líneas si hay salto
          children: [
            // Botón Filtro (con ancho adaptativo)
            _buildActionButton(
              context,
              onPressed: onShowCountFilterDialog,
              icon: Icons.pin_drop,
              label: selectedCountFieldId == null
                  ? 'Filtro Contador'
                  : 'Filtro Activo',
              color: selectedCountFieldId != null
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).colorScheme.surfaceVariant,
              isMobile: isMobile,
            ),

            // Botón Importar
            _buildActionButton(
              context,
              onPressed: onImportCSV,
              icon: Icons.file_upload,
              label: 'Importar CSV',
              color: Theme.of(context).colorScheme.surfaceVariant,
              isMobile: isMobile,
            ),

            // Botón Añadir (Botón de acción principal)
            _buildActionButton(
              context,
              onPressed: onGoToCreateAsset,
              icon: Icons.add,
              label: 'Añadir Activo',
              color: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              isMobile: isMobile,
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }

  // Helper para crear botones consistentes y responsivos
  Widget _buildActionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
    required bool isMobile,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: textColor),
      label: Text(label, style: TextStyle(color: textColor, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
