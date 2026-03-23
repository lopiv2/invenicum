import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_detail_appbar_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_detail_title_header_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_market_status_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_metadata_details_widget.dart';
import 'package:invenicum/screens/assets/local_widgets/asset_technical_specs_widget.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';

import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';

import 'package:invenicum/widgets/ui/asset_image_gallery_widget.dart';
import 'package:invenicum/widgets/ui/price_history_chart_widget.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';

class AssetDetailScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;
  final String itemId;

  const AssetDetailScreen({
    super.key,
    required this.containerId,
    required this.assetTypeId,
    required this.itemId,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  String? selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = context.read<InventoryItemProvider>();
      itemProvider.loadInventoryItems(
        containerId: int.parse(widget.containerId),
        assetTypeId: int.parse(widget.assetTypeId),
        forceReload: false,
      );
      itemProvider.loadPriceHistory(int.parse(widget.itemId));
    });
  }

  @override
  void didUpdateWidget(covariant AssetDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId) {
      selectedImageUrl = null;
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final itemProvider = context.watch<InventoryItemProvider>();

    final item = itemProvider.allInventoryItems
        .cast<InventoryItem?>()
        .firstWhere(
          (i) => i?.id.toString() == widget.itemId,
          orElse: () => null,
        );

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: itemProvider.isLoading
              ? const CircularProgressIndicator()
              : Text(l10n.assetNotFound),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AssetDetailAppBar(
        item: item,
        containerId: widget.containerId,
        assetTypeId: widget.assetTypeId,
        l10n: l10n,
        onNavigateSibling: (direction) => _navigateToSibling(direction),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssetDetailTitleHeader(item: item, theme: theme),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    BentoBoxWidget(
                      width: 780,
                      title: "Galería Visual",
                      icon: Icons.photo_library_outlined,
                      child: SizedBox(
                        height: 400,
                        child: AssetImageGallery(
                          item: item,
                          onImageTap: (url) =>
                              _showFullScreenImage(context, url),
                        ),
                      ),
                    ),

                    BentoBoxWidget(
                      width: 400,
                      title: "Estado y Mercado",
                      icon: Icons.analytics_outlined,
                      child: AssetMarketStatusWidget(item: item, l10n: l10n),
                    ),

                    BentoBoxWidget(
                      width: 1200,
                      title: "Historial de Valoración",
                      icon: Icons.insights_rounded,
                      child: Consumer<InventoryItemProvider>(
                        builder: (context, provider, _) {
                          if (provider.loadingHistory) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          return PriceHistoryChart(
                            history: provider.itemHistory,
                          );
                        },
                      ),
                    ),

                    BentoBoxWidget(
                      width: 720,
                      title: "Especificaciones",
                      icon: Icons.fact_check_outlined,
                      child: AssetTechnicalSpecsWidget(
                        item: item,
                        containerId: widget.containerId,
                        assetTypeId: widget.assetTypeId,
                      ),
                    ),

                    BentoBoxWidget(
                      width: 460,
                      title: "Trazabilidad",
                      icon: Icons.history_toggle_off_rounded,
                      child: AssetMetadataWidget(item: item, l10n: l10n),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSibling(int offset) {
  final itemProvider = context.read<InventoryItemProvider>();
  final items = itemProvider.allInventoryItems;
  if (items.isEmpty) return;
  final int currentId = int.tryParse(widget.itemId) ?? 0;
  final int currentIndex = items.indexWhere((i) => i.id == currentId);
  if (currentIndex != -1) {
    int nextIndex = (currentIndex + offset) % items.length;
    if (nextIndex < 0) nextIndex = items.length - 1;
    context.goNamed(
      RouteNames.assetDetail,
      pathParameters: {
        'containerId': widget.containerId,
        'assetTypeId': widget.assetTypeId,
        'assetId': items[nextIndex].id.toString(),
      },
    );
  }
}

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon:
                    const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}