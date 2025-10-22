// widgets/asset_list_header.dart

import 'package:flutter/material.dart';
import '../models/asset_type_model.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Expanded(
          child: Text(
            'Listado de Activos: "${assetType.name}"',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 20),
        // Botones de Acción
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón para Abrir Filtro de Conteo
            ElevatedButton.icon(
              onPressed: onShowCountFilterDialog,
              icon: const Icon(Icons.pin_drop),
              label: Text(
                selectedCountFieldId == null
                    ? 'Filtro Contador'
                    : 'Filtro Activo',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCountFieldId != null
                    ? Theme.of(context).colorScheme.inversePrimary
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: onImportCSV,
              icon: const Icon(Icons.file_upload),
              label: const Text('Importar CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            // Botón de Añadir Activo
            ElevatedButton.icon(
              onPressed: onGoToCreateAsset,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Activo'),
            ),
          ],
        ),
      ],
    );
  }
}