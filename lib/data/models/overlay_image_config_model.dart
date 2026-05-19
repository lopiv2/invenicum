import 'package:invenicum/core/utils/constants.dart';

/// Configuration for a single floating overlay image.
///
/// Each config controls the image asset, animation speed, facing direction,
/// appearance frequency, screen zone, rendered size, and random turning.
class OverlayImageConfig {
  /// Server-side ID (null for local-only entries).
  final int? id;

  /// Whether this is a system default (non-editable, non-deletable).
  final bool isDefault;

  /// Whether this cross-toon is currently enabled and may appear on screen.
  final bool enabled;

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
    this.id,
    this.isDefault = false,
    this.enabled = true,
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

  factory OverlayImageConfig.fromJson(Map<String, dynamic> json) {
    return OverlayImageConfig(
      id: json['id'] as int?,
      isDefault: json['isDefault'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
      imagePath: json['imagePath'] as String,
      speed: Duration(seconds: json['speed'] as int? ?? 8),
      direction: AnimationDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => AnimationDirection.alternate,
      ),
      frequency: Duration(seconds: json['frequency'] as int? ?? 600),
      zone: OverlayZone.values.firstWhere(
        (e) => e.name == json['zone'],
        orElse: () => OverlayZone.bottom,
      ),
      imageSize: (json['imageSize'] as num?)?.toDouble() ?? 80,
      turnMode: TurnMode.values.firstWhere(
        (e) => e.name == json['turnMode'],
        orElse: () => TurnMode.on,
      ),
      turnMinDelay: json['turnMinDelay'] as int? ?? 2,
      turnMaxDelay: json['turnMaxDelay'] as int? ?? 6,
      maxTurns: json['maxTurns'] as int? ?? 3,
      animationFps: json['animationFps'] as int? ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'isDefault': isDefault,
    'enabled': enabled,
    'imagePath': imagePath,
    'speed': speed.inSeconds,
    'direction': direction.name,
    'frequency': frequency.inSeconds,
    'zone': zone.name,
    'imageSize': imageSize,
    'turnMode': turnMode.name,
    'turnMinDelay': turnMinDelay,
    'turnMaxDelay': turnMaxDelay,
    'maxTurns': maxTurns,
    'animationFps': animationFps,
  };

  OverlayImageConfig copyWith({
    int? id,
    bool? isDefault,
    bool? enabled,
    String? imagePath,
    Duration? speed,
    AnimationDirection? direction,
    Duration? frequency,
    OverlayZone? zone,
    double? imageSize,
    TurnMode? turnMode,
    int? turnMinDelay,
    int? turnMaxDelay,
    int? maxTurns,
    int? animationFps,
  }) {
    return OverlayImageConfig(
      id: id ?? this.id,
      isDefault: isDefault ?? this.isDefault,
      enabled: enabled ?? this.enabled,
      imagePath: imagePath ?? this.imagePath,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
      frequency: frequency ?? this.frequency,
      zone: zone ?? this.zone,
      imageSize: imageSize ?? this.imageSize,
      turnMode: turnMode ?? this.turnMode,
      turnMinDelay: turnMinDelay ?? this.turnMinDelay,
      turnMaxDelay: turnMaxDelay ?? this.turnMaxDelay,
      maxTurns: maxTurns ?? this.maxTurns,
      animationFps: animationFps ?? this.animationFps,
    );
  }
}
