// widgets/asset_cylinder_gallery.dart

import 'dart:async';
import 'dart:ui'; // 🔑 Necesario para PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
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
  
  // Variables para el color de fondo de la tarjeta
  Color _cardBackgroundColor = Colors.white;
  double _cardOpacity = 1.0;

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
    final l10n = AppLocalizations.of(context)!;
    final allItems = widget.items;

    if (allItems.isEmpty) {
      return Center(child: Text(l10n.noAssetsToShow));
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
      child: Column(
        children: [
          // Fila 1: Play/Stop y Color Picker
          Row(
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
              // Botón Color Picker
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _cardBackgroundColor.withValues(alpha: _cardOpacity),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showColorPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(
                      Icons.palette,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Slider(
                  value: _rotationSpeed,
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  label: AppLocalizations.of(context)!.rotationSpeedLabel(_rotationSpeed.toStringAsFixed(1)),
                  onChanged: (val) => setState(() {
                    _rotationSpeed = val;
                    if (_isPlaying) _startAutoPlay();
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fila 2: Slider de Opacidad
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Opacidad: ${(_cardOpacity * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _cardOpacity,
                  min: 0,
                  max: 1.0,
                  divisions: 9,
                  label: '${(_cardOpacity * 100).toStringAsFixed(0)}%',
                  onChanged: (val) => setState(() {
                    _cardOpacity = val;
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    Color tempColor = _cardBackgroundColor;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectColor),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título de colores predefinidos
                const Text(
                  'Colores Predefinidos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // Selector de color predefinidos
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Colors.white,
                    Colors.grey.shade100,
                    Colors.blue.shade50,
                    Colors.amber.shade50,
                    Colors.red.shade50,
                    Colors.green.shade50,
                    Colors.purple.shade50,
                    Colors.pink.shade50,
                  ].map((color) {
                    final isSelected = tempColor == color;
                    return GestureDetector(
                      onTap: () => setStateDialog(() {
                        tempColor = color;
                      }),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Divisor
                Divider(color: Colors.grey.shade300),
                
                const SizedBox(height: 16),
                
                // Título de color personalizado
                const Text(
                  'Color Personalizado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Preview del color seleccionado
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: tempColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tempColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase(),
                      style: TextStyle(
                        color: _getContrainingColor(tempColor),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Slider para Red
                _buildColorSlider(
                  label: 'Rojo',
                  value: tempColor.red.toDouble(),
                  onChanged: (value) => setStateDialog(() {
                    tempColor = Color.fromARGB(
                      tempColor.alpha,
                      value.toInt(),
                      tempColor.green,
                      tempColor.blue,
                    );
                  }),
                ),
                
                // Slider para Green
                _buildColorSlider(
                  label: 'Verde',
                  value: tempColor.green.toDouble(),
                  onChanged: (value) => setStateDialog(() {
                    tempColor = Color.fromARGB(
                      tempColor.alpha,
                      tempColor.red,
                      value.toInt(),
                      tempColor.blue,
                    );
                  }),
                ),
                
                // Slider para Blue
                _buildColorSlider(
                  label: 'Azul',
                  value: tempColor.blue.toDouble(),
                  onChanged: (value) => setStateDialog(() {
                    tempColor = Color.fromARGB(
                      tempColor.alpha,
                      tempColor.red,
                      tempColor.green,
                      value.toInt(),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _cardBackgroundColor = tempColor;
                });
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorSlider({
    required String label,
    required double value,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(value.toInt().toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 255,
          divisions: 255,
          onChanged: onChanged,
          activeColor: const Color.fromARGB(255, 100, 150, 200),
        ),
      ],
    );
  }
  
  Color _getContrainingColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
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
              color: _cardBackgroundColor.withValues(alpha: _cardOpacity),
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
                        : _buildPlaceholder(context),
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

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.noImageLabel,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
