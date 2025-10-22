// (Al final del archivo asset_data_table.dart)

import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class InventoryDataSource extends DataTableSource {
  final InventoryItemProvider itemProvider;
  final AssetType assetType;
  List<InventoryItem> _items;
  final BuildContext context;
  final Function(InventoryItem) deleteCallback;
  final Function(InventoryItem) editCallback;
  final Function(InventoryItem) copyCallback;

  InventoryDataSource({
    required this.itemProvider,
    required this.assetType,
    required List<InventoryItem> items, // Se recibe la lista inicial
    required this.context,
    required this.deleteCallback,
    required this.editCallback,
    required this.copyCallback,
  }) : _items = items; // Asignación inicial

  void updateItems(List<InventoryItem> newItems) {
    _items = newItems;
    // Notifica a PaginatedDataTable2 que la fuente de datos ha cambiado.
    notifyListeners();
  }

  // --- Lógica para Abrir URL ---
  Future<void> _launchUrl(String url) async {
    // Aseguramos que el URL tenga un esquema si es necesario
    String fullUrl = url.startsWith('http') ? url : 'https://$url';
    final Uri uri = Uri.parse(fullUrl);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // En caso de fallo, mostramos un mensaje (usando un ScaffoldMessenger si estuviera disponible)
        debugPrint('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL $uri: $e');
    }
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

  // --- Métodos de DataTableSource ---

  @override
  DataRow? getRow(int index) {
    // 🚨 AJUSTE CRUCIAL: Convertir el índice GLOBAL (dado por PaginatedDataTable2)
    // al índice LOCAL (dentro de tu sublista 'items').

    // 1. Calcular el índice de inicio de la página actual (Base 0)
    final int startIndex =
        (itemProvider.currentPage - 1) * itemProvider.itemsPerPage;

    // 2. Calcular el índice local
    final int localIndex = index - startIndex;

    // 3. Comprobar si el índice local es válido en la sublista
    if (localIndex < 0 || localIndex >= _items.length) {
      // Esto es normal si la PaginatedDataTable2 llama a getRow con un índice
      // que no está en la sublista cargada actualmente (por ejemplo, si el Provider
      // aún no ha terminado de cargar la nueva página).
      return null;
    }

    final item = _items[localIndex]; // ¡Usamos el índice LOCAL!

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
      DataCell(Text(item.name)),
      // 3. Descripción
      DataCell(Text(item.description ?? '—', overflow: TextOverflow.ellipsis)),
    ];

    // 4. Campos Personalizados
    for (final fieldDef in assetType.fieldDefinitions) {
      final fieldValue = item.customFieldValues?[fieldDef.id.toString()] ?? '—';
      // 🔑 MODIFICACIÓN: Detectar tipo 'url' y hacerlo clicable
      if (fieldDef.type == CustomFieldType.url &&
          fieldValue != '—' &&
          fieldValue.isNotEmpty) {
        cells.add(
          DataCell(
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _launchUrl(fieldValue),
                child: Tooltip(
                  message: 'Abrir enlace: $fieldValue',
                  child: Text(
                    fieldValue,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        // Para todos los demás tipos de campos
        cells.add(DataCell(Text(fieldValue, overflow: TextOverflow.ellipsis)));
      }
    }

    // 5. Acciones
    cells.add(
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Editar',
              onPressed: () => editCallback(item),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Copiar',
              onPressed: () => copyCallback(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red[600],
              tooltip: 'Eliminar',
              onPressed: () => deleteCallback(item),
            ),
          ],
        ),
      ),
    );

    return DataRow(
      cells: cells,
      key: ValueKey(item.id),
    ); // Usar una key es buena práctica
  }

  @override
  int get rowCount => itemProvider.totalItems; // CLAVE: totalItems debe ser el TOTAL FILTRADO/SIN PAGINAR

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
