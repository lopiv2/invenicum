import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_theme_model.dart';
import '../providers/theme_provider.dart';

class ThemeColorDot extends StatelessWidget {
  final CustomTheme theme;

  const ThemeColorDot({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider para saber cuál es el tema actual
    final themeProvider = context.watch<ThemeProvider>();
    final isSelected = themeProvider.currentTheme.primaryColor.value == theme.primaryColor.value;

    return GestureDetector(
      onTap: () => themeProvider.setTheme(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: theme.primaryColor,
          radius: 18,
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}