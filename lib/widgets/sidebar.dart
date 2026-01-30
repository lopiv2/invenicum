import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const Sidebar({required this.icon, required this.title, required this.onTap});

  // ... (build method sin cambios)
  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema actual para usar sus colores
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    // Una forma más segura de comprobar si está seleccionado:
    // Si el título es "Dashboard" y la ruta contiene "dashboard", se marca.
    final isSelected = location.contains(title.toLowerCase());

    return Material(
      // 🚩 Cambiamos el color de fondo para que use el color primario con opacidad
      color: isSelected
          ? theme.primaryColor.withOpacity(0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.primaryColor : theme.hintColor,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  // 🚩 CORRECCIÓN: Si no está seleccionado, usa el color de texto del tema
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
