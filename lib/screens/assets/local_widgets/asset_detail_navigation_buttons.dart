import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetDetailNavigationButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool hasPrevious;
  final bool hasNext;
  final String? currentPosition;

  const AssetDetailNavigationButtons({
    Key? key,
    this.onPrevious,
    this.onNext,
    this.hasPrevious = false,
    this.hasNext = false,
    this.currentPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          _NavigationButton(
            icon: Icons.arrow_back_ios,
            label: l10n.previous,
            onPressed: hasPrevious ? onPrevious : null,
            goingBack: true,
          ),
          
          // Posición actual si existe
          if (currentPosition != null && currentPosition!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentPosition!,
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          
          // Botón siguiente
          _NavigationButton(
            icon: Icons.arrow_forward_ios,
            label: l10n.next,
            onPressed: hasNext ? onNext : null,
            goingBack: false,
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool goingBack;

  const _NavigationButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onPressed,
    required this.goingBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : Colors.grey.shade100,
            border: Border.all(
              color: isEnabled ? Colors.blue.shade300 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (goingBack) const SizedBox(width: 4),
              Icon(
                icon,
                size: 18,
                color: isEnabled ? Colors.blue.shade600 : Colors.grey.shade400,
              ),
              if (!goingBack) const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
