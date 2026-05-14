import 'package:flutter/material.dart';
import 'package:invenicum/core/themes/app_themes_registry.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';

String localizeThemeName(
  BuildContext context,
  CustomTheme theme, {
  bool includeNotes = false,
}) {
  final key = AppThemesRegistry.nameKeyForId(theme.id);
  if (key == null) return theme.name;

  final l10n = AppLocalizations.of(context)!;
  final name = switch (key) {
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
    _                    => theme.name,
  };

  if (includeNotes) {
    final notesKey = AppThemesRegistry.notesKeyForId(theme.id);
    if (notesKey != null) {
      final notes = _localizeNotes(l10n, notesKey);
      if (notes.isNotEmpty) return '$name\n$notes';
    }
  }

  return name;
}

String _localizeNotes(AppLocalizations l10n, String notesKey) {
  return switch (notesKey) {
    _ => '',
  };
}