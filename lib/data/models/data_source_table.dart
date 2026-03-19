// (Al final del archivo asset_data_table.dart)

import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/screens/asset_types/local_widgets/condition_badge_widget.dart';
import 'package:invenicum/widgets/ui/price_display_widget.dart';
import 'package:invenicum/data/models/location.dart'; // 🔑 Importar Location

class InventoryDataSource extends DataTableSource {
  final InventoryItemProvider itemProvider;
  final PreferencesProvider preferencesProvider;
  final AssetType assetType;
  List<InventoryItem> _items;
  final BuildContext context;
  final Function(InventoryItem) deleteCallback;
  final Function(InventoryItem) editCallback;
  final Function(InventoryItem) copyCallback;
  final Function(InventoryItem) printLabelCallback;
  final Function(InventoryItem) onRowTap;
  final List<Location> availableLocations;
  final int containerId;

  InventoryDataSource({
    required this.itemProvider,
    required this.preferencesProvider,
    required this.assetType,
    required List<InventoryItem> items,
    required this.context,
    required this.deleteCallback,
    required this.editCallback,
    required this.copyCallback,
    required this.printLabelCallback,
    required this.availableLocations,
    required this.containerId,
    required this.onRowTap,
  }) : _items = items;

  void updateItems(List<InventoryItem> newItems) {
    final Map<int, InventoryItem> oldMap = {for (var i in _items) i.id: i};

    bool changed = false;

    for (final item in newItems) {
      final old = oldMap[item.id];

      if (old == null || old.updatedAt != item.updatedAt) {
        changed = true;
        break;
      }
    }

    if (changed || newItems.length != _items.length) {
      _items = newItems;
      notifyListeners();
    }
  }

  // 🔑 NUEVO: Función auxiliar para obtener el nombre de la ubicación
  String _getLocationName(int? locationId) {
    if (locationId == null) {
      return '—';
    }
    final location = availableLocations.firstWhere(
      (loc) => loc.id == locationId,
      orElse: () => Location(
        id: locationId,
        name: locationId.toString(),
        containerId: containerId,
      ),
    );
    return location.name;
  }

