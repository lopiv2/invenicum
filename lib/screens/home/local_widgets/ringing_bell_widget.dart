import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RingingBell extends StatefulWidget {
  final bool isActive;
  const RingingBell({super.key, required this.isActive});

  @override
  State<RingingBell> createState() => _RingingBellState();
}

class _RingingBellState extends State<RingingBell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    if (widget.isActive) _startAnimation();
  }

  void _startAnimation() {
    // Crea un ciclo: va al final, vuelve al inicio, y repite.
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(RingingBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimation();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Rotación de -0.2 a 0.2 radianes para el efecto campana
        return Transform.rotate(
          angle: widget.isActive ? (_controller.value * 1) - 0.4 : 0.0,
          child: Icon(
            widget.isActive ? Icons.notifications_active_outlined : Icons.notifications_none_outlined,
            color: widget.isActive ? Colors.orange.shade700 : null,
            size: 20,
          ),
        );
      },
    );
  }
}