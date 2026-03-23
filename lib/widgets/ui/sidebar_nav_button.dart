import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarNavButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool compact;

  /// Nombre de la ruta (RouteNames.xxx) que activa el estado seleccionado.
  /// Si se proporciona, se usa para calcular [selected] automáticamente
  /// comparando con el nombre de la ruta actual — sin depender del path literal.
  final String? routeName;

  /// Override manual de selected. Si [routeName] está definido, este parámetro
  /// se ignora. Útil para rutas anidadas o lógica especial.
  final bool? selectedOverride;

  const SidebarNavButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.routeName,
    this.selectedOverride,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Si se proporciona routeName, calculamos selected automáticamente.
    // GoRouterState.of(context).name es el nombre de la ruta activa actual.
    final bool selected;
    if (routeName != null) {
      final currentName = GoRouterState.of(context).name;
      selected = currentName == routeName;
    } else {
      selected = selectedOverride ?? false;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 1 : 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer.withOpacity(0.4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.w500,
                    color: selected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
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