  // Método copiado de _AssetDataTableState (Necesario para las celdas)
  void _showImageDialog(BuildContext context, String fullImageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 0.1,
              maxScale: 4.0,
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No se pudo cargar la imagen.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text(
                      'Asegúrate de que la URL es correcta y el servidor está activo.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // 🔑 MÉTODO AUXILIAR PARA RENDERIZAR EL VALOR DE LA CELDA
  // ==========================================================
  DataCell _buildCustomFieldCell(
    BuildContext context,
    CustomFieldDefinition fieldDef,
    dynamic fieldValue,
  ) {
    final String displayValue = fieldValue?.toString() ?? '—';

    // 1. Campo Booleano (Check/Uncheck Icon)
    if (fieldDef.type == CustomFieldType.boolean) {
      final isChecked = fieldValue == true;
      return DataCell(
        Tooltip(
          message: isChecked ? 'Verdadero' : 'Falso',
          child: Icon(
            isChecked ? Icons.check_circle : Icons.cancel,
            color: isChecked ? Colors.green.shade600 : Colors.red.shade600,
            size: 20,
          ),
        ),
      );
    }

    // 2. Campo URL (Clicable)
    if (fieldDef.type == CustomFieldType.url &&
        displayValue != '—' &&
        displayValue.isNotEmpty) {
      return DataCell(
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => AppUtils.launchUrlWeb(displayValue),
            child: Tooltip(
              message: 'Abrir enlace: $displayValue',
              child: Text(
                displayValue,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    }
    // 🔑 3. Campo de Precio (Conversión y Formato)
    if (fieldDef.type == CustomFieldType.price && fieldValue != null) {
      return DataCell(
        PriceDisplayWidget(
          value: fieldValue,
          fontSize: 14, // Tamaño más adecuado para una tabla
          // Puedes pasarle un estilo personalizado si quieres mantener el bold
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      );
    }

    // 3. Otros Tipos (Texto, Número, Desplegable, etc.)
    return DataCell(
      Tooltip(
        message: displayValue,
        child: Text(displayValue, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  // --- Métodos de DataTableSource ---

  @override
  @override
  DataRow? getRow(int index) {
    // 1. Calcular el índice de inicio de la página actual (Base 0)
    final int startIndex =
        (itemProvider.currentPage - 1) * itemProvider.itemsPerPage;

    // 2. Calcular el índice local
    final int localIndex = index - startIndex;

    if (localIndex < 0 || localIndex >= _items.length) {
      return null;
    }

    final item = _items[localIndex];

    // --- LÓGICA DE COLORES DE STOCK ---
    Color? rowColor;
    final double currentQty = item.quantity.toDouble();
    final double minStock = item.minStock.toDouble();

    if (minStock > 0 && currentQty < minStock) {
      // Calculamos cuánto representa la cantidad actual respecto al mínimo
      // Ejemplo: si tengo 4 y el mínimo es 10, tengo el 40% (Ratio 0.4)
      final double ratio = currentQty / minStock;

      if (ratio < 0.5) {
        // MENOS del 50% del stock mínimo -> ROJO
        rowColor = Colors.red.withValues(alpha: 0.25);
      } else {
        // MÁS del 50% (pero por debajo del mínimo) -> NARANJA
        rowColor = Colors.orange.withValues(alpha: 0.25);
      }
    }

    final String? imageUrl = item.images.isNotEmpty
        ? item.images.first.url
        : null;
    final String fullImageUrl = imageUrl != null
        ? '${Environment.apiUrl}$imageUrl'
        : '';

    final List<DataCell> cells = [
      // 1. Célula de Imagen
      DataCell(
        Center(
          child: Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: imageUrl != null
                ? Tooltip(
                    message: 'Ver imagen',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showImageDialog(context, fullImageUrl),
                        child: Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 25,
                                color: Colors.grey,
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image_not_supported,
                    size: 25,
                    color: Colors.grey,
                  ),
          ),
        ),
      ),
      // 2. Nombre
      DataCell(
        Tooltip(
          message: item.name,
          child: Text(item.name, overflow: TextOverflow.ellipsis),
        ),
      ),

      // 3. Cantidad
      DataCell(
        Text(
          item.quantity.toString(),
          style: TextStyle(
            fontWeight: rowColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),

      // 4. Stock minimo
      DataCell(Text(item.minStock.toString())),

      // 5. Ubicación
      DataCell(
        Tooltip(
          message: _getLocationName(item.locationId),
          child: Text(
            _getLocationName(item.locationId),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(ConditionBadgeWidget(condition: item.condition)),
      // 6. Descripción
      DataCell(
        Tooltip(
          message: item.description ?? '—',
          child: Text(item.description ?? '—', overflow: TextOverflow.ellipsis),
        ),
      ),
      DataCell(
        Tooltip(
          message: item.barcode ?? '—',
          child: Text(item.barcode ?? '—', overflow: TextOverflow.ellipsis),
        ),
      ),
      DataCell(
        PriceDisplayWidget(
          value: item.marketValue,
          fontSize: 14,
          color:
              Colors.black87, // Color más neutro para la tabla si se prefiere
        ),
      ),
    ];

    // 5+. Campos Personalizados
    for (final fieldDef in assetType.fieldDefinitions) {
      final Map<String, dynamic> customValues = item.customFieldValues ?? {};

      final fieldValue =
          customValues[fieldDef.id.toString()] ??
          customValues[fieldDef.id] ??
          customValues[fieldDef.name];

      cells.add(_buildCustomFieldCell(context, fieldDef, fieldValue));
    }

    // Última celda: Acciones
    cells.add(
      DataCell(
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Editar',
                onPressed: () => editCallback(item),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Copiar',
                onPressed: () => copyCallback(item),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.print, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Imprimir Etiqueta',
                onPressed: () => printLabelCallback(item),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.red[600],
                tooltip: 'Eliminar',
                onPressed: () => deleteCallback(item),
              ),
            ],
          ),
        ),
      ),
    );

    return DataRow(
      cells: cells,
      key: ValueKey(item.id),
      color: WidgetStateProperty.resolveWith<Color?>((states) => rowColor),
      // 🔑 ESTO HACE QUE LA FILA SEA CLICABLE
      onSelectChanged: (selected) {
        if (selected != null) {
          onRowTap(item);
        }
      },
    );
  }

  @override
  int get rowCount => _items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
