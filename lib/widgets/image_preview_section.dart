import 'package:flutter/material.dart';

class ImagePreviewSection extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback onAddImage;
  final Function(String) onRemoveImage;

  const ImagePreviewSection({
    super.key,
    required this.imageUrls,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imágenes del Activo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),

        // Botón para seleccionar y añadir imagen
        ElevatedButton.icon(
          onPressed: onAddImage,
          icon: const Icon(Icons.upload),
          label: const Text('Seleccionar y Subir Imagen'),
        ),
        const SizedBox(height: 20),

        // --- PREVISUALIZACIÓN PRINCIPAL / EMPTY STATE ---
        if (imageUrls.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Aún no hay imágenes añadidas. La primera imagen será la principal.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          )
        else
          // Si hay imágenes, mostramos la primera grande
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Imagen Principal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 10),
              // Previsualización de la PRIMERA IMAGEN (Grande)
              _buildImagePreview(
                context,
                imageUrls.first,
                size: 300, // Tamaño grande para la principal
                isPrincipal: true,
              ),

              // --- LISTA DE MINIATURAS (si hay más de una) ---
              if (imageUrls.length > 1) ...[
                const SizedBox(height: 20),
                const Text(
                  'Miniaturas Adicionales',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: imageUrls.skip(1).map((url) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildImagePreview(
                          context,
                          url,
                          size: 100, // Tamaño pequeño para las miniaturas
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  /// Widget auxiliar para construir una previsualización de imagen con botón de eliminar.
  Widget _buildImagePreview(
    BuildContext context,
    String url, {
    required double size,
    bool isPrincipal = false,
  }) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          margin: isPrincipal ? null : const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: isPrincipal ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
              width: isPrincipal ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Muestra un placeholder si la URL no es una imagen válida
              return Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 40, color: Colors.red),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          // Muestra una parte de la URL base64 o el error
                          url.startsWith('data:') ? 'Imagen Local' : 'Error URL',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Botón de eliminar
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
            onPressed: () => onRemoveImage(url),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white70,
              padding: EdgeInsets.zero,
              minimumSize: const Size(30, 30),
            ),
          ),
        ),
      ],
    );
  }
}