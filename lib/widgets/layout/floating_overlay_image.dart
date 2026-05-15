import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/overlay_image_config_model.dart';

class FloatingOverlayImage extends StatefulWidget {
  final List<OverlayImageConfig> configs;

  const FloatingOverlayImage({
    super.key,
    required this.configs,
  });

  @override
  State<FloatingOverlayImage> createState() => _FloatingOverlayImageState();
}

class _FloatingOverlayImageState extends State<FloatingOverlayImage> {
  OverlayImageConfig? _currentConfig;
  double _verticalFraction = 0;
  bool _isActive = false;
  bool _facingRight = true;
  bool _moveRightToLeft = false;
  double _x = 0;
  double _originX = 0;
  double _targetX = 0;
  double _dx = 0;
  int _turnCount = 0;
  Timer? _animTimer;
  Timer? _turnTimer;
  bool _disposed = false;
  final Random _rng = Random();

  bool get _needsFlip => _facingRight == _moveRightToLeft;

  @override
  void initState() {
    super.initState();
    if (widget.configs.isNotEmpty) _scheduleNext();
  }

  void _scheduleNext() {
    if (widget.configs.isEmpty) return;
    final delay = _currentConfig?.frequency ?? widget.configs.first.frequency;
    Future.delayed(delay, _trigger);
  }

  void _trigger() {
    if (_disposed || !mounted || widget.configs.isEmpty) return;

    setState(() {
      _currentConfig = widget.configs[_rng.nextInt(widget.configs.length)];

      switch (_currentConfig!.direction) {
        case AnimationDirection.leftToRight:
          _facingRight = true;
          _moveRightToLeft = false;
        case AnimationDirection.rightToLeft:
          _facingRight = false;
          _moveRightToLeft = true;
        case AnimationDirection.alternate:
          _facingRight = true;
          _moveRightToLeft = _rng.nextBool();
      }

      switch (_currentConfig!.zone) {
        case OverlayZone.top:
          _verticalFraction = 0.05 + _rng.nextDouble() * 0.12;
        case OverlayZone.middle:
          _verticalFraction = 0.35 + _rng.nextDouble() * 0.3;
        case OverlayZone.bottom:
          _verticalFraction = 0.75 + _rng.nextDouble() * 0.2;
        case OverlayZone.random:
          _verticalFraction = _rng.nextDouble() * 0.9;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFirstSegment();
    });
  }

  void _startFirstSegment() {
    if (_disposed || !mounted || _currentConfig == null) return;

    final w = MediaQuery.of(context).size.width;
    final imgSize = _currentConfig!.imageSize;

    setState(() {
      _x = _moveRightToLeft ? w + imgSize : -imgSize;
      _originX = _x;
      _targetX = _moveRightToLeft ? -imgSize : w + imgSize;
      _isActive = true;
      _turnCount = 0;
    });

    _startAnimating();
    _startTurnTimer();
  }

  void _startAnimating() {
    _animTimer?.cancel();
    final totalPx = (_targetX - _originX).abs();
    if (totalPx <= 0) return;
    final totalMs = _currentConfig!.speed.inMilliseconds;
    final fps = _currentConfig!.animationFps.clamp(1, 120);
    final tickMs = (1000 / fps).round();
    final totalTicks = totalMs ~/ tickMs;
    if (totalTicks <= 0) return;
    _dx = (totalPx / totalTicks) * (_targetX > _originX ? 1 : -1);

    _animTimer = Timer.periodic(Duration(milliseconds: tickMs), _onTick);
  }

  void _onTick(Timer t) {
    if (_disposed || !_isActive) {
      t.cancel();
      return;
    }

    _x += _dx;

    final crossed = _dx > 0 ? _x >= _targetX : _x <= _targetX;

    if (crossed) {
      _x = _targetX;
      t.cancel();
      _onSegmentEnd();
      return;
    }

    setState(() {});
  }

  void _onSegmentEnd() {
    _turnTimer?.cancel();
    if (_disposed || !mounted) return;
    setState(() {
      _isActive = false;
      _currentConfig = null;
    });
    _scheduleNext();
  }

  void _startTurnTimer() {
    final mode = _currentConfig!.turnMode;
    if (mode == TurnMode.off) return;
    if (_turnCount >= _currentConfig!.maxTurns) return;

    final int delaySec;
    if (mode == TurnMode.on) {
      final min = _currentConfig!.turnMinDelay;
      var max = _currentConfig!.turnMaxDelay;
      if (max < min) max = min;
      delaySec = min + _rng.nextInt(max - min + 1);
    } else {
      if (_rng.nextBool()) return;
      delaySec = 1 + _rng.nextInt(10);
    }

    _turnTimer?.cancel();
    _turnTimer = Timer(Duration(seconds: delaySec), _onTurn);
  }

  void _onTurn() {
    if (_disposed || !_isActive || !mounted || _currentConfig == null) return;
    if (_currentConfig!.turnMode == TurnMode.off) return;

    final previousOrigin = _originX;

    setState(() {
      _moveRightToLeft = !_moveRightToLeft;
      _originX = _x;
      _targetX = previousOrigin;
      _dx = -_dx;
      _turnCount++;
    });

    _startTurnTimer();
  }

  @override
  void dispose() {
    _disposed = true;
    _turnTimer?.cancel();
    _animTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive || _currentConfig == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.maxHeight * _verticalFraction;
        final imgSize = _currentConfig!.imageSize;

        Widget image = Image.asset(
          _currentConfig!.imagePath,
          width: imgSize,
          height: imgSize,
          fit: BoxFit.contain,
        );

        if (_needsFlip) {
          image = Transform.scale(
            scaleX: -1,
            alignment: Alignment.center,
            child: image,
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: top,
              child: Transform.translate(
                offset: Offset(_x, 0),
                child: image,
              ),
            ),
          ],
        );
      },
    );
  }
}
