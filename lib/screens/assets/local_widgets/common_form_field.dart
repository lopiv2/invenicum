import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget reutilizable para campos de texto comunes con decoración consistente
class CommonFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helper;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final bool highlighted;
  final String? prefix;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const CommonFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.helper,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.highlighted = false,
    this.prefix,
    this.inputFormatters = const [],
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighlighted = highlighted;

    final decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffixIcon,
      helperText: helper,
      helperMaxLines: 2,
      filled: true,
      fillColor: isHighlighted
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: isHighlighted
            ? BorderSide(color: colorScheme.primary, width: 1.5)
            : BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(
        color: isHighlighted
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
      ),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration: decoration,
    );
  }
}
