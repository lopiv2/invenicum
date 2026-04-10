import 'dart:ui'; // Necesario para ImageFilter (Glassmorphism)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:invenicum/data/models/achievements_model.dart';
import 'package:invenicum/providers/achievement_provider.dart';
// Asegúrate de tener estas constantes o cámbialas por tus valores de diseño
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/widgets/ui/under_construction_overlay.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AchievementsCardWidget extends StatefulWidget {
  const AchievementsCardWidget({super.key});

  @override
  State<AchievementsCardWidget> createState() => _AchievementsCardWidgetState();
}

class _AchievementsCardWidgetState extends State<AchievementsCardWidget> {
  // Cambiar a 'true' para mostrar el overlay, 'false' para ocultarlo
  final bool _showUnderConstruction = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final achProv = context.watch<AchievementProvider>();
    // Supongamos que AppAchievements devuelve la lista de definiciones base.
    final baseDefinitions = AppAchievements.getDefinitions(context);

    // Mapeo para combinar estado base con estado del usuario
    final List<AchievementDefinition> finalAchievements = baseDefinitions.map((
      def,
    ) {
      final userStatus = achProv.achievements.firstWhere(
        (a) => a.id == def.id,
        // Si no está en el provider, devolvemos la definición base (bloqueado)
        orElse: () => def,
      );
      return AchievementDefinition(
        id: def.id,
        title: def.title,
        desc: def.desc,
        icon: def.icon,
        category: def.category,
        isLegendary: def.isLegendary,
        unlocked: userStatus.unlocked,
        unlockedAt: userStatus.unlockedAt,
      );
    }).toList();

    if (achProv.isLoading && achProv.achievements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final unlockedCount = achProv.unlockedCount;
    final totalCount = finalAchievements.length;
    final double progressPercentage = totalCount > 0
        ? unlockedCount / totalCount
        : 0.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          // Contenedor principal elegante
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABECERA MODERNA
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.achievementCollectionTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.achievementSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildModernProgressCircle(
                    context,
                    progressPercentage,
                    unlockedCount,
                    totalCount,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // REJILLA DE LOGROS ANIMADA
              LayoutBuilder(
                builder: (context, constraints) {
                  const double spacing = 12.0;
                  // Calculamos para 5 columnas
                  final double itemWidth =
                      (constraints.maxWidth - (spacing * 4)) / 5;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: finalAchievements.map((ach) {
                      return SizedBox(
                        width: itemWidth,
                        height: itemWidth,
                        child: _ModernAchievementItem(ach: ach, l10n: l10n),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        if (_showUnderConstruction)
          Positioned.fill(
            child: AbsorbPointer(
              child: const UnderConstructionOverlay(),
            ),
          ),
      ],
    );
  }

  // Widget de progreso circular minimalista
  Widget _buildModernProgressCircle(
    BuildContext context,
    double percentage,
    int current,
    int total,
  ) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: percentage,
            strokeWidth: 6,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            strokeCap: StrokeCap.round, // Bordes redondeados en la barra
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$current",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              height: 1,
              width: 15,
              color: theme.dividerColor,
              margin: const EdgeInsets.symmetric(vertical: 1),
            ),
            Text(
              "$total",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernAchievementItem extends StatefulWidget {
  final AchievementDefinition ach;
  final AppLocalizations l10n;
  const _ModernAchievementItem({required this.ach, required this.l10n});

  @override
  State<_ModernAchievementItem> createState() => _ModernAchievementItemState();
}

class _ModernAchievementItemState extends State<_ModernAchievementItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores basados en rareza (Legendario = Ámbar/Oro, Normal = Primario)
    final Color jewelColor = widget.ach.isLegendary
        ? Colors.amber
        : theme.colorScheme.primary;

    // Color de fondo del ítem: Vidrio esmerilado si está desbloqueado, sutil si no.
    final Color baseColor = widget.ach.unlocked
        ? jewelColor.withValues(alpha: isDark ? 0.15 : 0.1)
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 
            isDark ? 0.3 : 0.5,
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.ach.title,
        waitDuration: const Duration(milliseconds: 700),
        // Estilo de tooltip más moderno
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: GestureDetector(
          onTap: () => _showModernAchievementSheet(context, widget.l10n),
          // Animación de escala al pasar el ratón
          child: AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(
                  16,
                ), // Bordes más redondeados
                border: Border.all(
                  color: widget.ach.unlocked
                      ? jewelColor.withValues(alpha: 0.5)
                      : theme.dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
                  width: widget.ach.unlocked ? 1.5 : 1,
                ),
                // Efecto de brillo si está bloqueado y hover
                boxShadow: (_isHovered && widget.ach.unlocked)
                    ? [
                        BoxShadow(
                          color: jewelColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: -2,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // 1. Icono Principal (Limpio, sin textos encima)
                    Center(
                      child: Icon(
                        widget.ach.icon,
                        size: 28,
                        color: widget.ach.unlocked
                            ? jewelColor
                            : theme.hintColor.withValues(alpha: isDark ? 0.2 : 0.4),
                      ),
                    ),

                    // 2. Indicador de rareza legendaria (Pequeño destello en la esquina)
                    if (widget.ach.isLegendary)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Colors.amber.withValues(alpha: 
                            widget.ach.unlocked ? 1 : 0.3,
                          ),
                        ),
                      ),

                    // 3. Superposición de brillo sutil en hover
                    AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MODAL MODERNO ESTILO "BOTTOM SHEET" (En lugar de un Dialog central)
  void _showModernAchievementSheet(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final jewelColor = widget.ach.isLegendary
        ? Colors.amber
        : theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Para efecto glassmorphism
      builder: (context) => BackdropFilter(
        // Efecto de desenfoque detrás del panel
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.8 : 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            // Esto detecta automáticamente si hay un "notch" o barra inferior (como en iPhone)
            // y le suma 24 de margen extra para que no quede pegado al borde.
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra de arrastre superior
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),

              // Icono Grande y Elegante
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: jewelColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: jewelColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.ach.icon,
                  size: 64,
                  color: widget.ach.unlocked
                      ? jewelColor
                      : theme.hintColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),

              // Título y Categoría
              Text(
                widget.ach.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: widget.ach.unlocked ? null : theme.hintColor,
                ),
              ),
              const SizedBox(height: 4),
              if (widget.ach.isLegendary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.legendaryAchievementLabel,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                )
              else
                Text(
                  widget.ach.category.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: jewelColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

              const SizedBox(height: 32),
              const Divider(height: 1),
              const SizedBox(height: 24),

              // Descripción
              Text(
                widget.ach.desc,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: widget.ach.unlocked
                      ? theme.colorScheme.onSurface
                      : theme.hintColor,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              // Panel de Estado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.ach.unlocked
                      ? Colors.green.withValues(alpha: isDark ? 0.1 : 0.05)
                      : theme.colorScheme.primary.withValues(alpha: 
                          isDark ? 0.1 : 0.05,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.ach.unlocked
                        ? Colors.green.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.ach.unlocked
                          ? Icons.verified_rounded
                          : Icons.lock_outline_rounded,
                      color: widget.ach.unlocked
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ach.unlocked
                                ? l10n.achievementCompleted
                                : l10n.achievementLocked,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.ach.unlocked
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            widget.ach.unlocked && widget.ach.unlockedAt != null
                                ? l10n.achievementUnlockedDate(
                                    DateFormat('d MMMM, yyyy')
                                        .format(widget.ach.unlockedAt!),
                                  )
                                : l10n.achievementLockedMessage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botón de cerrar elegante
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface,
                    foregroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.closeButtonLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
