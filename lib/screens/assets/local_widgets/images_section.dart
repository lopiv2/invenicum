import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/assets/local_widgets/image_preview_section.dart';
import 'card_section_widget.dart';
import 'section_header_widget.dart';

/// Widget para la sección de imágenes
class ImagesSectionWidget extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback onAddImage;
  final ValueChanged<String> onRemoveImage;
  final Future<void> Function(String)? onAddImageFromUrl;

  const ImagesSectionWidget({
    super.key,
    required this.imageUrls,
    required this.onAddImage,
    required this.onRemoveImage,
    this.onAddImageFromUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CardSectionWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: l10n.assetImages,
            icon: Icons.photo_library_outlined,
          ),
          ImagePreviewSection(
            imageUrls: imageUrls,
            onAddImage: onAddImage,
            onRemoveImage: onRemoveImage,
            onAddImageFromUrl: onAddImageFromUrl,
          ),
        ],
      ),
    );
  }
}
