import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class VhsJitterLayer extends StatefulWidget {
  final double intensity;
  final int intervalMs;
  final Widget child;

  const VhsJitterLayer({
    super.key,
    required this.intensity,
    this.intervalMs = 50,
    required this.child,
  });

  @override
  State<VhsJitterLayer> createState() => _VhsJitterLayerState();
}

class _VhsJitterLayerState extends State<VhsJitterLayer> {
  Timer? _timer;
  double _xOffset = 0;
  double _yOffset = 0;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _startJitter();
  }

  void _startJitter() {
    _timer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {
      if (!mounted) return;
      setState(() {
        _xOffset = (_rng.nextDouble() - 0.5) * 2 * widget.intensity;
        _yOffset = _rng.nextDouble() < 0.1
            ? (_rng.nextDouble() - 0.5) * widget.intensity * 0.5
            : 0;
      });
    });
  }

  @override
  void didUpdateWidget(VhsJitterLayer old) {
    super.didUpdateWidget(old);
    if (widget.intervalMs != old.intervalMs ||
        widget.intensity != old.intensity) {
      _timer?.cancel();
      _startJitter();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_xOffset, _yOffset),
      child: widget.child,
    );
  }
}
