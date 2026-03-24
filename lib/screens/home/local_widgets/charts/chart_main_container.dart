import 'dart:ui';
import 'package:flutter/material.dart';

class GlassMainContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const GlassMainContainer({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Margen externo para que no pegue a los bordes de la pantalla
      margin: const EdgeInsets.all(16),
      // ClipRRect es vital para que el desenfoque (blur) no se salga de las esquinas redondeadas
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Color de fondo con opacidad baja
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              // El borde es lo que da el toque de "cristal"
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.black.withValues(alpha: 0.05),
                width: 1.5,
              ),
              // Sombra sutil para dar profundidad
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}