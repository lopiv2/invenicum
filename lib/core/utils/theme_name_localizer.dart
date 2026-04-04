import 'package:flutter/material.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';

String localizeThemeName(BuildContext context, CustomTheme theme) {
  final l10n = AppLocalizations.of(context)!;

  switch (theme.id) {
    case 'brand':
      return l10n.themeBrand;
    case 'emerald':
      return l10n.themeEmerald;
    case 'sunset':
      return l10n.themeSunset;
    case 'ocean':
      return l10n.oceanTheme;
    case 'lavender':
      return l10n.themeLavender;
    case 'forest':
      return l10n.themeForest;
    case 'cherry':
      return l10n.themeCherry;
    case 'indigo':
      return l10n.themeElectricNight;
    case 'amber':
      return l10n.themeAmberGold;
    case 'sakura':
      return l10n.cherryBlossomTheme;
    case 'slate':
      return l10n.themeModernSlate;
    case 'cyberpunk':
      return l10n.themeCyberpunk;
    case 'nordic':
      return l10n.themeNordicArctic;
    case 'dark_mode':
      return l10n.themeDeepNight;
    case 'custom_db':
    case 'db_theme':
      return l10n.myCustomTheme;
    default:
      return theme.name;
  }
}