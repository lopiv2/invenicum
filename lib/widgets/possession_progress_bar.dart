import 'package:flutter/material.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/inventory_item.dart';

class PossessionProgressBar extends StatelessWidget {
  final AssetType assetType;
  final List<InventoryItem> inventoryItems;

  const PossessionProgressBar({
    super.key,
    required this.assetType,
    required this.inventoryItems,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay campo de posesión configurado, no mostrar nada
    if (assetType.possessionFieldId == null || 
        assetType.possessionFieldId!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Contar total de items
    final totalItems = inventoryItems.length;
    
    // Contar items en posesión (campo booleano = true)
    int possessionCount = 0;
    for (var item in inventoryItems) {
      final customValues = item.customFieldValues ?? {};
      final fieldValue = customValues[assetType.possessionFieldId!];
      
      if (fieldValue is bool && fieldValue == true) {
        possessionCount++;
      } else if (fieldValue is int && fieldValue == 1) {
        possessionCount++;
      } else if (fieldValue is String && 
                 (fieldValue.toLowerCase() == 'true' || fieldValue == '1')) {
        possessionCount++;
      }
    }

    // Calcular el porcentaje
    final percentage = totalItems > 0 ? (possessionCount / totalItems) : 0.0;
    final percentageText = (percentage * 100).toStringAsFixed(1);

    // Obtener el nombre del campo de posesión
    String possessionFieldName = 'En Posesión';
    try {
      final field = assetType.fieldDefinitions.firstWhere(
        (field) => field.id.toString() == assetType.possessionFieldId,
      );
      possessionFieldName = field.name;
    } catch (e) {
      // Si no encuentra el campo, usar el nombre por defecto
      possessionFieldName = 'En Posesión';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con nombre del campo y porcentaje
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de $possessionFieldName',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$possessionCount / $totalItems ($percentageText%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorForProgress(percentage),
            ),
          ),
        ),
      ],
    );
  }

  /// Retorna un color basado en el porcentaje
  /// Rojo (0%) → Amarillo (50%) → Verde (100%)
  Color _getColorForProgress(double percentage) {
    if (percentage < 0.5) {
      // Rojo a Amarillo (0% - 50%)
      return Color.lerp(
        Colors.red,
        Colors.orange,
        percentage * 2,
      )!;
    } else {
      // Amarillo a Verde (50% - 100%)
      return Color.lerp(
        Colors.orange,
        Colors.green,
        (percentage - 0.5) * 2,
      )!;
    }
  }
}
