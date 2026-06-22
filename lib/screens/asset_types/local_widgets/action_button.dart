import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color hoverColor;
  final Color defaultColor;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.hoverColor,
    this.defaultColor = Colors.transparent,
    required this.onPressed,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(left: 4),
            transform: _hovered
                ? Matrix4.diagonal3Values(1.1, 1.1, 1)
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: _hovered ? widget.hoverColor : widget.defaultColor,
              borderRadius: BorderRadius.circular(9),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: theme.colorScheme.scrim.withValues(alpha: 1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
