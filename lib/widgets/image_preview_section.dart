import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Importación clave

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

  // --- WIDGET AUXILIAR QUE CARGA LA IMAGEN SEGÚN EL TIPO DE URL ---
  Widget _buildImageLoader(String url) {
    // 1. Verificar si es una Data URL (Base64)
    if (url.startsWith('data:')) {
      final String base64String = url.split(',').last;

      try {
        final Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // Fallback robusto para Base64 fallido (el error original)
        return Container(
          color: Colors.red[100],
          child: const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.red),
          ),
        );
      }
    } 
    // 2. Es una URL de Red (http/https) - ¡Usamos CachedNetworkImage!
    else {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        // Muestra un indicador de progreso mientras carga
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 30, // Reducimos el tamaño del indicador
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        // Muestra un ícono de error si la carga falla (mejor que el crash)
        errorWidget: (context, url, error) {
          // Si el error es una URL no válida o la imagen está corrupta
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.error_outline, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    }
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
          
          // Usamos el nuevo widget condicional aquí
          child: _buildImageLoader(url),
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
  
  // --- BUILD PRINCIPAL ---
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
}