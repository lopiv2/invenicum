import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/data/models/inventory_item.dart';

class AssetImageGallery extends StatefulWidget {
  final InventoryItem item;
  final Function(String) onImageTap;

  const AssetImageGallery({
    super.key,
    required this.item,
    required this.onImageTap,
  });

  @override
  State<AssetImageGallery> createState() => _AssetImageGalleryState();
}

class _AssetImageGalleryState extends State<AssetImageGallery> {
  // 1. Asegúrate de que el controlador sea FINAL
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.item.images.isEmpty) return _buildEmptyState();

    final List<String> imageUrls = widget.item.images
        .map((img) => '${Environment.apiUrl}${img.url}')
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                // 2. Vinculación explícita
                carouselController: _carouselController,
                itemCount: imageUrls.length,
                options: CarouselOptions(
                  height: 350,
                  viewportFraction: 0.7,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  enableInfiniteScroll: imageUrls.length > 1,
                  // Importante: actualizar el índice cuando el usuario desliza a mano
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  // 🚩 CALCULO DE DISTANCIA AL CENTRO
                  // Esto determina cuánto debe rotar cada imagen
                  final double distortionValue = (index - _currentIndex)
                      .toDouble();

                  return AnimatedBuilder(
                    animation:
                        PageController(), // No se usa pero ayuda a la reactividad
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: () => widget.onImageTap(imageUrls[index]),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(
                              3,
                              2,
                              0.0015,
                            ) // Perspectiva de profundidad
                            ..rotateY(
                              distortionValue * 0.2,
                            ), // 🚩 Rotación en el eje Y (Efecto 3D)
                          child: _buildImageCard(imageUrls[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- MINIATURAS ---
            if (imageUrls.length > 1)
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    final isSelected = _currentIndex == index;

                    return GestureDetector(
                      // Usamos behavior opaque para capturar el toque en toda la zona
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // 3. LA CLAVE: Primero actualizamos el índice y luego animamos
                        setState(() => _currentIndex = index);

                        _carouselController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // ... (Resto de métodos _buildImageCard y _buildEmptyState igual que antes)
  Widget _buildImageCard(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
    );
  }
}
