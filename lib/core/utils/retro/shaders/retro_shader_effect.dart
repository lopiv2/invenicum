import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:invenicum/core/utils/retro/retro_effects.dart';

/// Renders [RetroEffects] as a single GPU shader pass.
///
/// Uses a [RepaintBoundary] to capture the child as a texture,
/// then passes it to the GLSL shader as [uTexture] in FULL mode
/// ([uMode = 1.0]), which allows phosphor glow, bloom and chromatic
/// aberration to read actual pixel data instead of working blind.
///
/// Falls back gracefully to [child] if the shader can't be loaded.
class RetroShaderEffect extends StatefulWidget {
  final RetroEffects effects;
  final Widget child;
  final String shaderAsset;

  const RetroShaderEffect({
    super.key,
    required this.effects,
    required this.child,
    this.shaderAsset = 'assets/shaders/pipboy_effect.frag',
  });

  @override
  State<RetroShaderEffect> createState() => _RetroShaderEffectState();
}

class _RetroShaderEffectState extends State<RetroShaderEffect>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0;
  bool _ready = false;
  bool _failed = false;

  // The RepaintBoundary key lets us capture the child as a GPU image.
  final _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _time = elapsed.inMicroseconds / 1_000_000.0;
      if (_ready && mounted) setState(() {});
    });
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final prog = await ui.FragmentProgram.fromAsset(widget.shaderAsset);
      if (mounted) {
        setState(() {
          _program = prog;
          _ready = true;
        });
        _ticker.start();
      }
    } catch (e) {
      debugPrint('RetroShaderEffect: shader load failed — $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback: shader not available
    if (_failed) return widget.child;

    // While loading: render child normally (no flicker on startup)
    if (!_ready || _program == null) {
      return RepaintBoundary(key: _boundaryKey, child: widget.child);
    }

    return _ShaderCapturePainter(
      boundaryKey: _boundaryKey,
      program: _program!,
      effects: widget.effects,
      time: _time,
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget that captures the child image each frame and feeds it to the shader
// ─────────────────────────────────────────────────────────────────────────────

class _ShaderCapturePainter extends StatefulWidget {
  final GlobalKey boundaryKey;
  final ui.FragmentProgram program;
  final RetroEffects effects;
  final double time;
  final Widget child;

  const _ShaderCapturePainter({
    required this.boundaryKey,
    required this.program,
    required this.effects,
    required this.time,
    required this.child,
  });

  @override
  State<_ShaderCapturePainter> createState() => _ShaderCapturePainterState();
}

class _ShaderCapturePainterState extends State<_ShaderCapturePainter> {
  ui.Image? _snapshot;

  @override
  void didUpdateWidget(_ShaderCapturePainter old) {
    super.didUpdateWidget(old);
    // Capture a new snapshot every frame (time changed → rebuild triggered)
    _captureSnapshot();
  }

  Future<void> _captureSnapshot() async {
    final boundary = widget.boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    try {
      final img = await boundary.toImage(pixelRatio:
          WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio);
      if (mounted) setState(() => _snapshot = img);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Child rendered into a RepaintBoundary for texture capture ──────
        RepaintBoundary(
          key: widget.boundaryKey,
          child: widget.child,
        ),

        // ── Shader overlay (invisible until snapshot is ready) ─────────────
        if (_snapshot != null)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FullShaderPainter(
                  program: widget.program,
                  effects: widget.effects,
                  time: widget.time,
                  texture: _snapshot!,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter — full mode (uMode = 1.0, reads uTexture)
// ─────────────────────────────────────────────────────────────────────────────

class _FullShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final RetroEffects effects;
  final double time;
  final ui.Image texture;

  _FullShaderPainter({
    required this.program,
    required this.effects,
    required this.time,
    required this.texture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = program.fragmentShader();

    // ── Texture (binding 0) ────────────────────────────────────────────────
    s.setImageSampler(0, texture);

    int i = 0;

    // uResolution
    s.setFloat(i++, size.width);
    s.setFloat(i++, size.height);

    // uTime
    s.setFloat(i++, time);

    // uMode = 1.0 → FULL mode (reads texture, applies all effects)
    s.setFloat(i++, 1.0);

    // ── Effect toggles ─────────────────────────────────────────────────────
    s.setFloat(i++, effects.scanlines ? 1.0 : 0.0);
    s.setFloat(i++, effects.phosphorGlow ? 1.0 : 0.0);
    s.setFloat(i++, effects.curvature ? 1.0 : 0.0);
    s.setFloat(i++, effects.chromaticAberration ? 1.0 : 0.0);
    s.setFloat(i++, effects.flicker ? 1.0 : 0.0);
    s.setFloat(i++, effects.bloom ? 1.0 : 0.0);
    s.setFloat(i++, effects.vhsJitter ? 1.0 : 0.0);
    s.setFloat(i++, effects.pixelGrid ? 1.0 : 0.0);
    s.setFloat(i++, effects.noise ? 1.0 : 0.0);
    s.setFloat(i++, effects.dithering ? 1.0 : 0.0);

    // ── Effect parameters ──────────────────────────────────────────────────
    s.setFloat(i++, effects.scanlineOpacity);
    s.setFloat(i++, effects.scanlineSpacing);
    s.setFloat(i++, effects.glowRadius);

    final glow = effects.glowColor ?? const Color(0xFF00FF41);
    s.setFloat(i++, glow.r);
    s.setFloat(i++, glow.g);
    s.setFloat(i++, glow.b);

    s.setFloat(i++, effects.curvatureStrength);
    s.setFloat(i++, effects.aberrationOffset);
    s.setFloat(i++, effects.flickerIntensity);
    s.setFloat(i++, effects.bloomIntensity);
    s.setFloat(i++, effects.bloomRadius);

    final bloom = effects.bloomColor ?? const Color(0xFFFFFFFF);
    s.setFloat(i++, bloom.r);
    s.setFloat(i++, bloom.g);
    s.setFloat(i++, bloom.b);

    s.setFloat(i++, effects.jitterIntensity);
    s.setFloat(i++, effects.pixelGridSize);
    s.setFloat(i++, effects.pixelGridOpacity);
    s.setFloat(i++, effects.noiseOpacity);
    s.setFloat(i++, effects.noiseDensity.toDouble());
    s.setFloat(i++, effects.ditheringStrength);
    s.setFloat(i++, effects.ditheringPatternSize);

    final paint = Paint()..shader = s;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_FullShaderPainter old) =>
      old.time != time || old.effects != effects || old.texture != texture;
}