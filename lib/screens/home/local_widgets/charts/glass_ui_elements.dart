import 'package:flutter/material.dart';

class GlassDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ELIMINADO: Expanded de aquí
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 40, // Altura fija para consistencia visual
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          dropdownColor: Theme.of(context).cardColor, // Evita fondos negros feos
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}