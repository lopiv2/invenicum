import 'package:flutter/material.dart';
import 'package:invenicum/core/themes/app_themes_registry.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';

String localizeThemeName(
  BuildContext context,
  CustomTheme theme, {
  bool includeNotes = false,
}) {
  final nameKey = AppThemesRegistry.nameKeyForId(theme.id);
  final l10n = AppLocalizations.of(context)!;

  final notes = includeNotes
      ? _resolveNotes(l10n, AppThemesRegistry.notesKeyForId(theme.id))
      : null;

  final name = switch (nameKey) {
    'themeBrand'         => l10n.themeBrand,
    'themeEmerald'       => l10n.themeEmerald,
    'themeSunset'        => l10n.themeSunset,
    'oceanTheme'         => l10n.oceanTheme,
    'themeLavender'      => l10n.themeLavender,
    'themeForest'        => l10n.themeForest,
    'themeCherry'        => l10n.themeCherry,
    'themeElectricNight' => l10n.themeElectricNight,
    'themeAmberGold'     => l10n.themeAmberGold,
    'cherryBlossomTheme' => l10n.cherryBlossomTheme,
    'themeModernSlate'   => l10n.themeModernSlate,
    'themeCyberpunk'     => l10n.themeCyberpunk,
    'themeNordicArctic'  => l10n.themeNordicArctic,
    'themeDeepNight'     => l10n.themeDeepNight,
    'themeSnowy'         => l10n.themeSnowy,
    'themeFiesta'        => l10n.themeFiesta,
    'themeMatrix'        => l10n.themeMatrix,
    'themeVolcano'       => l10n.themeVolcano,
    _                    => theme.name,
  };

  if (notes != null) return '$name\n$notes';
  return name;
}

String? _resolveNotes(AppLocalizations l10n, String? notesKey) {
  if (notesKey == null) return null;
  return switch (notesKey) {
    'themePipboy3000Notes' => l10n.themePipboy3000Notes,
    _ => null,
  };
}