// widgets/asset_cylinder_gallery.dart

import 'dart:async';
import 'dart:ui'; // 🔑 Necesario para PointerDeviceKind
import 'package:flutter/material.dart';
import '../../../data/models/inventory_item.dart';
import '../../../../config/environment.dart';

// 1. Clase para permitir el arrastre con el ratón (clic izquierdo y mover)
class MouseDraggableScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // 👈 Habilita el arrastre con ratón
  };
}

class AssetCylinderGallery extends StatefulWidget {
  final List<InventoryItem> items;

  const AssetCylinderGallery({super.key, required this.items});

  @override
  State<AssetCylinderGallery> createState() => _AssetCylinderGalleryState();
}

class _AssetCylinderGalleryState extends State<AssetCylinderGallery> {
  late FixedExtentScrollController _scrollController;
  int _selectedIndex = 0;

  // Variables para el Auto-Play
  Timer? _timer;
  bool _isPlaying = false;
  bool _isHovering = false;
  double _rotationSpeed = 3.0; // Segundos por cada salto

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex,
    );
  }

  // 🎯 Lógica del Auto-Play
  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startAutoPlay();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: (_rotationSpeed * 1000).toInt()),
      (timer) {
        // 🎯 Solo avanza si el Play está activo Y el ratón NO está encima
        if (_isPlaying && !_isHovering && _scrollController.hasClients) {
          final nextIndex = _scrollController.selectedItem + 1;
          _scrollController.animateToItem(
            nextIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = widget.items;

    if (allItems.isEmpty) {
      return const Center(child: Text("No hay activos para mostrar"));
    }

    // 2. Aplicamos ScrollConfiguration para que el ratón pueda arrastrar
    return OrientationBuilder(
      builder: (context, orientation) {
        bool isPortrait = orientation == Orientation.portrait;
        return Column(
          children: [
            _buildControls(),
            Expanded(
              child: ScrollConfiguration(
                behavior: MouseDraggableScrollBehavior(),
                child: RotatedBox(
                  quarterTurns: isPortrait ? 0 : -1,
                  child: ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: isPortrait
                        ? MediaQuery.of(context).size.height * 0.2
                        : MediaQuery.of(context).size.width * 0.2,
                    diameterRatio: isPortrait ? 2.0 : 2.8,
                    perspective: 0.002,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedIndex = index % allItems.length;
                      });
                    },
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: allItems
                          .map((item) => _buildGalleryCard(item, isPortrait))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton.filled(
            icon: Icon(
              _isPlaying ? Icons.stop_circle : Icons.play_circle_filled,
            ),
            onPressed: _togglePlay,
            color: _isPlaying ? Colors.redAccent : Colors.greenAccent,
            iconSize: 40,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Slider(
              value: _rotationSpeed,
              min: 0.5,
              max: 10.0,
              divisions: 19,
              label: "${_rotationSpeed}s",
              onChanged: (val) => setState(() {
                _rotationSpeed = val;
                if (_isPlaying) _startAutoPlay();
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(InventoryItem item, bool isPortrait) {
    // 2. Lógica para determinar la imagen a mostrar
    final hasImage = item.images.isNotEmpty;
    final imageUrl = hasImage
        ? '${Environment.apiUrl}${item.images.first.url}'
        : null;
    return RotatedBox(
      quarterTurns: isPortrait ? 0 : 1,
      child: Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors
              .grab, // 👈 Cambia el puntero a una "mano" al pasar por encima
          child: Container(
            width: isPortrait ? MediaQuery.of(context).size.width * 0.75 : MediaQuery.of(context).size.width * 0.8,
            height: isPortrait ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.height * 0.8,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                25,
              ), // Bordes más redondeados para look premium
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen escalada y completa
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: hasImage
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Banner inferior con degradado elegante
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text("Sin imagen", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
