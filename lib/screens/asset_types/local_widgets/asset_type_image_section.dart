import 'dart:convert';
import 'package:flutter/material.dart';

/// Widget para la sección de imagen del tipo de activo
class AssetTypeImageSection extends StatelessWidget {
  final String? imagePreviewUrl;
  final VoidCallback onAddImage;
  final VoidCallback onRemoveImage;

  const AssetTypeImageSection({
    super.key,
    required this.imagePreviewUrl,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen del Tipo de Activo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: imagePreviewUrl != null
              ? Stack(
                  children: [
                    Center(
                      child: Image.memory(
                        base64Decode(imagePreviewUrl!.split(',')[1]),
                        fit: BoxFit.contain,
                        height: 180,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onRemoveImage,
                        color: Colors.red,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: onAddImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Seleccionar Imagen'),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
