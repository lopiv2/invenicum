import 'package:flutter/material.dart';

class CollapsibleBentoBoxWidget extends StatefulWidget {
  final double? width;
  final String title;
  final IconData icon;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool initiallyExpanded;
  final bool collapsible; // ← nuevo

  const CollapsibleBentoBoxWidget({
    super.key,
    this.width,
    required this.title,
    required this.icon,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.initiallyExpanded = false,
    this.collapsible = true, // ← por defecto colapsable
  });

  @override
  State<CollapsibleBentoBoxWidget> createState() =>
      _CollapsibleBentoBoxWidgetState();
}

class _CollapsibleBentoBoxWidgetState extends State<CollapsibleBentoBoxWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _expanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _rotateAnim = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.collapsible) return;
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontalPadding = widget.padding is EdgeInsets
        ? (widget.padding as EdgeInsets).left
        : 24.0;

    return Container(
      width: widget.width,
      constraints: const BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              onTap: widget.collapsible ? _toggle : null,
              borderRadius: BorderRadius.circular(32),
              child: Padding(
                padding: widget.padding,
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    // Flecha solo si es colapsable
                    if (widget.collapsible)
                      RotationTransition(
                        turns: _rotateAnim,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Contenido — con o sin animación según collapsible
            if (widget.collapsible)
              SizeTransition(
                sizeFactor: _expandAnim,
                axisAlignment: -1,
                child: _buildContent(horizontalPadding, theme),
              )
            else
              _buildContent(horizontalPadding, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double horizontalPadding, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        Padding(
          padding: widget.padding is EdgeInsets
              ? (widget.padding as EdgeInsets).copyWith(top: 20)
              : widget.padding,
          child: widget.child,
        ),
      ],
    );
  }
}