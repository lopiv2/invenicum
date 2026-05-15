// ─── lib/core/utils/retro/retro_effects.dart ─────────────────────────────────
//
// Capa de efectos visuales independiente de la paleta de colores.
// Cada RetroTheme declara qué efectos quiere. El widget RetroEffectsLayer
// los aplica en orden sobre el árbol de widgets.
//
// Añadir un nuevo tema = añadir una constante RetroEffects. Sin tocar shaders.
// Añadir un nuevo efecto = añadir un CustomPainter / shader y registrarlo aquí.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'effects/scanlines_layer.dart';
import 'effects/phosphor_glow_layer.dart';
import 'effects/curvature_layer.dart';
import 'effects/chromatic_aberration_layer.dart';
import 'effects/bloom_layer.dart';
import 'effects/vhs_jitter_layer.dart';
import 'effects/pixel_grid_layer.dart';
import 'effects/noise_layer.dart';
import 'effects/dithering_layer.dart';
import 'shaders/retro_shader_effect.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class RetroEffects {
  // ── Scanlines ──────────────────────────────────────────────────────────────
  /// Draws horizontal lines simulating a CRT raster.
  final bool scanlines;

  /// Opacity of the scanline overlay (0.0 – 1.0).
  final double scanlineOpacity;

  /// Height in logical pixels of each scanline gap.
  final double scanlineSpacing;

  // ── Phosphor glow ──────────────────────────────────────────────────────────
  /// Adds a soft bloom/glow around bright elements.
  final bool phosphorGlow;

  /// Glow spread radius.
  final double glowRadius;

  /// Glow color (usually the palette's primary / border color).
  final Color? glowColor;

  // ── Screen curvature ───────────────────────────────────────────────────────
  /// Applies a barrel-distortion-like vignette to mimic a curved CRT tube.
  /// (Pure vignette + rounded corners — no actual barrel distortion shader
  ///  unless you add a FragmentShader in the future.)
  final bool curvature;

  /// How strong the vignette darkening is at the edges (0.0 = none, 1.0 = black).
  final double curvatureStrength;

  // ── Chromatic aberration ───────────────────────────────────────────────────
  /// Draws the UI three times (R/G/B) with tiny offsets.
  /// Expensive — use only for hero screens or dialogs.
  final bool chromaticAberration;

  /// Pixel offset for the R and B channels.
  final double aberrationOffset;

  // ── Flicker ────────────────────────────────────────────────────────────────
  /// Randomly dims the screen slightly to simulate CRT refresh rate flicker.
  final bool flicker;

  /// Maximum opacity reduction per flicker frame (0.0 – 0.1 recommended).
  final double flickerIntensity;

  // ── Bloom ──────────────────────────────────────────────────────────────────
  /// Bright bloom / glow around elements (stronger than phosphorGlow).
  final bool bloom;

  /// Intensity of the bloom effect (0.0 – 1.0).
  final double bloomIntensity;

  /// Blur radius for bloom spread.
  final double bloomRadius;

  /// Tint color for the bloom.
  final Color? bloomColor;

  // ── VHS jitter ─────────────────────────────────────────────────────────────
  /// Random horizontal displacement simulating VHS tracking issues.
  final bool vhsJitter;

  /// Maximum horizontal offset in pixels.
  final double jitterIntensity;

  /// Interval in ms between jitter updates.
  final int jitterIntervalMs;

  // ── Pixel grid ─────────────────────────────────────────────────────────────
  /// Overlays a subtle pixel grid simulating a low-res display.
  final bool pixelGrid;

  /// Size of each grid cell in logical pixels.
  final double pixelGridSize;

  /// Opacity of the grid overlay.
  final double pixelGridOpacity;

  // ── Noise ──────────────────────────────────────────────────────────────────
  /// Static noise overlay like TV static.
  final bool noise;

  /// Opacity of the noise particles.
  final double noiseOpacity;

  /// Number of noise particles per frame.
  final int noiseDensity;

  // ── Dithering ──────────────────────────────────────────────────────────────
  /// Ordered dithering pattern overlay.
  final bool dithering;

  /// Strength of the dither pattern (0.0 – 1.0).
  final double ditheringStrength;

  /// Size of each dither cell in logical pixels.
  final double ditheringPatternSize;

  /// When true, [RetroEffectsLayer] replaces all individual
  /// [CustomPainter] layers with a single GPU [FragmentShader] pass.
  final bool useShader;

  const RetroEffects({
    this.scanlines = false,
    this.scanlineOpacity = 0.18,
    this.scanlineSpacing = 3.0,
    this.phosphorGlow = false,
    this.glowRadius = 6.0,
    this.glowColor,
    this.curvature = false,
    this.curvatureStrength = 0.35,
    this.chromaticAberration = false,
    this.aberrationOffset = 1.5,
    this.flicker = false,
    this.flickerIntensity = 0.04,
    this.bloom = false,
    this.bloomIntensity = 0.5,
    this.bloomRadius = 4.0,
    this.bloomColor,
    this.vhsJitter = false,
    this.jitterIntensity = 2.0,
    this.jitterIntervalMs = 50,
    this.pixelGrid = false,
    this.pixelGridSize = 4.0,
    this.pixelGridOpacity = 0.06,
    this.noise = false,
    this.noiseOpacity = 0.08,
    this.noiseDensity = 80,
    this.dithering = false,
    this.ditheringStrength = 0.2,
    this.ditheringPatternSize = 4.0,
    this.useShader = false,
  });

  /// No effects — plain retro palette, no post-processing.
  static const none = RetroEffects();

  /// Classic CGA monitor: scanlines + vignette + subtle flicker.
  static const cga = RetroEffects(
    scanlines: true,
    scanlineOpacity: 0.20,
    scanlineSpacing: 3.0,
    curvature: true,
    curvatureStrength: 0.30,
    flicker: true,
    flickerIntensity: 0.03,
  );

  /// EGA: slightly crisper, less curvature, phosphor glow.
  static const ega = RetroEffects(
    scanlines: true,
    scanlineOpacity: 0.14,
    scanlineSpacing: 2.5,
    phosphorGlow: true,
    glowRadius: 5.0,
    curvature: true,
    curvatureStrength: 0.20,
  );

  /// SCUMM-VM style: heavy scanlines, no curvature (flat LCD feel).
  static const scummCrt = RetroEffects(
    scanlines: true,
    scanlineOpacity: 0.28,
    scanlineSpacing: 4.0,
    phosphorGlow: true,
    glowRadius: 8.0,
    curvature: false,
  );

  /// VGA arcade: aberration + glow, no scanlines (high-res feel).
  static const vgaArcade = RetroEffects(
    chromaticAberration: true,
    aberrationOffset: 1.2,
    phosphorGlow: true,
    glowRadius: 4.0,
    curvature: true,
    curvatureStrength: 0.15,
  );

  /// VHS tape: jitter + noise + aberration + soft scanlines.
  static const vhs = RetroEffects(
    vhsJitter: true,
    jitterIntensity: 2.5,
    jitterIntervalMs: 40,
    noise: true,
    noiseOpacity: 0.10,
    noiseDensity: 100,
    chromaticAberration: true,
    aberrationOffset: 1.0,
    scanlines: true,
    scanlineOpacity: 0.08,
    scanlineSpacing: 2.0,
    curvature: true,
    curvatureStrength: 0.15,
  );

  /// LCD grid: pixel grid + subtle bloom + light dithering.
  static const lcd = RetroEffects(
    pixelGrid: true,
    pixelGridSize: 4.0,
    pixelGridOpacity: 0.08,
    bloom: true,
    bloomIntensity: 0.3,
    bloomRadius: 3.0,
    dithering: true,
    ditheringStrength: 0.15,
    ditheringPatternSize: 4.0,
  );

  /// Pip-Boy 3000 (Fallout): green monochrome CRT with soft glow.
  /// Uses a single GPU [FragmentShader] instead of multiple [CustomPainter]s.
  static const pipboy3000 = RetroEffects(
    scanlines: true,
    scanlineOpacity: 0.15,
    scanlineSpacing: 2.5,
    phosphorGlow: true,
    glowRadius: 6.0,
    glowColor: Color(0xFF00FF41),
    curvature: true,
    curvatureStrength: 0.02,
    flicker: true,
    flickerIntensity: 0.02,
    useShader: true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] with the visual effects declared in [effects].
