import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/models/overlay_image_config_model.dart';

class FloatingOverlayImage extends StatefulWidget {
  final List<OverlayImageConfig> configs;

  const FloatingOverlayImage({super.key, required this.configs});

  @override
  State<FloatingOverlayImage> createState() => _FloatingOverlayImageState();
}

class _FloatingOverlayImageState extends State<FloatingOverlayImage> {
  OverlayImageConfig? _currentConfig;
  bool _isActive = false;
  bool _moveRightToLeft = false;
  double _dx = 0;
  int _turnCount = 0;
  Timer? _animTimer;
  Timer? _turnTimer;
  bool _disposed = false;
  bool _needsBorderFlip = false;
  bool _needsVerticalFlip = false;
  final Random _rng = Random();

  // ─── Horizontal mode state ──────────────────────────────────────────────────
  double _verticalFraction = 0;
  double _originX = 0;
  double _targetX = 0;
  final ValueNotifier<double> _xNotifier = ValueNotifier(0);

  // ─── Border-walk mode state ────────────────────────────────────────────────
  final ValueNotifier<Offset> _posNotifier = ValueNotifier(Offset.zero);
  double _segOrigin = 0; // starting position on current axis
  double _segTarget = 0; // target position on current axis
  double _segDx = 0; // per-tick step on current axis
  String _segAxis = 'x'; // 'x' or 'y'
  double _rotationAngle = 0;

  // ─── Shared ─────────────────────────────────────────────────────────────────

  // Cache del widget imagen para evitar que se reconstruya (y parpadee) en cada tick.
  Widget? _cachedImage;
  String? _cachedImagePath;
  double? _cachedImageSize;

  // El asset siempre mira a la derecha por defecto.
  // Solo hay que voltear cuando el movimiento es hacia la izquierda.

  @override
  void initState() {
    super.initState();
    if (widget.configs.isNotEmpty) _scheduleNext();
  }

