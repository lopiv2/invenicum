// widgets/asset_grid_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/environment.dart';
import '../../../data/models/asset_type_model.dart';
import '../../../data/models/inventory_item.dart';
import '../../../../providers/inventory_item_provider.dart';
import '../../../data/services/toast_service.dart';

class AssetGridView extends StatefulWidget {
  final AssetType assetType;
  final List<InventoryItem> items;
  final int containerId;
  final int assetTypeId;
  final TextEditingController? searchController;

  const AssetGridView({
    super.key,
    required this.assetType,
    required this.items,
    required this.containerId,
    required this.assetTypeId,
    this.searchController,
  });

  @override
  State<AssetGridView> createState() => _AssetGridViewState();
}

class _AssetGridViewState extends State<AssetGridView> {
  int _columnsCount = 4;
  final int minColumns = 2;
  final int maxColumns = 8;

  // Items filtrados localmente según el texto de búsqueda.
  List<InventoryItem> get _filteredItems {
    final term = widget.searchController?.text.trim().toLowerCase() ?? '';
    if (term.isEmpty) return widget.items;
    return widget.items.where((item) {
      return item.name.toLowerCase().contains(term) ||
          (item.description ?? '').toLowerCase().contains(term) ||
          (item.location?.name ?? '').toLowerCase().contains(term) ||
          (item.customFieldValues?.values
                  .any((v) => v.toString().toLowerCase().contains(term)) ??
              false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    widget.searchController?.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController?.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _viewAssetDetails(BuildContext context, InventoryItem item) {
    context.go(
      '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}',
    );
  }

  void _showFullImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
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
    final String? imageUrl =
        item.images.isNotEmpty ? item.images.first.url : null;
    return imageUrl != null ? '${Environment.apiUrl}$imageUrl' : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayItems = _filteredItems;
    final hasSearch =
        (widget.searchController?.text.trim().isNotEmpty) ?? false;

    if (displayItems.isEmpty) {
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
              hasSearch ? 'Sin coincidencias.' : 'No hay activos creados aún.',
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
        // --- CONTROL DE COLUMNAS ---
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
                Icon(Icons.grid_view_rounded,
                    size: 18, color: theme.primaryColor),
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
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
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

        // --- GRID ---
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 16.0;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                    spacing, 0, spacing, spacing),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columnsCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: _columnsCount > 6 ? 0.5 : 0.8,
                ),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  final fullImageUrl = _getFullImageUrl(item);
                  return _buildModernAssetCard(
                      context, item, fullImageUrl, theme);
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
                        Positioned(
                          top: 4,
                          right: 4,
                          child: _buildQuickActions(context, item),
                        ),
                      ],
                    ),
                  ),
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
                          if (_columnsCount < 6)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 20),
                              child: Wrap(
                                spacing: 20,
                                runSpacing: 10,
                                children: widget.assetType.fieldDefinitions
                                    .take(6)
                                    .map((def) {
                                  final value =
                                      item.customFieldValues?[def.id
                                              .toString()] ??
                                          '—';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${def.name}: $value',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
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
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(icon, size: 14, color: iconColor ?? Colors.black87),
        ),
      ),
    );
  }
}