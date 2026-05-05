import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';

class FontFamilyDropdownWidget extends StatelessWidget {
  const FontFamilyDropdownWidget({super.key});

  List<DropdownMenuItem<String>> _buildFontOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final fonts = [
      ('Default', l10n.fontDefault),
      ('SCUMMCredits', l10n.fontSCUMMCredits),
      ('SCUMMSolid', l10n.fontSCUMMSolid),
      ('DayOfTheTentacle', l10n.fontDayOfTheTentacle),
      ('Efmi', l10n.fontEfmi),
      ('PUSAB', l10n.fontPUSAB),
    ];

    return fonts.map((font) {
      return DropdownMenuItem<String>(
        value: font.$1,
        child: Text(
          font.$2,
          style: TextStyle(
            fontFamily: font.$1 == 'Default' ? null : font.$1,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentFont = context.watch<PreferencesProvider>().selectedFontFamily;

    return DropdownButton<String>(
      value: _buildFontOptions(context).any((item) => item.value == currentFont)
          ? currentFont
          : 'Default',
      items: _buildFontOptions(context),
      onChanged: (String? newFont) {
        if (newFont != null) {
          context.read<PreferencesProvider>().setFontFamily(newFont);
          ToastService.success(l10n.preferencesUpdated);
        }
      },
    );
  }
}
