import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:invenicum/l10n/app_localizations.dart';

/// Widget overlay que muestra una pantalla de "En construcción" con efecto de cristal
/// 
/// Muestra un fondo difuminado y un panel de cristal traslúcido con:
/// - Ícono de construcción
/// - Título (En construcción / Próximamente)
/// - Descripción
/// 
/// Se puede personalizar el título y subtitle si se desea
class UnderConstructionOverlay extends StatelessWidget {
  /// Título personalizado (si es null, usa "underConstruction")
  final String? title;
  
  /// Subtítulo personalizado (si es null, usa "constructionSubtitle")
  final String? subtitle;
  
  /// Ícono a mostrar (por defecto: construcción)
  final IconData icon;
  
  /// Color del ícono
  final Color? iconColor;
  
  /// Blur sigma para el efecto de difuminado
  final double blurSigma;

  const UnderConstructionOverlay({
    super.key,
    this.title,
    this.subtitle,
    this.icon = Icons.construction_rounded,
    this.iconColor,
    this.blurSigma = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = title ?? l10n.underConstruction;
    final displaySubtitle = subtitle ?? l10n.constructionSubtitle;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Fondo con difuminado (BackdropFilter)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ),
        
        // Panel de cristal traslúcido centrado
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isDarkMode ? Colors.white : Colors.black)
                              .withValues(alpha: 0.08),
                          (isDarkMode ? Colors.white : Colors.black)
                              .withValues(alpha: 0.03),
                        ],
                      ),
                      border: Border.all(
                        color: (isDarkMode ? Colors.white : Colors.black)
                            .withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 48,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ícono
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.primaryColor.withValues(alpha: 0.15),
                              border: Border.all(
                                color: theme.primaryColor.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: 40,
                              color:
                                  iconColor ?? theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Título
                          Text(
                            displayTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.95)
                                  : Colors.black.withValues(alpha: 0.95),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          
                          // Subtítulo
                          Text(
                            displaySubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.black.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Puntos animados de carga
                          _AnimatedLoadingDots(
                            color: theme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget con puntos animados de carga
class _AnimatedLoadingDots extends StatefulWidget {
  final Color color;

  const _AnimatedLoadingDots({required this.color});

  @override
  State<_AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<_AnimatedLoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      )..repeat(reverse: true);
    });

    // Desfasamos cada punto para que no se animen al mismo tiempo
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].forward(from: (i * 0.2));
    }
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.4, end: 1.0).animate(
            CurvedAnimation(parent: controllers[index], curve: Curves.easeInOut),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        );
      }),
    );
  }
}
