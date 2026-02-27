import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:invenicum/models/achievements_model.dart';
import 'package:invenicum/providers/achievement_provider.dart';
import 'package:invenicum/utils/constants.dart';

class AchievementsCardWidget extends StatelessWidget {
  const AchievementsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final achProv = context.watch<AchievementProvider>();
    final baseDefinitions = AppAchievements.getDefinitions(context);

    final List<AchievementDefinition> finalAchievements = baseDefinitions.map((
      def,
    ) {
      final userStatus = achProv.achievements.firstWhere(
        (a) => a.id == def.id,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 8.0;
        final double itemWidth = (constraints.maxWidth - (spacing * 4)) / 5;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "LOGROS",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                _buildProgressBadge(
                  context,
                  achProv.unlockedCount,
                  finalAchievements.length,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: finalAchievements.map((ach) {
                return SizedBox(
                  width: itemWidth,
                  height: itemWidth,
                  child: _SteamAchievementItem(ach: ach),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBadge(BuildContext context, int current, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "$current / $total",
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SteamAchievementItem extends StatelessWidget {
  final AchievementDefinition ach;
  const _SteamAchievementItem({required this.ach});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color activeColor = ach.isLegendary
        ? Colors.amber
        : colorScheme.primary;

    return Tooltip(
      message: ach.title, // El nombre del logro que aparecerá al pasar el ratón
      waitDuration: const Duration(
        milliseconds: 500,
      ), // Tiempo antes de aparecer
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: TextStyle(
        color: theme.colorScheme.surface,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      child: GestureDetector(
        onTap: () => _showSteamModal(context),
        child: Container(
          decoration: BoxDecoration(
            // Si está bloqueado, un fondo sutilmente más oscuro que el fondo de la app
            color: ach.unlocked
                ? activeColor.withOpacity(0.1)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: ach.unlocked
                  ? activeColor.withOpacity(0.6)
                  : theme.dividerColor.withOpacity(0.1),
              width: ach.unlocked ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              // 1. Icono Principal
              Center(
                child: Icon(
                  ach.icon,
                  size: 24,
                  color: ach.unlocked
                      ? activeColor
                      : theme.hintColor.withOpacity(
                          0.2,
                        ), // Muy tenue si está bloqueado
                ),
              ),

              // 2. Banner inferior (Solo desbloqueados)
              if (ach.unlocked)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    color: activeColor.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      ach.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 6,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSteamModal(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = ach.isLegendary
        ? Colors.amber
        : theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        // Usamos el tinte para que el modal se vea "apagado" si está bloqueado
        surfaceTintColor: ach.unlocked ? activeColor : Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono con tratamiento de "bloqueado"
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ach.unlocked
                    ? activeColor.withOpacity(0.1)
                    : Colors.black12,
                border: Border.all(
                  color: ach.unlocked
                      ? activeColor
                      : theme.dividerColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: ColorFiltered(
                // Si está bloqueado, ponemos el icono en escala de grises para el modal
                colorFilter: ach.unlocked
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                    : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Icon(
                  ach.icon,
                  size: 60,
                  color: ach.unlocked
                      ? activeColor
                      : theme.hintColor.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              ach.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: ach.unlocked ? null : theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),

            // SECCIÓN DE ESTADO (Aquí es donde se nota la diferencia al pulsar)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ach.unlocked
                    ? Colors.green.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.05),
                border: Border.all(
                  color: ach.unlocked
                      ? Colors.green.withOpacity(0.3)
                      : theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ach.unlocked ? Icons.check_circle : Icons.flag_rounded,
                        size: 14,
                        color: ach.unlocked
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ach.unlocked
                            ? "LOGRO COMPLETADO"
                            : "OBJETIVO DE DESBLOQUEO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ach.unlocked
                              ? Colors.green
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ach.desc,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ach.unlocked ? null : theme.hintColor,
                      fontStyle: ach.unlocked
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            if (ach.unlocked && ach.unlockedAt != null) ...[
              const SizedBox(height: 16),
              Text(
                "CONSEGUIDO EL ${DateFormat('dd/MM/yyyy').format(ach.unlockedAt!)}",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              ach.unlocked ? "GENIAL" : "LO INTENTARÉ",
              style: TextStyle(color: activeColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
