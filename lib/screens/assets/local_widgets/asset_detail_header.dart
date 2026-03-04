import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/providers/preferences_provider.dart';

class AssetDetailHeader extends StatefulWidget {
  final InventoryItem item;
  final VoidCallback? onEdit;
  final Function(String)? onImageTap;
  final PreferencesProvider preferencesProvider;

  const AssetDetailHeader({
    Key? key,
    required this.item,
    this.onEdit,
    this.onImageTap,
    required this.preferencesProvider,
  }) : super(key: key);

  @override
  State<AssetDetailHeader> createState() => _AssetDetailHeaderState();
}

class _AssetDetailHeaderState extends State<AssetDetailHeader> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.item.images.isNotEmpty;
    final imageUrls = hasImage
        ? widget.item.images
            .map((img) => '${Environment.apiUrl}${img.url}')
            .toList()
        : <String>[];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen / Carrusel + Info básica en fila
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carrusel de imágenes
              if (hasImage)
                Column(
                  children: [
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CarouselSlider.builder(
                          carouselController: _carouselController,
                          itemCount: imageUrls.length,
                          options: CarouselOptions(
                            height: 280,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: imageUrls.length > 1,
                            onPageChanged: (index, reason) {
                              setState(() => _currentImageIndex = index);
                            },
                          ),
                          itemBuilder: (context, index, realIndex) {
                            return GestureDetector(
                              onTap: () =>
                                  widget.onImageTap?.call(imageUrls[index]),
                              child: Container(
                                color: Colors.grey.shade100,
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Miniaturas debajo
                    if (imageUrls.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        width: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            final isSelected = _currentImageIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _currentImageIndex = index);
                                _carouselController.animateToPage(index);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue.shade600
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: 60,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                )
              else
                Container(
                  width: 250,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              const SizedBox(width: 24),
              // Info básica
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoChip(
                      Icons.inventory_2,
                      'Stock',
                      widget.item.quantity.toString(),
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      Icons.warning_amber,
                      'Stock Mín.',
                      widget.item.minStock.toString(),
                      context,
                    ),
                    if (widget.item.location != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoChip(
                        Icons.location_on,
                        'Ubicación',
                        widget.item.location!.name,
                        context,
                      ),
                    ],
                    if (widget.item.barcode != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoChip(
                        Icons.qr_code,
                        'Código',
                        widget.item.barcode!,
                        context,
                      ),
                    ],
                    if (widget.item.marketValue > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '${widget.preferencesProvider.convertPrice(widget.item.marketValue).toStringAsFixed(2)} ${widget.preferencesProvider.selectedCurrency}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