/// Place this as high as possible in the widget tree — ideally wrapping
/// the MaterialApp's home or the Scaffold body.
///
/// Usage:
///   RetroEffectsLayer(
///     effects: RetroEffects.cga,
///     child: myScreen,
///   )
class RetroEffectsLayer extends StatefulWidget {
  final RetroEffects effects;
  final Widget child;

  const RetroEffectsLayer({
    super.key,
    required this.effects,
    required this.child,
  });

  @override
  State<RetroEffectsLayer> createState() => _RetroEffectsLayerState();
}

class _RetroEffectsLayerState extends State<RetroEffectsLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _flickerCtrl;
  double _flickerAlpha = 1.0;

  @override
  void initState() {
    super.initState();
    _flickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    if (widget.effects.flicker) _startFlicker();
  }

  void _startFlicker() {
    _flickerCtrl.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        final rng = math.Random();
        // Random pause between flicker frames (50–300 ms)
        Future.delayed(
          Duration(milliseconds: 50 + rng.nextInt(250)),
          () {
            if (!mounted) return;
            setState(() {
              _flickerAlpha =
                  1.0 - rng.nextDouble() * widget.effects.flickerIntensity;
            });
            _flickerCtrl.forward(from: 0);
          },
        );
      }
    });
    _flickerCtrl.forward();
  }

  @override
  void didUpdateWidget(RetroEffectsLayer old) {
    super.didUpdateWidget(old);
    if (widget.effects.flicker && !old.effects.flicker) _startFlicker();
  }

  @override
  void dispose() {
    _flickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── GPU shader path (replaces ALL individual CustomPainters) ──────────
    if (widget.effects.useShader) {
      return RetroShaderEffect(
        effects: widget.effects,
        child: widget.child,
      );
    }

    Widget result = widget.child;

    // 1. Phosphor glow (BackdropFilter blur — cheap approximation)
    if (widget.effects.phosphorGlow) {
      result = PhosphorGlowLayer(
        radius: widget.effects.glowRadius,
        color: widget.effects.glowColor,
        child: result,
      );
    }

    // 2. Scanlines overlay
    if (widget.effects.scanlines) {
      result = ScanlinesLayer(
        opacity: widget.effects.scanlineOpacity,
        spacing: widget.effects.scanlineSpacing,
        child: result,
      );
    }

    // 3. CRT curvature vignette
    if (widget.effects.curvature) {
      result = CurvatureLayer(
        strength: widget.effects.curvatureStrength,
        child: result,
      );
    }

    // 4. Chromatic aberration (most expensive — applied last)
    if (widget.effects.chromaticAberration) {
      result = ChromaticAberrationLayer(
        offset: widget.effects.aberrationOffset,
        child: result,
      );
    }

    // 5. Bloom (proper Gaussian blur glow)
    if (widget.effects.bloom) {
      result = BloomLayer(
        intensity: widget.effects.bloomIntensity,
        radius: widget.effects.bloomRadius,
        color: widget.effects.bloomColor,
        child: result,
      );
    }

    // 6. Dithering pattern overlay
    if (widget.effects.dithering) {
      result = DitheringLayer(
        strength: widget.effects.ditheringStrength,
        patternSize: widget.effects.ditheringPatternSize,
        child: result,
      );
    }

    // 7. Pixel grid overlay
    if (widget.effects.pixelGrid) {
      result = PixelGridLayer(
        gridSize: widget.effects.pixelGridSize,
        opacity: widget.effects.pixelGridOpacity,
        child: result,
      );
    }

    // 8. Noise overlay (animated static)
    if (widget.effects.noise) {
      result = NoiseLayer(
        opacity: widget.effects.noiseOpacity,
        density: widget.effects.noiseDensity,
        child: result,
      );
    }

    // 9. Flicker (opacity animation wrapper)
    if (widget.effects.flicker) {
      result = Opacity(opacity: _flickerAlpha, child: result);
    }

    // 10. VHS jitter (screen displacement — last to move everything)
    if (widget.effects.vhsJitter) {
      result = VhsJitterLayer(
        intensity: widget.effects.jitterIntensity,
        intervalMs: widget.effects.jitterIntervalMs,
        child: result,
      );
    }

    return result;
  }
}

