import 'package:invenicum/core/utils/constants.dart';

/// Configuration for a single floating overlay image.
///
/// Each config controls the image asset, animation speed, facing direction,
/// appearance frequency, screen zone, rendered size, and random turning.
class OverlayImageConfig {
  /// Path to the WEBP asset (e.g. `assets/images/mascot.webp`).
  final String imagePath;

  /// Duration the animation takes to cross the screen.
  ///
  /// Shorter values = faster movement. Defaults to 8 seconds.
  final Duration speed;

  /// Which direction the sprite faces in the asset.
  ///
  /// See [AnimationDirection] for details. Defaults to [AnimationDirection.alternate].
  final AnimationDirection direction;

  /// Minimum time between two consecutive appearances of this image.
  ///
  /// The countdown starts after the animation finishes. Defaults to 10 minutes.
  final Duration frequency;

  /// Vertical zone of the screen where the image appears.
  ///
  /// Defaults to [OverlayZone.bottom].
  final OverlayZone zone;

  /// Width and height of the rendered image in logical pixels.
  ///
  /// Defaults to 80.
  final double imageSize;

  /// Turn behaviour: [TurnMode.on] always attempts turns,
  /// [TurnMode.off] never turns, [TurnMode.random] flips a coin each time.
  ///
  /// Defaults to [TurnMode.on].
  final TurnMode turnMode;

  /// Minimum seconds before a random turn (only when [turnMode] is [TurnMode.on]).
  ///
  /// Defaults to 2.
  final int turnMinDelay;

  /// Maximum seconds before a random turn (only when [turnMode] is [TurnMode.on]).
  ///
  /// Defaults to 6.
  final int turnMaxDelay;

  /// Maximum number of random turns per appearance, regardless of the mode.
  ///
  /// Defaults to 3.
  final int maxTurns;

  /// Frame rate for the animation in frames per second.
  ///
  /// Lower values reduce CPU usage but make movement less smooth.
  /// Must be ≥ 1. Defaults to 60.
  final int animationFps;

  const OverlayImageConfig({
    required this.imagePath,
    this.speed = const Duration(seconds: 8),
    this.direction = AnimationDirection.alternate,
    this.frequency = const Duration(minutes: 10),
    this.zone = OverlayZone.bottom,
    this.imageSize = 80,
    this.turnMode = TurnMode.on,
    this.turnMinDelay = 2,
    this.turnMaxDelay = 6,
    this.maxTurns = 3,
    this.animationFps = 60,
  });
}
