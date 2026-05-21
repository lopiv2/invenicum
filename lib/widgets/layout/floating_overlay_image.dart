import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invenicum/config/environment.dart';
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
  bool _moveRightToLeft = false;
  double _originX = 0;
  double _targetX = 0;
  double _dx = 0;
  int _turnCount = 0;
  Timer? _animTimer;
  Timer? _turnTimer;
  bool _disposed = false;
  final Random _rng = Random();

  // Notifier aislado: solo reconstruye el Positioned, no el widget imagen.
  final ValueNotifier<double> _xNotifier = ValueNotifier(0);

  // Cache del widget imagen para evitar que se reconstruya (y parpadee) en cada tick.
  Widget? _cachedImage;
  String? _cachedImagePath;
  double? _cachedImageSize;

  // El asset siempre mira a la derecha por defecto.
  // Solo hay que voltear cuando el movimiento es hacia la izquierda.
  bool get _needsFlip => _moveRightToLeft;

  @override
  void initState() {
    super.initState();
    if (widget.configs.isNotEmpty) _scheduleNext();
  }

  @override
  void didUpdateWidget(FloatingOverlayImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasEmpty =
        oldWidget.configs.where((c) => c.enabled).isEmpty;
    if (!_isActive && _currentConfig == null && _activeConfigs.isNotEmpty && wasEmpty) {
      _scheduleNext();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _turnTimer?.cancel();
    _animTimer?.cancel();
    _xNotifier.dispose();
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
      _verticalFraction = verticalFraction;
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
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  // ─── Animation ───────────────────────────────────────────────────────────────

  void _startFirstSegment() {
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

    _launchTicker();
    _startTurnTimer();
  }

  void _launchTicker() {
    _animTimer?.cancel();

    final totalPx = (_targetX - _originX).abs();
    if (totalPx <= 0) return;

    final fps = _currentConfig!.animationFps.clamp(1, 120);
    final tickMs = 1000 ~/ fps;
    final totalTicks = _currentConfig!.speed.inMilliseconds ~/ tickMs;
    if (totalTicks <= 0) return;

    _dx = (totalPx / totalTicks) * (_targetX > _originX ? 1 : -1);

    _animTimer = Timer.periodic(Duration(milliseconds: tickMs), _onTick);
  }

  void _onTick(Timer t) {
    if (_disposed || !_isActive) {
      t.cancel();
      return;
    }

    _xNotifier.value += _dx;

    final crossed =
        _dx > 0 ? _xNotifier.value >= _targetX : _xNotifier.value <= _targetX;

    if (crossed) {
      _xNotifier.value = _targetX;
      t.cancel();
      _onSegmentEnd();
    }
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

    Widget image = _cachedImage ?? const SizedBox.shrink();

    if (_needsFlip) {
      image = Transform.scale(
        scaleX: -1,
        alignment: Alignment.center,
        child: image,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.maxHeight * _verticalFraction;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ValueListenableBuilder reconstruye SOLO el Positioned en cada tick,
            // no el widget imagen → el WebP/GIF nunca se interrumpe.
            ValueListenableBuilder<double>(
              valueListenable: _xNotifier,
              builder: (_, x, child) => Positioned(
                top: top,
                left: x,
                child: child!,
              ),
              child: image,
            ),
          ],
        );
      },
    );
  }
}