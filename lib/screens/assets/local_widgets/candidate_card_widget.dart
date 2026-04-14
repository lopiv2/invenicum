import 'package:flutter/material.dart';

class CandidateCard extends StatefulWidget {
  final Map<String, dynamic> candidate;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isSelected;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.subtitle,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<CandidateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final image = widget.candidate['image']?.toString();
    final name = widget.candidate['name']?.toString() ?? '';

    final isActive = _isHovered || widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: isActive ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),

              // 🌟 Glow + sombra dinámica
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(isActive ? 0.25 : 0.12),
                  blurRadius: isActive ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
              ],

              // 🟢 borde selección
              border: Border.all(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 🖼️ Imagen con lazy + fade-in
                  Positioned.fill(
                    child: image != null && image.isNotEmpty
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,

                            // ⚡ Lazy loading
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },

                            // ✨ Fade-in cuando carga
                            frameBuilder: (context, child, frame, _) {
                              if (frame == null) {
                                return AnimatedOpacity(
                                  opacity: 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: child,
                                );
                              }
                              return AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 300),
                                child: child,
                              );
                            },

                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(color: Colors.grey.shade300),
                  ),

                  // 🌫️ Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.75),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 📝 Texto
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.subtitle.isNotEmpty)
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                      ],
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
}
