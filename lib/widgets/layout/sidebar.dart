import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const Sidebar({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema actual para usar sus colores
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    final isSelected = location.contains(title.toLowerCase());

    return Material(
      color: isSelected
          ? theme.primaryColor.withValues(alpha:0.1)
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
                      : theme.textTheme.bodyLarge?.color?.withValues(alpha:0.7),
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
