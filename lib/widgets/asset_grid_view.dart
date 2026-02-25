// widgets/asset_grid_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/environment.dart';
import '../../models/asset_type_model.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_item_provider.dart';
import '../../services/toast_service.dart';

class AssetGridView extends StatefulWidget {
  final AssetType assetType;
  final List<InventoryItem> items;
  final int containerId;
  final int assetTypeId;

  const AssetGridView({
    super.key,
    required this.assetType,
    required this.items,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  State<AssetGridView> createState() => _AssetGridViewState();
}

class _AssetGridViewState extends State<AssetGridView> {
  // Configuración inicial más equilibrada para pantallas grandes/medianas
  int _columnsCount = 4;
  final int minColumns = 2;
  final int maxColumns = 8;

  void _viewAssetDetails(BuildContext context, InventoryItem item) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}',
    );
  }

  // --- FUNCIÓN PARA VER IMAGEN EN GRANDE ---
  void _showFullImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Imagen con Hero para una transición suave si lo deseas
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            // Botón de cerrar y título
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editAsset(BuildContext context, InventoryItem item) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}/edit',
      extra: item,
    );
  }

  void _deleteAsset(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Activo'),
        content: Text('¿Confirmas que deseas eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<InventoryItemProvider>().deleteInventoryItem(
                item.id,
                widget.containerId,
                widget.assetTypeId,
              );
              ToastService.success('Activo eliminado.');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _getFullImageUrl(InventoryItem item) {
    final String? imageUrl = item.images.isNotEmpty
        ? item.images.first.url
        : null;
    return imageUrl != null ? '${Environment.apiUrl}$imageUrl' : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemProvider = context.watch<InventoryItemProvider>();

    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.hintColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              (itemProvider.filters.isEmpty &&
                      itemProvider.globalSearchTerm == null)
                  ? 'No hay activos creados aún.'
                  : 'Sin coincidencias.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // --- CONTROL DE COLUMNAS ESTILIZADO ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: 18,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Vista: $_columnsCount col.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: _columnsCount.toDouble(),
                      min: minColumns.toDouble(),
                      max: maxColumns.toDouble(),
                      divisions: maxColumns - minColumns,
                      onChanged: (val) =>
                          setState(() => _columnsCount = val.round()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- GRID DE ACTIVOS ---
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double spacing = 16.0;

              return GridView.builder(
                padding: EdgeInsets.fromLTRB(spacing, 0, spacing, spacing),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columnsCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  // Ajuste dinámico de la altura: Si hay muchas columnas, hacemos la tarjeta más alta proporcionalmente
                  childAspectRatio: _columnsCount > 6 ? 0.5 : 0.8,
                ),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final fullImageUrl = _getFullImageUrl(item);

                  return _buildModernAssetCard(
                    context,
                    item,
                    fullImageUrl,
                    theme,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernAssetCard(
    BuildContext context,
    InventoryItem item,
    String url,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            InkWell(
              onTap: () => _viewAssetDetails(context, item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- IMAGEN SUPERIOR ---
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        url.isNotEmpty
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholderIcon(theme),
                              )
                            : _buildPlaceholderIcon(theme),
                        // Gradiente sutil inferior para que el nombre destaque
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Menú de acciones rápido (Overlay)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: _buildQuickActions(context, item),
                        ),
                      ],
                    ),
                  ),

                  // --- INFORMACIÓN ---
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  item.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _columnsCount > 6 ? 11 : 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description ?? 'Sin descripción',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontSize: 10,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          // Campos personalizados rápidos (solo si hay espacio)
                          if (_columnsCount < 6)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                top: 20,
                              ), // Un solo respiro pequeño antes de los campos
                              child: Wrap(
                                // Usamos Wrap en lugar de Column para que si son cortos quepan varios
                                spacing: 20, // Espacio horizontal entre campos
                                runSpacing:
                                    10, // 🎯 CLAVE: Espacio vertical mínimo entre líneas de campos
                                children: widget.assetType.fieldDefinitions
                                    .take(6)
                                    .map((def) {
                                      final value =
                                          item.customFieldValues?[def.id
                                              .toString()] ??
                                          '—';
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ), // Padding interno mínimo
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '${def.name}: $value',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColor,
                                            height:
                                                1.1, // Reduce la altura de la línea del texto
                                          ),
                                          maxLines: 1,
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (url.isNotEmpty)
              Positioned(
                top: 4,
                left: 8,
                child: Tooltip(
                  message: 'Ver Imagen',
                  child: _miniActionButton(
                    icon: Icons.zoom_in_rounded,
                    onPressed: () => _showFullImage(context, url, item.name),
                    color: Colors.black54,
                    iconColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),

      // --- BOTÓN DE LUPA (Zoom) ---
    );
  }

  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Container(
      color: theme.primaryColor.withOpacity(0.03),
      child: Icon(
        Icons.inventory_2_outlined,
        color: theme.primaryColor.withOpacity(0.1),
        size: 32,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, InventoryItem item) {
    return Row(
      children: [
        _miniActionButton(
          icon: Icons.edit_rounded,
          onPressed: () => _editAsset(context, item),
          color: Colors.white,
        ),
        _miniActionButton(
          icon: Icons.delete_outline_rounded,
          onPressed: () => _deleteAsset(context, item),
          color: Colors.white,
          iconColor: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _miniActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(icon, size: 14, color: iconColor ?? Colors.black87),
        ),
      ),
    );
  }
}
