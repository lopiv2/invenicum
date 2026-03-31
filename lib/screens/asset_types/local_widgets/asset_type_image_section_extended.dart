import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Widget para la sección de imagen del tipo de activo (versión extendida para edición)
/// Soporta tanto imágenes remotas como Base64
class AssetTypeImageSectionExtended extends StatelessWidget {
  final String? imagePreviewUrl;
  final bool isNewImageBase64;
  final VoidCallback onAddImage;
  final VoidCallback onRemoveImage;

  const AssetTypeImageSectionExtended({
    super.key,
    required this.imagePreviewUrl,
    required this.isNewImageBase64,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      child: isNewImageBase64
                          ? Image.memory(
                              // Nueva imagen (Base64)
                              base64Decode(imagePreviewUrl!.split(',')[1]),
                              fit: BoxFit.contain,
                              height: 180,
                            )
                          : Image.network(
                              // Imagen existente (URL remota)
                              imagePreviewUrl!,
                              fit: BoxFit.contain,
                              height: 180,
                              errorBuilder: (c, e, s) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
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
                        label: Text(l10n.selectImageButton),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
