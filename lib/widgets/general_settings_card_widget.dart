import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/widgets/language_dropdown_widget.dart';

class GeneralSettingsCardWidget extends StatelessWidget {
  final String themeName;
  final Color themeColor;
  final VoidCallback onThemePickerTap;

  const GeneralSettingsCardWidget({
    super.key,
    required this.themeName,
    required this.themeColor,
    required this.onThemePickerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.generalSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(AppLocalizations.of(context)!.applicationTheme),
              subtitle: Text('${AppLocalizations.of(context)!.current}: $themeName'),
              trailing: CircleAvatar(
                backgroundColor: themeColor,
                radius: 12,
              ),
              onTap: onThemePickerTap,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.language),
              subtitle: Text(AppLocalizations.of(context)!.selectApplicationLanguage),
              trailing: const LanguageDropdownWidget(),
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}
