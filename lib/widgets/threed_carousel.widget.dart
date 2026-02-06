import 'package:flutter/material.dart';

class ThreeDCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final Function(int) onPageChanged;
  final Function(String) onImageTap;

  const ThreeDCarousel({
    super.key,
    required this.imageUrls,
    required this.onPageChanged,
    required this.onImageTap,
  });

  @override
  State<ThreeDCarousel> createState() => _ThreeDCarouselState();
}

class _ThreeDCarouselState extends State<ThreeDCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    // viewportFraction determina qué tan "cerca" están las imágenes laterales
    _pageController = PageController(viewportFraction: 0.65, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox(
        height: 350,
        child: Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    return SizedBox(
      height: 400, // Ajusta según tu diseño
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: widget.onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          // Lógica de rotación y escala
          final double relativePosition = index - _currentPage;
          
          // Matrix4 para el efecto 3D
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Perspectiva (profundidad)
              ..scale(1 - relativePosition.abs() * 0.25) // Escala lateral
              ..rotateY(relativePosition * 0.4), // Rotación circular
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => widget.onImageTap(widget.imageUrls[index]),
              child: _buildCard(widget.imageUrls[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }
}