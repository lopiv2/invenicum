// lib/core/themes/retro_theme_extension.dart

import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_theme.dart';

/// ============================================================================
/// RETRO THEME EXTENSION
/// ============================================================================
///
/// Allows attaching a RetroTheme to Flutter ThemeData.
///
/// Usage:
///
/// ThemeData(
///   extensions: [
///     RetroThemeExtension(retroTheme),
///   ],
/// )
///
/// Read:
///
/// final retro = Theme.of(context)
///     .extension<RetroThemeExtension>()
///     ?.retro;
///
/// ============================================================================

@immutable
class RetroThemeExtension extends ThemeExtension<RetroThemeExtension> {
  /// Active retro theme.
  ///
  /// Null means retro mode disabled.
  final RetroTheme? retro;

  const RetroThemeExtension(this.retro);

  @override
  RetroThemeExtension copyWith({RetroTheme? retro}) =>
      RetroThemeExtension(retro ?? this.retro);

  @override
  RetroThemeExtension lerp(
    covariant ThemeExtension<RetroThemeExtension>? other,
    double t,
  ) {
    if (other is! RetroThemeExtension) {
      return this;
    }

    // Retro themes are discrete, not interpolated.
    return t < 0.5 ? this : other;
  }
}
