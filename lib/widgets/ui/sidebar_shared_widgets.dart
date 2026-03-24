import 'package:flutter/material.dart';

class AddIconButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const AddIconButton({super.key, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
      onPressed: isLoading ? null : onTap,
    );
  }
}

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const ActionIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      onPressed: onTap,
    );
  }
}