  @override
  void didUpdateWidget(FloatingOverlayImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasEmpty = oldWidget.configs.where((c) => c.enabled).isEmpty;
    if (!_isActive &&
        _currentConfig == null &&
        _activeConfigs.isNotEmpty &&
        wasEmpty) {
      _scheduleNext();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _turnTimer?.cancel();
    _animTimer?.cancel();
    _xNotifier.dispose();
    _posNotifier.dispose();
    super.dispose();
  }

  // ─── Scheduling ──────────────────────────────────────────────────────────────

  List<OverlayImageConfig> get _activeConfigs =>
      widget.configs.where((c) => c.enabled).toList();

  void _scheduleNext() {
    if (_activeConfigs.isEmpty) return;
    final delay = _currentConfig?.frequency ?? widget.configs.first.frequency;
    Future.delayed(delay, _trigger);
  }

  void _trigger() {
    if (_disposed || !mounted || _activeConfigs.isEmpty) return;

    final config = _activeConfigs[_rng.nextInt(_activeConfigs.length)];
    bool moveRightToLeft;

    switch (config.direction) {
      case AnimationDirection.leftToRight:
        moveRightToLeft = false;
      case AnimationDirection.rightToLeft:
        moveRightToLeft = true;
      case AnimationDirection.alternate:
        moveRightToLeft = _rng.nextBool();
      case AnimationDirection.borderWalk:
        moveRightToLeft = false;
    }

    double verticalFraction;
    switch (config.zone) {
      case OverlayZone.top:
        verticalFraction = 0.05 + _rng.nextDouble() * 0.12;
      case OverlayZone.middle:
        verticalFraction = 0.35 + _rng.nextDouble() * 0.3;
      case OverlayZone.bottom:
        verticalFraction = 0.75 + _rng.nextDouble() * 0.2;
      case OverlayZone.random:
        verticalFraction = _rng.nextDouble() * 0.9;
    }

    // Precachear la imagen ANTES de activar la animación, así nunca
    // se reconstruye durante el movimiento.
    _rebuildImageCache(config);

    setState(() {
      _currentConfig = config;
      _moveRightToLeft = moveRightToLeft;
      if (config.direction != AnimationDirection.borderWalk) {
        _verticalFraction = verticalFraction;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _startFirstSegment());
  }

  // ─── Image cache ─────────────────────────────────────────────────────────────

  /// Reconstruye el widget imagen solo cuando cambia el path o el tamaño.
  /// Durante el movimiento, [_cachedImage] nunca se toca → sin parpadeo.
  void _rebuildImageCache(OverlayImageConfig config) {
    final path = config.imagePath;
    final size = config.imageSize;

    if (path == _cachedImagePath && size == _cachedImageSize) return;

    _cachedImagePath = path;
    _cachedImageSize = size;
    _cachedImage = _buildImageWidget(path, size);
  }

  Widget _buildImageWidget(String path, double size) {
    if (path.startsWith('data:')) {
      final parts = path.split(',');
      final bytes = parts.length > 1
          ? Uint8List.fromList(parts[1].codeUnits)
          : Uint8List(0);
      return Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    final relative = path.startsWith('/images/')
        ? path.substring(8)
        : path.startsWith('images/')
        ? path.substring(7)
        : path;

    return Image.network(
      '${Environment.apiUrl}/images/$relative',
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }

  // ─── Animation ───────────────────────────────────────────────────────────────

  void _startFirstSegment() {
    if (_disposed || !mounted || _currentConfig == null) return;

    final isBorderWalk =
        _currentConfig!.direction == AnimationDirection.borderWalk;

    if (isBorderWalk) {
      _startBorderWalk();
    } else {
      _startHorizontal();
    }
  }

  // ─── Horizontal mode ────────────────────────────────────────────────────────

  void _startHorizontal() {
    if (_disposed || !mounted || _currentConfig == null) return;

    final w = MediaQuery.of(context).size.width;
    final imgSize = _currentConfig!.imageSize;
    final startX = _moveRightToLeft ? w + imgSize : -imgSize;
    final endX = _moveRightToLeft ? -imgSize : w + imgSize;

    _originX = startX;
    _targetX = endX;
    _xNotifier.value = startX;
    _turnCount = 0;

    setState(() => _isActive = true);

    _launchHorizontalTicker();
    _startTurnTimer();
  }

  void _launchHorizontalTicker() {
    _animTimer?.cancel();

    final totalPx = (_targetX - _originX).abs();
    if (totalPx <= 0) return;

    final fps = _currentConfig!.animationFps.clamp(1, 120);
    final tickMs = 1000 ~/ fps;
    final totalTicks = _currentConfig!.speed.inMilliseconds ~/ tickMs;
    if (totalTicks <= 0) return;

    _dx = (totalPx / totalTicks) * (_targetX > _originX ? 1 : -1);

    _animTimer = Timer.periodic(
      Duration(milliseconds: tickMs),
      _onHorizontalTick,
    );
  }

  void _onHorizontalTick(Timer t) {
    if (_disposed || !_isActive) {
      t.cancel();
      return;
    }

    _xNotifier.value += _dx;

    final crossed = _dx > 0
        ? _xNotifier.value >= _targetX
        : _xNotifier.value <= _targetX;

    if (crossed) {
      _xNotifier.value = _targetX;
      t.cancel();
      _endCurrent();
    }
  }

  // ─── Border-walk mode ──────────────────────────────────────────────────────

  void _startBorderWalk() {
    if (_disposed || !mounted || _currentConfig == null) return;

    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final imgSize = _currentConfig!.imageSize;

    // Pick a random edge: 0=bottom, 1=right, 2=top, 3=left
    final edge = _rng.nextInt(4);
    // Pick direction: 0=forward (clockwise), 1=backward (counter-clockwise)
    final forward = _rng.nextBool();

    _posNotifier.value = Offset.zero;
    _turnCount = 0;

    switch (edge) {
      case 0: // Bottom edge
        _segAxis = 'x';
        _needsVerticalFlip = false;
        if (forward) {
          _segOrigin = -imgSize;
          _segTarget = screenW;
          _posNotifier.value = Offset(-imgSize, screenH - imgSize);
          _rotationAngle = 0;
          _needsBorderFlip = false;
        } else {
          _segOrigin = screenW;
          _segTarget = -imgSize;
          _posNotifier.value = Offset(screenW, screenH - imgSize);
          _rotationAngle = 0;
          _needsBorderFlip = true; // solo flip horizontal, sin rotar
        }
        break;
      case 1: // Right edge
        _segAxis = 'y';
        _needsVerticalFlip = false;
        if (forward) {
          _segOrigin = -imgSize;
          _segTarget = screenH;
          _posNotifier.value = Offset(screenW - imgSize, -imgSize);
          _rotationAngle = pi / 2;
          _needsBorderFlip = true; // cabeza a la izquierda bajando
        } else {
          _segOrigin = screenH;
          _segTarget = -imgSize;
          _posNotifier.value = Offset(screenW - imgSize, screenH);
          _rotationAngle = -pi / 2; // mismo ángulo
          _needsBorderFlip = false; // sin flip subiendo
        }
        break;
      case 2: // Top edge
        _segAxis = 'x';
        _needsVerticalFlip = true;
        if (forward) {
          _segOrigin = -imgSize;
          _segTarget = screenW;
          _posNotifier.value = Offset(-imgSize, 0);
          _rotationAngle = 0;
          _needsBorderFlip = false;
        } else {
          _segOrigin = screenW;
          _segTarget = -imgSize;
          _posNotifier.value = Offset(screenW, 0);
          _rotationAngle = 0;
          _needsBorderFlip = true;
        }
        break;
      case 3: // Left edge
        _segAxis = 'y';
        _needsVerticalFlip = false;
        if (forward) {
          _segOrigin = -imgSize;
          _segTarget = screenH;
          _posNotifier.value = Offset(0, -imgSize);
          _rotationAngle = pi / 2;
          _needsBorderFlip = false;
        } else {
          _segOrigin = screenH;
          _segTarget = -imgSize;
          _posNotifier.value = Offset(0, screenH);
          _rotationAngle = -pi / 2;
          _needsBorderFlip = true;
        }
        break;
    }

    _setupBorderWalkTicker();
    setState(() => _isActive = true);
  }

  void _setupBorderWalkTicker() {
    _animTimer?.cancel();

    final totalPx = (_segTarget - _segOrigin).abs();
    if (totalPx <= 0) return;

    final fps = _currentConfig!.animationFps.clamp(1, 120);
    final tickMs = 1000 ~/ fps;

    // Calcular píxeles por segundo basándose en screenWidth como referencia
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final refDistance = screenW + screenH; // perímetro parcial de referencia
    final totalDurationMs = _currentConfig!.speed.inMilliseconds;
    final pxPerTick = (refDistance / totalDurationMs) * tickMs;

    _segDx = pxPerTick * (_segTarget > _segOrigin ? 1 : -1);

    _animTimer = Timer.periodic(
      Duration(milliseconds: tickMs),
      _onBorderWalkTick,
    );
  }

  void _onBorderWalkTick(Timer t) {
    if (_disposed || !_isActive) {
      t.cancel();
      return;
    }

    final cur = _posNotifier.value;
    final newVal = (_segAxis == 'x' ? cur.dx : cur.dy) + _segDx;
    final crossed = _segDx > 0 ? newVal >= _segTarget : newVal <= _segTarget;

    if (crossed) {
      t.cancel();
      _endCurrent();
    } else {
      final updated = _segAxis == 'x'
          ? Offset(newVal, cur.dy)
          : Offset(cur.dx, newVal);
      _posNotifier.value = updated;
    }
  }

  void _endCurrent() {
    _turnTimer?.cancel();
    if (_disposed || !mounted) return;
    setState(() {
      _isActive = false;
      _currentConfig = null;
    });
    _scheduleNext();
  }

  void _startTurnTimer() {
    // Border walk doesn't use turn mode
    if (_currentConfig?.direction == AnimationDirection.borderWalk) return;
    final mode = _currentConfig?.turnMode;
    if (mode == null || mode == TurnMode.off) return;
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

    _originX = _xNotifier.value;
    _targetX = previousOrigin;
    _dx = -_dx;

    setState(() {
      _moveRightToLeft = !_moveRightToLeft;
      _turnCount++;
    });

    _startTurnTimer();
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_isActive || _currentConfig == null) return const SizedBox.shrink();

    final isBorderWalk =
        _currentConfig!.direction == AnimationDirection.borderWalk;

    Widget image = _cachedImage ?? const SizedBox.shrink();

    if (isBorderWalk) {
      image = Transform.scale(
        scaleY: _needsVerticalFlip ? -1 : 1,
        scaleX: _needsBorderFlip ? -1 : 1,
        alignment: Alignment.center,
        child: Transform.rotate(angle: _rotationAngle, child: image),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isBorderWalk) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ValueListenableBuilder<Offset>(
                valueListenable: _posNotifier,
                builder: (_, pos, child) =>
                    Positioned(top: pos.dy, left: pos.dx, child: child!),
                child: image,
              ),
            ],
          );
        }

        final top = constraints.maxHeight * _verticalFraction;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _xNotifier,
              builder: (_, x, child) =>
                  Positioned(top: top, left: x, child: child!),
              child: image,
            ),
          ],
        );
      },
    );
  }
}
