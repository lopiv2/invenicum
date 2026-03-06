import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:invenicum/widgets/ui/price_display_widget.dart';

import 'package:invenicum/l10n/app_localizations.dart';

class TotalMarketValueWidget extends StatelessWidget {
  final double marketValue;
  final bool isLoading;

  const TotalMarketValueWidget({
    super.key,
    required this.marketValue,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Sutil sombra de color para dar profundidad sin ensuciar
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha:0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.1),
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha:0.9),
                  theme.colorScheme.primaryContainer.withValues(alpha:0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Círculo decorativo de fondo (Aura cool)
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha:0.05),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_graph_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.activeInsight,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha:0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge de porcentaje o estatus (Opcional)
                        Icon(
                          Icons.more_horiz,
                          color: Colors.white.withValues(alpha:0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.totalMarketValue,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isLoading)
                      _buildLoader()
                    else
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: PriceDisplayWidget(
                          value: marketValue,
                          style: const TextStyle(
                            fontSize: 36, // Más grande, más impacto
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha:0.1), height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: LinearProgressIndicator(
        backgroundColor: Colors.white10,
        color: Colors.white30,
        minHeight: 2,
      ),
    );
  }
}
